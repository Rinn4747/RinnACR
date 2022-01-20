local profile = {}
RinnBLM = {}
RinnBLM.leylines = 
	{
		castpos = {x = 0,y = 0,z = 0,h = 0},
		casttime = 0,
	}

profile.GUI = {
    open = false,
    visible = true,
    name = "PVE BLM 1.0",
}
 
profile.classes = {
    [FFXIV.JOBS.BLACKMAGE] = true,
	[FFXIV.JOBS.THAUMATURGE] = true,
} 

buffblackmage = 
	{
		firestarter = 165,
		thunder3 = 163,
		thunder4 = 1210,
		thundercloud = 164,
		flare= 2960,
		triplecast = 1211,
	}

varblackmage = 
	{ 
		fire = {141,true},
		fire2 = {147,true},
		fire3 = {152,true},
		fire4 = {3577,true},
		blizzard = {142,true},
		blizzard2 = {25793,true},
		blizzard3 = {154,true},
		blizzard4 = {3576,true},
		umbralsoul = {16506,true},
		freeze = {159,true},
		transpose = {149,false},
		thunder3 = {153,true},
		thunder4 = {7420,true},
		leyline = {3573,false},
		scathe = {156,true},
		triplecast = {7421,false},
		manafont = {158,false},
		sharpcast = {3574,false},
		xenoglossy = {16507,true},
		foul = {7422,true},
		manaward = {157,false},
		despair = {16505,true},
		flare = {162,true},
		
		--gauge[1]
		--gauge[2] 3 (fire) to -3 (ice)
		--gauge[3]
		--gauge[4] remaining time on cycle
		--gauge[5] polyglot
	}

profile.ogcdtimer = 0
profile.safejump = 0
profile.firecycle = false

function profile:trueNorth()
	if (not Player:IsMoving() or HasBuff(Player.id,buffblackmage["triplecast"])) then
		return true
	end
	return false
end

function profile.waitedOGCD(number)
	if TimeSince(profile.ogcdtimer) > number then
		return true
	end
	return false
end

function profile.counttarget(targetid)
	local targets = MEntityList("alive,attackable,targetable,maxdistance=5,distanceto="..tostring(targetid))
	return (table.size(targets))
end	
 
function profile.setVar()
	for i,e in pairs(varblackmage) do
		profile[i] = ActionList:Get(1,e[1])
		if profile[i] then
			if e[2] then
				profile[i]["isready"] = profile[i]:IsReady(MGetTarget().id)
			else
				profile[i]["isready"] = profile[i]:IsReady(Player)
			end
		end
	end
end

function profile.checkEach(tbl,string)
	local bool = (string == nil)
	for _,e in pairs(tbl) do
		if bool then
			if profile[tostring(e)]["isready"] then
				profile[tostring(e)]:Cast(MGetTarget().id)
				return true
			end
		elseif not bool then
			if profile[tostring(e)]["isready"] then
				profile[tostring(e)]:Cast(Player.id)
				return true
			end
		end
	end
	return false
end
 
function profile.Cast()
    local currentTarget = MGetTarget()
	if (currentTarget) then
		if Player:IsMoving() then
			profile.safejump = Now()
		end	
		profile.setVar()
			
		--leyline
		if TimeSince(profile.safejump) > 3000 and profile.checkEach({"leyline"},"player") then
			RinnBLM.leylines.castpos = Player.pos
			RinnBLM.leylines.casttime = Now()
			return true
		end
		--triplecast
		if currentTarget.distance2d < 7 and Player:IsMoving() and profile.checkEach({"triplecast"},"player") then
			return true
		end
		
		--rotation single & aoe
		if profile.counttarget(currentTarget.id) > 2 then
			if profile:trueNorth() and Player.gauge ~= nil and Player.gauge[2] == 0 and Player.gauge[1] == 0 and profile.checkEach({"blizzard2"}) then
				return true
			end
			--proc thunder 4
			if HasBuff(Player.id,buffblackmage["thundercloud"]) and Player.mp.current < 1000 and profile.checkEach({"thunder4"}) then
				return true
			end
			--manafont
			if Player.mp.current < 1000 and profile.checkEach({"manafont"},"player") then
				return true
			end			
			--switch to frost cycle
			if profile:trueNorth() and Player.mp.current < 1000 and Player.gauge ~= nil and Player.gauge[2] > -3 and profile.checkEach({"blizzard2"}) then
				return true
			end
			--sharpcast
			if not HasBuff(currentTarget.id,buffblackmage["thunder4"]) and Player.gauge ~= nil and Player.gauge[2] == -3 and profile.checkEach({"sharpcast"},"player") then		
				return true
			end
			--thunder 4
			if profile:trueNorth() and not HasBuff(currentTarget.id,buffblackmage["thunder4"]) and profile.waitedOGCD(4000) and Player.gauge ~= nil and Player.gauge[2] == -3 and profile.checkEach({"thunder4"}) then
				profile.ogcdtimer = Now()
				return true
			end
			--foul
			if Player.gauge ~= nil and Player.gauge[2] == -3 and Player.gauge[5] > 0 and profile.checkEach({"foul"}) then
				return true
			end
			--umbral heart through freeze
			if profile:trueNorth() and Player.gauge ~= nil and Player.gauge[2] == -3 and Player.gauge[1] ~= 3 and profile.checkEach({"freeze"}) then			
				profile.firecycle = true
				return true
			end
			
			--switch to fire cycle
			if profile:trueNorth() and Player.gauge ~= nil and Player.gauge[2] < 3 and Player.gauge[1] == 3 and profile.checkEach({"fire2"}) then
				return true
			end
			if profile:trueNorth() and Player.gauge ~= nil and Player.gauge[2] == 3 and Player.gauge[1] == 3 and not HasBuff(Player.id,buffblackmage["flare"]) and profile.checkEach({"fire2"}) then
				return true
			end			
			if profile:trueNorth() and Player.mp.current < 3000  and profile.checkEach({"flare"}) then
				return true
			end
			if profile:trueNorth() and Player.mp.current > 0 and Player.gauge ~= nil and Player.gauge[4] > 7000 and profile.checkEach({"flare"}) then
				return true
			end			
		else
			if profile:trueNorth() and Player.gauge ~= nil and Player.gauge[2] == 0 and Player.gauge[1] == 0 and profile.checkEach({"blizzard3"}) then
				return true
			end
			--proc fire 3
			if HasBuff(Player.id,buffblackmage["firestarter"]) and Player.mp.current < 1000 and profile.checkEach({"fire3"}) then
				return true
			end
			--proc thunder 3
			if HasBuff(Player.id,buffblackmage["thundercloud"]) and Player.mp.current < 1000 and profile.checkEach({"thunder3"}) then
				return true
			end
			--manafont
			if Player.mp.current < 1000 and profile.checkEach({"manafont"},"player") then
				return true
			end
			--switch to frost cycle
			if profile:trueNorth() and Player.mp.current < 1000 and Player.gauge ~= nil and Player.gauge[2] > -3 and profile.checkEach({"blizzard3"}) then
				return true
			end
			--sharpcast
			if not HasBuff(currentTarget.id,buffblackmage["thunder3"]) and Player.gauge ~= nil and Player.gauge[2] == -3 and profile.checkEach({"sharpcast"},"player") then		
				return true
			end			
			--thunder 3
			if profile:trueNorth() and not HasBuff(currentTarget.id,buffblackmage["thunder3"]) and profile.waitedOGCD(4000) and Player.gauge ~= nil and Player.gauge[2] == -3 and profile.checkEach({"thunder3"}) then
				profile.ogcdtimer = Now()
				return true
			end
			--xenoglossy
			if Player.gauge ~= nil and Player.gauge[2] == -3 and Player.gauge[5] > 0 and profile.checkEach({"xenoglossy"}) then
				return true
			end
			--umbral heart through blizzard 4
			if profile:trueNorth() and Player.gauge ~= nil and Player.gauge[2] == -3 and Player.gauge[1] ~= 3 and profile.checkEach({"blizzard4"}) then			
				return true
			end
			
			--switch to fire cycle
			if profile:trueNorth() and Player.gauge ~= nil and Player.gauge[2] < 3 and Player.gauge[1] == 3 and profile.checkEach({"fire3"}) then
				return true
			end
			if Player.mp.current < 2000  and profile.checkEach({"despair"}) then
				profile.firecycle = false
				return true
			end
			if profile:trueNorth() and Player.mp.current > 0 and Player.gauge ~= nil and Player.gauge[4] > 7000 and profile.checkEach({"fire4"}) then
				return true
			end
			if profile:trueNorth() and Player.mp.current > 0 and Player.gauge ~= nil and Player.gauge[4] <= 7000 and profile.checkEach({"fire"}) then
				return true
			end
		end
	return false
	end
end

function profile.Draw()
    if (profile.GUI.open) then	
	profile.GUI.visible, profile.GUI.open = GUI:Begin(profile.GUI.name, profile.GUI.open)
	if ( profile.GUI.visible ) then 
            ACR_PVESMN_Burn = GUI:Checkbox("Test",ACR_PVESMN_Burn)
			--GUI:BulletText(tostring())
			GUI:BulletText("Test ACR SMN !")
        end
        GUI:End()
    end	
end
 
function profile.OnOpen()
    profile.GUI.open = true
end
 
function profile.OnLoad()
    ACR_PVESMN_Burn = ACR.GetSetting("ACR_PVESMN_Burn",false)
end
 
function profile.OnClick(mouse,shiftState,controlState,altState,entity)
 
end
 
function profile.OnUpdate(event, tickcount)

end
 
return profile