local profile = {}

profile.GUI = {
    open = false,
    visible = true,
    name = "PVE NIN 80 1.0",
}
 
profile.classes = {
    [FFXIV.JOBS.NINJA] = true,
} 

profile.ninjaBuff = 
	{
		kassatsu = 497,
		tenshijin = 1186,
	}

profile.ninjaSkill = 
	{
		
		spinningedge = {2240,true},
		gustslash = {2242,true},
		aeolianedge = {2255,true},
		armorcrush = {3563,true},
		deathblossom = {2254,false},
		hakkemujinsatsu = {16488,false},
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
	}	

function profile:skillID(string)
	if profile.ninjaSkill[string] ~= nil then
		return profile.ninjaSkill[string][1]
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
	if profile.ninjaBuff[string] ~= nil then
		if HasBuff(Player.id,profile.ninjaBuff[string]) then
			return true
		end
	end
	return false
end

function profile:hasBuffOthers(string)
	if profile.ninjaBuff[string] ~= nil then
		if HasBuff(MGetTarget().id,profile.ninjaBuff[string]) then
			return true
		end
	end
	return false
end

function profile:hasBuffOthersDuration(string,duration)
	if profile.ninjaBuff[string] ~= nil then
		if HasBuff(MGetTarget().id,profile.ninjaBuff[string],0,duration) then
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
	for i,e in pairs(profile.ninjaSkill) do
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
 
profile.targetedFromAfar = false
profile.castingNinjutsu = false
profile.mudra = {}
profile.mudraresult = ""
profile.mudracounter = 0
profile.mudranumber = 0
profile.mudratarget = ""
profile.ntsj1 = false
profile.ntsj2 = false
profile.ntsj3 = false
profile.ntsj4 = false
profile.ntsj5 = false
profile.ntsj6 = false
profile.ntsj7 = false
profile.ntsj8 = false
profile.ntsj9 = false
profile.ninjutsumaxtimer = 0

function profile.Cast()
    local currentTarget = MGetTarget()
	if (currentTarget) then
		profile.setVar()
		if Player:IsMoving() then
			profile.safejump = Now()
		end
		if TimeSince(profile.ninjutsumaxtimer) > 5000 and profile.castingNinjutsu  then
			profile.castingNinjutsu = false
		end
		--d("casting ninjutsu : "..tostring(profile.castingNinjutsu))
		--d("ninjutsu result : "..tostring(profile.mudraresult))
		--tenshijin
		if profile.checkEach({"tenshijin"},false) and not profile:hasBuffSelf("tenshijin") and not profile.castingNinjutsu then
			profile.ntsj1 = true
			profile.ntsj2 = true
			profile.ntsj3 = true
			profile.ntsj4 = true
			profile.ntsj5 = true
			profile.ntsj6 = true
			profile.ntsj7 = true
			profile.ntsj8 = true
			profile.ntsj9 = true		
			return true
		end
		-- aoe tsj3 into tsj4 (katon) into tsj8 (doton)
		-- single tsj 1 into tsj5 (raiton) into tsj9 (suiton)
		if profile.counttarget() > 2 then
			if profile:hasBuffSelf("tenshijin") and profile.waitedOGCD(1500) and profile.ntsj3 and profile.checkEach({"tsj3"}) then
				profile.ntsj3 = false
				profile.ogcdtimer = Now()
				return true
			end
			if profile:hasBuffSelf("tenshijin") and profile.waitedOGCD(1500) and profile.ntsj4 and profile.checkEach({"tsj4"}) then
				profile.ntsj4 = false
				profile.ogcdtimer = Now()
				return true
			end		
			if profile:hasBuffSelf("tenshijin") and profile.waitedOGCD(1500) and profile.ntsj8 and profile.checkEach({"tsj8"},"player")  then
				profile.ntsj8 = false
				profile.ogcdtimer = Now()
				return true
			end		
		else
			if profile:hasBuffSelf("tenshijin") and profile.waitedOGCD(1500) and profile.ntsj1 and profile.checkEach({"tsj1"}) then
				profile.ntsj1 = false
				profile.ogcdtimer = Now()
				return true
			end
			if profile:hasBuffSelf("tenshijin") and profile.waitedOGCD(1500) and profile.ntsj5 and profile.checkEach({"tsj5"}) then
				profile.ntsj5 = false
				profile.ogcdtimer = Now()
				return true
			end		
			if profile:hasBuffSelf("tenshijin") and profile.waitedOGCD(1500) and profile.ntsj9 and profile.checkEach({"tsj9"})  then
				profile.ntsj9 = false
				profile.ogcdtimer = Now()
				return true
			end
		end
		if profile:hasBuffSelf("tenshijin") then return false end
		
		--casting ninjutsu any
		if profile.castingNinjutsu then
			--d(profile.mudracounter < profile.mudranumber)
			if profile.waitedOGCD(500) and profile.mudracounter < profile.mudranumber then
				profile.ogcdtimer = Now()
				if  profile.checkEach({profile.mudra[profile.mudracounter+1]}) then
					profile.mudracounter = profile.mudracounter + 1
					--d(profile.mudracounter)
					return true
				end
			elseif profile.waitedOGCD(500) and profile.mudracounter >= profile.mudranumber then
				profile.ogcdtimer = Now()
				if profile.mudratarget == "player" then
					if profile.checkEach({profile.mudraresult},"player") then
						profile.castingNinjutsu = false
						return true
					end				
				else
					if profile.checkEach({profile.mudraresult}) then
						profile.castingNinjutsu = false
						return true
					end				
				end
			end
		end
		if profile.castingNinjutsu then return false end
		--kassatsu
		if currentTarget.distance < 5 and not Player:IsMoving() and (not profile["ten"].isoncd) and profile.checkEach({"kassatsu"},"player") then
			return true
		end
		--hyoton (kassatsu)
		-- if profile:hasBuffSelf("kassatsu") and profile.checkEach({"hyoton2"}) then
			-- return true
		-- end
		--calling hyoshoranryu
		--if profile:hasBuffSelf("kassatsu") and (not profile["ten"].isoncd) then
		if Player.level >= 76 then
			if profile.counttarget() > 2 then
				if profile:hasBuffSelf("kassatsu") then
					--d(profile["meisui"].isoncd)
					profile.mudracounter = 0
					profile.mudranumber = 2
					--profile.mudra = {}
					profile.mudra = {"chi","ten2"}
					profile.mudraresult = "katon2"
					profile.ninjutsumaxtimer = Now()
					profile.castingNinjutsu = true
					profile.mudratarget = "target"
					return false
				end		
			else
				if profile:hasBuffSelf("kassatsu") then
					--d(profile["meisui"].isoncd)
					profile.mudracounter = 0
					profile.mudranumber = 2
					--profile.mudra = {}
					profile.mudra = {"chi","jin2"}
					profile.mudraresult = "hyoton2"
					profile.ninjutsumaxtimer = Now()
					profile.castingNinjutsu = true
					profile.mudratarget = "target"
					return false
				end	
			end
		else
			if profile.counttarget() > 2 then
				if profile:hasBuffSelf("kassatsu") then
					--d(profile["meisui"].isoncd)
					profile.mudracounter = 0
					profile.mudranumber = 2
					--profile.mudra = {}
					profile.mudra = {"chi","ten2"}
					profile.mudraresult = "katon"
					profile.ninjutsumaxtimer = Now()
					profile.castingNinjutsu = true
					profile.mudratarget = "target"
					return false
				end		
			else
				if profile:hasBuffSelf("kassatsu") then
					--d(profile["meisui"].isoncd)
					profile.mudracounter = 0
					profile.mudranumber = 2
					--profile.mudra = {}
					profile.mudra = {"ten","chi2"}
					profile.mudraresult = "raiton"
					profile.ninjutsumaxtimer = Now()
					profile.castingNinjutsu = true
					profile.mudratarget = "target"
					return false
				end	
			end		
		end
		--meisui
		if profile.checkEach({"meisui"},"player") then
			return true
		end
		--calling suiton (meisui)
		if currentTarget.distance < 5 and  Player.level >= 72 and (not profile["meisui"].isoncd) and (not profile.castingNinjutsu) and Player.gauge ~= nil and Player.gauge[1] <= 50  and (not profile["ten"].isoncd) then
			--d(profile["meisui"].isoncd)
			profile.mudracounter = 0
			profile.mudranumber = 3
			profile.mudra = {"chi","ten2","jin2"}
			profile.mudraresult = "suiton"
			profile.ninjutsumaxtimer = Now()
			profile.castingNinjutsu = true
			profile.mudratarget = "target"
			profile.ogcdtimer = Now()
			return false
			--d("preparing to use meisui")
		end
		--trickattack
		if profile.checkEach({"trickattack"}) then
			return true
		end
		--calling suiton (trickattack)
		if currentTarget.distance < 5 and (not profile["trickattack"].isoncd) and (not profile.castingNinjutsu) and (not profile["ten"].isoncd) then
			profile.mudracounter = 0
			profile.mudranumber = 3
			profile.mudra = {"chi","ten2","jin2"}
			profile.mudraresult = "suiton"
			profile.ninjutsumaxtimer = Now()
			profile.mudratarget = "target"
			profile.castingNinjutsu = true
			profile.ogcdtimer = Now()
			return false
		end
		--raiton
		-- if profile.checkEach({"raiton"}) then
			-- return true
		-- end
		--huraijin
		if Player.level >= 60 then
			if Player.gauge ~= nil and Player.gauge[2] == 0 and profile.checkEach({"huraijin"}) then
				return true
			end
		else
			-- if Player.gauge ~= nil and Player.gauge[2] == 0 and profile.checkEach({"huton"},"player") then
				-- return true
			-- end		
			if Player.gauge ~= nil and Player.gauge[2] == 0 and (not profile.castingNinjutsu) and (not profile["ten"].isoncd)  then
				profile.mudracounter = 0
				profile.mudranumber = 3
				profile.mudra = {"jin","chi2","ten2"}
				profile.mudraresult = "huton"
				profile.ninjutsumaxtimer = Now()
				profile.mudratarget = "player"
				profile.castingNinjutsu = true
				profile.ogcdtimer = Now()
				return false				
			end
		end		
		--calling raiton
		if Player.level >= 72 then
			if profile.counttarget() > 2 then
				if currentTarget.distance < 5 and (profile["trickattack"].isoncd) and (profile["meisui"].isoncd)  and (not profile.castingNinjutsu) and (not profile["ten"].isoncd)  then
					profile.mudracounter = 0
					profile.mudranumber = 2
					profile.mudra = {"chi","ten2"}
					profile.mudraresult = "katon"
					profile.ninjutsumaxtimer = Now()
					profile.mudratarget = "target"
					profile.castingNinjutsu = true
					profile.ogcdtimer = Now()
					return false			
				end		
			else
				if currentTarget.distance < 5 and (profile["trickattack"].isoncd) and (profile["meisui"].isoncd)  and (not profile.castingNinjutsu) and (not profile["ten"].isoncd)  then
					profile.mudracounter = 0
					profile.mudranumber = 2
					profile.mudra = {"ten","chi2"}
					profile.mudraresult = "raiton"
					profile.ninjutsumaxtimer = Now()
					profile.mudratarget = "target"
					profile.castingNinjutsu = true
					profile.ogcdtimer = Now()
					return false			
				end
			end
		else
			if profile.counttarget() > 2 then
				if currentTarget.distance < 5 and (profile["trickattack"].isoncd) and (not profile.castingNinjutsu) and (not profile["ten"].isoncd)  then
					profile.mudracounter = 0
					profile.mudranumber = 2
					profile.mudra = {"chi","ten2"}
					profile.mudraresult = "katon"
					profile.ninjutsumaxtimer = Now()
					profile.mudratarget = "target"
					profile.castingNinjutsu = true
					profile.ogcdtimer = Now()
					return false			
				end		
			else
				if currentTarget.distance < 5 and (profile["trickattack"].isoncd) and (not profile.castingNinjutsu) and (not profile["ten"].isoncd)  then
					profile.mudracounter = 0
					profile.mudranumber = 2
					profile.mudra = {"ten","chi2"}
					profile.mudraresult = "raiton"
					profile.ninjutsumaxtimer = Now()
					profile.mudratarget = "target"
					profile.castingNinjutsu = true
					profile.ogcdtimer = Now()
					return false			
				end
			end		
		end
		--ogcdtimer
		if profile.checkEach({"dreamwithinadream"}) then
			return true
		end			
		if Player.gauge ~= nil and Player.gauge[1] <= 60 and profile.checkEach({"mug"}) then
			return true
		end		
		--gauge use -50
		if Player.gauge ~= nil and Player.gauge[1] >= 50 and profile.checkEach({"bunshin"},"player") then
			return true
		end		
		if (profile.counttarget() > 2) or (Player.level < 68) then
			if Player.gauge ~= nil and Player.gauge[1] >= 50 and profile.checkEach({"hellfrogmedium"}) then
				return true
			end		
		else
			if Player.gauge ~= nil and Player.gauge[1] >= 50 and profile.checkEach({"bhavacakra"}) then
				return true
			end		
		end
		-- 123 124 combo single / 12 combo aoe
		if profile.counttarget() > 2 then
			if profile:lastUsedCombo("deathblossom") and profile.checkEach({"hakkemujinsatsu"},"player") then
				return true
			end
			if profile.checkEach({"deathblossom"},"player") then
				return true
			end			
		else
			if Player.gauge ~= nil and Player.gauge[2] > 0 and Player.gauge[2] < 30000 and profile:lastUsedCombo("gustslash") and profile.checkEach({"armorcrush"}) then
				return true
			end			
			if profile:lastUsedCombo("gustslash") and profile.checkEach({"aeolianedge"}) then
				return true
			end			
			if profile:lastUsedCombo("spinningedge") and profile.checkEach({"gustslash"}) then
				return true
			end		
			if profile.checkEach({"spinningedge"}) then
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
            ACR_PVENIN_Burn = GUI:Checkbox("Test",ACR_PVENIN_Burn)
			--GUI:BulletText(tostring())
			GUI:BulletText("Test ACR NIN !")
        end
        GUI:End()
    end	
end
 
function profile.OnOpen()
    profile.GUI.open = true
end
 
function profile.OnLoad()
    ACR_PVENIN_Burn = ACR.GetSetting("ACR_PVENIN_Burn",false)
end
 
function profile.OnClick(mouse,shiftState,controlState,altState,entity)
 
end
 
function profile.OnUpdate(event, tickcount)

end
 
return profile