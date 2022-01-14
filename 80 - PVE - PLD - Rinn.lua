local profile = {}

profile.GUI = {
    open = false,
    visible = true,
    name = "PVE PLD 80 1.2",
}
 
profile.classes = {
	[FFXIV.JOBS.PALADIN] = true,
	[FFXIV.JOBS.GLADIATOR] = true,
} 

--2587
varpaladin = 
	{
		fastblade = {9,true},
		riotblade = {15,true},
		rageofhalone = {21,true},
		royalauthority = {3539,true},
		goringblade= {3538,true},
		atonement= {16460,true},
		totaleclipse = {7381,false},
		prominence = {16457,false},
		sheltron = {3542,false},
		shieldbash = {16,true},
		ironwill = {28,false},
		requiescat = {7383,true},
		holyspirit = {7384,true},
		holycircle = {16458,false},
		confiteor = {16459,true},
		fightorflight = {20,false},
		spiritswithin = {29,true},
		shieldlob = {24,true},
		circleofscorn = {23,false},
		--shield bash 16
		--shield lob 24
		--total eclipse 7381
		--spiritswithin 29
		--iron will 28
		--fightorflight 20
		--rampart 7531

	}

stunlist = {}
stuntimer = 0
profile.ogcdtimer = 0

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
	for i,e in pairs(varpaladin) do
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
 
function profile.Cast()
    local currentTarget = MGetTarget()
	-- if currentTarget and stunlist[currentTarget.id] == nil then
		-- stunlist[currentTarget.id] = 0
	-- elseif currentTarget and stunlist[currentTarget.id] ~= nil then
		-- d(stunlist[currentTarget.id])
	-- end
	if (currentTarget) then
		profile.setVar()
		--def stance
		if not HasBuff(Player.id,79) and profile.checkEach({"ironwill"},false) then
			return true
		end
		--range 18y
		if (currentTarget.distance > 10) and profile.checkEach({"shieldlob"},true) then
			return true
		end		
		
		--buffs defensive
		
		--buffs offensive
		if (currentTarget.distance < 5) and profile.checkEach({"fightorflight"},false) then
			return true
		end
		
		--ogcd defensive
		if not HasBuff(Player.id,1856) and Player.gauge ~= nil and Player.gauge[1] >= 50 and  profile.checkEach({"sheltron"},false) then
			return true
		end
		
		--ogcd offensive
		if (TimeSince(profile.ogcdtimer) > 3000) and  profile.checkEach({"spiritswithin"},true) then
			profile.ogcdtimer = Now()
			return true
		end
		if (TimeSince(profile.ogcdtimer) > 3000) and (currentTarget.distance < 5) and profile.checkEach({"circleofscorn"},false) then
			profile.ogcdtimer = Now()
			return true
		end				
		
		--caster part
		if not HasBuff(Player.id,1368) and Player.mp["percent"] == 100 and profile.checkEach({"requiescat"},true) then
			return true
		end
		
		--d(profile.counttarget() > 1)
		if profile.counttarget() > 1 then
			if HasBuff(Player.id,1368,2) and profile.checkEach({"holycircle"},false) then
				return true
			end
		else
			if HasBuff(Player.id,1368,2) and profile.checkEach({"holyspirit"},true) then
				return true
			end
		end
		
		if HasBuff(Player.id,1368,1) and profile.checkEach({"confiteor"},true) then
			return true
		end
		
		--gcd
		if HasBuff(Player.id,1902) and  profile.checkEach({"atonement"},true) then
			return true
		end

		--123 124 single / 12 aoe
		if profile.counttarget() > 1 then
			if (Player.lastcomboid == 7381) and profile.checkEach({"prominence"},false) then
				return true
			end		
			if profile.checkEach({"totaleclipse"},false) then
				return true
			end			
		else
			if not HasBuff(currentTarget.id,725) and (Player.lastcomboid == 15) and profile.checkEach({"goringblade"},true) then
				return true
			end	
			
			if (Player.lastcomboid == 15) and profile.checkEach({"rageofhalone","royalauthority"},true) then
				return true
			end		
			
			if (Player.lastcomboid == 9) and profile.checkEach({"riotblade"},true) then
				return true
			end
			
			-- if not HasBuff(currentTarget.id,2) and stunlist[currentTarget.id] < 3 and (TimeSince(stuntimer) > 2000) and profile.checkEach({"shieldbash"},true) then
				-- stunlist[currentTarget.id] = stunlist[currentTarget.id] + 1
				-- stuntimer = Now()
				-- return true
			-- end			
			
			if profile.checkEach({"fastblade"},true) then
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
            ACR_PVEPLD_Burn = GUI:Checkbox("Test",ACR_PVEPLD_Burn)
			--GUI:BulletText(tostring())
			GUI:BulletText("Test ACR PLD !")
        end
        GUI:End()
    end	
end
 
function profile.OnOpen()
    profile.GUI.open = true
end
 
function profile.OnLoad()
    ACR_PVEPLD_Burn = ACR.GetSetting("ACR_PVEPLD_Burn",false)
end
 
function profile.OnClick(mouse,shiftState,controlState,altState,entity)
 
end
 
function profile.OnUpdate(event, tickcount)

end
 
return profile