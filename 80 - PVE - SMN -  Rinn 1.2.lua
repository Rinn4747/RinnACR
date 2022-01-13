local profile = {}

profile.GUI = {
    open = false,
    visible = true,
    name = "PVE SMN",
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
		
	}

profile.ogcdtimer = 0	
 
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
 
function profile.Cast()
    local currentTarget = MGetTarget()
	local g = Player.gauge
	
	if (currentTarget) then
		profile.setVar()
		if (Player.pet == nil) and profile["carbuncle"]["isready"] then
			profile["carbuncle"]:Cast(Player)
			return true
		end	
		
		if profile["ruin4"]["isready"] then --not ogcd
			profile["ruin4"]:Cast(currentTarget.id)
			return true
		end

		if profile["summonbahamut"]["isready"] and Player.pet ~= nil then
			profile["summonbahamut"]:Cast(currentTarget.id)
			return true
		end
		
		if (Player.pet ~= nil) and (Player.pet.name == "Demi-Bahamut") then
			if profile["erkindlebahamut"]["isready"] then
				profile["erkindlebahamut"]:Cast(currentTarget.id)
				return true
			end
			if profile["astralimpulse"]["isready"] then
				profile["astralimpulse"]:Cast(currentTarget.id)
				return true
			end
			if profile["deathflare"]["isready"] then
				profile["deathflare"]:Cast(currentTarget.id)
				return true
			end			
		end
		
		if (Player.pet ~= nil) and (Player.pet.name == "Demi-Phoenix") then
			if profile["erkindlephoenix"]["isready"] then
				profile["erkindlephoenix"]:Cast(currentTarget.id)
				return true
			end		
			if profile["fountainoffire"]["isready"] then
				profile["fountainoffire"]:Cast(currentTarget.id)
				return true
			end
			if profile["rekindle"]["isready"] then
				profile["rekindle"]:Cast(currentTarget.id)
				return true
			end			
		end
		--ifrit
		if Player.gauge ~= nil and (Player.gauge[5] == 1) and (Player.gauge[2] == 0) then
			if profile["summonifrit"]["isready"] then
				profile["summonifrit"]:Cast(currentTarget.id)
				return true
			end	
		end
		if profile["rubyrite"]["isready"] then
			profile["rubyrite"]:Cast(currentTarget.id)
			return true
		end
		--titan
		if Player.gauge ~= nil and (Player.gauge[6] == 1) and (Player.gauge[2] == 0) then
			if profile["summontitan"]["isready"] then
				profile["summontitan"]:Cast(currentTarget.id)
				return true
			end	
		end
		if profile["topazrite"]["isready"] then
			profile["topazrite"]:Cast(currentTarget.id)
			return true
		end
		--garuda
		if Player.gauge ~= nil and (Player.gauge[7] == 1) and (Player.gauge[2] == 0) then
			if profile["summongaruda"]["isready"] then
				profile["summongaruda"]:Cast(currentTarget.id)
				return true
			end	
		end
		if profile["emeraldrite"]["isready"] then
			profile["emeraldrite"]:Cast(currentTarget.id)
			return true
		end		
		
		
		if (Player.gauge ~= nil) and (Player.gauge[2] == 0) and profile["ruin3"]["isready"] then
			profile["ruin3"]:Cast(currentTarget.id)
			return true
		end
	
		
		if (Player.gauge ~= nil) and (Player.gauge[10] > 0) and (TimeSince(profile.ogcdtimer) > 3000) then
			if profile["fester"]["isready"] then
				profile["fester"]:Cast(currentTarget.id)
				profile.ogcdtimer = Now()	
				return true
			end			
		elseif (Player.gauge ~= nil) and (Player.gauge[10] == 0) and (TimeSince(profile.ogcdtimer) > 3000) then
			if profile["energydrain"]["isready"] then
				profile["energydrain"]:Cast(currentTarget.id)
				profile.ogcdtimer = Now()
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