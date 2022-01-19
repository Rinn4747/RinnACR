profile = {}

profile.GUI = {
    open = false,
    visible = true,
    name = "PVE SCH 80 1.0",
}
 
profile.classes = {
    [FFXIV.JOBS.SCHOLAR] = true,
} 

profile.scholarBuff = 
	{
		swiftcast = 167,
		raise = 148,
		biolysis = 1895,
		bio = 179,
		bio2 = 189,
		galvanize = 297, --shield from adloquium
		dissipation = 791,
		excogitation = 1220,
		
	}	

profile.scholarSkill = 
	{

		biolysis = {16540,true},
		luciddreaming = {7562,false},
		swiftcast = {7561,false},
		artofwar = {16539,false},
		broil3 = {16541,true},
		aetherflow = {166,false},
		energydrain = {167,true},
		physick = {190,true},
		adloquium = {185,true},
		indomitability = {3583,false},
		eos = {17215,false},
		selene = {17216,false},
		lustrate = {189,true},
		succor = {186,false},
		sacredsoil = {188,true},
		whisperingdawn = {16537,false},
		feyillumination = {16538,false},
		feyblessing = {16543,false},
		summonseraph = {16545,false},
		consolation = {16546,false},
		recitation = {16542,false},
		dissipation = {3587,false},
		excogitation = {7434,false},
		resurrection = {173,true},
		bio = {17864,true},
		bio2 = {17865,true},
		ruin = {17869,true},
		broil = {3584,true},
		broil2 = {7435,true},
		
	}
	
function profile:skillID(string)
	if profile.scholarSkill[string] ~= nil then
		return profile.scholarSkill[string][1]
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
	if profile.scholarBuff[string] ~= nil then
		if HasBuff(Player.id,profile.scholarBuff[string]) then
			return true
		end
	end
	return false
end

function profile:hasBuffOthers(string)
	if profile.scholarBuff[string] ~= nil then
		if HasBuff(MGetTarget().id,profile.scholarBuff[string]) then
			return true
		end
	end
	return false
end

function profile:hasBuffOthersDuration(string,duration)
	if profile.scholarBuff[string] ~= nil then
		if HasBuff(MGetTarget().id,profile.scholarBuff[string],0,duration) then
			return true
		end
	end
	return false
end

function profile.isValidHealTarget(e)
	if (table.valid(e) and e.alive and e.targetable and not e.aggro) then
		return (e.chartype == 4) or (e.id == Player.id) or
			(e.chartype == 0 and (e.type == 2 or e.type == 3 or e.type == 5)) or
			(e.chartype == 3 and e.type == 2) or
			(((e.chartype == 5 or e.chartype == 9) and e.type == 2) and (e.friendly or not e.attackable))
	end
	
	return false
end

function profile.getBestHealTarget( range, hp )	
	local range = range or ml_global_information.AttackRange
	local hp = hp or 95
	local trusts = MEntityList("chartype=9,distance2d=24")
	local search = ""
	local healables = {}
	if trusts ~= nil then
		search = "alive,chartype=9,targetable,maxdistance="..tostring(range)
	else	
		search = "alive,friendly,chartype=4,myparty,targetable,maxdistance="..tostring(range)
	end
	
	local el = MEntityList(search)	
	if ( table.valid(el) ) then
		for i,entity in pairs(el) do
			if (profile.isValidHealTarget(entity) and entity.hp.percent <= hp) then
				healables[i] = entity
			end
		end
		healables[#healables+1] = Player
	end
	
	
	if (table.valid(healables)) then
		local lowest = nil
		local lowesthp = 100
		
		for i,entity in pairs(healables) do
			if (not lowest or (lowest and entity.hp.percent < lowesthp)) then
				lowest = entity
				lowesthp = entity.hp.percent
			end
		end
		
		if (lowest) then
			return lowest
		end
	end
	
    return nil
end

function profile.getTankTarget()	
	if (npc == nil) then npc = false end
	local range = range or ml_global_information.AttackRange
	local hp = 100
	local trusts = MEntityList("chartype=9,distance2d=24")
	local search = ""
	local healables = {}
	if trusts ~= nil then
		search = "alive,chartype=9,targetable,maxdistance="..tostring(range)
	else	
		search = "alive,friendly,chartype=4,myparty,targetable,maxdistance="..tostring(range)
	end
	
	local el = MEntityList(search)	
	if ( table.valid(el) ) then
		for i,entity in pairs(el) do
			if (profile.isValidHealTarget(entity) and entity.hp.percent <= hp) then
				healables[i] = entity
			end
		end
		healables[#healables+1] = Player
	end
	
	
	if (table.valid(healables)) then
		for i,entity in pairs(healables) do
			if GetRoleString(entity.job) == "Tank" then
				return entity
			end
		end
		
	end
	
    return nil
end

function profile.countLowHPTarget(range,from)	
	local range = range or ml_global_information.AttackRange
	local from = IsNull(from,"")
	local search = ""
	local healables = {}
	local lowhp = {}
	local trusts = MEntityList("chartype=9,distance2d=24")
	lowhp.hundred = {}
	lowhp.ninety = {}
	lowhp.eighty = {}
	lowhp.seventy = {}
	lowhp.sixty = {}
	lowhp.fifty = {}
	lowhp.fourty = {}
	lowhp.thirty = {}
	lowhp.twenty = {}
	lowhp.ten = {}
	local resulttable = {}
	if trusts ~= nil then
		search = "alive,chartype=9,targetable,maxdistance="..tostring(range)
	else	
		search = "alive,friendly,chartype=4,myparty,targetable,maxdistance="..tostring(range)
	end	
	--search = "chartype=9,targetable,maxdistance="..tostring(range)
	if (from ~= "") then 
		search = search .. ",distanceto=" .. tostring(from) 
	end
	
	local el = MEntityList(search)	
	if (table.valid(el)) then
		for i,entity in pairs(el) do
		
			if (profile.isValidHealTarget(entity)) then
				healables[i] = entity
			end
			
		end	
	end
	healables[#healables+1] = Player
	

	
	if (table.valid(healables)) then
		local lowest = nil
		local lowesthp = 100
		
		for i,entity in pairs(healables) do
			if entity.hp.percent <= 100 then
				lowhp.hundred[i] = entity
			end		
			if entity.hp.percent < 90 then
				lowhp.ninety[i] = entity
			end
			if entity.hp.percent < 80 then
				lowhp.eighty[i] = entity
			end
			if entity.hp.percent < 70 then
				lowhp.seventy[i] = entity
			end
			if entity.hp.percent < 60 then
				lowhp.sixty[i] = entity
			end
			if entity.hp.percent < 50 then
				lowhp.fifty[i] = entity
			end
			if entity.hp.percent < 40 then
				lowhp.fourty[i] = entity
			end
			if entity.hp.percent < 30 then
				lowhp.thirty[i] = entity
			end
			if entity.hp.percent < 20 then
				lowhp.twenty[i] = entity
			end
			if entity.hp.percent < 10 then
				lowhp.ten[i] = entity
			end			
		end
		
		resulttable = 
		{
			["100"] = table.size(lowhp.hundred),
			["90"] = table.size(lowhp.ninety),
			["80"] = table.size(lowhp.eighty),
			["70"] = table.size(lowhp.seventy),
			["60"] = table.size(lowhp.sixty),
			["50"] = table.size(lowhp.fifty),
			["40"] = table.size(lowhp.fourty),
			["30"] = table.size(lowhp.thirty),
			["20"] = table.size(lowhp.twenty),
			["10"] = table.size(lowhp.ten),
		}
		
		
		return resulttable
	end
	
	
    return nil

end

function profile.getBestRevive()
	local party = IsNull(party,false)
	local role = role or ""
	range = 30
	
	local el = nil
	local trusts = MEntityList("chartype=9,distance2d=24")
	if trusts ~= nil then
		el = MEntityList("dead,chartype=9,targetable,maxdistance="..tostring(range))
	else	
		el = MEntityList("dead,friendly,chartype=4,myparty,targetable,maxdistance="..tostring(range))
	end	
	local targets = {}
	if (table.valid(el)) then
		for id,entity in pairs(el) do
			targets[id] = entity
		end
	end
	
	-- Filter out targets with the res buff.
	if (targets) then
		for id,entity in pairs(targets) do
			if (HasBuffs(entity,"148")) then
				targets[id] = nil
			end
		end
	end
	
	if (targets) then
		for id,entity in pairs(targets) do
			if (entity) then
				return entity
			end
		end
	end
	return nil
end

function profile.targetExists(targ)
	if targ ~= nil and targ ~= 0 then
		return true
	else
		return false
	end
end

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
	for i,e in pairs(profile.scholarSkill) do
		profile[i] = ActionList:Get(1,e[1])
	end
end

function profile.setSkillVar()
	for i,e in pairs(profile.scholarSkill) do
		--profile[i] = ActionList:Get(1,e[1])
		if profile[i] then
			if e[2] then
				profile[i]["isready"] = profile[i]:IsReady(MGetTarget().id)
			else
				profile[i]["isready"] = profile[i]:IsReady(Player)
			end
		end
	end
end 

function profile.setHealVar(filter,target)
	for i,e in pairs(profile.scholarSkill) do
		--profile[i] = ActionList:Get(1,e[1])
		profile[i][filter] = {}
		if profile[i] then
			profile[i][filter]["isready"] = profile[i]:IsReady(target)
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

function profile.healCheckEach(tbl,targetid,filter,string)
	local bool = (string == nil)
	for _,e in pairs(tbl) do
		if bool then
			if profile[tostring(e)][filter]["isready"] then
				profile[tostring(e)]:Cast(targetid)
				return true
			end
		elseif not bool then
			if profile[tostring(e)][filter]["isready"] then
				profile[tostring(e)]:Cast(Player)
				return true
			end
		end
	end
	return false
end
 

profile.ogcdtimer = 0
profile.safejump = 0
profile.healtarget = 0
profile.aoehealtarget = {}
profile.aoehealme = {}
profile.panicbutton = {}
profile.tanktarget = 0
profile.revivetarget = 0

function profile.Cast()
    local currentTarget = MGetTarget()
	profile.setVar()
	profile.healtarget = profile.getBestHealTarget(30,95)
	profile.aoehealme = profile.countLowHPTarget(15,Player.id)
	profile.panicbutton = profile.countLowHPTarget(30,Player.id)
	profile.revivetarget = profile.getBestRevive()
	profile.tanktarget = profile.getTankTarget()
	if (profile.healtarget ~= nil) and (profile.healtarget ~= 0) then
		profile.setHealVar("healtarget",profile.healtarget.id)
		profile.aoehealtarget = profile.countLowHPTarget(6,profile.healtarget.id)
	end
	if (profile.tanktarget ~= nil) and (profile.tanktarget ~= 0) then
		profile.setHealVar("tanktarget",profile.tanktarget.id)
	end
	if (profile.revivetarget ~= nil) and (profile.revivetarget ~= 0) then
		profile.setHealVar("revivetarget",profile.revivetarget.id)
	end
	profile.setHealVar("player",Player.id)
	
	if not profile:hasBuffSelf("dissipation") and Player.gauge ~= nil and Player.gauge[3] == 0 and (Player.pet == nil) and profile.healCheckEach({"eos"},Player.id,"player","player") then	
		return true
	end
	
	--swift cast raise
	if profile.targetExists(profile.revivetarget) then
		if profile["resurrection"]["revivetarget"]["isready"] and profile.healCheckEach({"swiftcast"},Player.id,"player","player") then
			return true
		end
		if profile:hasBuffSelf("swiftcast") and profile.waitedOGCD(2000) and not Player:IsMoving() and not HasBuff(profile.revivetarget.id,profile.scholarBuff["raise"]) and profile.healCheckEach({"resurrection"},profile.revivetarget.id,"revivetarget") then
			profile.ogcdtimer = Now()
			return true
		end		
	end
	if profile:hasBuffSelf("swiftcast") then return false end
	--indomitability
	if Player.gauge ~= nil and Player.gauge[1] > 0 and (profile.aoehealme["90"] >= 2) and profile.healCheckEach({"indomitability"},Player.id,"player","player") then
		return true
	end

	--aetherflow
	if Player.gauge ~= nil and Player.gauge[1] == 0 and  Player.incombat and profile.healCheckEach({"aetherflow"},Player.id,"player","player") then
		return true
	end	
	--luciddreaming	
	if Player.mp.percent < 75 and profile.healCheckEach({"luciddreaming"},Player.id,"player","player") then
		return true
	end
	--summonseraph
	if profile.panicbutton["40"] >= 3 and profile.healCheckEach({"summonseraph"},Player.id,"player","player") then
		return true
	end
	--consolation
	if Player.gauge ~= nil and Player.gauge[3] > 0 and profile.panicbutton["60"] >= 3 and profile.healCheckEach({"consolation"},Player.id,"player","player") then
		return true
	end
	--dissipation
	if profile.panicbutton["40"] >= 3 and not profile["summonseraph"]["player"]["isready"] and not profile["aetherflow"]["player"]["isready"]  then
		if profile.healCheckEach({"dissipation"},Player.id,"player","player") then
			return true
		end
	end	
	--feyblessing
	if profile.aoehealme["70"] >= 2  and profile.healCheckEach({"feyblessing"},Player.id,"player","player") then
		return true
	end	
	--whisperingdawn
	if profile.aoehealme["80"] >= 2  and profile.healCheckEach({"whisperingdawn"},Player.id,"player","player") then
		return true
	end
	--succor
	if profile.aoehealme["90"] >= 3  and profile.healCheckEach({"succor"},Player.id,"player","player") then
		return true
	end		
	--excogitation
	if profile.targetExists(profile.tanktarget) and not HasBuff(profile.tanktarget.id,profile.scholarBuff["excogitation"])  and profile.isValidHealTarget(profile.tanktarget) and profile.tanktarget.hp.percent < 70 then
		if profile.healCheckEach({"excogitation"},profile.tanktarget.id,"tanktarget") then
			return true
		end
	end
	--excog if aetherflow off cooldown and remaining charges
	if profile.targetExists(profile.tanktarget) and not HasBuff(profile.tanktarget.id,profile.scholarBuff["excogitation"])  and profile.isValidHealTarget(profile.tanktarget) then
		if Player.gauge ~= nil and Player.gauge[1] > 0 and profile["aetherflow"]["isready"] and profile.healCheckEach({"excogitation"},profile.tanktarget.id,"tanktarget") then
			return true
		end
	end	
	--lustrate
	if profile.targetExists(profile.healtarget) and not HasBuff(profile.healtarget.id,profile.scholarBuff["galvanize"]) and profile.isValidHealTarget(profile.healtarget) and (profile.healtarget.hp.percent < 50 and (GetRoleString(profile.healtarget.job) ~= "Tank") or (profile.healtarget.hp.percent < 70 and GetRoleString(profile.healtarget.job) == "Tank")) then
		if profile.healCheckEach({"adloquium"},profile.healtarget.id,"healtarget") then
			return true
		end		
	end
	--recitation
	if profile.targetExists(profile.healtarget) and not HasBuff(profile.healtarget.id,profile.scholarBuff["galvanize"]) and profile.isValidHealTarget(profile.healtarget) and (profile.healtarget.hp.percent < 50 and (GetRoleString(profile.healtarget.job) ~= "Tank") or (profile.healtarget.hp.percent < 70 and GetRoleString(profile.healtarget.job) == "Tank")) then
		if not Player:IsMoving() and profile.healCheckEach({"recitation"},Player.id,"player","player") then
			return true
		end		
	end	
	--adloquium
	if profile.targetExists(profile.healtarget) and not HasBuff(profile.healtarget.id,profile.scholarBuff["galvanize"]) and profile.isValidHealTarget(profile.healtarget) and (profile.healtarget.hp.percent < 70 and (GetRoleString(profile.healtarget.job) ~= "Tank") or (profile.healtarget.hp.percent < 70 and GetRoleString(profile.healtarget.job) == "Tank")) then
		if not Player:IsMoving() and profile.healCheckEach({"adloquium"},profile.healtarget.id,"healtarget") then
			return true
		end		
	end
	--physick
	if profile.targetExists(profile.healtarget) and profile.isValidHealTarget(profile.healtarget) and (profile.healtarget.hp.percent < 95 and (GetRoleString(profile.healtarget.job) ~= "Tank") or (profile.healtarget.hp.percent < 85 and GetRoleString(profile.healtarget.job) == "Tank")) then
		if not Player:IsMoving() and profile.healCheckEach({"physick"},profile.healtarget.id,"healtarget") then
			return true
		end
	end	

	if (currentTarget) then
		profile.setSkillVar()
		if Player:IsMoving() then
			profile.safejump = Now()
		end
		if Player.gauge ~= nil and Player.gauge[1] > 0 and profile["aetherflow"]["isready"] and profile.checkEach({"energydrain"}) then
			return true
		end
		if (profile.counttarget()) > 2 and (Player.level >= 46) then
			if profile.checkEach({"artofwar"},"player") then
				return true
			end		
		else
			if (not profile:hasBuffOthers("biolysis") and not profile:hasBuffOthers("bio") and not profile:hasBuffOthers("bio2"))  and profile.checkEach({"bio","bio2","biolysis"}) then
				return true
			end			
			if not Player:IsMoving() and profile.checkEach({"ruin","broil","broil2","broil3"}) then
				return true
			end
		end
		return false
	end
	return false
end

function profile.Draw()
    if (profile.GUI.open) then	
	profile.GUI.visible, profile.GUI.open = GUI:Begin(profile.GUI.name, profile.GUI.open)
	if ( profile.GUI.visible ) then 
            ACR_PVESCH_Burn = GUI:Checkbox("Test",ACR_PVESCH_Burn)
			--GUI:BulletText(tostring())
			GUI:BulletText("Test ACR SCH !")
        end
        GUI:End()
    end	
end
 
function profile.OnOpen()
    profile.GUI.open = true
end
 
function profile.OnLoad()
    ACR_PVESCH_Burn = ACR.GetSetting("ACR_PVESCH_Burn",false)
end
 
function profile.OnClick(mouse,shiftState,controlState,altState,entity)
 
end
 
function profile.OnUpdate(event, tickcount)

end
 
return profile