local profilevpr = {}

profilevpr.GUI = {
    open = false,
    visible = true,
    name = "PVE VPR 80 1.1",
}
 
profilevpr.classes = {
    [FFXIV.JOBS.VIPER] = true,
} 



profilevpr.viperBuff = 
	{

		noxiousgash = 3667,
		hunterinstinct = 3668,
		swiftscaled = 3669,
		
		flankstungvenom = 3645,
		flanksbanevenom = 3646,
		hindstungvenom = 3647,
		hindsbanevenom = 3648,
		
		grimhuntervenom = 3649,
		grimskinvenom = 3650,
		
		--aoe
		fellhuntervenom = 3659,
		fellskinvenom = 3660,
		
		--123
		huntervenom = 3657,
		swiftskinvenom = 3658,
		
		
	}
profilevpr.viperSkill = 
	{
		steelfangs = {34606, true},
		dreadfangs = {34607, true},
		huntersting = {34608, true},
		swiftskinsting = {34609, true},
		flankstingstrike = {34610, true},
		flanksbanefang = {34611, true},
		hindstingstrike = {34612, true},
		hindsbanefang = {34613, true},
		steelmaw = {34614, false},
		dreadmaw = {34615, false},
		hunterbite = {34616, false},
		swiftskinbite = {34617, false},
		jaggedmaw = {34618, false},
		bloodiedmaw = {34619, false},
		
		dreadwinder = {34620, true},
		huntercoil = {34621, true},
		swiftskincoil = {34622, true},
		pitofdread = {34623, false},
		hunterden = {34624, false},
		swiftskinden = {34625, false},
		
		writhingsnap = {34632, true},
		deathrattle = {34634, true},
		lastlash = {34635, false},
		twinfangbite = {34636, true},
		twinbloodbite = {34637, true},
		twinfangthresh = {34638, false},
		twinbloodthresh = {34639, false},
		slither = {34646, true},
		
		serpenttail = {35920, true},
		twinfang = {35921, true},
		twinblood = {35922, true},
		
	}
	
function profilevpr:skillID(string)
	if profilevpr.viperSkill[string] ~= nil then
		return profilevpr.viperSkill[string][1]
	end
end

function profilevpr:lastUsedCombo(string)
	if profilevpr:skillID(string) ~= nil then
		if Player.lastcomboid == profilevpr:skillID(string) then
			return true
		end
	end
	return false
end


function profilevpr:hasBuffSelf(string)
	if profilevpr.viperBuff[string] ~= nil then
		if HasBuff(Player.id,profilevpr.viperBuff[string]) then
			return true
		end
	end
	return false
end

function profilevpr:hasBothBuff()
	if HasBuff(Player.id,profilevpr.viperBuff["swiftscaled"]) and HasBuff(Player.id,profilevpr.viperBuff["hunterinstinct"]) then
		return true
	end
	return false
end

profilevpr.ogcdtimer = 0
profilevpr.safejump = 0

function profilevpr.counttarget()
	local counter = 0
	local targets = MEntityList("alive,attackable,targetable,maxdistance=5")
	if targets ~= nil then
		for i,e in pairs(targets) do 
			counter = counter + 1 
		end
	end
	return counter
end

function profilevpr.counttargetfrom(targetid)
	local targets = MEntityList("alive,attackable,targetable,maxdistance=5,distanceto="..tostring(targetid))
	return (table.size(targets))
end	


function profilevpr.hasNotMovedFor(number)
	if TimeSince(profilevpr.safejump) > number then
		return true
	end
	return false
end

function profilevpr.waitedOGCD(number)
	if TimeSince(profilevpr.ogcdtimer) > number then
		return true
	end
	return false
end
 
function profilevpr.setVar()
	for i,e in pairs(profilevpr.viperSkill) do
		profilevpr[i] = ActionList:Get(1,e[1])
		if profilevpr[i] then
			if e[2] then
				profilevpr[i]["isready"] = profilevpr[i]:IsReady(MGetTarget().id)
			else
				profilevpr[i]["isready"] = profilevpr[i]:IsReady(Player)
			end
		end
	end
end 

function profilevpr.checkEach(tbl,string)
	local bool = (string == nil)
	for _,e in pairs(tbl) do
		if bool then
			if profilevpr[tostring(e)]["isready"] then
				profilevpr[tostring(e)]:Cast(MGetTarget().id)
				return true
			end
		elseif not bool then
			if profilevpr[tostring(e)]["isready"] then
				profilevpr[tostring(e)]:Cast(Player)
				return true
			end
		end
	end
	return false
end
 
function profilevpr.Cast()
    local currentTarget = MGetTarget()
	if (currentTarget) and currentTarget.attackable then
		profilevpr.setVar()
		--[[
		flankstungvenom = 3645,
		flanksbanevenom = 3646,
		hindstungvenom = 3647,
		hindsbanevenom = 3648,		
		
		aoe
		fellhuntervenom 3659
		fellskinvenom 3660
		
		123
		huntervenom 3657
		swiftskinvenom 3658
		]]--
		
		if profilevpr.checkEach({"deathrattle","lastlash"}) then
			return true
		end			
		
		if Player.level > 25 and profilevpr.counttargetfrom(currentTarget.id) > 2 and currentTarget.distance < 8 then
		
		--grimhuntervenom > jaggedmaw
		--grimskinvenom > bloodiedmaw
		
		
		-- has buff fellhuntervenom > twinfangthresh
		-- has buff fellskinvenom > twinbloodthresh
		
			if profilevpr:hasBuffSelf("fellhuntervenom") then
				if profilevpr.checkEach({"twinfangthresh"}) then
					return true
				end				
			end
			
		
			if profilevpr:hasBuffSelf("fellskinvenom") then
				if profilevpr.checkEach({"twinbloodthresh"}) then
					return true
				end					
			end			
		
		
			if not profilevpr:hasBuffSelf("fellhuntervenom") and not profilevpr:hasBuffSelf("fellskinvenom") then
				if profilevpr.checkEach({"swiftskinden","hunterden","pitofdread"}) then
					return true
				end	
				-- if profilevpr.checkEach({"pitofdread"}) then
					-- return true
				-- end					
			end
			
			if profilevpr:hasBuffSelf("fellhuntervenom") or profilevpr:hasBuffSelf("fellskinvenom") then
				return false
			end
			
			
	
		
			if not profilevpr:hasBuffSelf("grimhuntervenom") and not profilevpr:hasBuffSelf("grimskinvenom") then
				if profilevpr.checkEach({"jaggedmaw","hunterbite"}) then
					return true
				end				
			end
		
			if profilevpr:hasBuffSelf("grimhuntervenom") and profilevpr:hasBothBuff() then
				if profilevpr.checkEach({"swiftskinbite","jaggedmaw"}) then
					return true
				end				
			end	
			
			if profilevpr:hasBuffSelf("grimskinvenom") and profilevpr:hasBothBuff() then
				if profilevpr.checkEach({"hunterbite","bloodiedmaw"}) then
					return true
				end				
			end				

		
			if (profilevpr:lastUsedCombo("dreadmaw") or profilevpr:lastUsedCombo("steelmaw")) then
			 if not profilevpr:hasBuffSelf("hunterinstinct") and profilevpr.checkEach({"hunterbite"}) then
				return true
			 elseif profilevpr:hasBuffSelf("hunterinstinct") and not profilevpr:hasBuffSelf("swiftscaled") and profilevpr.checkEach({"swiftskinbite"}) then
				return true
			 end
			end		
			
		
			if Player.level >= 35 and not HasBuff(currentTarget.id,profilevpr.viperBuff["noxiousgash"]) and profilevpr.checkEach({"dreadmaw"}) then
				return true
			else
				if profilevpr.checkEach({"steelmaw"}) then return true end
			end		
		
		else

				-- if profilevpr.checkEach({"huntersting","flankstingstrike"}) then
					-- return true
				-- end			
				
			-- 123
			-- huntervenom 3657
			-- swiftskinvenom 3658				
			
			if profilevpr:hasBuffSelf("huntervenom") then
				if profilevpr.checkEach({"twinfangbite"}) then
					return true
				end				
			end
			
		
			if profilevpr:hasBuffSelf("swiftskinvenom") then
				if profilevpr.checkEach({"twinbloodbite"}) then
					return true
				end					
			end			
		
		
			if not profilevpr:hasBuffSelf("huntervenom") and not profilevpr:hasBuffSelf("swiftskinvenom") then
				if profilevpr.checkEach({"swiftskincoil","huntercoil","dreadwinder"}) then
					return true
				end	
				-- if profilevpr.checkEach({"pitofdread"}) then
					-- return true
				-- end					
			end
			
			if profilevpr:hasBuffSelf("huntervenom") or profilevpr:hasBuffSelf("swiftskinvenom") then
				return false
			end			
			
				
	
			if profilevpr:hasBuffSelf("hindsbanevenom") and profilevpr:hasBothBuff() then
				if profilevpr.checkEach({"swiftskinsting","hindsbanefang"}) then
					return true
				end				
			end		
			
			
			if profilevpr:hasBuffSelf("flankstungvenom") and profilevpr:hasBothBuff() then --ok checked
				if profilevpr.checkEach({"huntersting","flankstingstrike"}) then
					return true
				end				
			end
			
			if profilevpr:hasBuffSelf("flanksbanevenom") and profilevpr:hasBothBuff() then --okchecked
				if profilevpr.checkEach({"huntersting","flanksbanefang"}) then
					return true
				end				
			end		
			
			if profilevpr:hasBuffSelf("hindstungvenom") and profilevpr:hasBothBuff() then
				--if (profilevpr:lastUsedCombo("dreadfangs") or profilevpr:lastUsedCombo("steelfangs")) then
					if profilevpr.checkEach({"swiftskinsting","hindstingstrike"}) then
						return true
					end				
				--end
			end
			if profilevpr:hasBothBuff() and not profilevpr:hasBuffSelf("flankstungvenom") and not profilevpr:hasBuffSelf("flanksbanevenom") and not profilevpr:hasBuffSelf("hindstungvenom") and not profilevpr:hasBuffSelf("hindsbanevenom") then
				if (profilevpr:lastUsedCombo("dreadfangs") or profilevpr:lastUsedCombo("steelfangs")) then
					if profilevpr.checkEach({"huntersting"}) then return true end
				end
			end
			
			if not profilevpr:hasBuffSelf("flankstungvenom") and not profilevpr:hasBuffSelf("flanksbanevenom") and not profilevpr:hasBuffSelf("hindstungvenom") and not profilevpr:hasBuffSelf("hindsbanevenom") then
				if profilevpr.checkEach({"hindstingstrike","hindsbanefang","flankstingstrike","flanksbanefang"}) then
					return true
				end
			end
			
			
			if (profilevpr:lastUsedCombo("dreadfangs") or profilevpr:lastUsedCombo("steelfangs")) then
			 if not profilevpr:hasBuffSelf("hunterinstinct") and profilevpr.checkEach({"huntersting"}) then
				return true
			 elseif profilevpr:hasBuffSelf("hunterinstinct") and not profilevpr:hasBuffSelf("swiftscaled") and profilevpr.checkEach({"swiftskinsting"}) then
				return true
			 end
			end
		
			
			
			if Player.level >= 10 and not HasBuff(currentTarget.id,profilevpr.viperBuff["noxiousgash"]) and profilevpr.checkEach({"dreadfangs"}) then
				return true
			else
				if profilevpr.checkEach({"steelfangs"}) then return true end
			end
			
			if Player.level >= 15 and profilevpr.checkEach({"writhingsnap"}) then
				return true 
			end
		end
	
	return false
	end
end



function profilevpr.Draw()
    if (profilevpr.GUI.open) then	
	profilevpr.GUI.visible, profilevpr.GUI.open = GUI:Begin(profilevpr.GUI.name, profilevpr.GUI.open)
	if ( profilevpr.GUI.visible ) then 
            ACR_PVEVPR_Burn = GUI:Checkbox("Test",ACR_PVEVPR_Burn)
			--GUI:BulletText(tostring())
			GUI:BulletText("Test ACR VPR !")
        end
        GUI:End()
    end	
end
 
function profilevpr.OnOpen()
    profilevpr.GUI.open = true
end
 
function profilevpr.OnLoad()
    ACR_PVEVPR_Burn = ACR.GetSetting("ACR_PVEVPR_Burn",false)
end
 
function profilevpr.OnClick(mouse,shiftState,controlState,altState,entity)
 
end
 
function profilevpr.OnUpdate(event, tickcount)

end
 
return profilevpr
