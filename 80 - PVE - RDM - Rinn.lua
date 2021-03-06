local profile = {}

profile.GUI = {
    open = false,
    visible = true,
    name = "PVE RDM 80 1.2",
}
 
profile.classes = {
    [FFXIV.JOBS.REDMAGE] = true,
} 

verredmage = 
	{
		jolt = {7503,true},
		jolt2 = {7524,true},
		veraero = {7507,true},
		verthunder = {7505,true},
		verfire = {7510,true},
		verstone = {7511,true},
		enchantedriposte = {7527,true},
		enchantedzwerchhau = {7528,true},
		enchantedredoublement  = {7529,true},
		riposte = {7507,true},
		zwerchhau = {7512,true},
		redoublement = {7516,true},
		verflare = {7525,true},
		verholy = {7526,true},
		scorch = {16530,true},
		scatter = {7509,true},
		verthunder2 = {16524,true},
		veraero2 = {16525,true},
		impact = {16526,true},
		moulinet = {7513,true},
		enchantedmoulinet = {7530,true},
		fleche = {7517,true},
		contresixte = {7519,true},
		engagement = {16527,true},
		manafication = {7521,false},
		swiftcast = {7561,false},
		verraise = {7523,true},

	}
	
--	verflare 7525 
--	scorch 16530
--7504  7512  7516
--7527  7528  7529
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

function profile.setVar()
	for i,e in pairs(verredmage) do
		profile[i] = ActionList:Get(1,e[1])
	end
end 
 
function profile.setSkillVar()
	for i,e in pairs(verredmage) do
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

profile.enchantedmelee = false
profile.enchantedmeleeaoe = 0
 
profile.revivetarget = 0 
 
function profile.Cast()
    local currentTarget = MGetTarget()
	
	profile.setVar()
	profile.revivetarget = profile.getBestRevive()
	profile["swiftcast"]["isready"] = profile["swiftcast"]:IsReady(Player.id)
	if (Player.level >= 64) and (profile.revivetarget ~= nil) and (profile.revivetarget ~= 0) then
		profile["verraise"]["revivetarget"] = {}
		profile["verraise"]["revivetarget"]["isready"] = profile["verraise"]:IsReady(profile.revivetarget.id)
	
		if profile["verraise"]["revivetarget"]["isready"] then
			if not HasBuff(Player.id,167) and profile["swiftcast"]["isready"] then
				profile["swiftcast"]:Cast(Player.id)
				return true
			end
			if HasBuff(Player.id,167) and not HasBuff(profile.revivetarget.id,148) then --148 status effect raise --167 swiftcast
				profile["verraise"]:Cast(profile.revivetarget.id)
				return true
			end
			if HasBuff(Player.id,1249) and not HasBuff(profile.revivetarget.id,148) then --1249 dual cast
				profile["verraise"]:Cast(profile.revivetarget.id)
				return true
			end			
		end
					
	end	
	if (Player.level >= 64) and (HasBuff(Player.id,167) or HasBuff(Player.id,1249)) and ((profile.revivetarget ~= nil) and (profile.revivetarget ~= 0)) and not HasBuff(profile.revivetarget.id,148) then return false end	
	if (currentTarget) then
		profile.setSkillVar()
		
		--buffs
		if Player.gauge ~= nil and (Player.gauge[2] > 50) and (Player.gauge[1] > 50) and profile.checkEach({"manafication"},false) then
			return true
		end		
		--ogcd timer
		if (TimeSince(profile.ogcdtimer) > 3000) and profile.checkEach({"fleche"},true) then
			profile.ogcdtimer = Now()
			return true
		end
		if (TimeSince(profile.ogcdtimer) > 3000) and profile.checkEach({"contresixte"},true) then
			profile.ogcdtimer = Now()
			return true
		end
		if (TimeSince(profile.ogcdtimer) > 3000) and profile.checkEach({"engagement"},true) then
			profile.ogcdtimer = Now()
			return true
		end		
		
		--melee trigger gauge >50 single or gauge > 60 aoe
		if (profile.counttarget() > 2) then
			if (Player.gaugetest ~= nil) and (Player.gaugetest[10] >= 1)  and profile.checkEach({"enchantedmoulinet"},true) then
				return true
			end
			if (Player.gauge ~= nil) and (Player.gauge[2] > 60) and (Player.gauge[1] > 60) and profile.checkEach({"enchantedmoulinet"},true) then
				return true
			end
		else
			-- if Player.lastcomboid == verredmage["zwerchhau"][1] and (Player.gauge[2] > 15) and (Player.gauge[1] > 15) and profile.checkEach({"enchantedredoublement"},true) then
				-- return true
			-- end
			-- if profile.enchantedmelee and (Player.gauge[2] > 30) and (Player.gauge[1] > 30) and profile.checkEach({"enchantedzwerchhau"},true) then
				-- profile.enchantedmelee = false
				-- return true
			-- end
			-- if Player.gauge ~= nil and (Player.gauge[2] > 50) and (Player.gauge[1] > 50) and profile.checkEach({"enchantedriposte"},true) then
				-- profile.enchantedmelee = true
				-- return true
			-- end
			if (Player.gaugetest ~= nil) and (Player.gaugetest[10] == 2) and profile.checkEach({"enchantedredoublement"},true) then
				return true
			end
			if (Player.gaugetest ~= nil) and (Player.gaugetest[10] == 1) and profile.checkEach({"enchantedzwerchhau"},true) then
				return true
			end
			if Player.gauge ~= nil and (Player.gauge[2] > 50) and (Player.gauge[1] > 50) and profile.checkEach({"enchantedriposte"},true) then
				return true
			end			
		end
		
		--after melee trigger
		if Player.gauge ~= nil and ((Player.gauge[1] > Player.gauge[2]) or (Player.gauge[1] == Player.gauge[2]))  and profile.checkEach({"verflare"},true) then
			return true
		end
		if Player.gauge ~= nil and (Player.gauge[2] > Player.gauge[1]) and profile.checkEach({"verholy"},true) then
			return true
		end		
		if profile.checkEach({"scorch"},true) then
			return true
		end
		--proc spells 
		if not HasBuff(Player.id,1249) then
			if Player.gauge ~= nil and ((Player.gauge[2] > Player.gauge[1]) or (Player.gauge[2] == Player.gauge[1])) and (not Player:IsMoving()) and profile.checkEach({"verstone"},true) then
				return true
			end
			if Player.gauge ~= nil and ((Player.gauge[1] > Player.gauge[2]) or (Player.gauge[2] == Player.gauge[1])) and (not Player:IsMoving()) and profile.checkEach({"verfire"},true) then
				return true
			end	
		end
	
	--aoe target
	
		if (profile.counttarget() > 2)  then
			if HasBuff(Player.id,1249) then		
				if profile.checkEach({"scatter","impact"},true) then
					return true
				end
			end
			if Player.gauge ~= nil and (Player.gauge[2] > Player.gauge[1]) and (not Player:IsMoving()) and profile.checkEach({"veraero2"},true) then
				return true
			end
			if Player.gauge ~= nil and ((Player.gauge[1] > Player.gauge[2]) or (Player.gauge[1] == Player.gauge[2])) and (not Player:IsMoving())  and profile.checkEach({"verthunder2"},true) then
				return true
			end
			
		end
	--single target
		--after dual cast spell
		if not (profile.counttarget() > 2) and HasBuff(Player.id,1249) then
			if Player.gauge ~= nil and (Player.gauge[2] > Player.gauge[1]) and profile.checkEach({"veraero"},true) then
				return true
			elseif Player.gauge ~= nil and (Player.gauge[2] == Player.gauge[1]) and not profile["verstone"]["isready"] and profile.checkEach({"veraero"},true) then
				return true
			end
			if Player.gauge ~= nil and ((Player.gauge[1] > Player.gauge[2]) or (Player.gauge[1] == Player.gauge[2]) ) and profile.checkEach({"verthunder"},true) then
				return true
			end
		end
		if not (profile.counttarget() > 2) and (not Player:IsMoving()) and profile.checkEach({"jolt","jolt2"},true) then	
			return true
		end
	
		return false
	end
end



function profile.Draw()
    if (profile.GUI.open) then	
	profile.GUI.visible, profile.GUI.open = GUI:Begin(profile.GUI.name, profile.GUI.open)
	if ( profile.GUI.visible ) then 
            ACR_PVERDM_Burn = GUI:Checkbox("Test",ACR_PVERDM_Burn)
			--GUI:BulletText(tostring())
			GUI:BulletText("Test ACR RDM !")
        end
        GUI:End()
    end	
end
 
function profile.OnOpen()
    profile.GUI.open = true
end
 
function profile.OnLoad()
    ACR_PVERDM_Burn = ACR.GetSetting("ACR_PVERDM_Burn",false)
end
 
function profile.OnClick(mouse,shiftState,controlState,altState,entity)
 
end
 
function profile.OnUpdate(event, tickcount)

end
 
return profile