local profile = {}

profile.GUI = {
    open = false,
    visible = true,
    name = "PVE DRK 80 1.1",
}
 
profile.classes = {
    [FFXIV.JOBS.DARKKNIGHT] = true,
} 

profile.darkknightBuff = 
	{
		grit = 743,
		blackestnight = 1178,
		delirium = 1972,
		
		
	}

profile.darkknightSkill = 
	{
	
		hardslash = {3617,true},
		syphonstrike = {3623,true},
		souleater = {3632,true},
		unmend = {3624,true},
		saltedearth = {3639,false},
		plunge = {3640,true},
		carveandsplit = {3643,true},
		abyssaldrain = {3641,true},
		edgeofdarkness = {16467,true},
		floodofdarkness = {16466,true},		
		edgeofshadow = {16470,true},
		floodofshadow = {16469,true},
		unleash = {3621,false},
		stalwartsoul = {16468,false},
		livingshadow = {16472,false},
		bloodspiller = {7392,true},
		quietus = {7391,false},
		delirium = {7390,false},
		bloodweapon = {3625,false},
		grit = {3629,true},
		blackestnight = {3629,false},
	}

function profile:skillID(string)
	if profile.darkknightSkill[string] ~= nil then
		return profile.darkknightSkill[string][1]
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
	if profile.darkknightBuff[string] ~= nil then
		if HasBuff(Player.id,profile.darkknightBuff[string]) then
			return true
		end
	end
	return false
end

function profile:hasBuffOthers(string)
	if profile.darkknightBuff[string] ~= nil then
		if HasBuff(MGetTarget().id,profile.darkknightBuff[string]) then
			return true
		end
	end
	return false
end

function profile:hasBuffOthersDuration(string,duration)
	if profile.darkknightBuff[string] ~= nil then
		if HasBuff(MGetTarget().id,profile.darkknightBuff[string],0,duration) then
			return true
		end
	end
	return false
end

profile.ogcdtimer = 0
profile.safejump = 0


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
	for i,e in pairs(profile.darkknightSkill) do
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

profile.steps = {"emboite","entrechat","jete","pirouette"}
 
function profile.Cast()
    local currentTarget = MGetTarget()
	if (currentTarget) then
		profile.setVar()
		if Player:IsMoving() then
			profile.safejump = Now()
		end
		
		--grit 
		if not profile:hasBuffSelf("grit") and profile.checkEach({"grit"}) then
			return true
		end
		--unmend
			--and (not currentTarget.aggro)
		if currentTarget.distance > 10 and profile.checkEach({"unmend"}) then
			return true
		end
		--delirium
		if currentTarget.distance < 5 and profile.checkEach({"delirium"},"player") then
			return true
		end
		--bloodweapon
		if currentTarget.distance < 5 and profile.checkEach({"bloodweapon"},"player") then
			return true
		end
		--gauge[3] == 1 free dark arts (blackestnight)
		--gauge[2] darkside
		if profile.counttarget() > 1 then
			if Player.gauge ~= nil and ((Player.gauge[2] < 3) or (Player.mp.current > 3000)) and profile.checkEach({"floodofdarkness","floodofshadow"}) then
				return true
			end		
		else
			if Player.gauge ~= nil and ((Player.gauge[2] < 3) or (Player.mp.current > 3000)) and profile.checkEach({"edgeofdarkness","edgeofshadow"}) then
				return true
			end
		end
		--gauge[1] blood gauge
		if Player.gauge ~= nil and Player.gauge[1] >= 50 and profile.checkEach({"livingshadow"},"player") then
			return true
		end
		-- if Player.mp.current > 3000 and profile.checkEach({"blackestnight"},"player") then
			-- return true
		-- end		
		if profile.counttarget() > 1 then -- ((Player.gauge[1] >= 50) or (profile:hasBuffSelf("darkarts")))
			if Player.gauge ~= nil and (Player.gauge[1] >= 50) and profile.checkEach({"quietus"},"player") then
				return true
			end
			if Player.gauge ~= nil and profile:hasBuffSelf("delirium") and profile.checkEach({"quietus"},"player") then
				return true
			end			
		else
			if Player.gauge ~= nil and (Player.gauge[1] >= 50) and profile.checkEach({"bloodspiller"}) then
				return true
			end
			if Player.gauge ~= nil and profile:hasBuffSelf("delirium") and profile.checkEach({"bloodspiller"}) then
				return true
			end				
		end				
		--jump if close and not moved as dps
		if not Player:IsMoving() and profile.hasNotMovedFor(3000) and profile.waitedOGCD(3000) and currentTarget.distance < 5 then
			if profile.checkEach({"plunge"}) then
				profile.ogcdtimer = Now()
				return true
			end			
		end
		--ogcd 
			--carveandsplit
		if profile.counttarget() > 1 then
			if profile.waitedOGCD(3000) and profile.checkEach({"abyssaldrain"}) then
				profile.ogcdtimer = Now()
				return true
			end			
		else
			if profile.waitedOGCD(3000) and profile.checkEach({"carveandsplit"}) then
				profile.ogcdtimer = Now()
				return true
			end		
		end
			--saltedearth
		if profile.waitedOGCD(3000) and profile.checkEach({"saltedearth"},"player") then
			profile.ogcdtimer = Now()
			return true
		end
		
		-- 123 combo single / 12 combo aoe
		if profile.counttarget() > 1 then
			if profile:lastUsedCombo("unleash") and profile.checkEach({"stalwartsoul"},"player") then
				return true
			end		
			if profile.checkEach({"unleash"},"player") then
				return true
			end
		else
			if profile:lastUsedCombo("syphonstrike") and  profile.checkEach({"souleater"}) then
				return true
			end	
			if profile:lastUsedCombo("hardslash") and profile.checkEach({"syphonstrike"}) then
				return true
			end	
			if profile.checkEach({"hardslash"}) then
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
            ACR_PVEDRK_Burn = GUI:Checkbox("Test",ACR_PVEDRK_Burn)
			--GUI:BulletText(tostring())
			GUI:BulletText("Test ACR DRK !")
        end
        GUI:End()
    end	
end
 
function profile.OnOpen()
    profile.GUI.open = true
end
 
function profile.OnLoad()
    ACR_PVEDRK_Burn = ACR.GetSetting("ACR_PVEDRK_Burn",false)
end
 
function profile.OnClick(mouse,shiftState,controlState,altState,entity)
 
end
 
function profile.OnUpdate(event, tickcount)

end
 
return profile