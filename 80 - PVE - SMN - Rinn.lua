local profile = {}

profile.GUI = {
    open = false,
    visible = true,
    name = "PVE SMN 1.5",
}
 
profile.classes = {
    [FFXIV.JOBS.SUMMONER] = true,
	[FFXIV.JOBS.ARCANIST] = true,
} 

varsummoner = 
	{ 
		ruin = {163,true},
		ruin2 = {172,true},
		ruin3 = {3579,true},
		summonbahamut = {7427,true},
		erkindlebahamut = {7429,true},
		astralimpulse = {25820,true},
		fountainoffire = {16514,true},
		erkindlephoenix = {16516,true},
		carbuncle = {25798,false},
		searinglight = {25801,false},
		radiantaegis = {25799,false},
		summonifrit = {25805,true},
		summontitan = {25806,true},
		summongaruda = {25807,true},
		rubyrite= {25823,true},
		topazrite= {25824,true},
		emeraldrite= {25825,true},
		rekindle= {25830,false}, 
		deathflare= {3582,true}, 
		ruin4= {7426,true},
		energydrain= {16508,true},
		fester= {181,true},
		tridisaster= {25826,true},
		astralflare= {25821,true},
		topazcastastrophe= {25833,true},
		rubycastastrophe= {25832,true},
		emeraldcastastrophe= {25834,true},
		brandofpurgatory= {16515,true},
		painflare= {3578,true},
		aethercharge= {25800,false},
		outburst= {25800,true},
		summontopaz= {25803,true},
		summonruby= {25802,true},
		summonemerald= {25804,true},
		topazruin= {25809,true},
		topazoutburst= {25815,true},
		rubyruin= {25808,true},
		rubyoutburst= {25814,true},
		emeraldruin= {25810,true},
		emeraldoutburst= {25816,true},
		dreadwyrmstance = {3581,false},
		topazruin3 = {25818,true},
		rubyruin3 = {25817,true},
		emeraldruin3 = {25819,true},
		topazruin2 = {25812,true},
		emeraldruin2 = {25813,true},
		rubyruin2 = {25811,true},
		resurrection = {173,true},
		swiftcast = {7561,false},
	}

profile.ogcdtimer = 0


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

function profile.counttarget(targetid)
	local targets = MEntityList("alive,attackable,targetable,maxdistance=5,distanceto="..tostring(targetid))
	return (table.size(targets))
end	

function profile.setVar()
	for i,e in pairs(varsummoner) do
		profile[i] = ActionList:Get(1,e[1])
	end
end 
 
function profile.setSkillVar()
	for i,e in pairs(varsummoner) do
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

function profile.checkEach(tbl,bool)
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
 
profile.revivetarget = 0 
 
function profile.Cast()
    local currentTarget = MGetTarget()
	local g = Player.gauge
	profile.setVar()
	profile.revivetarget = profile.getBestRevive()
	if (Player.level >= 12) and (profile.revivetarget ~= nil) and (profile.revivetarget ~= 0) then
		profile["swiftcast"]["isready"] = profile["swiftcast"]:IsReady(Player.id)
		profile["resurrection"]["revivetarget"] = {}
		profile["resurrection"]["revivetarget"]["isready"] = profile["resurrection"]:IsReady(profile.revivetarget.id)
		if profile["resurrection"]["revivetarget"]["isready"] then
			if not HasBuff(Player.id,167) and profile["swiftcast"]["isready"] then
				profile["swiftcast"]:Cast(Player.id)
				return true
			end
			if HasBuff(Player.id,167) and not HasBuff(profile.revivetarget.id,148) then --148 status effect raise --167 swiftcast
				profile["resurrection"]:Cast(profile.revivetarget.id)
				return true
			end
		end
	end	
	if (Player.level >= 12) and HasBuff(Player.id,167) and ((profile.revivetarget ~= nil) and (profile.revivetarget ~= 0)) and not HasBuff(profile.revivetarget.id,148) then return false end
	if (currentTarget) then
		profile.setSkillVar()
		if (Player.gauge ~= nil) and (Player.gauge[1] == 0) and (Player.gauge[2] == 0) and (Player.pet == nil) and profile.checkEach({"carbuncle"},false) then
			return true
		end	
		
		--ogcd
		if (Player.gauge ~= nil) and (Player.gauge[10] == 0) and (TimeSince(profile.ogcdtimer) > 3000) and profile.checkEach({"energydrain"},true) then
			profile.ogcdtimer = Now()
			return true
		end
		if profile.counttarget(currentTarget.id) > 2 then
			if (Player.gauge ~= nil) and (Player.gauge[10] > 0) and (TimeSince(profile.ogcdtimer) > 3000) and profile.checkEach({"painflare"},true) then
				profile.ogcdtimer = Now()	
				return true
			end		
		else
			if (Player.gauge ~= nil) and (Player.gauge[10] > 0) and (TimeSince(profile.ogcdtimer) > 3000) and profile.checkEach({"fester"},true) then
				profile.ogcdtimer = Now()	
				return true
			end
		end
		
		--not ogcd proc
		if profile.checkEach({"ruin4"},true) then
			return true
		end

		--big summon
		if Player.pet ~= nil and (profile.checkEach({"aethercharge","dreadwyrmstance"},false) or profile.checkEach({"summonbahamut"},true)) then
			return true
		end
		
		--bahamut spells
		if ((Player.pet ~= nil) and (Player.pet.name == "Demi-Bahamut")) or (Player.gauge ~= nil and (Player.gauge[1] > 0)) then
			if profile.checkEach({"erkindlebahamut"},true) then
				return true
			end
			if profile.checkEach({"deathflare"},true) then
				return true
			end
			if profile.counttarget(currentTarget.id) > 2 then
				if profile.checkEach({"astralflare"},true) then
					return true
				end			
			else
				if profile.checkEach({"astralimpulse"},true) then
					return true
				end
			end
		end
		
		--phoenix spells
		if (Player.pet ~= nil) and (Player.pet.name == "Demi-Phoenix") then
			if profile.checkEach({"erkindlephoenix"},true) then
				return true
			end		
			if profile.checkEach({"rekindle"},true) then
				return true
			end
			if profile.counttarget(currentTarget.id) > 2 then
				if profile.checkEach({"brandofpurgatory"},true) then
					return true
				end				
			else
				if profile.checkEach({"fountainoffire"},true) then
					return true
				end
			end
		end
		--ifrit
		if Player.gauge ~= nil and (Player.gauge[5] == 1) and (Player.gauge[2] == 0) and  profile.checkEach({"summonruby","summonifrit"},true) then
			return true
		end
		if profile.counttarget(currentTarget.id) > 2 then
			if (not Player:IsMoving()) and profile.checkEach({"rubyoutburst","rubycastastrophe"},true) then
				return true
			end			
		else
			if (not Player:IsMoving()) and profile.checkEach({"rubyruin","rubyruin2","rubyruin3","rubyrite"},true) then
				return true
			end
		end
		--titan
		if Player.gauge ~= nil and (Player.gauge[6] == 1) and (Player.gauge[2] == 0) and  profile.checkEach({"summontopaz","summontitan"},true) then
			return true
		end
		if profile.counttarget(currentTarget.id) > 2 then
			if profile.checkEach({"topazoutburst","topazcastastrophe"},true) then
				return true
			end		
		else
			if profile.checkEach({"topazruin","topazruin2","topazruin3","topazrite"},true) then
				return true
			end
		end
		--garuda
		if Player.gauge ~= nil and (Player.gauge[7] == 1) and (Player.gauge[2] == 0) and  profile.checkEach({"summonemerald","summongaruda"},true) then
			return true
		end
		if profile.counttarget(currentTarget.id) > 2 then
			if profile.checkEach({"emeraldoutburst","emeraldcastastrophe"},true) then
				return true
			end		
		else
			if profile.checkEach({"emeraldruin","emeraldruin2","emeraldruin3","emeraldrite"},true) then
				return true
			end
		end
		
		if profile.counttarget(currentTarget.id) > 2 then	
			if (Player.gauge ~= nil) and (Player.gauge[2] == 0) and profile.checkEach({"outburst","tridisaster"},true) then
				return true
			end
		end
		--single target
		if profile.counttarget(currentTarget.id) <= 2 then
			if (Player.gauge ~= nil) and (Player.gauge[2] == 0) and profile.checkEach({"ruin","ruin2","ruin3"},true) then
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
            ACR_PVESMN_Burn = GUI:Checkbox("Test",ACR_PVESMN_Burn)
			--GUI:BulletText(tostring())
			GUI:BulletText("Test ACR SMN !")
        end
        GUI:End()
    end	
end
 
function profile.OnOpen()
    profile.GUI.open = true
end
 
function profile.OnLoad()
    ACR_PVESMN_Burn = ACR.GetSetting("ACR_PVESMN_Burn",false)
end
 
function profile.OnClick(mouse,shiftState,controlState,altState,entity)
 
end
 
function profile.OnUpdate(event, tickcount)

end
 
return profile