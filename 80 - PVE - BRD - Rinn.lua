local profile = {}

profile.GUI = {
    open = false,
    visible = true,
    name = "PVE BRD 80 1.0",
}
 
profile.classes = {
    [FFXIV.JOBS.BARD] = true,
	[FFXIV.JOBS.ARCHER] = true,
} 

profile.bardBuff = 
	{
		stormbite = 1201,
		causticbite = 1200,
		mageballad = 2217,
		armypaeon = 2218,
		wandererminuet = 2216,
		windbite = 129,
		venomousbite = 124,
	}
profile.bardSkill = 
	{
		quicknock = {106,true},
		shadowbite = {16494,true},
		ironjaws = {3560,true},
		refulgentarrow = {7409,true},
		burstshot = {16495,true},
		causticbite = {7406,true},
		stormbite = {7407,true},
		empyrealarrow = {3558,true},
		sidewinder = {3562,true},
		bloodletter = {110,true},
		rainofdeath = {117,true},
		mageballad = {114,true},
		armypaeon = {116,true},
		wandererminuet = {3559,true},
		apexarrow = {16496,true},
		pitchperfect = {7404,true},
		straightshot = {98,true},
		heavyshot = {97,true},
		windbite = {113,true},
		venomousbite = {100,true},
	}
	
function profile:skillID(string)
	if profile.bardSkill[string] ~= nil then
		return profile.bardSkill[string][1]
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
	if profile.bardBuff[string] ~= nil then
		if HasBuff(Player.id,profile.bardBuff[string]) then
			return true
		end
	end
	return false
end

function profile:hasBuffOthers(string)
	if profile.bardBuff[string] ~= nil then
		if HasBuff(MGetTarget().id,profile.bardBuff[string]) then
			return true
		end
	end
	return false
end

function profile:hasBuffOthersDuration(string,duration)
	if profile.bardBuff[string] ~= nil then
		if HasBuff(MGetTarget().id,profile.bardBuff[string],0,duration) then
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
	for i,e in pairs(profile.bardSkill) do
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
		
		
		--repertoire stacks gauge[2]
			--if 3 stacks
		if (Player.gauge ~= nil) and (Player.gauge[2] == 3) and profile.checkEach({"pitchperfect"}) then
			return true
		end		
			--if any stack and song with last than 3 sec remaining
		if (Player.gauge ~= nil) and ((Player.gauge[2] > 0) and (Player.gauge[3] < 3000) ) and profile.checkEach({"pitchperfect"}) then
			return true
		end		
		--songs gauge[3]	remaining time
		if (not profile:hasBuffSelf("armypaeon")) and (not profile:hasBuffSelf("wandererminuet")) and profile.checkEach({"mageballad"}) then
			return true
		end
		if (not profile:hasBuffSelf("mageballad")) and (not profile:hasBuffSelf("wandererminuet")) and profile.checkEach({"armypaeon"}) then
			return true
		end
		if (not profile:hasBuffSelf("armypaeon")) and (not profile:hasBuffSelf("mageballad")) and profile.checkEach({"wandererminuet"}) then
			return true
		end		
		--gauge[4] soulvoice gauge
		if (Player.gauge ~= nil) and (Player.gauge[4] == 100) and profile.checkEach({"apexarrow"}) then
			return true
		end
		
		--ogcd
		if profile.waitedOGCD(3000) and profile.checkEach({"sidewinder"}) then
			profile.ogcdtimer = Now()
			return true
		end
		if profile.waitedOGCD(3000) and profile.checkEach({"empyrealarrow"}) then
			profile.ogcdtimer = Now()
			return true
		end
		if (profile.counttarget(currentTarget.id) > 2) then
			if profile.waitedOGCD(3000) and profile.checkEach({"rainofdeath"}) then
				profile.ogcdtimer = Now()
				return true
			end			
		else
			if profile.waitedOGCD(3000) and profile.checkEach({"bloodletter"}) then
				profile.ogcdtimer = Now()
				return true
			end					
		end
		--dot renew
		if (profile:hasBuffOthers("causticbite") and profile:hasBuffOthers("stormbite")) and ((not profile:hasBuffOthersDuration("causticbite",10)) or (not profile:hasBuffOthersDuration("stormbite",10))) and profile.checkEach({"ironjaws"}) then
			return true
		end
		if (profile:hasBuffOthers("windbite") and profile:hasBuffOthers("venomousbite")) and ((not profile:hasBuffOthersDuration("venomousbite",10)) or (not profile:hasBuffOthersDuration("windbite",10))) and profile.checkEach({"ironjaws"}) then
			return true
		end		
		--dot
		if not profile:hasBuffOthers("causticbite") and profile.checkEach({"causticbite"}) then
			return true
		end
		if not profile:hasBuffOthers("stormbite") and profile.checkEach({"stormbite"}) then
			return true
		end
		if not profile:hasBuffOthers("venomousbite") and profile.checkEach({"venomousbite"}) then
			return true
		end
		if not profile:hasBuffOthers("windbite") and profile.checkEach({"windbite"}) then
			return true
		end			
		if (profile.counttarget(currentTarget.id) > 2) and currentTarget.distance < 12 then
			--proc aoe
			if profile.checkEach({"shadowbite"}) then
				return true
			end
			if profile.checkEach({"straightshot","refulgentarrow"}) then --if ironjaws proc 
				return true
			end			
			--main spam aoe
			if profile.checkEach({"quicknock"}) then
				return true
			end			
		else
			--proc single
			if profile.checkEach({"straightshot","refulgentarrow"}) then
				return true
			end
			--main spam single
			if profile.checkEach({"heavyshot","burstshot"}) then
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
            ACR_PVEBRD_Burn = GUI:Checkbox("Test",ACR_PVEBRD_Burn)
			--GUI:BulletText(tostring())
			GUI:BulletText("Test ACR BRD !")
        end
        GUI:End()
    end	
end
 
function profile.OnOpen()
    profile.GUI.open = true
end
 
function profile.OnLoad()
    ACR_PVEBRD_Burn = ACR.GetSetting("ACR_PVEBRD_Burn",false)
end
 
function profile.OnClick(mouse,shiftState,controlState,altState,entity)
 
end
 
function profile.OnUpdate(event, tickcount)

end
 
return profile
