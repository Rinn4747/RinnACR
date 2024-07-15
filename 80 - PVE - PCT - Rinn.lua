profilepct = {}

if not ACR_PVEPCT_Single then
	ACR_PVEPCT_Single = false
end

profilepct.GUI = {
    open = false,
    visible = true,
    name = "PVE PCT 1.5",
}
 
profilepct.classes = {
    [FFXIV.JOBS.PICTOMANCER] = true,
} 

varpictomancer = 
	{ 
		fireinred = {34650, true},
		aeroingreen = {34651, true},
		waterinblue = {34652, true},
		blizzardincyan = {34653, true},
		stoneinyellow = {34654, true},
		thunderinmagenta = {34655, true},
		fire2inred = {34656, true},
		aero2ingreen = {34657, true},
		water2inblue = {34658, true},
		blizzard2incyan = {34659, true},
		stone2inyellow = {34660, true},
		thunder2inmagenta = {34661, true},		
		
		holyinwhite = {34662, true},
		pommotif = {34664, false},
		wingmotif = {34665, false},
		hammermotif = {34668, false},
		starryskymotif = {34669, false},
		
		pommuse = {34670, true},
		wingedmuse = {34671, true},
		strikingmuse = {34674, false},
		starrymuse = {34675, false},
		mogoftheages = {34676, true},
		hammerstamp = {34678, true},
		substractivepalette = {34683, false},
	}
	
profilepct.substractivepalette = 3674
profilepct.hammertime = 3680
profilepct.ogcdtimer = 0
profilepct.checkissue = 0


function profilepct.getBestRevive()
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

function profilepct.counttarget(targetid)
	local targets = MEntityList("alive,attackable,targetable,maxdistance=5,distanceto="..tostring(targetid))
	return (table.size(targets))
end	

function profilepct.setVar()
	for i,e in pairs(varpictomancer) do
		profilepct[i] = ActionList:Get(1,e[1])
	end
end 
 
function profilepct.setSkillVar()
	for i,e in pairs(varpictomancer) do
		--profilepct[i] = ActionList:Get(1,e[1])
		if profilepct[i] then
			if e[2] then
				profilepct[i]["isready"] = profilepct[i]:IsReady(MGetTarget().id)
			else
				profilepct[i]["isready"] = profilepct[i]:IsReady(Player)
			end
		end
	end
end

function profilepct.checkEach(tbl,bool)
	for _,e in pairs(tbl) do
		if bool then
			if profilepct[tostring(e)]["isready"] then
				d("[RinnACR] Casting "..tostring(e))
				profilepct.checkissue = Now()
				profilepct[tostring(e)]:Cast(MGetTarget().id)
				return true
			end
		elseif not bool then
			if profilepct[tostring(e)]["isready"] then
				d("[RinnACR] Casting "..tostring(e))
				profilepct.checkissue = Now()
				profilepct[tostring(e)]:Cast(Player)
				return true
			end
		end
	end
	return false
end 
 
profilepct.revivetarget = 0 
 
function profilepct.Cast()
    local currentTarget = MGetTarget()
	local g = Player.gauge
	profilepct.setVar()
	
	if (not Player:IsMoving()) and (currentTarget) then
		profilepct.setSkillVar()
		
		if Player.level >= 50 and HasBuff(Player.id,3680) then
			if profilepct.checkEach({"hammerstamp"},true) then
				return true
			end				
		end
		
		if Player.level >= 30 then
			if profilepct.checkEach({"mogoftheages"},true) then
				return true
			end				
		
			if profilepct.checkEach({"pommuse","wingedmuse"},true) then
				return true
			end		
		
			if profilepct.checkEach({"pommotif","wingmotif"},false) then
				return true
			end		
		end
		
		if Player.level >= 50 and not HasBuff(Player.id,3680) then
			if profilepct.checkEach({"strikingmuse"},false) then
				return true
			end			
			if profilepct.checkEach({"hammermotif"},false) then
				return true
			end		
		end		
		
		if Player.level >= 70 then
			if profilepct["starrymuse"].isready then
			--if profilepct.checkEach({"starrymuse"},false) then
				profilepct["starrymuse"]:Cast(Player.id)
				return true
			end		
			if profilepct.checkEach({"starryskymotif"},false) then
				return true
			end		
		
		end			
		
		if HasBuff(Player.id,3674) then
			if profilepct.counttarget(currentTarget.id) > 2 then
				if profilepct.checkEach({"thunder2inmagenta","stone2inyellow","blizzard2incyan"},true) then
					return true
				end
			else
				if profilepct.checkEach({"thunderinmagenta","stoneinyellow","blizzardincyan"},true) then
					return true
				end		
			end
		end
		
		if not HasBuff(Player.id,3674) and profilepct.checkEach({"substractivepalette"},false) then
			return true
		end
		
		if profilepct.checkEach({"holyinwhite"},true) then
			return true
		end
		
		if profilepct.counttarget(currentTarget.id) > 2 then
			if profilepct.checkEach({"water2inblue","aero2ingreen","fire2inred"},true) then
				return true
			end
		else
			if profilepct.checkEach({"waterinblue","aeroingreen","fireinred"},true) then
				return true
			end		
		end
		return false
	end
end



function profilepct.Draw()
    if (profilepct.GUI.open) then	
	profilepct.GUI.visible, profilepct.GUI.open = GUI:Begin(profilepct.GUI.name, profilepct.GUI.open)
	if ( profilepct.GUI.visible ) then 
			ACR_PVEPCT_Single = GUI:Checkbox("ACR Single",ACR_PVEPCT_Single)
			--GUI:BulletText(tostring())
			GUI:BulletText("ACR Single Toggle !")
        end
        GUI:End()
    end	
end
 
function profilepct.OnOpen()
    profilepct.GUI.open = true
end
 
function profilepct.OnLoad()
    ACR_PVEPCT_Burn = ACR.GetSetting("ACR_PVEPCT_Burn",false)
end
 
function profilepct.OnClick(mouse,shiftState,controlState,altState,entity)
 
end
 
function profilepct.OnUpdate(event, tickcount)

end
 
return profilepct
