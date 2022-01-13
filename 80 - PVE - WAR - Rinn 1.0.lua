local profile = {}

profile.GUI = {
    open = false,
    visible = true,
    name = "PVE WAR 80",
}
 
profile.classes = {
    [FFXIV.JOBS.WARRIOR] = true,
} 

--2587
varwarrior = 
	{
		heavyswing = {31,true},
		maim = {37,true},
		stormpath = {42,true},
		stormeye = {45,true},
		innerbeast = {49,true},
		overpower = {41,true},
		mythriltempest = {16462,false},
		steelcyclone = {51,false},
		

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
	for i,e in pairs(varwarrior) do
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
		
		if profile.counttarget() > 1 then
			if Player.gauge ~= nil and Player.gauge[1] >= 50 and profile.checkEach({"steelcyclone"},true)  then
				return true
			end		
		else
			if Player.gauge ~= nil and Player.gauge[1] >= 50 and profile.checkEach({"innerbeast"},true)  then
				return true
			end
		end
		
		if profile.counttarget() > 1 then
			if Player.lastcomboid == 41 and profile.checkEach({"mythriltempest"},false) then
				return true
			end		
			if profile.checkEach({"overpower"},true) then
				return true
			end		
			
		else
			if not HasBuff(Player.id,2677) and Player.lastcomboid == 37 and profile.checkEach({"stormeye"},true) then
				return true
			end
			
			if Player.lastcomboid == 37 and profile.checkEach({"stormpath"},true) then
				return true
			end		
			if Player.lastcomboid == 31 and profile.checkEach({"maim"},true) then
				return true
			end
			
			if profile.checkEach({"heavyswing"},true) then
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
            ACR_PVEWAR_Burn = GUI:Checkbox("Test",ACR_PVEWAR_Burn)
			--GUI:BulletText(tostring())
			GUI:BulletText("Test ACR WAR !")
        end
        GUI:End()
    end	
end
 
function profile.OnOpen()
    profile.GUI.open = true
end
 
function profile.OnLoad()
    ACR_PVEWAR_Burn = ACR.GetSetting("ACR_PVEWAR_Burn",false)
end
 
function profile.OnClick(mouse,shiftState,controlState,altState,entity)
 
end
 
function profile.OnUpdate(event, tickcount)

end
 
return profile