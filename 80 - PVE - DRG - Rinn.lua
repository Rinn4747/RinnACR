local profile = {}

profile.GUI = {
    open = false,
    visible = true,
    name = "PVE DRG 80 1.1",
}
 
profile.classes = {
    [FFXIV.JOBS.DRAGOON] = true,
	[FFXIV.JOBS.LANCER] = true,
} 

profile.dragoonBuff = 
	{
		disembowel = 2720,
		fangandclaw = 802,
		wheelingthrust = 803,
		truenorth = 1250,
	}
profile.dragoonSkill = 
	{
		truethrust = {75,true},
		vorpalthrust = {78,true},
		fullthrust = {84,true},
		disembowel = {87,true},
		chaosthrust = {88,true},
		wheelingthrust = {3556,true},
		fangandclaw = {3554,true},
		raidenthrust = {16479,true},
		doomspike = {86,true},
		sonicthrust = {7397,true},
		coerthantorment = {16477,true},
		nastrond = {7400,true},
		geirskogul = {3555,true},
		dragonsight = {7398,false},
		battlelitany = {3557,false},
		jump = {92,true},
		highjump = {16478,true},
		miragedive = {7399,true},
		spineshatterdive = {95,true},
		dragonfiredive = {96,true},
		stardiver = {16480,true},
		truenorth = {7546,false},
		
	}
	
function profile:skillID(string)
	if profile.dragoonSkill[string] ~= nil then
		return profile.dragoonSkill[string][1]
	end
end

function profile:lastUsedCombo(string)
	if profile:skillID(string) ~= nil then
		if Player.lastcomboid == profile:skillID(string) then
			return true
		end
	end
	return false
end


function profile:hasBuffSelf(string)
	if profile.dragoonBuff[string] ~= nil then
		if HasBuff(Player.id,profile.dragoonBuff[string]) then
			return true
		end
	end
	return false
end

profile.ogcdtimer = 0
profile.safejump = 0

function profile.counttarget()
	local counter = 0
	local targets = MEntityList("alive,attackable,targetable,maxdistance=5")
	if targets ~= nil then
		for i,e in pairs(targets) do 
			counter = counter + 1 
		end
	end
	return counter
end

function profile.hasNotMovedFor(number)
	if TimeSince(profile.safejump) > number then
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
 
function profile.setVar()
	for i,e in pairs(profile.dragoonSkill) do
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
				profile[tostring(e)]:Cast(Player)
				return true
			end
		end
	end
	return false
end
 
function profile.Cast()
    local currentTarget = MGetTarget()
	if (currentTarget) then
		profile.setVar()
		if Player:IsMoving() then
			profile.safejump = Now()
		end
		--gauge[2] = number of miragedive to life of the dragoon
		
		--proc 
		if profile.checkEach({"miragedive"}) then
			return true
		end
		
		--ogcd jump
		if currentTarget.distance < 5 and profile.waitedOGCD(3000) and profile.hasNotMovedFor(2000) and profile.checkEach({"jump","highjump","spineshatterdive","dragonfiredive"}) then
			profile.ogcdtimer = Now()
			return true
		end
		--ogcd miragedive proc
		if profile.checkEach({"geirskogul","nastrond","stardiver"}) then
			return true
		end
		--truenorth
		if not profile:hasBuffSelf("truenorth") and (profile:hasBuffSelf("fangandclaw") or profile:hasBuffSelf("wheelingthrust"))  and profile.checkEach({"truenorth"},"player") then
			return true
		end

		--extended 123 / 145 combo
		if profile.checkEach({"fangandclaw"}) then
			return true
		end
		if profile.checkEach({"wheelingthrust"}) then
			return true
		end

		--123 145 combo / 123 aoe combo
		if profile.counttarget() > 2 then
			if profile:lastUsedCombo("sonicthrust") and profile.checkEach({"coerthantorment"}) then
				return true
			end		
			if profile:lastUsedCombo("doomspike") and profile.checkEach({"sonicthrust"}) then
				return true
			end		
			if profile.checkEach({"doomspike"}) then
				return true
			end			
		else
			if profile:lastUsedCombo("disembowel") and profile.checkEach({"chaosthrust"}) then
				return true
			end		
			if not profile:hasBuffSelf("disembowel") and (profile:lastUsedCombo("truethrust") or profile:lastUsedCombo("raidenthrust")) and profile.checkEach({"disembowel"}) then
				return true
			end		
			if profile:lastUsedCombo("vorpalthrust") and profile.checkEach({"fullthrust"}) then
				return true
			end
			if (profile:lastUsedCombo("truethrust") or profile:lastUsedCombo("raidenthrust"))  and profile.checkEach({"vorpalthrust"}) then
				return true
			end
			if profile.checkEach({"truethrust"}) then
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
            ACR_PVEDRG_Burn = GUI:Checkbox("Test",ACR_PVEDRG_Burn)
			--GUI:BulletText(tostring())
			GUI:BulletText("Test ACR DRG !")
        end
        GUI:End()
    end	
end
 
function profile.OnOpen()
    profile.GUI.open = true
end
 
function profile.OnLoad()
    ACR_PVEDRG_Burn = ACR.GetSetting("ACR_PVEDRG_Burn",false)
end
 
function profile.OnClick(mouse,shiftState,controlState,altState,entity)
 
end
 
function profile.OnUpdate(event, tickcount)

end
 
return profile