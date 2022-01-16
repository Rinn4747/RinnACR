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
		suiton = {2271,true},
		bhavacakra = {7402,true},
		hellfrogmedium = {7401,true},
		mug = {2248,true},
		dreamwithinadream = {3566,true},
		bunshin = {16493,false},
		huraijin = {25876,true},
		trickattack = {2258,true},
		raiton = {2267,true},
		kassatsu = {2264,false},
		hyoton2 = {16492,true},
		tenshijin = {7403,false},
		tsj1 = {18873,true},
		tsj2 = {18874,true},
		tsj3 = {18875,true},
		tsj4 = {18876,true},
		tsj5 = {18877,true},
		tsj6 = {18878,true},
		tsj7 = {18879,true},
		tsj8 = {18880,true},
		tsj9 = {18881,true},
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
profile.ntsj1 = 0
profile.ntsj2 = 0
profile.ntsj3 = 0
profile.ntsj4 = 0
profile.ntsj5 = 0
profile.ntsj6 = 0
profile.ntsj7 = 0
profile.ntsj8 = 0
profile.ntsj9 = 0

function profile.Cast()
    local currentTarget = MGetTarget()
	if (currentTarget) then
		profile.setVar()
		if Player:IsMoving() then
			profile.safejump = Now()
		end
		--d(profile.castingNinjutsu)
		--tenshijin
		if profile.checkEach({"tenshijin"},false) and not profile:hasBuffSelf("tenshijin") then	
			return true
		end
		if profile:hasBuffSelf("tenshijin") and TimeSince(profile.ntsj1) > 10000 and profile.checkEach({"tsj1"}) then
			profile.ntsj1 = Now()
			d("tsj1")
			return true
		end		
		if profile:hasBuffSelf("tenshijin") and TimeSince(profile.ntsj9) > 10000 and profile.checkEach({"tsj9"})  then
			profile.ntsj9 = Now()
			d("tsj9")
			return true
		end
		if profile:hasBuffSelf("tenshijin") and TimeSince(profile.ntsj8) > 10000 and profile.checkEach({"tsj8"}) then
			profile.ntsj8 = Now()
			d("tsj8")
			return true
		end
		if profile:hasBuffSelf("tenshijin") and TimeSince(profile.ntsj7) > 10000 and profile.checkEach({"tsj7"}) then
			profile.ntsj7 = Now()
			d("tsj7")
			return true
		end
		if profile:hasBuffSelf("tenshijin") and TimeSince(profile.ntsj6) > 10000 and profile.checkEach({"tsj6"}) then
			profile.ntsj6 = Now()
			d("tsj6")
			return true
		end
		if profile:hasBuffSelf("tenshijin") and TimeSince(profile.ntsj5) > 10000 and profile.checkEach({"tsj5"}) then
			profile.ntsj5 = Now()
			d("tsj5")
			return true
		end
		if profile:hasBuffSelf("tenshijin") and TimeSince(profile.ntsj4) > 10000 and profile.checkEach({"tsj4"}) then
			profile.ntsj4 = Now()
			d("tsj4")
			return true
		end		

		--casting ninjutsu any
		if profile.castingNinjutsu then
			d(profile.mudracounter < profile.mudranumber)
			if profile.mudracounter < profile.mudranumber then
				if profile.checkEach({profile.mudra[profile.mudracounter+1]}) then
					profile.mudracounter = profile.mudracounter + 1
					d(profile.mudracounter)
					return true
				end
			else
				if profile.checkEach({profile.mudraresult}) then
					profile.castingNinjutsu = false
					return true
				end			
			end
		end
		--kassatsu
		if profile.checkEach({"kassatsu"},"player") and (not profile["ten"].isoncd) then
			return true
		end
		--hyoton (kassatsu)
		if profile:hasBuffSelf("kassatsu") and profile.checkEach({"hyoton2"}) then
			return true
		end
		--calling hyoshoranryu
		if profile:hasBuffSelf("kassatsu") and (not profile["ten"].isoncd) then
			--d(profile["meisui"].isoncd)
			profile.mudracounter = 0
			profile.mudranumber = 2
			profile.mudra = {}
			profile.mudra = {"chi","jin2"}
			profile.mudraresult = "hyoton2"
			profile.castingNinjutsu = true
			--d("preparing to use meisui")
		end		
		--meisui
		if profile.checkEach({"meisui"},"player") then
			return true
		end
		--calling suiton (meisui)
		if (not profile["meisui"].isoncd) and (not profile.castingNinjutsu) and Player.gauge ~= nil and Player.gauge[1] <= 50  and (not profile["ten"].isoncd) then
			--d(profile["meisui"].isoncd)
			profile.mudracounter = 0
			profile.mudranumber = 3
			profile.mudra = {"chi","ten2","jin2"}
			profile.mudraresult = "suiton"
			profile.castingNinjutsu = true
			--d("preparing to use meisui")
		end
		--trickattack
		if profile.checkEach({"trickattack"}) then
			return true
		end
		--calling suiton (trickattack)
		if (not profile["trickattack"].isoncd) and (not profile.castingNinjutsu) and (not profile["ten"].isoncd) then
			profile.mudracounter = 0
			profile.mudranumber = 3
			profile.mudra = {"chi","ten2","jin2"}
			profile.mudraresult = "suiton"
			profile.castingNinjutsu = true
		end
		--raiton
		if profile.checkEach({"raiton"}) then
			return true
		end
		--calling raiton 
		if (profile["trickattack"].isoncd) and (profile["meisui"].isoncd)  and (not profile.castingNinjutsu) and (not profile["ten"].isoncd)  then
			profile.mudracounter = 0
			profile.mudranumber = 2
			profile.mudra = {"ten","chi2"}
			profile.mudraresult = "raiton"
			profile.castingNinjutsu = true
		end		
		--huraijin
		if Player.gauge ~= nil and Player.gauge[2] == 0 and profile.checkEach({"huraijin"}) then
			return true
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
		if profile.counttarget() > 2 then
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