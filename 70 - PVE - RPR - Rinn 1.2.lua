local profile = {}

profile.GUI = {
    open = false,
    visible = true,
    name = "PVE RPR 70",
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
 
function profile.Cast()
    local currentTarget = MGetTarget()
	
	if (currentTarget) then
		profile.setVar()
		
		if profile.counttarget() > 2 then
			if (Player.lastcomboid == 24377) and (TimeSince(profile.ogcdtimer) > 3000) then
				if profile["grimswathe"]["isready"] then
					profile["grimswathe"]:Cast(currentTarget.id)
					return true
				end
				profile.ogcdtimer = Now()
			end
		else
			if (Player.lastcomboid == 24375) and (TimeSince(profile.ogcdtimer) > 3000) then
				if profile["bloodstalk"]["isready"] then
					profile["bloodstalk"]:Cast(currentTarget.id)
					return true
				end
				if profile["unveiledgibbet"]["isready"] then
					profile["unveiledgibbet"]:Cast(currentTarget.id)
					return true
				end
				if profile["unveiledgallows"]["isready"] then
					profile["unveiledgallows"]:Cast(currentTarget.id)
					return true
				end
				profile.ogcdtimer = Now()
			end		
		end
		
		
		if profile.counttarget() > 2 then
			if (Player.gauge ~= nil) and (Player.gauge[1] <= 50)  then --ogcd ?
				if profile["soulscythe"]["isready"] then
					profile["soulscythe"]:Cast(Player)
					return true
				end			
			end			
		else
			if (Player.gauge ~= nil) and (Player.gauge[1] <= 50)  then --ogcd ?
				if profile["soulslice"]["isready"] then
					profile["soulslice"]:Cast(currentTarget.id)
					return true
				end			
			end
		end
		
		
		if profile.counttarget() > 2 then
			if profile["guillotine"]["isready"] and (Player.lastcomboid == 24377) and HasBuff(Player.id,2587) then
				profile["guillotine"]:Cast(currentTarget.id)
				return true
			end		
		else
			if profile["gallows"]["isready"] and (Player.lastcomboid == 24375) and HasBuff(Player.id,2587) and HasBuff(Player.id,2589) then
				profile["gallows"]:Cast(currentTarget.id)
				return true
			end		
			if profile["gibbet"]["isready"] and (Player.lastcomboid == 24375) and HasBuff(Player.id,2587) then
				profile["gibbet"]:Cast(currentTarget.id)
				return true
			end
		end
		
		if profile.counttarget() > 2 then
			if profile["nightmarescythe"]["isready"] and (Player.lastcomboid == 24376) then
				profile["nightmarescythe"]:Cast(Player)
				return true
			end
			if profile["whorlofdeath"]["isready"] and not HasBuff(currentTarget.id,2586) then
				profile["whorlofdeath"]:Cast(Player)
				return true
			end				
			if profile["spinningscythe"]["isready"]  then
				profile["spinningscythe"]:Cast(Player)
				return true
			end			
		else
			if profile["infernalslice"]["isready"] and (Player.lastcomboid == 24374) then
				profile["infernalslice"]:Cast(currentTarget.id)
				return true
			end		
			if profile["waxingslice"]["isready"] and (Player.lastcomboid == 24373) then
				profile["waxingslice"]:Cast(currentTarget.id)
				return true
			end
			if profile["shadowofdeath"]["isready"] and not HasBuff(currentTarget.id,2586) then
				profile["shadowofdeath"]:Cast(currentTarget.id)
				return true
			end		
			if profile["slice"]["isready"] then
				profile["slice"]:Cast(currentTarget.id)
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