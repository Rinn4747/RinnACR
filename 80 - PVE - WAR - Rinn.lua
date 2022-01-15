local profile = {}

profile.GUI = {
    open = false,
    visible = true,
    name = "PVE WAR 80 1.1",
}
 
profile.classes = {
    [FFXIV.JOBS.WARRIOR] = true,
	[FFXIV.JOBS.MARAUDER] = true,
} 

--2587
varwarrior = 
	{
		heavyswing = {31,true},
		maim = {37,true},
		stormpath = {42,true},
		stormeye = {45,true},
		innerbeast = {49,true},
		overpower = {41,true},
		mythriltempest = {16462,false},
		steelcyclone = {51,false},
		tomahawk = {46,true},
		fellcleave = {3549,true},
		decimate = {3550,false},
		innerchaos= {16465,true},
		innercyclone= {16463,false},
		infuriate= {52,false},
		innerrelease = {7389,false},
		upheaval = {7387,true},
		orogeny = {25751,false},
		--bloodwhetting = {25752,true},
		primalrend = {25753,true},
		berserk = {38,false},
		defiance = {48,false},
		onslaught={7386,true},
		

	}

stunlist = {}
stuntimer = 0
profile.ogcdtimer = 0

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
 
function profile.setVar()
	for i,e in pairs(varwarrior) do
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

function profile.checkEach(tbl,bool)
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
		--tomahawk if distance2d > 10
		--math.distance2d(Player.pos.x,Player.pos.y,currentTarget.pos.x,currentTarget.pos.y) > 6
		--and (not currentTarget.aggro)
		
		--stance
		if (not HasBuff(Player.id,91)) and profile.checkEach({"defiance"},true) then
			return true
		end				
		--range 18y
		if (currentTarget.distance > 10) and profile.checkEach({"tomahawk"},true) then
			return true
		end
		--safety measure
		-- if (currentTarget.distance < 5 ) and (not Player:IsMoving()) and (TimeSince(profile.ogcdtimer) > 3000) and profile.checkEach({"onslaught"},true) then
			-- profile.ogcdtimer = Now()
			-- return true
		-- end			
		--buff  1177
		if (currentTarget.distance < 5 ) and (HasBuff(Player.id,2677) or (Player.level < 50)) and profile.checkEach({"berserk","innerrelease"},true) then
			return true
		end		
		--ogcd buffid = 1897
		if (TimeSince(profile.ogcdtimer) > 3000) and  (currentTarget.distance < 5 ) and (not HasBuff(Player.id,1177)) and (not HasBuff(Player.id,1897)) and HasBuff(Player.id,2677) and profile.checkEach({"infuriate"},true) then
			profile.ogcdtimer = Now()
			return true
		end
		--ogcd attacks
		if profile.counttarget() > 1 then
			if (TimeSince(profile.ogcdtimer) > 3000) and   profile.checkEach({"orogeny"},false) then
				profile.ogcdtimer = Now()
				return true
			end			
		else
			if (TimeSince(profile.ogcdtimer) > 3000) and  profile.checkEach({"upheaval"},true) then
				profile.ogcdtimer = Now()
				return true
			end
		end
		if profile.checkEach({"primalrend"},true) then
			return true
		end	
		--gauge -50
		if profile.counttarget() > 1 then
			if Player.gauge ~= nil and ((Player.gauge[1] >= 50) or (HasBuff(Player.id,1177))) and profile.checkEach({"steelcyclone","decimate","innercyclone"},true)  then
				return true
			end		
		else
			if Player.gauge ~= nil and ((Player.gauge[1] >= 50) or (HasBuff(Player.id,1177)))  and profile.checkEach({"innerbeast","fellcleave","innerchaos"},true)  then
				return true
			end
		end
		
		--123 124 singe / aoe 12
		if profile.counttarget() > 1 then
			if Player.lastcomboid == 41 and profile.checkEach({"mythriltempest"},false) then
				return true
			end		
			if profile.checkEach({"overpower"},true) then
				return true
			end		
			
		else
			if not HasBuff(Player.id,2677) and Player.lastcomboid == 37 and profile.checkEach({"stormeye"},true) then
				return true
			end
			
			if Player.lastcomboid == 37 and profile.checkEach({"stormpath"},true) then
				return true
			end		
			if Player.lastcomboid == 31 and profile.checkEach({"maim"},true) then
				return true
			end
			
			if profile.checkEach({"heavyswing"},true) then
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
            ACR_PVEWAR_Burn = GUI:Checkbox("Test",ACR_PVEWAR_Burn)
			--GUI:BulletText(tostring())
			GUI:BulletText("Test ACR WAR !")
        end
        GUI:End()
    end	
end
 
function profile.OnOpen()
    profile.GUI.open = true
end
 
function profile.OnLoad()
    ACR_PVEWAR_Burn = ACR.GetSetting("ACR_PVEWAR_Burn",false)
end
 
function profile.OnClick(mouse,shiftState,controlState,altState,entity)
 
end
 
function profile.OnUpdate(event, tickcount)

end
 
return profile