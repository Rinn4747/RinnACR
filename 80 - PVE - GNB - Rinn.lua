local profile = {}

profile.GUI = {
    open = false,
    visible = true,
    name = "PVE GNB 80 1.0",
}
 
profile.classes = {
    [FFXIV.JOBS.GUNBREAKER] = true,
} 

profile.gunbreakerBuff = 
	{
		royalguard = 1833,
		sonicbreak = 1837,
		bowshock = 1838,
	}

profile.gunbreakerSkill = 
	{
		keenedge = {16137,true},
		brutalshell = {16139,true},
		solidbarrel = {16145,true},
		sonicbreak = {16153,true},
		lightningshot = {16143,true},
		roughdivide = {16154,true},
		aurora = {16151,false},
		gnashingfang = {16146,true},
		savageclaw = {16147,true},
		wickedtalon = {16150,true},
		jugularrip = {16156,true}, 
		abdomentear = {16157,true}, 
		eyegouge = {16158,true}, 
		nomercy = {16138,true},
		demonslice = {16141,false},
		demonslaughter = {16149,false},
		blastingzone = {16165,true},
		burststrike = {16162,true},
		fatedcircle = {16163,false},
		bloodfest = {16164,true},
		royalguard = {16142,false},
		bowshock = {16159,false},
		dangerzone = {16144,true},
	}

function profile:skillID(string)
	if profile.gunbreakerSkill[string] ~= nil then
		return profile.gunbreakerSkill[string][1]
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
	if profile.gunbreakerBuff[string] ~= nil then
		if HasBuff(Player.id,profile.gunbreakerBuff[string]) then
			return true
		end
	end
	return false
end

function profile:hasBuffOthers(string)
	if profile.gunbreakerBuff[string] ~= nil then
		if HasBuff(MGetTarget().id,profile.gunbreakerBuff[string]) then
			return true
		end
	end
	return false
end

function profile:hasBuffOthersDuration(string,duration)
	if profile.gunbreakerBuff[string] ~= nil then
		if HasBuff(MGetTarget().id,profile.gunbreakerBuff[string],0,duration) then
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
	for i,e in pairs(profile.gunbreakerSkill) do
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
 
profile.targetedFromAfar = false

function profile.Cast()
    local currentTarget = MGetTarget()
	if (currentTarget) then
		profile.setVar()
		if Player:IsMoving() then
			profile.safejump = Now()
		end
		
		--stance
		if not profile:hasBuffSelf("royalguard") and profile.checkEach({"royalguard"}) then
			return true	
		end
		--range
		if currentTarget.distance > 10 and profile.checkEach({"lightningshot"}) then
			profile.targetedFromAfar = true
			return true
		end
		--trying to build early enmity
		if profile.targetedFromAfar and currentTarget.distance < 5 then
			if profile.counttarget() > 1 then
				if profile:lastUsedCombo("demonslice") and profile.checkEach({"demonslaughter"}) then
					profile.targetedFromAfar = false
					return true
				end			
				if profile.checkEach({"demonslice"}) then
					return true
				end		
			else
				if profile:lastUsedCombo("brutalshell") and profile.checkEach({"solidbarrel"}) then
					profile.targetedFromAfar = false
					return true
				end	
				if profile:lastUsedCombo("keenedge") and profile.checkEach({"brutalshell"}) then
					return true
				end			
				if profile.checkEach({"keenedge"}) then
					return true
				end
			end
		end
		--proc post combo		
		if  profile.checkEach({"eyegouge","jugularrip","abdomentear"}) then
			return true
		end		
		if  profile.checkEach({"gnashingfang","savageclaw","wickedtalon"}) then
			return true
		end		
		--dot
		if profile.counttarget() > 1 then
			if not profile:hasBuffOthers("sonicbreak") and not profile:hasBuffOthers("bowshock") and profile.checkEach({"bowshock"},"player") then
				return true
			end			
			if not profile:hasBuffOthers("sonicbreak") and not profile:hasBuffOthers("bowshock") and profile.checkEach({"sonicbreak"}) then
				return true
			end	
		else
			if not profile:hasBuffOthers("sonicbreak") and not profile:hasBuffOthers("bowshock") and profile.checkEach({"sonicbreak"}) then
				return true
			end
			if not profile:hasBuffOthers("sonicbreak") and not profile:hasBuffOthers("bowshock") and profile.checkEach({"bowshock"},"player") then
				return true
			end
		end
		--buff damage+
		if profile.checkEach({"nomercy"},"player") then
			return true
		end
		--jump if close and not moved as extra dps
		if not Player:IsMoving() and profile.hasNotMovedFor(3000) and profile.waitedOGCD(3000) and currentTarget.distance < 5 then
			if profile.checkEach({"roughdivide"}) then
				profile.ogcdtimer = Now()
				return true
			end			
		end
		--ogcd dps
		if profile.waitedOGCD(3000) and profile.checkEach({"dangerzone","blastingzone"}) then
			profile.ogcdtimer = Now()
			return true
		end		
		--cartridge gauge[1]
		if Player.gauge ~= nil and Player.gauge[1] == 0 then
			if profile.checkEach({"bloodfest"}) then
				return true
			end				
		end
		if Player.gauge ~= nil and Player.gauge[1] > 0 then
			if profile.counttarget() > 1 then
				if profile.checkEach({"fatedcircle"},"player") then
					return true
				end			
			else
				if profile.checkEach({"burststrike"}) then
					return true
				end			
			end
		end
		-- 123 combo single / 12 combo aoe
		if profile.counttarget() > 1 then
			if profile:lastUsedCombo("demonslice") and profile.checkEach({"demonslaughter"}) then
				return true
			end			
			if profile.checkEach({"demonslice"}) then
				return true
			end		
		else
			if profile:lastUsedCombo("brutalshell") and profile.checkEach({"solidbarrel"}) then
				return true
			end	
			if profile:lastUsedCombo("keenedge") and profile.checkEach({"brutalshell"}) then
				return true
			end			
			if profile.checkEach({"keenedge"}) then
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
            ACR_PVEGNB_Burn = GUI:Checkbox("Test",ACR_PVEGNB_Burn)
			--GUI:BulletText(tostring())
			GUI:BulletText("Test ACR GNB !")
        end
        GUI:End()
    end	
end
 
function profile.OnOpen()
    profile.GUI.open = true
end
 
function profile.OnLoad()
    ACR_PVEGNB_Burn = ACR.GetSetting("ACR_PVEGNB_Burn",false)
end
 
function profile.OnClick(mouse,shiftState,controlState,altState,entity)
 
end
 
function profile.OnUpdate(event, tickcount)

end
 
return profile