local profile = {}

profile.GUI = {
    open = false,
    visible = true,
    name = "PVE SMN 1.3",
}
 
profile.classes = {
    [FFXIV.JOBS.SUMMONER] = true,
} 

varsummoner = 
	{ 
		ruin3 = {3579,true},
		summonbahamut = {7427,true},
		erkindlebahamut = {7429,true},
		astralimpulse = {25820,true},
		fountainoffire = {16514,true},
		erkindlephoenix = {16516,true},
		carbuncle = {25798,false},
		--unconfirmed :
		searinglight = {25801,false},
		radiantaegis = {25799,false},
		--
		summonifrit = {25805,true},
		summontitan = {25806,true},
		summongaruda = {25807,true},
		rubyrite= {25823,true},
		topazrite= {25824,true},
		emeraldrite= {25825,true},
		--ogcd ?
		rekindle= {25830,false}, --?
		deathflare= {3582,true}, --3582
		ruin4= {7426,true},
		energydrain= {16508,true},
		fester= {181,true},
		tridisaster= {25826,true},
		astralflare= {25821,true},
		topazcastastrophe= {25833,true},
		rubycastastrophe= {25832,true},
		emeraldcastastrophe= {25834,true},
		brandofpurgatory= {16515,true},
		painflare= {3578,true},
		
	}

profile.ogcdtimer = 0

function profile.counttarget(targetid)
	local targets = MEntityList("alive,attackable,targetable,maxdistance=5,distanceto="..tostring(targetid))
	return (table.size(targets))
end	
 
function profile.setVar()
	for i,e in pairs(varsummoner) do
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
	local g = Player.gauge
	
	if (currentTarget) then
		profile.setVar()
		if (Player.gauge ~= nil) and (Player.gauge[1] == 0) and (Player.pet == nil) and profile.checkEach({"carbuncle"},false) then
			return true
		end	
		
		--ogcd
		if (Player.gauge ~= nil) and (Player.gauge[10] == 0) and (TimeSince(profile.ogcdtimer) > 3000) and profile.checkEach({"energydrain"},true) then
			profile.ogcdtimer = Now()
			return true
		end
		if profile.counttarget(currentTarget.id) > 2 then
			if (Player.gauge ~= nil) and (Player.gauge[10] > 0) and (TimeSince(profile.ogcdtimer) > 3000) and profile.checkEach({"painflare"},true) then
				profile.ogcdtimer = Now()	
				return true
			end		
		else
			if (Player.gauge ~= nil) and (Player.gauge[10] > 0) and (TimeSince(profile.ogcdtimer) > 3000) and profile.checkEach({"fester"},true) then
				profile.ogcdtimer = Now()	
				return true
			end
		end
		
		--not ogcd proc
		if profile.checkEach({"ruin4"},true) then
			return true
		end

		--big summon
		if Player.pet ~= nil and profile.checkEach({"summonbahamut"},true)  then
			return true
		end
		
		--bahamut spells
		if (Player.pet ~= nil) and (Player.pet.name == "Demi-Bahamut") then
			if profile.checkEach({"erkindlebahamut"},true) then
				return true
			end
			if profile.checkEach({"deathflare"},true) then
				return true
			end
			if profile.counttarget(currentTarget.id) > 2 then
				if profile.checkEach({"astralflare"},true) then
					return true
				end			
			else
				if profile.checkEach({"astralimpulse"},true) then
					return true
				end
			end
		end
		
		--phoenix spells
		if (Player.pet ~= nil) and (Player.pet.name == "Demi-Phoenix") then
			if profile.checkEach({"erkindlephoenix"},true) then
				return true
			end		
			if profile.checkEach({"rekindle"},true) then
				return true
			end
			if profile.counttarget(currentTarget.id) > 2 then
				if profile.checkEach({"brandofpurgatory"},true) then
					return true
				end				
			else
				if profile.checkEach({"fountainoffire"},true) then
					return true
				end
			end
		end
		--ifrit
		if Player.gauge ~= nil and (Player.gauge[5] == 1) and (Player.gauge[2] == 0) and  profile.checkEach({"summonifrit"},true) then
			return true
		end
		if profile.counttarget(currentTarget.id) > 2 then
			if (not Player:IsMoving()) and profile.checkEach({"rubycastastrophe"},true) then
				return true
			end			
		else
			if (not Player:IsMoving()) and profile.checkEach({"rubyrite"},true) then
				return true
			end
		end
		--titan
		if Player.gauge ~= nil and (Player.gauge[6] == 1) and (Player.gauge[2] == 0) and  profile.checkEach({"summontitan"},true) then
			return true
		end
		if profile.counttarget(currentTarget.id) > 2 then
			if profile.checkEach({"topazcastastrophe"},true) then
				return true
			end		
		else
			if profile.checkEach({"topazrite"},true) then
				return true
			end
		end
		--garuda
		if Player.gauge ~= nil and (Player.gauge[7] == 1) and (Player.gauge[2] == 0) and  profile.checkEach({"summongaruda"},true) then
			return true
		end
		if profile.counttarget(currentTarget.id) > 2 then
			if profile.checkEach({"emeraldcastastrophe"},true) then
				return true
			end		
		else
			if profile.checkEach({"emeraldrite"},true) then
				return true
			end
		end
		
		if profile.counttarget(currentTarget.id) > 2 then	
			if (Player.gauge ~= nil) and (Player.gauge[2] == 0) and profile.checkEach({"tridisaster"},true) then
				return true
			end
		end
		--single target
		if profile.counttarget(currentTarget.id) <= 2 then
			if (Player.gauge ~= nil) and (Player.gauge[2] == 0) and profile.checkEach({"ruin3"},true) then
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