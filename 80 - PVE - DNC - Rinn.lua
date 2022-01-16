local profile = {}

profile.GUI = {
    open = false,
    visible = true,
    name = "PVE DNC 80 1.1",
}
 
profile.classes = {
    [FFXIV.JOBS.DANCER] = true,
} 

profile.dancerBuff = 
	{
		standardstepcomplete = 1821,
		standarstepevaluation = 1818,
		technicalstepcomplete = 1822,
		technicalstepevaluation = 1819,		
	}

profile.dancerSkill = 
	{
		cascade = {15989,true},
		fountain = {15990,true},
		reversecascade = {15991,true},
		fountainfall = {15992,true},
		windmill = {15993,false},
		bladeshower = {15994,false},
		risingwindmill = {15995,false},
		bloodshower = {15996,false},
		standardstep = {15997,false},
		technicalstep = {15998,false},
		fandance = {16007,true},
		fandance2 = {16008,true},
		fandance3 = {16009,true},
		emboite = {15999,false},
		entrechat = {16000,false},
		jete = {16001,false},
		pirouette = {16002,false},
		saberdance = {16005,true},
		standardfinish = {16192,false},
		technicalfinish = {16196,false},
		flourish = {16013,false},
	}

function profile:skillID(string)
	if profile.dancerSkill[string] ~= nil then
		return profile.dancerSkill[string][1]
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
	if profile.dancerBuff[string] ~= nil then
		if HasBuff(Player.id,profile.dancerBuff[string]) then
			return true
		end
	end
	return false
end

function profile:hasBuffOthers(string)
	if profile.dancerBuff[string] ~= nil then
		if HasBuff(MGetTarget().id,profile.dancerBuff[string]) then
			return true
		end
	end
	return false
end

function profile:hasBuffOthersDuration(string,duration)
	if profile.dancerBuff[string] ~= nil then
		if HasBuff(MGetTarget().id,profile.dancerBuff[string],0,duration) then
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
	for i,e in pairs(profile.dancerSkill) do
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

profile.steps = {"emboite","entrechat","jete","pirouette"}
 
function profile.Cast()
    local currentTarget = MGetTarget()
	if (currentTarget) then
		profile.setVar()


		--ogcd offensive buff
		if profile.checkEach({"flourish"}) then
			return true
		end	
		--devilment to add
		
		--ogcd procs
		if profile.checkEach({"fandance"}) then
			return true
		end
		if profile.checkEach({"fandance2"}) then
			return true
		end
		if profile.checkEach({"fandance3"}) then
			return true
		end
		
		--ogcd gauge
		if Player.gauge ~= nil and Player.gauge[2] >= 50 and profile.checkEach({"saberdance"}) then
			return true
		end		
		--procs gcd
		if profile.checkEach({"reversecascade"}) then
			return true
		end				
		if profile.checkEach({"fountainfall"}) then
			return true
		end
		if profile.checkEach({"risingwindmill"},"player") then
			return true
		end
		if profile.checkEach({"bloodshower"},"player") then
			return true
		end		

		--standard steps
		if not profile:hasBuffSelf("standardstepcomplete") and profile.checkEach({"standardstep"}) then
			return true
		end
		
		if profile:hasBuffSelf("standarstepevaluation") then
			if Player.gauge ~= nil and Player.gauge[7] == 0 then
				local firstmove = Player.gauge[3]
				if profile.checkEach({profile.steps[firstmove]},"player") then
					return true
				end
			end
			if Player.gauge ~= nil and Player.gauge[7] == 1 then
				local secondmove = Player.gauge[4]
				if profile.checkEach({profile.steps[secondmove]},"player") then
					return true
				end
			end
			if Player.gauge ~= nil and Player.gauge[7] == 2 then
				if profile.checkEach({"standardfinish"},"player") then
					return true
				end
			end			
		end
			
		--technical steps
		if not profile:hasBuffSelf("technicalstepcomplete") and profile.checkEach({"technicalstep"}) then
			return true
		end
		
		if profile:hasBuffSelf("technicalstepevaluation") then
			if Player.gauge ~= nil and Player.gauge[7] == 0 then
				local firstmove = Player.gauge[3]
				if profile.checkEach({profile.steps[firstmove]},"player") then
					return true
				end
			end
			if Player.gauge ~= nil and Player.gauge[7] == 1 then
				local secondmove = Player.gauge[4]
				if profile.checkEach({profile.steps[secondmove]},"player") then
					return true
				end
			end
			if Player.gauge ~= nil and Player.gauge[7] == 2 then
				local thirdmove = Player.gauge[5]
				if profile.checkEach({profile.steps[thirdmove]},"player") then
					return true
				end
			end
			if Player.gauge ~= nil and Player.gauge[7] == 3 then
				local fourthmove = Player.gauge[6]
				if profile.checkEach({profile.steps[fourthmove]},"player") then
					return true
				end
			end			
			if Player.gauge ~= nil and Player.gauge[7] == 4 then
				if profile.checkEach({"technicalfinish"},"player") then
					return true
				end
			end			
		end		
		
		
		--12 combo / aoe 12 combo
		if profile.counttarget() > 2 then
			if profile:lastUsedCombo("windmill") and profile.checkEach({"bladeshower"}) then
				return true
			end		
			if profile.checkEach({"windmill"}) then
				return true
			end		
		else
			if profile:lastUsedCombo("cascade") and profile.checkEach({"fountain"}) then
				return true
			end
			
			if profile.checkEach({"cascade"}) then
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
            ACR_PVEDNC_Burn = GUI:Checkbox("Test",ACR_PVEDNC_Burn)
			--GUI:BulletText(tostring())
			GUI:BulletText("Test ACR DNC !")
        end
        GUI:End()
    end	
end
 
function profile.OnOpen()
    profile.GUI.open = true
end
 
function profile.OnLoad()
    ACR_PVEDNC_Burn = ACR.GetSetting("ACR_PVEDNC_Burn",false)
end
 
function profile.OnClick(mouse,shiftState,controlState,altState,entity)
 
end
 
function profile.OnUpdate(event, tickcount)

end
 
return profile