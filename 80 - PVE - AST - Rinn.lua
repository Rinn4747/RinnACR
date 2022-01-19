local profile = {}

profile.GUI = {
    open = false,
    visible = true,
    name = "PVE AST 80 1.0",
}
 
profile.classes = {
    [FFXIV.JOBS.ASTROLOGIAN] = true,
} 

profile.astrologianBuff = 
	{

		swiftcast = 167,
		raise = 148,
		collectiveunconscious = 848,
		collectiveunconscious2 = 849,
		giantdominance = 1248,
		horoscope = 1890,
		clarifyingdraw = 2713,
		lightspeed = 841,
		ladyofthecrown = 2055,
		combust = 838,
		combust2 = 843,
		combust3 = 1881,
		aspectedbenefic = 835,
		aspectedhelios = 836,
		benefic2 = 815,
	}	

profile.astrologianSkill = 
	{

		combust = {35991,true},
		combust2 = {3608,true},
		combust3 = {16554,true},
		malefic = {3596,true},		
		malefic2 = {3598,true},		
		malefic3 = {7442,true},		
		malefic4 = {16555,true},		
		gravity = {3615,true},
		celestialopposition = {16553,false},
		swiftcast = {7561,false},
		luciddreaming = {7562,false},
		benefic = {3594,true},
		essentialdignity = {3614,true},
		benefic2 = {3610,true},
		aspectedbenefic = {3595,true},
		helios = {3600,false},
		aspectedhelios = {3601,false},
		celestialintersection = {16556,true},
		collectiveunconscious = {3613,false},
		earthlystar = {7439,true},
		stellarexplosion = {8324,false},
		horoscope = {16557,false},
		draw = {3590,false},
		astrodyne = {25870,false},
		minorarcana = {7443,false},
		lordofthecrown = {7444,false},
		ladyofthecrown = {7445,false},
		lightspeed = {3606,false},
		neutralsect = {16559,false},
		ascend = {3603,true},
		card1 = {4401,true},
		card2 = {4402,true},
		card3 = {4403,true},
		card4 = {4404,true},
		card5 = {4405,true},
		card6 = {4406,true},

	}
	
function profile:skillID(string)
	if profile.astrologianSkill[string] ~= nil then
		return profile.astrologianSkill[string][1]
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
	if profile.astrologianBuff[string] ~= nil then
		if HasBuff(Player.id,profile.astrologianBuff[string]) then
			return true
		end
	end
	return false
end

function profile:hasBuffOthers(string)
	if profile.astrologianBuff[string] ~= nil then
		if HasBuff(MGetTarget().id,profile.astrologianBuff[string]) then
			return true
		end
	end
	return false
end

function profile:hasBuffOthersDuration(string,duration)
	if profile.astrologianBuff[string] ~= nil then
		if HasBuff(MGetTarget().id,profile.astrologianBuff[string],0,duration) then
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
	for i,e in pairs(profile.astrologianSkill) do
		profile[i] = ActionList:Get(1,e[1])
	end
end

function profile.setSkillVar()
	for i,e in pairs(profile.astrologianSkill) do
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
	for i,e in pairs(profile.astrologianSkill) do
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
	
	--collectiveunconscious
	if profile.panicbutton["60"] >= 3 and profile.healCheckEach({"collectiveunconscious"},Player.id,"player","player") then
		return true
	end
	if profile.hasBuffSelf("collectiveunconscious") and not profile.panicbutton["40"] >= 2 then return false end
	--swift cast raise
	if profile.targetExists(profile.revivetarget) then
		if profile["ascend"]["revivetarget"]["isready"] and profile.healCheckEach({"swiftcast"},Player.id,"player","player") then
			return true
		end
		if profile:hasBuffSelf("swiftcast") and profile.waitedOGCD(2000) and not Player:IsMoving() and not HasBuff(profile.revivetarget.id,profile.astrologianBuff["raise"]) and profile.healCheckEach({"ascend"},profile.revivetarget.id,"revivetarget") then
			profile.ogcdtimer = Now()
			return true
		end		
	end
	if profile:hasBuffSelf("swiftcast") then return false end
	--celestialopposition
	if (profile.aoehealme["90"] >= 2) and profile.healCheckEach({"celestialopposition"},Player.id,"player","player") then
		return true
	end
	--luciddreaming
	if Player.mp.percent < 75 and profile.healCheckEach({"luciddreaming"},Player.id,"player","player") then
		return true
	end
	--astrodyne
	if profile.healCheckEach({"astrodyne"},Player.id,"player","player") then
		return true
	end
	--use minorarcana card1
	if tonumber(profile.getClosestEntity()) < 5 and profile.healCheckEach({"ladyofthecrown","lordofthecrown"},Player.id,"player","player") then
		return true
	end	
	--minorarcana
	if profile.healCheckEach({"minorarcana"},Player.id,"player","player") then
		return true
	end
	--givecardbuff to healtarget
	if profile.targetExists(profile.healtarget) and profile.isValidHealTarget(profile.healtarget)  then		
		if profile.healCheckEach({"card1","card2","card3","card4","card5","card6"},profile.healtarget.id,"healtarget") then
			return true
		end		
	end	
	--draw
	if Player.mp.percent < 95 and profile.healCheckEach({"draw"},Player.id,"player","player") then
		return true
	end	
	--benefic2 proc
	if profile.targetExists(profile.tanktarget) and profile:hasBuffSelf("benefic2") and  profile.isValidHealTarget(profile.healtarget) and (profile.healtarget.hp.percent < 50 and (GetRoleString(profile.healtarget.job) ~= "Tank") or (profile.healtarget.hp.percent < 70 and GetRoleString(profile.healtarget.job) == "Tank")) then
		if not Player:IsMoving() and profile.healCheckEach({"benefic2"},profile.healtarget.id,"healtarget") then
			return true
		end
	end	
	--essentialdignity
	if profile.targetExists(profile.healtarget) and profile.isValidHealTarget(profile.healtarget) and (profile.healtarget.hp.percent < 50 and (GetRoleString(profile.healtarget.job) ~= "Tank") or (profile.healtarget.hp.percent < 70 and GetRoleString(profile.healtarget.job) == "Tank")) then		
		if not Player:IsMoving() and profile.healCheckEach({"essentialdignity"},profile.healtarget.id,"healtarget") then
			return true
		end		
	end
	
	--horoscope
	if profile.aoehealme["60"] >= 3 and profile.healCheckEach({"horoscope"},Player.id,"player","player") then
		return true
	end		
	--aspectedhelios
	if not profile:hasBuffSelf("aspectedhelios") and profile.aoehealme["70"] >= 3 and not Player:IsMoving() and profile.healCheckEach({"aspectedhelios"},Player.id,"player") then
		return true
	end	
	--helios
	if profile.aoehealme["70"] >= 3 and not Player:IsMoving() and profile.healCheckEach({"helios"},Player.id,"player") then
		return true
	end
	--earthlystar proc
	if profile:hasBuffSelf("giantdominance") and profile.healCheckEach({"stellarexplosion"},Player.id,"player","player") then
		return true
	end
	--earthlystar
	if profile.targetExists(profile.healtarget) and profile.isValidHealTarget(profile.healtarget) and profile.aoehealtarget["90"] >= 3 and profile.healCheckEach({"earthlystar"},profile.healtarget.id,"healtarget") then
		return true
	end
	--lightspeed
	if profile.targetExists(profile.healtarget) and profile.isValidHealTarget(profile.healtarget) and (profile.healtarget.hp.percent < 50 and (GetRoleString(profile.healtarget.job) ~= "Tank") or (profile.healtarget.hp.percent < 70 and GetRoleString(profile.healtarget.job) == "Tank")) then	
		if profile.healCheckEach({"lightspeed"},Player.id,"player","player") then
			return true
		end	
	end
	--celestialintersection
	if profile.targetExists(profile.tanktarget) and profile.isValidHealTarget(profile.tanktarget) and profile.tanktarget.hp.percent < 50 then
		if profile.healCheckEach({"celestialintersection"},profile.tanktarget.id,"tanktarget") then
			return true
		end
	end		
	--benefic2
	if profile.targetExists(profile.healtarget) and profile.isValidHealTarget(profile.healtarget) and (profile.healtarget.hp.percent < 50 and (GetRoleString(profile.healtarget.job) ~= "Tank") or (profile.healtarget.hp.percent < 70 and GetRoleString(profile.healtarget.job) == "Tank")) then
		if not Player:IsMoving() and profile.healCheckEach({"benefic2"},profile.healtarget.id,"healtarget") then
			return true
		end		
	end
	--aspectedbenefic
	if profile.targetExists(profile.tanktarget) and not HasBuff(profile.tanktarget.id,profile.astrologianBuff["aspectedbenefic"]) and profile.isValidHealTarget(profile.tanktarget) and profile.tanktarget.hp.percent < 90 then
		if profile.healCheckEach({"aspectedbenefic"},profile.tanktarget.id,"tanktarget") then
			return true
		end
	end	
	--benefic
	if profile.targetExists(profile.healtarget) and profile.isValidHealTarget(profile.healtarget) and (profile.healtarget.hp.percent < 95 and (GetRoleString(profile.healtarget.job) ~= "Tank") or (profile.healtarget.hp.percent < 85 and GetRoleString(profile.healtarget.job) == "Tank")) then
		if not Player:IsMoving() and profile.healCheckEach({"benefic"},profile.healtarget.id,"healtarget") then
			return true
		end
	end	
	if (currentTarget) then
		profile.setSkillVar()
		if Player:IsMoving() then
			profile.safejump = Now()
		end
		--damage dot ability
		if profile.countTargetFrom(currentTarget.id) > 2 then
			if not Player:IsMoving() and profile.checkEach({"gravity"}) then
				return true
			end		
		else
			if (not profile:hasBuffOthers("combust3") and not profile:hasBuffOthers("combust2") and not profile:hasBuffOthers("combust"))  and profile.checkEach({"combust3","combust2","combust"}) then
				return true
			end			
			if not Player:IsMoving() and profile.checkEach({"malefic","malefic2","malefic3","malefic4"}) then
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
            ACR_PVEAST_Burn = GUI:Checkbox("Test",ACR_PVEAST_Burn)
			--GUI:BulletText(tostring())
			GUI:BulletText("Test ACR AST !")
        end
        GUI:End()
    end	
end
 
function profile.OnOpen()
    profile.GUI.open = true
end
 
function profile.OnLoad()
    ACR_PVEAST_Burn = ACR.GetSetting("ACR_PVEAST_Burn",false)
end
 
function profile.OnClick(mouse,shiftState,controlState,altState,entity)
 
end
 
function profile.OnUpdate(event, tickcount)

end
 
return profile