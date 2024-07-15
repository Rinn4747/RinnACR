profilenin = {}

profilenin.GUI = {
    open = false,
    visible = true,
    name = "PVE NIN 80 1.0",
}
 
profilenin.classes = {
    [FFXIV.JOBS.NINJA] = true,
	--[FFXIV.JOBS.ROGUE] = true,
} 

profilenin.ninjaBuff = 
	{
		kassatsu = 497,
		tenshijin = 1186,
		phantomkamaitachiready = 2723,
		shadowwalker = 3848,
		raijuready= 2690,
	}

profilenin.ninjaSkill = 
	{
		
		spinningedge = {2240,true},
		gustslash = {2242,true},
		aeolianedge = {2255,true},
		armorcrush = {3563,true},
		deathblossom = {2254,false},
		hakkemujinsatsu = {16488,false},
		assassinate = {2246,true},
		chi = {2261,false},
		ten = {2259,false},
		jin = {2263,false},
		meisui = {16489,false},
		ten2 = {18805,false},
		chi2 = {18806,false},
		jin2 = {18807,false},
		suiton = {2271,true},
		doton = {2270,false},
		huton = {2269,false},
		katon = {2266,true},
		fuma = {2265,true},
		bhavacakra = {7402,true},
		hellfrogmedium = {7401,true},
		mug = {2248,true},
		dreamwithinadream = {3566,true},
		bunshin = {16493,false},
		huraijin = {25876,true},
		trickattack = {2258,true},
		raiton = {2267,true},
		kassatsu = {2264,false},
		katon2 = {16491,true},
		hyoton2 = {16492,true},
		tenshijin = {7403,false},
		tsj1 = {18873,true}, --fuma 
		tsj2 = {18874,true}, --fuma 
		tsj3 = {18875,true}, --fuma 
		tsj4 = {18876,true}, --katon
		tsj5 = {18877,true}, --raiton
		tsj6 = {18878,true}, --hyoton
		tsj7 = {18879,true}, --huton
		tsj8 = {18880,false}, --doton
		tsj9 = {18881,true}, --suiton
		phantomkamaitachi = {25774,true},
		forkedraiju = {25777,true},
	}	

function profilenin:skillID(string)
	if profilenin.ninjaSkill[string] ~= nil then
		return profilenin.ninjaSkill[string][1]
	end
end

function profilenin:lastUsedCombo(string)
	if profilenin:skillID(string) ~= nil then
		if Player.lastcomboid == profilenin:skillID(string) then
			return true
		end
	end
	return false
end


function profilenin:hasBuffSelf(string)
	if profilenin.ninjaBuff[string] ~= nil then
		if HasBuff(Player.id,profilenin.ninjaBuff[string]) then
			return true
		end
	end
	return false
end

function profilenin:hasBuffOthers(string)
	if profilenin.ninjaBuff[string] ~= nil then
		if HasBuff(MGetTarget().id,profilenin.ninjaBuff[string]) then
			return true
		end
	end
	return false
end

function profilenin:hasBuffOthersDuration(string,duration)
	if profilenin.ninjaBuff[string] ~= nil then
		if HasBuff(MGetTarget().id,profilenin.ninjaBuff[string],0,duration) then
			return true
		end
	end
	return false
end

profilenin.ogcdtimer = 0
profilenin.safejump = 0


function profilenin.counttarget()
	local counter = 0
	local targets = MEntityList("alive,attackable,targetable,maxdistance=5")
	if targets ~= nil then
		for i,e in pairs(targets) do 
			counter = counter + 1 
		end
	end
	return counter
end
 
function profilenin.hasNotMovedFor(number)
	if TimeSince(profilenin.safejump) > number then
		return true
	end
	return false
end

function profilenin.waitedOGCD(number)
	if TimeSince(profilenin.ogcdtimer) > number then
		return true
	end
	return false
end
 
function profilenin.setVar()
	for i,e in pairs(profilenin.ninjaSkill) do
		profilenin[i] = ActionList:Get(1,e[1])
		if profilenin[i] then
			if e[2] then
				profilenin[i]["isready"] = profilenin[i]:IsReady(MGetTarget().id)
			else
				profilenin[i]["isready"] = profilenin[i]:IsReady(Player)
			end
		end
	end
end 

function profilenin.checkEach(tbl,string)
	local bool = (string == nil)
	for _,e in pairs(tbl) do
		if bool then
			if profilenin[tostring(e)]["isready"] then
				profilenin[tostring(e)]:Cast(MGetTarget().id)
				return true
			end
		elseif not bool then
			if profilenin[tostring(e)]["isready"] then
				profilenin[tostring(e)]:Cast(Player)
				return true
			end
		end
	end
	return false
end

function profilenin.onlyCheckEach(tbl,string)
	local bool = (string == nil)
	for _,e in pairs(tbl) do
		if bool then
			if profilenin[tostring(e)]["isready"] then
				return true
			end
		elseif not bool then
			if profilenin[tostring(e)]["isready"] then
				return true
			end
		end
	end
	return false
end
 
profilenin.targetedFromAfar = false
profilenin.castingNinjutsu = false
profilenin.mudra = {}
profilenin.mudraresult = ""
profilenin.mudracounter = 0
profilenin.mudranumber = 0
profilenin.mudratarget = ""
profilenin.ntsj1 = false
profilenin.ntsj2 = false
profilenin.ntsj3 = false
profilenin.ntsj4 = false
profilenin.ntsj5 = false
profilenin.ntsj6 = false
profilenin.ntsj7 = false
profilenin.ntsj8 = false
profilenin.ntsj9 = false
profilenin.ninjutsumaxtimer = 0

function profilenin.Cast()
    local currentTarget = MGetTarget()
	if currentTarget and currentTarget.attackable then
		profilenin.setVar()
		local tenAvailable = profilenin["ten"]:IsReady()
		local chiAvailable = profilenin["chi"]:IsReady()
		local jinAvailable = profilenin["jin"]:IsReady()
		--d("ten is available"..tostring(tenAvailable))
		if Player:IsMoving() then
			profilenin.safejump = Now()
		end
		if TimeSince(profilenin.ninjutsumaxtimer) > 5000 and profilenin.castingNinjutsu  then
			profilenin.castingNinjutsu = false
		end
		--d("casting ninjutsu : "..tostring(profilenin.castingNinjutsu))
		--d("ninjutsu result : "..tostring(profilenin.mudraresult))
		--tenshijin
		if not profilenin:hasBuffSelf("tenshijin") and not profilenin.castingNinjutsu and profilenin.checkEach({"tenshijin"},false) then
			profilenin.ntsj1 = true
			profilenin.ntsj2 = true
			profilenin.ntsj3 = true
			profilenin.ntsj4 = true
			profilenin.ntsj5 = true
			profilenin.ntsj6 = true
			profilenin.ntsj7 = true
			profilenin.ntsj8 = true
			profilenin.ntsj9 = true		
			return true
		end
		-- aoe tsj3 into tsj4 (katon) into tsj8 (doton)
		-- single tsj 1 into tsj5 (raiton) into tsj9 (suiton)
		if profilenin.counttarget() > 2 then
			if profilenin:hasBuffSelf("tenshijin") and profilenin.waitedOGCD(1500) and profilenin.ntsj3 and profilenin.checkEach({"tsj3"}) then
				profilenin.ntsj3 = false
				profilenin.ogcdtimer = Now()
				return true
			end
			if profilenin:hasBuffSelf("tenshijin") and profilenin.waitedOGCD(1500) and profilenin.ntsj4 and profilenin.checkEach({"tsj4"}) then
				profilenin.ntsj4 = false
				profilenin.ogcdtimer = Now()
				return true
			end		
			if profilenin:hasBuffSelf("tenshijin") and profilenin.waitedOGCD(1500) and profilenin.ntsj8 and profilenin.checkEach({"tsj8"},"player")  then
				profilenin.ntsj8 = false
				profilenin.ogcdtimer = Now()
				return true
			end		
		else
			if profilenin:hasBuffSelf("tenshijin") and profilenin.waitedOGCD(1500) and profilenin.ntsj1 and profilenin.checkEach({"tsj1"}) then
				profilenin.ntsj1 = false
				profilenin.ogcdtimer = Now()
				return true
			end
			if profilenin:hasBuffSelf("tenshijin") and profilenin.waitedOGCD(1500) and profilenin.ntsj5 and profilenin.checkEach({"tsj5"}) then
				profilenin.ntsj5 = false
				profilenin.ogcdtimer = Now()
				return true
			end		
			if profilenin:hasBuffSelf("tenshijin") and profilenin.waitedOGCD(1500) and profilenin.ntsj9 and profilenin.checkEach({"tsj9"})  then
				profilenin.ntsj9 = false
				profilenin.ogcdtimer = Now()
				return true
			end
		end
		if profilenin:hasBuffSelf("tenshijin") then return false end
		
		--casting ninjutsu any
		if profilenin.castingNinjutsu then
			--d(profilenin.mudracounter < profilenin.mudranumber)
			if profilenin.waitedOGCD(500) and profilenin.mudracounter < profilenin.mudranumber then
				profilenin.ogcdtimer = Now()
				if  profilenin.checkEach({profilenin.mudra[profilenin.mudracounter+1]}) then
					profilenin.mudracounter = profilenin.mudracounter + 1
					--d(profilenin.mudracounter)
					return true
				end
			elseif profilenin.waitedOGCD(500) and profilenin.mudracounter >= profilenin.mudranumber then
				profilenin.ogcdtimer = Now()
				if profilenin.mudratarget == "player" then
					if profilenin.checkEach({profilenin.mudraresult},"player") then
						profilenin.castingNinjutsu = false
						return true
					end				
				else
					if profilenin.checkEach({profilenin.mudraresult}) then
						profilenin.castingNinjutsu = false
						return true
					end				
				end
			end
		end
		if profilenin.castingNinjutsu then return false end
		--kassatsu
		if currentTarget.distance < 5 and not Player:IsMoving() and (not profilenin["ten"].isoncd) and profilenin.checkEach({"kassatsu"},"player") then
			return true
		end
		--hyoton (kassatsu)
		-- if profilenin:hasBuffSelf("kassatsu") and profilenin.checkEach({"hyoton2"}) then
			-- return true
		-- end
		--calling hyoshoranryu
		--if profilenin:hasBuffSelf("kassatsu") and (not profilenin["ten"].isoncd) then
		
		--TEN lvl 30 
		--CHI lvl 35 
		--JIN lvl 45
		if Player.level >= 76 then
			if profilenin.counttarget() > 2 then
				if profilenin:hasBuffSelf("kassatsu") and chiAvailable and tenAvailable then
					--d(profilenin["meisui"].isoncd)
					profilenin.mudracounter = 0
					profilenin.mudranumber = 2
					--profilenin.mudra = {}
					profilenin.mudra = {"chi","ten2"}
					profilenin.mudraresult = "katon2"
					profilenin.ninjutsumaxtimer = Now()
					profilenin.castingNinjutsu = true
					profilenin.mudratarget = "target"
					return false
				end		
			else
				if profilenin:hasBuffSelf("kassatsu") and tenAvailable and jinAvailable then
					--d(profilenin["meisui"].isoncd)
					profilenin.mudracounter = 0
					profilenin.mudranumber = 2
					--profilenin.mudra = {}
					profilenin.mudra = {"ten","jin2"}
					profilenin.mudraresult = "hyoton2"
					profilenin.ninjutsumaxtimer = Now()
					profilenin.castingNinjutsu = true
					profilenin.mudratarget = "target"
					return false
				end	
			end
		else
			if profilenin.counttarget() > 2 then
				if profilenin:hasBuffSelf("kassatsu") and chiAvailable and tenAvailable then
					--d(profilenin["meisui"].isoncd)
					profilenin.mudracounter = 0
					profilenin.mudranumber = 2
					--profilenin.mudra = {}
					profilenin.mudra = {"chi","ten2"}
					profilenin.mudraresult = "katon"
					profilenin.ninjutsumaxtimer = Now()
					profilenin.castingNinjutsu = true
					profilenin.mudratarget = "target"
					return false
				end		
			else
				if profilenin:hasBuffSelf("kassatsu") and tenAvailable and chiAvailable then
					--d(profilenin["meisui"].isoncd)
					profilenin.mudracounter = 0
					profilenin.mudranumber = 2
					--profilenin.mudra = {}
					profilenin.mudra = {"ten","chi2"}
					profilenin.mudraresult = "raiton"
					profilenin.ninjutsumaxtimer = Now()
					profilenin.castingNinjutsu = true
					profilenin.mudratarget = "target"
					return false
				end	
			end		
		end
		--raijuready
		if HasBuff(Player.id,profilenin.ninjaBuff["raijuready"]) and profilenin.checkEach({"forkedraiju"}) then
			return true 
		end
		
		--meisui
		if HasBuff(Player.id,profilenin.ninjaBuff["shadowwalker"]) and Player.gauge ~= nil and Player.gauge[2] >= 50 and profilenin.checkEach({"meisui"}) then
			return true
		end
		--calling suiton (meisui)
		if 
			currentTarget.distance < 5 and Player.level >= 72 and (not profilenin["meisui"].isoncd) and (not profilenin.castingNinjutsu) and 
			Player.gauge ~= nil and Player.gauge[2] >= 50 and (not profilenin["ten"].isoncd) and
			chiAvailable and tenAvailable and jinAvailable
		then
			--d(profilenin["meisui"].isoncd)
			profilenin.mudracounter = 0
			profilenin.mudranumber = 3
			profilenin.mudra = {"ten","chi2","jin2"}
			profilenin.mudraresult = "suiton"
			profilenin.ninjutsumaxtimer = Now()
			profilenin.castingNinjutsu = true
			profilenin.mudratarget = "target"
			profilenin.ogcdtimer = Now()
			return false
			--d("preparing to use meisui")
		end
		--trickattack
		if profilenin.checkEach({"trickattack"}) then
			return true
		end
		--assassinate
		if profilenin.checkEach({"assassinate"}) then
			return true
		end		
		--calling suiton (trickattack)
		if 
			currentTarget.distance < 5 and (not profilenin["trickattack"].isoncd) and (not profilenin.castingNinjutsu) and (not profilenin["ten"].isoncd) and
			chiAvailable and tenAvailable and jinAvailable
		then
			profilenin.mudracounter = 0
			profilenin.mudranumber = 3
			profilenin.mudra = {"ten","chi2","jin2"}
			profilenin.mudraresult = "suiton"
			profilenin.ninjutsumaxtimer = Now()
			profilenin.mudratarget = "target"
			profilenin.castingNinjutsu = true
			profilenin.ogcdtimer = Now()
			return false
		end
		--raiton
		-- if profilenin.checkEach({"raiton"}) then
			-- return true
		-- end
		--huraijin
		--[[
		if Player.level >= 60 then
			if Player.gauge ~= nil and Player.gauge[2] == 0 and profilenin.checkEach({"huraijin"}) then
				return true
			end
		else
			-- if Player.gauge ~= nil and Player.gauge[2] == 0 and profilenin.checkEach({"huton"},"player") then
				-- return true
			-- end		
			if 
				Player.gauge ~= nil and Player.gauge[2] == 0 and (not profilenin.castingNinjutsu) and (not profilenin["ten"].isoncd) and
				chiAvailable and tenAvailable and jinAvailable
			then
				profilenin.mudracounter = 0
				profilenin.mudranumber = 3
				profilenin.mudra = {"chi","jin2","ten2"}
				profilenin.mudraresult = "huton"
				profilenin.ninjutsumaxtimer = Now()
				profilenin.mudratarget = "player"
				profilenin.castingNinjutsu = true
				profilenin.ogcdtimer = Now()
				return false				
			end
		end
		--]]
		--calling raiton
		if Player.level >= 72 then
			if profilenin.counttarget() > 2 then
				if 
					currentTarget.distance < 5 and (profilenin["trickattack"].isoncd) and (profilenin["meisui"].isoncd)  and (not profilenin.castingNinjutsu) and (not profilenin["ten"].isoncd) and
					chiAvailable and tenAvailable 
				then
					profilenin.mudracounter = 0
					profilenin.mudranumber = 2
					profilenin.mudra = {"chi","ten2"}
					profilenin.mudraresult = "katon"
					profilenin.ninjutsumaxtimer = Now()
					profilenin.mudratarget = "target"
					profilenin.castingNinjutsu = true
					profilenin.ogcdtimer = Now()
					return false			
				end		
			else
				if 
					currentTarget.distance < 5 and (profilenin["trickattack"].isoncd) and (profilenin["meisui"].isoncd)  and (not profilenin.castingNinjutsu) and (not profilenin["ten"].isoncd) and 
					chiAvailable and tenAvailable 
				then
					profilenin.mudracounter = 0
					profilenin.mudranumber = 2
					profilenin.mudra = {"ten","chi2"}
					profilenin.mudraresult = "raiton"
					profilenin.ninjutsumaxtimer = Now()
					profilenin.mudratarget = "target"
					profilenin.castingNinjutsu = true
					profilenin.ogcdtimer = Now()
					return false			
				end
			end
		else
			if profilenin.counttarget() > 2 then
				if 
					currentTarget.distance < 5 and (profilenin["trickattack"].isoncd) and (not profilenin.castingNinjutsu) and (not profilenin["ten"].isoncd) and 
					chiAvailable and tenAvailable 
				then
					profilenin.mudracounter = 0
					profilenin.mudranumber = 2
					profilenin.mudra = {"chi","ten2"}
					profilenin.mudraresult = "katon"
					profilenin.ninjutsumaxtimer = Now()
					profilenin.mudratarget = "target"
					profilenin.castingNinjutsu = true
					profilenin.ogcdtimer = Now()
					return false			
				end		
			else
				if 
					currentTarget.distance < 5 and (profilenin["trickattack"].isoncd) and (not profilenin.castingNinjutsu) and (not profilenin["ten"].isoncd) and
					chiAvailable and tenAvailable 
				then
					profilenin.mudracounter = 0
					profilenin.mudranumber = 2
					profilenin.mudra = {"ten","chi2"}
					profilenin.mudraresult = "raiton"
					profilenin.ninjutsumaxtimer = Now()
					profilenin.mudratarget = "target"
					profilenin.castingNinjutsu = true
					profilenin.ogcdtimer = Now()
					return false			
				end
			end		
		end
		if 
			currentTarget.distance < 5 and (not profilenin.castingNinjutsu) and --and (profilenin["trickattack"].isoncd) and (not profilenin["ten"].isoncd)
			tenAvailable and not chiAvailable
		then
			profilenin.mudracounter = 0
			profilenin.mudranumber = 1
			profilenin.mudra = {"ten"}
			profilenin.mudraresult = "fuma"
			profilenin.ninjutsumaxtimer = Now()
			profilenin.mudratarget = "target"
			profilenin.castingNinjutsu = true
			profilenin.ogcdtimer = Now()
			return false			
		end
		if profilenin.counttarget() > 2 and tenAvailable and chiAvailable and not jinAvailable then
			profilenin.mudracounter = 0
			profilenin.mudranumber = 2
			profilenin.mudra = {"chi","ten2"}
			profilenin.mudraresult = "katon"
			profilenin.ninjutsumaxtimer = Now()
			profilenin.mudratarget = "target"
			profilenin.castingNinjutsu = true
			profilenin.ogcdtimer = Now()
			return false				
		elseif profilenin.counttarget() < 2 and tenAvailable and chiAvailable and not jinAvailable then
			profilenin.mudracounter = 0
			profilenin.mudranumber = 2
			profilenin.mudra = {"ten","chi2"}
			profilenin.mudraresult = "raiton"
			profilenin.ninjutsumaxtimer = Now()
			profilenin.mudratarget = "target"
			profilenin.castingNinjutsu = true
			profilenin.ogcdtimer = Now()
			return false					
		end
		--ogcdtimer
		if profilenin.checkEach({"dreamwithinadream"}) then
			return true
		end			
		if Player.gauge ~= nil and Player.gauge[2] <= 60 and profilenin.checkEach({"mug"}) then
			return true
		end		
		--gauge use -50
		if HasBuff(Player.id,profilenin.ninjaBuff["phantomkamaitachiready"]) and profilenin.checkEach({"phantomkamaitachi"}) then
			return true
		end		
		if Player.gauge ~= nil and Player.gauge[2] >= 50 and profilenin.checkEach({"bunshin"},"player") then
			return true
		end
		if (profilenin.counttarget() > 2) or (Player.level < 68) then
			if Player.gauge ~= nil and Player.gauge[2] >= 50 and profilenin["meisui"].isoncd and profilenin.checkEach({"hellfrogmedium"}) then
				return true
			end		
		else
			if Player.gauge ~= nil and Player.gauge[2] >= 50 and profilenin["meisui"].isoncd and profilenin.checkEach({"bhavacakra"}) then
				return true
			end		
		end
		-- 123 124 combo single / 12 combo aoe
		if (profilenin.counttarget() > 2) and (Player.level >= 38) then
			if profilenin:lastUsedCombo("deathblossom") and profilenin.checkEach({"hakkemujinsatsu"},"player") then
				return true
			end
			if profilenin.checkEach({"deathblossom"},"player") then
				return true
			end			
		else
			if Player.gauge ~= nil and Player.gauge[1] < 4  and profilenin:lastUsedCombo("gustslash") and profilenin.checkEach({"armorcrush"}) then
				return true
			end			
			if profilenin:lastUsedCombo("gustslash") and profilenin.checkEach({"aeolianedge"}) then
				return true
			end			
			if profilenin:lastUsedCombo("spinningedge") and profilenin.checkEach({"gustslash"}) then
				return true
			end		
			if profilenin.checkEach({"spinningedge"}) then
				return true
			end
		end
	return false
	end
end



function profilenin.Draw()
    if (profilenin.GUI.open) then	
	profilenin.GUI.visible, profilenin.GUI.open = GUI:Begin(profilenin.GUI.name, profilenin.GUI.open)
	if ( profilenin.GUI.visible ) then 
            ACR_PVENIN_Burn = GUI:Checkbox("Test",ACR_PVENIN_Burn)
			--GUI:BulletText(tostring())
			GUI:BulletText("Test ACR NIN !")
        end
        GUI:End()
    end	
end
 
function profilenin.OnOpen()
    profilenin.GUI.open = true
end
 
function profilenin.OnLoad()
    ACR_PVENIN_Burn = ACR.GetSetting("ACR_PVENIN_Burn",false)
end
 
function profilenin.OnClick(mouse,shiftState,controlState,altState,entity)
 
end
 
function profilenin.OnUpdate(event, tickcount)

end
 
return profilenin
