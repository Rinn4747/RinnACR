local profile = {}

profile.GUI = {
    open = false,
    visible = true,
    name = "PVE MCH 80 1.0",
}
 
profile.classes = {
    [FFXIV.JOBS.MACHINIST] = true,
} 

profile.machinistBuff = 
	{
		-- stormbite = 1201,
		-- causticbite = 1200,
		-- mageballad = 2217,
		-- armypaeon = 2218,
		-- wandererminuet = 2216,
		-- windbite = 129,
		-- venomousbite = 124,
	}
profile.machinistSkill = 
	{
		splitshot = {2866,true},
		slugshot = {2868,true},
		cleanshot = {2873,true},
		hotshot = {2872,true},
		heatedsplitshot = {7411,true},
		heatedslugshot = {7412,true},
		heatedcleanshot = {7413,true},
		spreadshot = {2870,true},
		drill = {16498,true},
		reassemble = {2876,false},
		barrelstabilizer = {7414,false},
		airanchor = {16500,true},
		ricochet = {2890,true},
		gaussround = {2874,true},
		hypercharge = {17209,false},
		heatblast = {7410,true},
		autocrossbow = {16497,true},
		wildfire = {2878,true},
		bioblaster = {16499,true},
		flamethrower = {7418,true},
		rookautoturret = {2864,false},
		rookoverdrive = {7415,false},
		automatonqueen = {16501,false},
		queenoverdrive = {16502,false},

	}
	
function profile:skillID(string)
	if profile.machinistSkill[string] ~= nil then
		return profile.machinistSkill[string][1]
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
	if profile.machinistBuff[string] ~= nil then
		if HasBuff(Player.id,profile.machinistBuff[string]) then
			return true
		end
	end
	return false
end

function profile:hasBuffOthers(string)
	if profile.machinistBuff[string] ~= nil then
		if HasBuff(MGetTarget().id,profile.machinistBuff[string]) then
			return true
		end
	end
	return false
end

function profile:hasBuffOthersDuration(string,duration)
	if profile.machinistBuff[string] ~= nil then
		if HasBuff(MGetTarget().id,profile.machinistBuff[string],0,duration) then
			return true
		end
	end
	return false
end

profile.ogcdtimer = 0
profile.safejump = 0

function profile.counttarget(targetid)
	local targets = MEntityList("alive,attackable,targetable,maxdistance=5,distanceto="..tostring(targetid))
	return (table.size(targets))
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
	for i,e in pairs(profile.machinistSkill) do
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
		--gauge[2] battery
			--gaugetestdata[10] remaining automaton duration
		if Player.gauge ~= nil and Player.gauge[2] >= 50 and profile.checkEach({"rookautoturret","automatonqueen"},"player") then
			return true
		end
		if Player.gaugetest ~= nil and Player.gaugetest[10] <= 2 and profile.checkEach({"rookoverdrive","queenoverdrive"},"player") then
			return true
		end
		--gauge[1] heat
		if Player.gauge ~= nil and Player.gauge[1] <= 50 and Player.gauge[3] == 0 and profile.checkEach({"barrelstabilizer"},"player") then
			return true
		end		
		if Player.gauge ~= nil and Player.gauge[1] >= 50 and (not profile["ricochet"]["isready"]) and (not profile["gaussround"]["isready"]) and Player.gauge[3] == 0 and profile.checkEach({"hypercharge"},"player") then
			return true
		end
		if profile.counttarget(currentTarget.id) > 2 and currentTarget.distance < 12 then
			if Player.gauge ~= nil and Player.gauge[3] > 0  and  profile.checkEach({"autocrossbow"}) then
				return true
			end		
		else
			if Player.gauge ~= nil and Player.gauge[3] > 0  and  profile.checkEach({"heatblast"}) then
				return true
			end
		end
		--ogcd (must burn ricochet and gauss fast so that heatblast / autocrossbow can actually recharge em)
		if Player.gauge ~= nil and Player.gauge[3] == 0 and profile.waitedOGCD(500) and profile.checkEach({"ricochet"}) then
			profile.ogcdtimer = Now()
			return true
		end		
		if Player.gauge ~= nil and Player.gauge[3] == 0 and profile.waitedOGCD(500) and profile.checkEach({"gaussround"}) then
			profile.ogcdtimer = Now()
			return true
		end

			
		if profile.waitedOGCD(500) and profile.checkEach({"wildfire"}) then
			profile.ogcdtimer = Now()
			return true
		end
		
		--not ogcd
		if profile.checkEach({"hotshot","airanchor"}) then --+20 battery
			return true
		end
		if profile.checkEach({"reassemble"},"player") then
			return true
		end		
		if profile.counttarget(currentTarget.id) > 2 and currentTarget.distance < 12 then
			if profile.checkEach({"bioblaster"}) then
				return true
			end		
		else
			if profile.checkEach({"drill"}) then
				return true
			end		
		end
		

		--123 combo single / 1 aoe
		if profile.counttarget(currentTarget.id) > 2 and currentTarget.distance < 12 then
			if profile.checkEach({"spreadshot"}) then
				return true
			end		
		else
			if profile:lastUsedCombo("slugshot") and profile.checkEach({"cleanshot","heatedcleanshot"}) then
				return true
			end	
			if profile:lastUsedCombo("splitshot") and profile.checkEach({"slugshot","heatedslugshot"}) then
				return true
			end			
			if profile.checkEach({"splitshot","heatedsplitshot"}) then
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
            ACR_PVEMCH_Burn = GUI:Checkbox("Test",ACR_PVEMCH_Burn)
			--GUI:BulletText(tostring())
			GUI:BulletText("Test ACR MCH !")
        end
        GUI:End()
    end	
end
 
function profile.OnOpen()
    profile.GUI.open = true
end
 
function profile.OnLoad()
    ACR_PVEMCH_Burn = ACR.GetSetting("ACR_PVEMCH_Burn",false)
end
 
function profile.OnClick(mouse,shiftState,controlState,altState,entity)
 
end
 
function profile.OnUpdate(event, tickcount)

end
 
return profile