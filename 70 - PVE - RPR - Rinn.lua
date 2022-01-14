local profile = {}

profile.GUI = {
    open = false,
    visible = true,
    name = "PVE RPR 70 Orig 1.2",
}
 
profile.classes = {
    [FFXIV.JOBS.REAPER] = true,
} 

--2587
varreaper = 
	{
		slice = {24373,true},
		waxingslice = {24374,true},
		infernalslice = {24375,true},
		bloodstalk = {24389,true},
		unveiledgibbet = {24390,true},
		unveiledgallows = {24391,true},
		gibbet = {24382,true},
		gallows = {24383,true},
		soulslice = {24380,true},
		shadowofdeath = {24378,true},
		spinningscythe = {24376,false},
		nightmarescythe = {24377,false},	
		grimswathe = {24392,true},
		guillotine  = {24384,true},
		soulscythe  = {24381,false},
		whorlofdeath  = {24379,false},

	}

profile.ogcdtimer = 0
profile.usedgibbet = false

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
	for i,e in pairs(varreaper) do
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
	
	if (currentTarget) then
		profile.setVar()
		
		
		
		--gcd 30sec recast  +50 gauge
		if profile.counttarget() > 2 then
			if (Player.gauge ~= nil) and (Player.gauge[1] <= 50) and profile.checkEach({"soulscythe"},true) then 
				return true
			end			
		else
			if (Player.gauge ~= nil) and (Player.gauge[1] <= 50) and profile.checkEach({"soulslice"},true) then 
				return true
			end
		end
		

		--ogcd gauge skills
		if profile.counttarget() > 2 then
			if (Player.lastcomboid == 24377) and (TimeSince(profile.ogcdtimer) > 3000) and profile.checkEach({"grimswathe"},true) then
				profile.ogcdtimer = Now()
				return true
			end
		else
			if (Player.lastcomboid == 24375) and (TimeSince(profile.ogcdtimer) > 3000) and  profile.checkEach({"bloodstalk","unveiledgibbet","unveiledgallows"},true) then
				profile.ogcdtimer = Now()
				return true
			end		
		end			

		
		
		--procs gcd after gauge skill
		if profile.counttarget() > 2 then
			if (Player.lastcomboid == 24377) and HasBuff(Player.id,2587) and profile.checkEach({"guillotine"},true) then
				return true
			end		
		else
			if (Player.lastcomboid == 24375) and HasBuff(Player.id,2587) and HasBuff(Player.id,2589) and profile.checkEach({"gallows"},true) then
				return true
			end		
			if (Player.lastcomboid == 24375) and HasBuff(Player.id,2587) and profile.checkEach({"gibbet"},true) then
				return true
			end
		end
			
		
		--123 combo // 12 aoe combo
		if profile.counttarget() > 2 then
			if (Player.lastcomboid == 24376) and profile.checkEach({"nightmarescythe"},false) then
				return true
			end
			if not HasBuff(currentTarget.id,2586) and profile.checkEach({"whorlofdeath"},false) then
				return true
			end				
			if profile.checkEach({"spinningscythe"},false)  then
				return true
			end			
		else
			if (Player.lastcomboid == 24374) and profile.checkEach({"infernalslice"},true) then
				return true
			end		
			if (Player.lastcomboid == 24373) and profile.checkEach({"waxingslice"},true) then
				return true
			end
			if not HasBuff(currentTarget.id,2586) and profile.checkEach({"shadowofdeath"},true) then
				return true
			end		
			if profile.checkEach({"slice"},true) then
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
            ACR_PVERPR_Burn = GUI:Checkbox("Test",ACR_PVERPR_Burn)
			--GUI:BulletText(tostring())
			GUI:BulletText("Test ACR RPR !")
        end
        GUI:End()
    end	
end
 
function profile.OnOpen()
    profile.GUI.open = true
end
 
function profile.OnLoad()
    ACR_PVERPR_Burn = ACR.GetSetting("ACR_PVERPR_Burn",false)
end
 
function profile.OnClick(mouse,shiftState,controlState,altState,entity)
 
end
 
function profile.OnUpdate(event, tickcount)

end
 
return profile