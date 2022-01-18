local profile = {}

profile.GUI = {
    open = false,
    visible = true,
    name = "PVE SAM 80 1.0",
}
 
profile.classes = {
    [FFXIV.JOBS.SAMURAI] = true,
} 

profile.samuraiBuff = 
	{
		fugetsu = 1298,
		higanbana = 1228,
		fuka = 1299,
		kaiten = 1229,
	}

profile.samuraiSkill = 
	{
		hakaze = {7477,true},
		jinpu = {7478,true},
		gekko = {7481,true},
		shifu = {7479,true},
		kasha = {7482,true},
		yukikaze = {7480,true},
		higanbana = {7489,true},
		tenkagoten = {7488,true},
		midaresetsugekka = {7487,true},
		fuga = {7483,true},
		mangetsu = {7484,false},
		oka = {7485,false},
		meditate = {7497,false},
		ikishoten = {16482,false},
		hagakure = {7495,false},
		mekyoshisui = {7499,false},
		hissatsukaiten = {7494,false},
		kaeshihiganbana = {16484,true},
		kaeshigoken = {16485,true},
		kaeshisetsugekka = {16486,true},
		--tsubamegaeshi = {16137,true},
		
		hissatsusenei = {16481,true},
		hissatsuguren = {7496,true},
		
		hissatsushinten = {7490,true},
		hissatsukyuten = {7491,false},
		shoha = {16487,true},		
	}

function profile:skillID(string)
	if profile.samuraiSkill[string] ~= nil then
		return profile.samuraiSkill[string][1]
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
	if profile.samuraiBuff[string] ~= nil then
		if HasBuff(Player.id,profile.samuraiBuff[string]) then
			return true
		end
	end
	return false
end

function profile:hasBuffOthers(string)
	if profile.samuraiBuff[string] ~= nil then
		if HasBuff(MGetTarget().id,profile.samuraiBuff[string]) then
			return true
		end
	end
	return false
end

function profile:hasBuffOthersDuration(string,duration)
	if profile.samuraiBuff[string] ~= nil then
		if HasBuff(MGetTarget().id,profile.samuraiBuff[string],0,duration) then
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
	for i,e in pairs(profile.samuraiSkill) do
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
profile.firingkenki = 0

function profile.Cast()
    local currentTarget = MGetTarget()
	if (currentTarget) then
		profile.setVar()
		if Player:IsMoving() then
			profile.safejump = Now()
		end
		--gauge[1] ==> kenki
		--gauge[2] ==> 7 all 3 sen // getsu sen => 2 // ka sen => 4 // setsu sen => 1
			--getsu + setsu + ka => 7
			--setsu + ka => 5
			--getsu + ka => 6
			--getsu + setsu => 3
			--ka => 4
			--getsu => 2
			--setsu => 1
		--gauge[3] ==> shoha
		if profile.counttarget() > 2 then
			if not profile:hasBuffSelf("kaiten") and profile["kaeshigoken"]["isready"] and  profile.checkEach({"hissatsukaiten"}) then
				return true
			end
			--tsubamegaeshi
			if profile.checkEach({"kaeshigoken"}) then
				return true
			end		
		else
			if not profile:hasBuffSelf("kaiten") and profile["kaeshisetsugekka"]["isready"] and  profile.checkEach({"hissatsukaiten"}) then
				return true
			end
			--tsubamegaeshi
			if profile.checkEach({"kaeshisetsugekka"}) then
				return true
			end
		end
		--gauge[1]  +50 
		if Player.gauge ~= nil and (Player.gauge[1] <= 50) and profile.checkEach({"ikishoten"}) then
			return true
		end
		if (not profile["kaeshisetsugekka"]["isready"]) or (not profile["kaeshigoken"]["isready"])  then
			profile.firingkenki = 35
		else
			profile.firingkenki = 45
		end
		--gauge[1] use big skill
		if (profile.counttarget() > 2) or (Player.level < 72) then
			if Player.gauge ~= nil and (Player.gauge[1] >= profile.firingkenki) and profile.checkEach({"hissatsuguren"}) then
				return true
			end		
		else
			if Player.gauge ~= nil and (Player.gauge[1] >= profile.firingkenki) and profile.checkEach({"hissatsusenei"}) then
				return true
			end
		end
		--gauge[1] use small skill		
		if (profile.counttarget() > 2) or (Player.level < 72) then
			if Player.gauge ~= nil and (Player.gauge[1] >= profile.firingkenki) and profile.checkEach({"hissatsukyuten"},"player") then
				return true
			end		
		else
			if Player.gauge ~= nil and (Player.gauge[1] >= profile.firingkenki) and profile.checkEach({"hissatsushinten"}) then
				return true
			end
		end		
		--shoha
		if Player.gauge ~= nil and (Player.gauge[3] == 3) and profile.checkEach({"shoha"}) then
			return true
		end
		--midare boost
		if profile.counttarget() > 2 then
			if not profile:hasBuffSelf("kaiten") and Player.gauge ~= nil and (Player.gauge[2] == 6) and profile.checkEach({"hissatsukaiten"}) then
				return true
			end		
		else
			if not profile:hasBuffSelf("kaiten") and Player.gauge ~= nil and (Player.gauge[2] == 7) and profile.checkEach({"hissatsukaiten"}) then
				return true
			end
		end
		--hagakure
		if profile.counttarget() > 2 then
			if Player.gauge ~= nil and (Player.gauge[2] == 7) and profile.checkEach({"hagakure"},"player") then
				return true
			end
		end
		--midaresetsugekka
		if profile.counttarget() > 2 then
			if Player.gauge ~= nil and (Player.gauge[2] == 6) and profile.checkEach({"tenkagoten"}) then
				return true
			end		
		else
			if Player.gauge ~= nil and (Player.gauge[2] == 7) and profile.checkEach({"midaresetsugekka"}) then
				return true
			end
		end
		
		--dot
		if Player.gauge ~= nil and ((Player.gauge[2] == 1) or (Player.gauge[2] == 2) or (Player.gauge[2] == 4)) and not profile:hasBuffOthers("higanbana") and profile.checkEach({"higanbana"}) then
			return true
		end
		
		--gets buffs
		if profile.counttarget() > 2 then
			if not profile:hasBuffSelf("fuka") then
				if profile:lastUsedCombo("fuga") and profile.checkEach({"oka"}) then
					return true
				end		
				if profile.checkEach({"fuga"}) then
					return true
				end		
			end
			if not profile:hasBuffSelf("fugetsu") then
				if profile:lastUsedCombo("fuga") and profile.checkEach({"mangetsu"}) then
					return true
				end		
				if profile.checkEach({"fuga"}) then
					return true
				end
			end			
		else
			if profile:lastUsedCombo("jinpu") and profile.checkEach({"gekko"}) then
				return true
			end
			if profile:lastUsedCombo("shifu") and profile.checkEach({"kasha"}) then
				return true
			end
			if Player.gauge ~= nil and (Player.gauge[2] == 6) then
				if profile:lastUsedCombo("hakaze") and profile.checkEach({"yukikaze"}) then
					return true
				end			
				if profile.checkEach({"hakaze"}) then
					return true
				end			
			end
			if not profile:hasBuffSelf("fuka") then
				if profile:lastUsedCombo("hakaze") and profile.checkEach({"shifu"}) then
					return true
				end		
				if profile.checkEach({"hakaze"}) then
					return true
				end		
			end
			if not profile:hasBuffSelf("fugetsu") then
				if profile:lastUsedCombo("hakaze") and profile.checkEach({"jinpu"}) then
					return true
				end		
				if profile.checkEach({"hakaze"}) then
					return true
				end
			end
		end
		
		--123 145 16 single combo (if has buffs) / 12 13 aoe combo (if has buffs)
		if profile.counttarget() > 2 then
			if profile:hasBuffSelf("fuka") and profile:hasBuffSelf("fugetsu") and Player.gauge ~= nil and (Player.gauge[2] == 2) then
				if profile:lastUsedCombo("fuga") and profile.checkEach({"oka"}) then
					return true
				end		
				if profile.checkEach({"fuga"}) then
					return true
				end			
			end
			if profile:hasBuffSelf("fuka") and profile:hasBuffSelf("fugetsu") and Player.gauge ~= nil and (Player.gauge[2] == 0) then
				if profile:lastUsedCombo("fuga") and profile.checkEach({"mangetsu"}) then
					return true
				end		
				if profile.checkEach({"fuga"}) then
					return true
				end	
			end		
		else
			if profile:hasBuffSelf("fuka") and profile:hasBuffSelf("fugetsu") and Player.gauge ~= nil and (Player.gauge[2] == 6) then
				if profile:lastUsedCombo("hakaze") and profile.checkEach({"yukikaze"}) then
					return true
				end			
				if profile.checkEach({"hakaze"}) then
					return true
				end			
			end
			if profile:hasBuffSelf("fuka") and profile:hasBuffSelf("fugetsu") and Player.gauge ~= nil and (Player.gauge[2] == 2) then
				if profile:lastUsedCombo("shifu") and profile.checkEach({"kasha"}) then
					return true
				end		
				if profile:lastUsedCombo("hakaze") and profile.checkEach({"shifu"}) then
					return true
				end		
				if profile.checkEach({"hakaze"}) then
					return true
				end			
			end
			if profile:hasBuffSelf("fuka") and profile:hasBuffSelf("fugetsu") and Player.gauge ~= nil and (Player.gauge[2] == 0) then
				if profile:lastUsedCombo("jinpu") and profile.checkEach({"gekko"}) then
					return true
				end
				if profile:lastUsedCombo("hakaze") and profile.checkEach({"jinpu"}) then
					return true
				end		
				if profile.checkEach({"hakaze"}) then
					return true
				end		
			end
		end
	return false
	end
end



function profile.Draw()
    if (profile.GUI.open) then	
	profile.GUI.visible, profile.GUI.open = GUI:Begin(profile.GUI.name, profile.GUI.open)
	if ( profile.GUI.visible ) then 
            ACR_PVESAM_Burn = GUI:Checkbox("Test",ACR_PVESAM_Burn)
			--GUI:BulletText(tostring())
			GUI:BulletText("Test ACR SAM !")
        end
        GUI:End()
    end	
end
 
function profile.OnOpen()
    profile.GUI.open = true
end
 
function profile.OnLoad()
    ACR_PVESAM_Burn = ACR.GetSetting("ACR_PVESAM_Burn",false)
end
 
function profile.OnClick(mouse,shiftState,controlState,altState,entity)
 
end
 
function profile.OnUpdate(event, tickcount)

end
 
return profile