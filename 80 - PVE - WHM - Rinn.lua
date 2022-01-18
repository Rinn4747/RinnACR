profile = {}

profile.GUI = {
    open = false,
    visible = true,
    name = "PVE WHM 80 1.0",
}
 
profile.classes = {
    [FFXIV.JOBS.WHITEMAGE] = true,
	[FFXIV.JOBS.CONJURER] = true,
} 

profile.whitemageBuff = 
	{
		dia = 1871,
		freecure = 155,
		aero = 143,
		aero2 = 144,
		medica2 = 150,
		regen = 158,
	}	

profile.whitemageSkill = 
	{

		aero2 = {132,true},
		stone3 = {3568,true},
		dia = {16532,true},
		glare = {16533,true},
		holy = {139,false},
		cure = {120,true},
		cure2 = {135,true},		
		tetragrammaton = {3570,true},
		luciddreaming = {7562,false},
		thinair = {7430,false},
		medica = {124,true},
		cure3 = {131,true},
		assize = {3571,false},
		afflatussolace = {16531,true},
		afflatusrapture = {16534,true},
		afflatusmisery = {16535,true},
		asylum = {3569,true},
		benediction = {140,true},
		swiftcast = {7561,false},
		pom = {136,false},
		plenaryindulgence = {7433,false},
		temperance = {16536,false},
		divinebenison = {7432,true},
		regen = {137,true},
		medica2 = {133,false},
		stone2 = {127,true},
		stone = {119,true},
		aero = {121,true},
	}
	
function profile:skillID(string)
	if profile.whitemageSkill[string] ~= nil then
		return profile.whitemageSkill[string][1]
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
	if profile.whitemageBuff[string] ~= nil then
		if HasBuff(Player.id,profile.whitemageBuff[string]) then
			return true
		end
	end
	return false
end

function profile:hasBuffOthers(string)
	if profile.whitemageBuff[string] ~= nil then
		if HasBuff(MGetTarget().id,profile.whitemageBuff[string]) then
			return true
		end
	end
	return false
end

function profile:hasBuffOthersDuration(string,duration)
	if profile.whitemageBuff[string] ~= nil then
		if HasBuff(MGetTarget().id,profile.whitemageBuff[string],0,duration) then
			return true
		end
	end
	return false
end

profile.ogcdtimer = 0
profile.safejump = 0

function profile.isValidHealTarget(e)
	if (table.valid(e) and e.alive and e.targetable and not e.aggro) then
		return (e.chartype == 4) or (e.id == Player.id) or
			(e.chartype == 0 and (e.type == 2 or e.type == 3 or e.type == 5)) or
			(e.chartype == 3 and e.type == 2) or
			(((e.chartype == 5 or e.chartype == 9) and e.type == 2) and (e.friendly or not e.attackable))
	end
	
	return false
end

function profile.getBestHealTarget( npc, range, hp, whitelist )	
	local npc = npc
	if (npc == nil) then npc = false end
	local range = range or ml_global_information.AttackRange
	local hp = hp or 95
	local whitelist = IsNull(whitelist,"")
	local trusts = MEntityList("chartype=9,distance2d=24")
	local search = ""
	local healables = {}
	if trusts ~= nil then
		search = "alive,chartype=9,targetable,maxdistance="..tostring(range)
	else	
		search = "alive,friendly,chartype=4,myparty,targetable,maxdistance="..tostring(range)
	end
	--search = "chartype=9,targetable,maxdistance="..tostring(range)
	if (whitelist ~= "") then search = search .. ",contentid=" .. tostring(whitelist) end
	
	local el = MEntityList(search)	
	if ( table.valid(el) ) then
		for i,entity in pairs(el) do
			if (IsValidHealTarget(entity) and entity.hp.percent <= hp) then
				healables[i] = entity
			end
		end
		healables[#healables+1] = Player
	end
	
	if (npc) then
		search = "alive,targetable,maxdistance="..tostring(range)
		if (whitelist ~= "") then search = search .. ",contentid=" .. tostring(whitelist)  end
	
		el = MEntityList(search)
		if ( table.valid(el) ) then
			for i,entity in pairs(el) do
				if (IsValidHealTarget(entity) and entity.hp.percent <= hp) then
					healables[i] = entity
				end
			end
		end
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
	
	if (gBotMode == GetString("partyMode") and not IsPartyLeader()) then
		local leader, isEntity = GetPartyLeader()
		if (leader and leader.id ~= 0) then
			local leaderentity = EntityList:Get(leader.id)
			if (leaderentity and leaderentity.distance <= range and leaderentity.hp.percent <= hp) then
				return leaderentity
			end
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
			if (IsValidHealTarget(entity) and entity.hp.percent <= hp) then
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
		
			if (IsValidHealTarget(entity)) then
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

function profile.getBestPartyHealTarget( npc, range, hp, whitelist )	
	local npc = npc
	if (npc == nil) then npc = false end
	local range = range or ml_global_information.AttackRange
	local hp = hp or 95
	local whitelist = IsNull(whitelist,"")
	
	local search = ""
	local healables = {}
	
	search = "alive,friendly,chartype=4,myparty,targetable,maxdistance="..tostring(range)
	if (whitelist ~= "") then search = search .. ",contentid=" .. tostring(whitelist) end
	
	local el = MEntityList(search)	
	if ( table.valid(el) ) then
		for i,entity in pairs(el) do
			if (IsValidHealTarget(entity) and entity.hp.percent <= hp) then
				healables[i] = entity
			end
		end
		--healables[#healables+1] = Player
	end
	healables[#healables+1] = Player
	
	if (npc) then
		search = "alive,targetable,maxdistance="..tostring(range)
		if (whitelist ~= "") then search = search .. ",contentid=" .. tostring(whitelist)  end
	
		el = MEntityList(search)
		if ( table.valid(el) ) then
			for i,entity in pairs(el) do
				if (IsValidHealTarget(entity) and entity.hp.percent <= hp) then
					healables[i] = entity
				end
			end
		end
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
	
	if (gBotMode == GetString("partyMode") and not IsPartyLeader()) then
		local leader, isEntity = GetPartyLeader()
		if (leader and leader.id ~= 0) then
			local leaderentity = EntityList:Get(leader.id)
			if (leaderentity and leaderentity.distance <= range and leaderentity.hp.percent <= hp) then
				return leaderentity
			end
		end
	end
	
    return nil
end

function profile.getClosestHealTarget()
    local pID = Player.id
    local el = MEntityList("nearest,friendly,chartype=4,myparty,targetable,exclude="..tostring(pID)..",maxdistance="..tostring(ml_global_information.AttackRange))
	--local el = MEntityList("nearest,friendly,chartype=4,myparty,exclude="..tostring(pID)..",maxdistance="..tostring(ml_global_information.AttackRange))
    if ( table.valid(el) ) then
        local i,e = next(el)
        if (i~=nil and e~=nil) then
            return e
        end
    end
    
    local el = MEntityList("nearest,friendly,chartype=4,targetable,exclude="..tostring(pID)..",maxdistance="..tostring(ml_global_information.AttackRange))
	--local el = MEntityList("nearest,friendly,chartype=4,exclude="..tostring(pID)..",maxdistance="..tostring(ml_global_information.AttackRange))
    if ( table.valid(el) ) then
        local i,e = next(el)
        if (i~=nil and e~=nil) then
            return e
        end
    end
    --ml_debug("GetBestHealTarget() failed with no entity found matching params")
    return nil
end

function profile.getBestRevive( party, role)
	party = IsNull(party,false)
	role = role or ""
	range = 30
	
	local el = nil
	if (party) then
		el = MEntityList("myparty,friendly,chartype=4,targtable,dead,maxdistance="..tostring(range))
	else
		el = MEntityList("friendly,dead,chartype=4,targetable,maxdistance="..tostring(range))
	end 
	
	-- Filter out the inappropriate roles.
	local targets = {}
	if (table.valid(el)) then
		local roleTable = GetRoleTable(role)
		if (roleTable) then
			for id,entity in pairs(el) do
				if (entity.job and roleTable[entity.job]) then
					targets[id] = entity
				end
			end
		else
			for id,entity in pairs(el) do
				targets[id] = entity
			end
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
	
	if (gBotMode == GetString("partyMode") and not IsPartyLeader()) then
		local leader, isEntity = GetPartyLeader()
		if (leader and leader.id ~= 0) then
			local leaderentity = EntityList:Get(leader.id)
			if (leaderentity and leaderentity.distance <= range and not leader.alive and MissingBuffs(leaderentity, "148")) then
				return leaderentity
			end
		end
	end
	
	return nil
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
	for i,e in pairs(profile.whitemageSkill) do
		profile[i] = ActionList:Get(1,e[1])
	end
end

function profile.setSkillVar()
	for i,e in pairs(profile.whitemageSkill) do
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
	for i,e in pairs(profile.whitemageSkill) do
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
 
profile.targetedFromAfar = false
profile.firingkenki = 0
profile.healtarget = 0
profile.aoehealtarget = {}
profile.aoehealme = {}
profile.panicbutton = {}
profile.tanktarget = 0

function profile.Cast()
    local currentTarget = MGetTarget()
	profile.setVar()
	profile.healtarget = profile.getBestHealTarget(false,30,95)
	profile.aoehealme = profile.countLowHPTarget(15,Player.id)
	profile.panicbutton = profile.countLowHPTarget(30,Player.id)
	profile.tanktarget = profile.getTankTarget()
	if (profile.healtarget ~= nil) and (profile.healtarget ~= 0) then
		profile.setHealVar("healtarget",profile.healtarget.id)
		profile.aoehealtarget = profile.countLowHPTarget(6,profile.healtarget.id)
	end
	if (profile.tanktarget ~= nil) and (profile.tanktarget ~= 0) then
		profile.setHealVar("tanktarget",profile.tanktarget.id)
	end
	profile.setHealVar("player",Player.id)
	--assize
	if ((profile.aoehealme["90"] >= 2) or (Player.mp.percent < 70)) and profile.healCheckEach({"assize"},Player.id,"player","player") then
		return true
	end
	--luciddreaming
	if Player.mp.percent < 75 and profile.healCheckEach({"luciddreaming"},Player.id,"player","player") then
		return true
	end
	--tetragrammaton
	if profile.isValidHealTarget(profile.healtarget) and (profile.healtarget.hp.percent < 50 and (GetRoleString(profile.healtarget.job) ~= "Tank") or (profile.healtarget.hp.percent < 70 and GetRoleString(profile.healtarget.job) == "Tank")) then		
		if not Player:IsMoving() and profile.healCheckEach({"tetragrammaton"},profile.healtarget.id,"healtarget") then
			return true
		end		
	end
	--temperance
	if profile.panicbutton["40"] >= 3 and profile.healCheckEach({"temperance"},Player.id,"player","player") then
		return true
	end	
	--cure3
	if profile.isValidHealTarget(profile.healtarget) and profile.aoehealtarget["50"] >= 3 and not Player:IsMoving() and profile.healCheckEach({"cure3"},profile.healtarget.id,"healtarget") then
		return true
	end
	--plenaryindulgence
	if profile.aoehealme["60"] >= 3 and profile.healCheckEach({"plenaryindulgence"},Player.id,"player","player") then
		return true
	end		
	--afflatusrapture
	if profile.aoehealme["70"] >= 3 and profile.healCheckEach({"afflatusrapture"},Player.id,"player") then
		return true
	end
	--medica2
	if not profile:hasBuffSelf("medica2") and profile.aoehealme["70"] >= 3 and not Player:IsMoving() and profile.healCheckEach({"medica2"},Player.id,"player") then
		return true
	end	
	--medica
	if profile.aoehealme["70"] >= 3 and not Player:IsMoving() and profile.healCheckEach({"medica"},Player.id,"player") then
		return true
	end
	--pom
	if profile.panicbutton["70"] >= 3 and profile.healCheckEach({"pom"},Player.id,"player","player") then
		return true
	end	
	--asylum
	if profile.isValidHealTarget(profile.healtarget) and profile.aoehealtarget["90"] >= 3 and profile.healCheckEach({"asylum"},profile.healtarget.id,"healtarget") then
		return true
	end
	--afflatussolace
	if profile.isValidHealTarget(profile.healtarget) and (profile.healtarget.hp.percent < 50 and (GetRoleString(profile.healtarget.job) ~= "Tank") or (profile.healtarget.hp.percent < 70 and GetRoleString(profile.healtarget.job) == "Tank")) then
		if profile.healCheckEach({"afflatussolace"},profile.healtarget.id,"healtarget") then
			return true
		end		
	end	
	--thinair
	if profile.isValidHealTarget(profile.healtarget) and (profile.healtarget.hp.percent < 50 and (GetRoleString(profile.healtarget.job) ~= "Tank") or (profile.healtarget.hp.percent < 70 and GetRoleString(profile.healtarget.job) == "Tank")) then	
		if profile.healCheckEach({"thinair"},Player.id,"player","player") then
			return true
		end	
	end
	--divine benison
	if profile.isValidHealTarget(profile.tanktarget) and profile.tanktarget.hp.percent < 50 then
		if profile.healCheckEach({"divinebenison"},profile.tanktarget.id,"tanktarget") then
			return true
		end
	end		
	--cure2
	if profile.isValidHealTarget(profile.healtarget) and (profile.healtarget.hp.percent < 50 and (GetRoleString(profile.healtarget.job) ~= "Tank") or (profile.healtarget.hp.percent < 70 and GetRoleString(profile.healtarget.job) == "Tank")) then
		if not Player:IsMoving() and profile.healCheckEach({"cure2"},profile.healtarget.id,"healtarget") then
			return true
		end		
	end
	--cure2 proc
	if  profile:hasBuffSelf("freecure") and  profile.isValidHealTarget(profile.healtarget) and profile.healtarget.hp.percent < 95 then
		if not Player:IsMoving() and profile.healCheckEach({"cure2"},profile.healtarget.id,"healtarget") then
			return true
		end
	end
	--regen
	if not HasBuff(profile.tanktarget.id,profile.whitemageBuff["regen"]) and profile.isValidHealTarget(profile.tanktarget) and profile.tanktarget.hp.percent < 90 then
		if profile.healCheckEach({"regen"},profile.tanktarget.id,"tanktarget") then
			return true
		end
	end	
	--cure1
	if profile.isValidHealTarget(profile.healtarget) and (profile.healtarget.hp.percent < 95 and (GetRoleString(profile.healtarget.job) ~= "Tank") or (profile.healtarget.hp.percent < 85 and GetRoleString(profile.healtarget.job) == "Tank")) then
	--if profile.isValidHealTarget(profile.healtarget) and profile.healtarget.hp.percent < 95 then
		if not Player:IsMoving() and profile.healCheckEach({"cure"},profile.healtarget.id,"healtarget") then
			return true
		end
	end	
	if (currentTarget) then
		profile.setSkillVar()
		if Player:IsMoving() then
			profile.safejump = Now()
		end
		--proc damage afflatus
		if profile.checkEach({"afflatusmisery"}) then
			return true
		end
		--damage dot ability
		if profile.counttarget() > 2 then
			if not Player:IsMoving() and profile.checkEach({"holy"},"player") then
				return true
			end		
		else
			if (not profile:hasBuffOthers("dia") and not profile:hasBuffOthers("aero2") and not profile:hasBuffOthers("aero"))  and profile.checkEach({"aero","aero2","dia"}) then
				return true
			end			
			if not Player:IsMoving() and profile.checkEach({"stone","stone2","stone3","glare"}) then
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
            ACR_PVEWHM_Burn = GUI:Checkbox("Test",ACR_PVEWHM_Burn)
			--GUI:BulletText(tostring())
			GUI:BulletText("Test ACR WHM !")
        end
        GUI:End()
    end	
end
 
function profile.OnOpen()
    profile.GUI.open = true
end
 
function profile.OnLoad()
    ACR_PVEWHM_Burn = ACR.GetSetting("ACR_PVEWHM_Burn",false)
end
 
function profile.OnClick(mouse,shiftState,controlState,altState,entity)
 
end
 
function profile.OnUpdate(event, tickcount)

end
 
return profile