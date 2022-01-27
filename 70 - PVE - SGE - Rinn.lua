local profile = {}

profile.GUI = {
    open = false,
    visible = true,
    name = "PVE SGE 80 1.0",
}
 
profile.classes = {
    [FFXIV.JOBS.SAGE] = true,
} 

profile.sageBuff = 
	{

		swiftcast = 167,
		raise = 148,
		kardion = 2605, --others (or sage) grant the healing party
		kardia = 2604, -- on sage, kardion is applied
		eukrasiandosis = 2614,
		eukrasianprognosis = 2609, --similar to sch galvanize
		eukrasiandiagnosis = 2607, --do not stack with prognosis
		eukrasia = 2606, --buff to apply eukrasian effect
		physis = 2617,
		physis2 = 2620,
	}	

profile.sageSkill = 
	{
		swiftcast = {7561,false},
		luciddreaming = {7562,false},	
		eukrasia = {24290,false},
		kardia = {24285,true},
		dosis = {24283,true},
		eukrasiandosis = {24293, true},
		dyskrasia = {24297,false}, --aoe centered on sage
		phlegma = {24289,true}, --aoe centered on you need target
		prognosis = {24286,false},
		eukrasianprognosis = {24292,false},
		diagnosis = {24284,true},
		eukrasiandiagnosis = {24291,true},
		pepsis = {24301,false}, --remove eukrasiandiagnosis or eukrasianprognosis
		physis = {24288,false},
		physis2 = {24302,false},
		druochole = {24302,true}, --gauge[2] addergal no long cd, heal single target
		kerachole = {24298,false}, -- damage mitigation
		ixochole = {24299,false}, -- aoe heal
		taurochole = {24303,false}, --single target heal and damage mitigation
		haima = {24305,false},
		zoe = {24300,false}, --heal boost on one spell
		soteria = {24294,false}, --heal kardion boost for 15s
		egeiro = {24287,true}, --sge raise

	}
	
function profile:skillID(string)
	if profile.sageSkill[string] ~= nil then
		return profile.sageSkill[string][1]
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
	if profile.sageBuff[string] ~= nil then
		if HasBuff(Player.id,profile.sageBuff[string]) then
			return true
		end
	end
	return false
end

function profile:hasBuffOthers(string)
	if profile.sageBuff[string] ~= nil then
		if HasBuff(MGetTarget().id,profile.sageBuff[string]) then
			return true
		end
	end
	return false
end

function profile:hasBuffOthersDuration(string,duration)
	if profile.sageBuff[string] ~= nil then
		if HasBuff(MGetTarget().id,profile.sageBuff[string],0,duration) then
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

function profile.getClosestEntity()
	local entity = MEntityList("attackable,nearest")
	if entity ~= nil then
		for i,e in pairs(entity) do
			return e.distance2d
		end
	end
	return 500
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

function profile.countTargetFrom(targetid)
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
	for i,e in pairs(profile.sageSkill) do
		profile[i] = ActionList:Get(1,e[1])
	end
end

function profile.setSkillVar()
	for i,e in pairs(profile.sageSkill) do
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
	for i,e in pairs(profile.sageSkill) do
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
	
	--swift cast raise
	if profile.targetExists(profile.revivetarget) then
		if profile["egeiro"]["revivetarget"]["isready"] and profile.healCheckEach({"swiftcast"},Player.id,"player","player") then
			return true
		end
		if profile:hasBuffSelf("swiftcast") and profile.waitedOGCD(2000) and not Player:IsMoving() and not HasBuff(profile.revivetarget.id,profile.sageBuff["raise"]) and profile.healCheckEach({"egeiro"},profile.revivetarget.id,"revivetarget") then
			profile.ogcdtimer = Now()
			return true
		end		
	end
	if profile:hasBuffSelf("swiftcast") then return false end
	--kardion
	if profile.targetExists(profile.tanktarget) and profile.isValidHealTarget(profile.tanktarget) and not profile:hasBuffSelf("kardia") then
		if profile.targetExists(profile.tanktarget) and profile.healCheckEach({"kardia"},profile.tanktarget.id,"tanktarget") then
			return true
		end
	end	
	--luciddreaming
	if Player.mp.percent < 75 and profile.healCheckEach({"luciddreaming"},Player.id,"player","player") then
		return true
	end
	--allchole
	if Player.mp.percent < 95 or (Player.gauge ~= nil and Player.gauge[2] == 3) then
		--taurochole
		if profile.targetExists(profile.healtarget) and  profile.isValidHealTarget(profile.healtarget) and (profile.healtarget.hp.percent < 50 and (GetRoleString(profile.healtarget.job) ~= "Tank") or (profile.healtarget.hp.percent < 70 and GetRoleString(profile.healtarget.job) == "Tank")) then
			if not Player:IsMoving() and profile.healCheckEach({"taurochole"},profile.healtarget.id,"healtarget") then
				return true
			end
		end
		--druochole
		if profile.targetExists(profile.healtarget) and  profile.isValidHealTarget(profile.healtarget) and (profile.healtarget.hp.percent < 50 and (GetRoleString(profile.healtarget.job) ~= "Tank") or (profile.healtarget.hp.percent < 70 and GetRoleString(profile.healtarget.job) == "Tank")) then
			if not Player:IsMoving() and profile.healCheckEach({"taurochole"},profile.healtarget.id,"healtarget") then
				return true
			end
		end
		--ixochole
		if profile.aoehealme["90"] >= 2 and profile.healCheckEach({"ixochole"},Player.id,"player","player") then
			return true
		end
		--kerachole
		if profile.healCheckEach({"kerachole"},Player.id,"player","player") then
			return true
		end
		
	end
	--haima
	if profile.panicbutton["50"] >= 2 and profile.healCheckEach({"haima"},Player.id,"player","player") then
		return true
	end
	--soteria
	if profile.targetExists(profile.tanktarget) and profile.isValidHealTarget(profile.tanktarget) and profile.tanktarget.hp.percent < 50 then
		if profile.healCheckEach({"soteria"},Player.id,"player","player") then
			return true
		end
	end		
	--zoe
	if profile.targetExists(profile.healtarget) and profile.isValidHealTarget(profile.healtarget) and (profile.healtarget.hp.percent < 50 and (GetRoleString(profile.healtarget.job) ~= "Tank") or (profile.healtarget.hp.percent < 70 and GetRoleString(profile.healtarget.job) == "Tank")) then
		if not Player:IsMoving() and profile.healCheckEach({"zoe"},Player.id,"player","player") then
			return true
		end		
	end	
	--physis2
	if not profile:hasBuffSelf("physis2") and not profile:hasBuffSelf("physis") and profile.aoehealme["70"] >= 3 and not Player:IsMoving() and profile.healCheckEach({"physis","physis2"},Player.id,"player") then
		return true
	end		
	--pepsis
	if profile.targetExists(profile.healtarget) and profile.isValidHealTarget(profile.healtarget) and (HasBuff(profile.healtarget.id,profile.sageBuff["eukrasiandiagnosis"]) or HasBuff(profile.healtarget.id,profile.sageBuff["eukrasianprognosis"])) and profile.healCheckEach({"pepsis"},Player.id,"player","player") then
		return true
	end
	--eukrasianprognosis
	if not profile:hasBuffSelf("eukrasia") and profile.aoehealme["90"] >= 3 and profile.healCheckEach({"eukrasia"},Player.id,"player") then
		return true
	end
	if profile:hasBuffSelf("eukrasia") and profile.aoehealme["90"] >= 3 and not Player:IsMoving() and profile.healCheckEach({"eukrasianprognosis"},Player.id,"player") then
		return true
	end	
	--prognosis
	if profile.aoehealme["70"] >= 3 and not Player:IsMoving() and profile.healCheckEach({"prognosis"},Player.id,"player") then
		return true
	end	
	--diagnosis
	if profile.targetExists(profile.healtarget) and profile.isValidHealTarget(profile.healtarget) and (profile.healtarget.hp.percent < 95 and (GetRoleString(profile.healtarget.job) ~= "Tank") or (profile.healtarget.hp.percent < 85 and GetRoleString(profile.healtarget.job) == "Tank")) then
		if not Player:IsMoving() and profile.healCheckEach({"diagnosis"},profile.healtarget.id,"healtarget") then
			return true
		end
	end	
	
	if (currentTarget) then
		profile.setSkillVar()
		if Player:IsMoving() then
			profile.safejump = Now()
		end
		--damage dot ability
		if currentTarget.distance2d < 6 and profile.checkEach({"phlegma"}) then
			return true
		end
		if (profile.countTargetFrom(currentTarget.id) > 2) and (currentTarget.distance < 5) then
			if not Player:IsMoving() and profile.checkEach({"dyskrasia"}) then
				return true
			end		
		else
			if (not profile:hasBuffOthers("eukrasiandosis")) and not profile:hasBuffSelf("eukrasia")  and profile.checkEach({"eukrasia"}) then
				return true
			end
			if (not profile:hasBuffOthers("eukrasiandosis")) and profile:hasBuffSelf("eukrasia")  and profile.checkEach({"eukrasiandosis"}) then
				return true
			end			
			if not Player:IsMoving() and profile.checkEach({"dosis"}) then
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
            ACR_PVESGE_Burn = GUI:Checkbox("Test",ACR_PVESGE_Burn)
			--GUI:BulletText(tostring())
			GUI:BulletText("Test ACR SGE !")
        end
        GUI:End()
    end	
end
 
function profile.OnOpen()
    profile.GUI.open = true
end
 
function profile.OnLoad()
    ACR_PVESGE_Burn = ACR.GetSetting("ACR_PVESGE_Burn",false)
end
 
function profile.OnClick(mouse,shiftState,controlState,altState,entity)
 
end
 
function profile.OnUpdate(event, tickcount)

end
 
return profile
