-- v1.60 --
--I do not restrict or even encourage players to modify and customize lua that meets their own usage habits according to their own needs.
--I even added comments to some code to explain what this is used for and the positioning identification of related global in the decompiled script.
--[[
Use agreement：
Allow：
Personal use
Personal use after modification
Secondary distribution after modification

forbidden:
Commercial
After the modification, the secondary distribution still uses the name containing sch

There is no guarantee (I can only guarantee that there is no subjective malice when writing, and I am not responsible for all kinds of unintended consequences)

Please also make sure to download the file published by the official discord user yeahsch (sch) through the assistant. Any other method may be a malicious script.
Github : https://github.com/sch-lda/SCH-LUA-YIMMENU

External links
Yimmenu lib by Discord@alice2333 https://discord.com/channels/388227343862464513/1124473215436214372 Ability to provide support to developers
YimMenu-HeistLua https://github.com/wangzixuank/YimMenu-HeistLua A Yim open source task script

The Globals and Locals used in Lua are widely copied from the UnknownCheats forum, the Heist Control script, and the MusinessBanager script. Although Blue-Flag Lua is a bit outdated, it also provides some inspiration.
Alice, wangzixuan, and nord123 in the official Discord of the little assistant provided help with the writing of Lua

Websites that may be helpful for lua writing
1.Yimmenu Lua API https://github.com/YimMenu/YimMenu/tree/master/docs/lua
2.GTA5 Native Reference (native Function) https://nativedb .spyral.dev
3.GTA5 decompile script https://github.com/Primexz/GTAV-Decompiled-Scripts
4.PlebMaster (quick search model Hash) https://forge.plebmasters.de
5.gta-v-data-dumps (check ptfx/sound/model) https://github.com/DurtyFree/gta-v-data-dumps
5.FiveM Native Reference https://docs.fivem.net/docs/
]]

---------------------------------------------------------------------------------------functions Functions for lua to call to implement specific functions
local luaversion = "v1.60"
path = package.path
if path:match("YimMenu") then
    log.info("sch-lua "..luaversion.." For personal testing and learning use only, commercial use is prohibited")
else
    local_()
end

local gentab = gui.add_tab("sch-lua-Alpha-"..luaversion)

function calcDistance(pos, tarpos) -- Calculate the distance between two 3D coordinates
    local dx = pos.x - tarpos.x
    local dy = pos.y - tarpos.y
    local dz = pos.z - tarpos.z
    local distance = math.sqrt(dx*dx + dy*dy + dz*dz)
    return distance
end

function upgrade_vehicle(vehicle)
    for i = 0, 49 do
        local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
        VEHICLE.SET_VEHICLE_MOD(vehicle, i, num - 1, true)
    end
end

function run_script(name) --start script thread
    script.run_in_fiber(function (runscript)
        SCRIPT.REQUEST_SCRIPT(name)  
        repeat runscript:yield() until SCRIPT.HAS_SCRIPT_LOADED(name)
        SYSTEM.START_NEW_SCRIPT(name, 5000)
        SCRIPT.SET_SCRIPT_AS_NO_LONGER_NEEDED(name)
    end)
end

function DELETE_OBJECT_BY_HASH(hash)
    for _, ent in pairs(entities.get_all_objects_as_handles()) do
        if ENTITY.GET_ENTITY_MODEL(ent) == hash then
            PED.SET_PED_COORDS_KEEP_VEHICLE(ent, 0, 0, 0)
        end
    end
end

function screen_draw_text(text, x, y, p0 , size) --draw text on screen
	HUD.BEGIN_TEXT_COMMAND_DISPLAY_TEXT("STRING") --The following were found in the decompiled script files: STRING, TWOSTRINGS, NUMBER, PERCENTAGE, FO_TWO_NUM, ESMINDOLLA, ESDOLLA, MTPHPER_XPNO, AHD_DIST, CMOD_STAT_0, CMOD_STAT_1, CMOD_STAT_2, CMOD_STAT_3, DFLT_MNU_OPT, F3A_TRAFDEST, ES_HELP_SOC3
	HUD.SET_TEXT_FONT(0)
	HUD.SET_TEXT_SCALE(p0, size) --Size range : 0F to 1.0F --p0 is unknown and doesn't seem to have an effect, yet in the game scripts it changes to 1.0F sometimes.
	HUD.SET_TEXT_DROP_SHADOW()
	HUD.SET_TEXT_WRAP(0.0, 1.0) --Limit the line width, beyond the automatic line wrap start - left boundry on screen position (0.0 - 1.0)  end - right boundry on screen position (0.0 - 1.0)
	HUD.SET_TEXT_DROPSHADOW(1, 0, 0, 0, 0) --distance - shadow distance in pixels, both horizontal and vertical    -- r, g, b, a - color
	HUD.SET_TEXT_OUTLINE()
	HUD.SET_TEXT_EDGE(1, 0, 0, 0, 0)
	HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(text)
	HUD.END_TEXT_COMMAND_DISPLAY_TEXT(x, y) --proportion of the axis
end

function StatGetInt(stathash)
    statvalue = STATS.STAT_GET_INT(stathash, statvalue, -1) 
    return statvalue
end

--[[  
Not used yet
function attach_to_player(hash, bone, x, y, z, xrot, yrot, zrot)     --attach entity to itself
    local user_ped = PLAYER.PLAYER_PED_ID()
    hash = joaat(hash)

    STREAMING.REQUEST_MODEL(hash)
    while not STREAMING.HAS_MODEL_LOADED(hash) do		
        script_util:yield()
    end
    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)

    local object = OBJECT.CREATE_OBJECT(hash, 0.0,0.0,0, true, true, false)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(object, user_ped, PED.GET_PED_BONE_INDEX(PLAYER.PLAYER_PED_ID(), bone), x, y, z, xrot, yrot, zrot, false, false, false, false, 2, true) 

end
]]

function CreatePed(index, Hash, Pos, Heading)
    script.run_in_fiber(function (ctped)

    STREAMING.REQUEST_MODEL(Hash)
    while not STREAMING.HAS_MODEL_LOADED(Hash) do ctped:yield() end
    local Spawnedp = PED.CREATE_PED(index, Hash, Pos.x, Pos.y, Pos.z, Heading, true, true)
    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(Hash)
    return Spawnedp
    end)
end

function CreateObject(Hash, Pos, static)
    script.run_in_fiber(function (ctobjC)
        STREAMING.REQUEST_MODEL(Hash)
        while not STREAMING.HAS_MODEL_LOADED(Hash) do ctobjC:yield() end
        local SpawnedObjs = create_object(Hash, Pos)
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(Hash)
        if static then
            ENTITY.FREEZE_ENTITY_POSITION(SpawnedObjs, true)
        end
        return SpawnedObjs
    end)
end

function create_object(hash, pos)
    script.run_in_fiber(function (ctobjS)
        STREAMING.REQUEST_MODEL(hash)
        while not STREAMING.HAS_MODEL_LOADED(hash) do ctobjS:yield() end
        local obj = OBJECT.CREATE_OBJECT(hash, pos.x, pos.y, pos.z, true, false, false)
        return obj
    end)
end

function request_model(hash)
    script.run_in_fiber(function (rqmd)
        STREAMING.REQUEST_MODEL(hash)
        while not STREAMING.HAS_MODEL_LOADED(hash) do
            rqmd:yield()
        end
        return STREAMING.HAS_MODEL_LOADED(hash)
    end)
end

function Create_Network_Ped(pedType, modelHash, x, y, z, heading)
    request_model(modelHash)
    local ped = PED.CREATE_PED(pedType, modelHash, x, y, z, heading, true, true)

    ENTITY.SET_ENTITY_LOAD_COLLISION_FLAG(ped, true)
    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(ped, true, false)
    ENTITY.SET_ENTITY_SHOULD_FREEZE_WAITING_ON_COLLISION(ped, true)

    NETWORK.NETWORK_REGISTER_ENTITY_AS_NETWORKED(ped)
    local net_id = NETWORK.PED_TO_NET(ped)
    NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(net_id, true)
    NETWORK.SET_NETWORK_ID_CAN_MIGRATE(net_id, true)
    for _, pid in pairs(players.list()) do
        NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(net_id, pid, true)
    end

    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(modelHash)
    return ped
end

function CreateVehicle(Hash, Pos, Heading, Invincible)
    script.run_in_fiber(function (ctveh)
        STREAMING.REQUEST_MODEL(Hash)
        while not STREAMING.HAS_MODEL_LOADED(Hash) do ctveh:yield() end
        local SpawnedVehicle = VEHICLE.CREATE_VEHICLE(Hash, Pos.x,Pos.y,Pos.z, Heading , true, true, true)
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(Hash)
        if Invincible then
            ENTITY.SET_ENTITY_INVINCIBLE(SpawnedVehicle, true)
        end
        return SpawnedVehicle
    end)
end

--------------------------------------------------------------------------------------- functions A function called by lua to realize a specific function

--------------------------------------------------------------------------------------- MPx Read role 1 or role 2, removed due to instability

--[[
gentab:add_button("测试6", function()
    local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), false)
    local targpos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
    distance = calcDistance(pos,targpos)
    formattedDistance = string.format("%.1f", distance)
    log.info(formattedDistance)
end)
]]

--------------------------------------------------------------------------------------- MPx Read role 1 or role 2, removed due to instability

--------------------------------------------------------------------------------------- Lua manager page

gentab:add_text("To use the player function, please select a player in the yim player list and scroll to the bottom of the player page") 

gentab:add_text("task function") 

gentab:add_button("Complete the final chapter of Perico with one click", function()
    script.run_in_fiber(function (pericoinstcpl)
        local FMMC2020host = NETWORK.NETWORK_GET_HOST_OF_SCRIPT("fm_mission_controller_2020",0,0)
        while not PLAYER.PLAYER_ID() == FMMC2020host do   --If it is judged that it is not a script host, it will automatically grab the script host
            network.force_script_host("fm_mission_controller_2020") --抢脚本主机
            pericoinstcpl:yield()
        end
        locals.set_int("fm_mission_controller_2020",45451,51338752)  --关键代码    
        locals.set_int("fm_mission_controller_2020",46829,50) --关键代码
    end)
end)

gentab:add_sameline()

gentab:add_button("Configure the front of Pei Island (cheetah statue)", function()
    local playerid = globals.get_int(1574918) --疑似与MPPLY_LAST_MP_CHAR相等  --用于判断当前是角色1还是角色2
    local mpx = "MP0_"--用于判断当前是角色1还是角色2
    if playerid == 1 then --用于判断当前是角色1还是角色2
        mpx = "MP1_" --用于判断当前是角色1还是角色2
    end
    STATS.STAT_SET_INT(joaat(mpx.."H4CNF_TARGET"), 5, true)  --https://beholdmystuff.github.io/perico-stattext-maker/ 生成的stat们
    STATS.STAT_SET_INT(joaat(mpx.."H4CNF_BS_GEN"), 131071, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4CNF_BS_ENTR"), 63, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4CNF_APPROACH"), -1, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4CNF_WEAPONS"), 1, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4CNF_WEP_DISRP"), 3, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4CNF_ARM_DISRP"), 3, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4CNF_HEL_DISRP"), 3, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4LOOT_GOLD_C"), 255, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4LOOT_GOLD_C_SCOPED"), 255, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4LOOT_PAINT_SCOPED"), 127, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4LOOT_PAINT"), 127, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4LOOT_GOLD_V"), 585151, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4LOOT_PAINT_V"), 438863, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4_PROGRESS"), 124271, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4_MISSIONS"), 65279, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4LOOT_COKE_I_SCOPED"), 16777215, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4LOOT_COKE_I"), 16777215, true)
    locals.set_int("heist_island_planning", 1526, 2) --刷新面板
end)

gentab:add_sameline()

gentab:add_button("Configuration Pei island front (pink diamond)", function()
    local playerid = globals.get_int(1574918) --疑似与MPPLY_LAST_MP_CHAR相等
    local mpx = "MP0_"
    if playerid == 1 then 
        mpx = "MP1_" 
    end
    STATS.STAT_SET_INT(joaat(mpx.."H4CNF_TARGET"), 3, true) --https://beholdmystuff.github.io/perico-stattext-maker/ 生成的stat们
    STATS.STAT_SET_INT(joaat(mpx.."H4CNF_BS_GEN"), 131071, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4CNF_BS_ENTR"), 63, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4CNF_APPROACH"), -1, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4CNF_WEAPONS"), 1, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4CNF_WEP_DISRP"), 3, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4CNF_ARM_DISRP"), 3, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4CNF_HEL_DISRP"), 3, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4LOOT_GOLD_C"), 255, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4LOOT_GOLD_C_SCOPED"), 255, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4LOOT_PAINT_SCOPED"), 127, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4LOOT_PAINT"), 127, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4LOOT_GOLD_V"), 585151, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4LOOT_PAINT_V"), 438863, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4_PROGRESS"), 124271, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4_MISSIONS"), 65279, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4LOOT_COKE_I_SCOPED"), 16777215, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4LOOT_COKE_I"), 16777215, true)
    locals.set_int("heist_island_planning", 1526, 2)
end)

gentab:add_sameline()

gentab:add_button("Reset Pey Island", function()
    local playerid = globals.get_int(1574918) --疑似与MPPLY_LAST_MP_CHAR相等
    local mpx = "MP0_"
    if playerid == 1 then 
        mpx = "MP1_" 
    end
    STATS.STAT_SET_INT(joaat(mpx.."H4CNF_TARGET"), 0, true)--https://beholdmystuff.github.io/perico-stattext-maker/ 生成的stat们
    STATS.STAT_SET_INT(joaat(mpx.."H4CNF_BS_GEN"), 0, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4CNF_BS_ENTR"), 0, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4CNF_APPROACH"), 0, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4CNF_WEAPONS"), 0, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4CNF_WEP_DISRP"), 0, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4CNF_ARM_DISRP"), 0, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4CNF_HEL_DISRP"), 0, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4LOOT_GOLD_C"), 0, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4LOOT_GOLD_C_SCOPED"), 0, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4LOOT_PAINT_SCOPED"), 0, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4LOOT_PAINT"), 0, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4LOOT_GOLD_V"), 0, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4LOOT_PAINT_V"), 0, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4_PROGRESS"), 0, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4_MISSIONS"), 0, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4LOOT_COKE_I_SCOPED"), 0, true)
    STATS.STAT_SET_INT(joaat(mpx.."H4LOOT_COKE_I"), 0, true)
    locals.set_int("heist_island_planning", 1526, 2)
    gui.show_message("Notice", "The planning panel will be restored to the state just bought Orca!")
end)

gentab:add_button("Configure Casino Front (Diamond)", function()
    local playerid = globals.get_int(1574918) --疑似与MPPLY_LAST_MP_CHAR相等
    local mpx = "MP0_"
    if playerid == 1 then 
        mpx = "MP1_" 
    end
    STATS.STAT_SET_INT(joaat(mpx.."H3OPT_APPROACH"), 2, true)--https://beholdmystuff.github.io/perico-stattext-maker/ 生成的stat们
    STATS.STAT_SET_INT(joaat(mpx.."H3_LAST_APPROACH"), 3, true)
    STATS.STAT_SET_INT(joaat(mpx.."H3OPT_TARGET"), 3, true) --主目标:钻石
    STATS.STAT_SET_INT(joaat(mpx.."H3OPT_BITSET1"), 159, true)
    STATS.STAT_SET_INT(joaat(mpx.."H3OPT_KEYLEVELS"), 2, true)
    STATS.STAT_SET_INT(joaat(mpx.."H3OPT_DISRUPTSHIP"), 3, true)
    STATS.STAT_SET_INT(joaat(mpx.."H3OPT_CREWWEAP"), 1, true)
    STATS.STAT_SET_INT(joaat(mpx.."H3OPT_CREWDRIVER"), 1, true)
    STATS.STAT_SET_INT(joaat(mpx.."H3OPT_CREWHACKER"), 5, true)
    STATS.STAT_SET_INT(joaat(mpx.."H3OPT_VEHS"), 0, true)
    STATS.STAT_SET_INT(joaat(mpx.."H3OPT_WEAPS"), 0, true)
    STATS.STAT_SET_INT(joaat(mpx.."H3OPT_BITSET0"),443351, true)
    STATS.STAT_SET_INT(joaat(mpx.."H3OPT_MASKS"), 12, true)
    STATS.STAT_SET_INT(joaat(mpx.."H3_COMPLETEDPOSIX"), -1, true)
    STATS.STAT_SET_INT(joaat(mpx.."CAS_HEIST_FLOW"), -1, true)
    STATS.STAT_SET_INT(joaat(mpx.."H3OPT_POI"), 1023, true)
    STATS.STAT_SET_INT(joaat(mpx.."H3OPT_ACCESSPOINTS"), 2047, true)
end)

gentab:add_sameline()

gentab:add_button("Configure Casino Front (Gold)", function()
    local playerid = globals.get_int(1574918) --疑似与MPPLY_LAST_MP_CHAR相等
    local mpx = "MP0_"
    if playerid == 1 then 
        mpx = "MP1_" 
    end
    STATS.STAT_SET_INT(joaat(mpx.."H3OPT_APPROACH"), 2, true)--https://beholdmystuff.github.io/perico-stattext-maker/ 生成的stat们
    STATS.STAT_SET_INT(joaat(mpx.."H3_LAST_APPROACH"), 3, true)
    STATS.STAT_SET_INT(joaat(mpx.."H3OPT_TARGET"), 1, true) --主目标: 黄金
    STATS.STAT_SET_INT(joaat(mpx.."H3OPT_BITSET1"), 159, true)
    STATS.STAT_SET_INT(joaat(mpx.."H3OPT_KEYLEVELS"), 2, true)
    STATS.STAT_SET_INT(joaat(mpx.."H3OPT_DISRUPTSHIP"), 3, true)
    STATS.STAT_SET_INT(joaat(mpx.."H3OPT_CREWWEAP"), 1, true)
    STATS.STAT_SET_INT(joaat(mpx.."H3OPT_CREWDRIVER"), 1, true)
    STATS.STAT_SET_INT(joaat(mpx.."H3OPT_CREWHACKER"), 5, true)
    STATS.STAT_SET_INT(joaat(mpx.."H3OPT_VEHS"), 0, true)
    STATS.STAT_SET_INT(joaat(mpx.."H3OPT_WEAPS"), 0, true)
    STATS.STAT_SET_INT(joaat(mpx.."H3OPT_BITSET0"),443351, true)
    STATS.STAT_SET_INT(joaat(mpx.."H3OPT_MASKS"), 12, true)
    STATS.STAT_SET_INT(joaat(mpx.."H3_COMPLETEDPOSIX"), -1, true)
    STATS.STAT_SET_INT(joaat(mpx.."CAS_HEIST_FLOW"), -1, true)
    STATS.STAT_SET_INT(joaat(mpx.."H3OPT_POI"), 1023, true)
    STATS.STAT_SET_INT(joaat(mpx.."H3OPT_ACCESSPOINTS"), 2047, true)
end)

gentab:add_sameline()

gentab:add_button("Reset casino plan panel", function()
    local playerid = globals.get_int(1574918) --疑似与MPPLY_LAST_MP_CHAR相等
    local mpx = "MP0_"
    if playerid == 1 then 
        mpx = "MP1_" 
    end
    STATS.STAT_SET_INT(joaat(mpx.."H3OPT_APPROACH"), 0, true)
    STATS.STAT_SET_INT(joaat(mpx.."H3_LAST_APPROACH"), 0, true)
    STATS.STAT_SET_INT(joaat(mpx.."H3OPT_TARGET"), 0, true)
    STATS.STAT_SET_INT(joaat(mpx.."H3OPT_BITSET1"), 0, true)
    STATS.STAT_SET_INT(joaat(mpx.."H3OPT_KEYLEVELS"), 0, true)
    STATS.STAT_SET_INT(joaat(mpx.."H3OPT_DISRUPTSHIP"), 0, true)
    STATS.STAT_SET_INT(joaat(mpx.."H3OPT_BITSET0"),0, true)
    STATS.STAT_SET_INT(joaat(mpx.."H3OPT_MASKS"), 0, true)
    STATS.STAT_SET_INT(joaat(mpx.."H3_COMPLETEDPOSIX"), 0, true)
    STATS.STAT_SET_INT(joaat(mpx.."CAS_HEIST_FLOW"), 0, true)
    STATS.STAT_SET_INT(joaat(mpx.."H3OPT_POI"), 0, true)
    STATS.STAT_SET_INT(joaat(mpx.."H3OPT_ACCESSPOINTS"), 0, true)
end)


gentab:add_button("Switch CEO/Leader", function()
    local playerIndex = globals.get_int(1574918) --疑似与MPPLY_LAST_MP_CHAR相等
    --playerOrganizationTypeRaw: {('Global_1895156[PLAYER::PLAYER_ID() /*609*/].f_10.f_429', '1')}  GLOBAL  
    --playerOrganizationType: {('1895156', '*609', '10', '429', '1')}  GLOBAL  global + (pid *pidmultiplier) + offset + offset + offset (values: 0 = CEO and 1 = MOTORCYCLE CLUB) 
    if globals.get_int(1895156+playerIndex*609+10+429+1) == 0 then --1895156+playerIndex*609+10+429+1 = 0 为CEO =1为摩托帮首领
        globals.set_int(1895156+playerIndex*609+10+429+1,1)
        gui.show_message("prompt","Converted to Biker Gang Leader")
    else
        if globals.get_int(1895156+playerIndex*609+10+429+1) == 1 then
            globals.set_int(1895156+playerIndex*609+10+429+1,0)
            gui.show_message("prompt","Converted to CEO")
        else
            gui.show_message("you are not the boss","You are neither CEO nor chief")
        end
    end
end)

gentab:add_sameline()

gentab:add_button("Show office computer", function()
    local playerIndex = globals.get_int(1574918) --疑似与MPPLY_LAST_MP_CHAR相等
    if globals.get_int(1895156+playerIndex*609+10+429+1) == 0 then
        run_script("appfixersecurity")
    else
        if globals.get_int(1895156+playerIndex*609+10+429+1) == 1 then
            globals.set_int(1895156+playerIndex*609+10+429+1,0)
            gui.show_message("prompt","Converted to CEO")
            run_script("appfixersecurity")
            else
            gui.show_message("Don't forget to register as CEO/Leader","It may also be a script detection error, known problem, no feedback required")
            run_script("appfixersecurity")
        end
    end
end)

gentab:add_sameline()

gentab:add_button("show bunker computer", function()
    local playerIndex = globals.get_int(1574918) --疑似与MPPLY_LAST_MP_CHAR相等
    if globals.get_int(1895156+playerIndex*609+10+429+1) == 0 then
        run_script("appbunkerbusiness")
    else
        if globals.get_int(1895156+playerIndex*609+10+429+1) == 1 then
            run_script("appbunkerbusiness")
            else
                gui.show_message("Don't forget to register as CEO/Leader","It may also be a script detection error, known problem, no feedback required")
                run_script("appbunkerbusiness")
            end
    end
end)

gentab:add_sameline()

gentab:add_button("show hangar computer", function()
    local playerIndex = globals.get_int(1574918) --疑似与MPPLY_LAST_MP_CHAR相等
    if globals.get_int(1895156+playerIndex*609+10+429+1) == 0 then
        run_script("appsmuggler")
    else
        if globals.get_int(1895156+playerIndex*609+10+429+1) == 1 then
            run_script("appsmuggler")
            else
                gui.show_message("Don't forget to register as CEO/Leader","It may also be a script detection error, known problem, no feedback required")
                run_script("appsmuggler")
            end
    end
end)

gentab:add_sameline()

gentab:add_button("Display game hall industry master control computer", function()
    local playerIndex = globals.get_int(1574918) --疑似与MPPLY_LAST_MP_CHAR相等
    if globals.get_int(1895156+playerIndex*609+10+429+1) == 0 then
        run_script("apparcadebusinesshub")
    else
        if globals.get_int(1895156+playerIndex*609+10+429+1) == 1 then
            run_script("apparcadebusinesshub")
        else
                gui.show_message("Don't forget to register as CEO/Leader","It may also be a script detection error, known problem, no feedback required")
                run_script("apparcadebusinesshub")
        end
    end
end)

gentab:add_sameline()

gentab:add_button("Show the Terrorist Dashboard", function()
    local playerIndex = globals.get_int(1574918) --疑似与MPPLY_LAST_MP_CHAR相等
    if globals.get_int(1895156+playerIndex*609+10+429+1) == 0 then
        run_script("apphackertruck")
    else
        if globals.get_int(1895156+playerIndex*609+10+429+1) == 1 then
            run_script("apphackertruck")
        else
            gui.show_message("Don't forget to register as CEO/Leader","It may also be a script detection error, known problem, no feedback required")
            run_script("apphackertruck")
        end
    end
end)

gentab:add_sameline()

gentab:add_separator()

gentab:add_button("Show Avengers panel", function()
    local playerIndex = globals.get_int(1574918) --疑似与MPPLY_LAST_MP_CHAR相等
    if globals.get_int(1895156+playerIndex*609+10+429+1) == 0 then
        run_script("appAvengerOperations")
    else
        if globals.get_int(1895156+playerIndex*609+10+429+1) == 1 then
            run_script("appAvengerOperations")
        else
            gui.show_message("Don't forget to register as CEO/Leader","It may also be a script detection error, known problem, no feedback required")
            run_script("appAvengerOperations")
        end
    end
end)

gentab:add_separator()
gentab:add_text("Entertainment function (low stability, full of bugs)(After the particle effect reaches the memory limit, it will not be able to continue to be generated.") --不解释，我自己也搞不明白
gentab:add_text(" Please enable and disable the function of cleaning PTFX water column and fire column at the bottom of this page)")

gentab:add_button("light fireworks", function()
    script.run_in_fiber(function (firew)
        
    local animlib = 'anim@mp_fireworks'
    local ptfx_asset = "scr_indep_fireworks"
    local anim_name = 'place_firework_3_box'
    local effect_name = "scr_indep_firework_trailburst"

    STREAMING.REQUEST_ANIM_DICT(animlib)

    local pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 0.52, 0.0)
    local ped = PLAYER.PLAYER_PED_ID()

    ENTITY.FREEZE_ENTITY_POSITION(ped, true)
    TASK.TASK_PLAY_ANIM(ped, animlib, anim_name, -1, -8.0, 3000, 0, 0, false, false, false)

    firew:sleep(1500)

    STREAMING.REQUEST_MODEL(3176209716)
    while not STREAMING.HAS_MODEL_LOADED(3176209716) do firew:yield() end

    local firework_box = OBJECT.CREATE_OBJECT(3176209716, pos.x, pos.y, pos.z, true, false, false)
    local firework_box_pos = ENTITY.GET_ENTITY_COORDS(firework_box)

    OBJECT.PLACE_OBJECT_ON_GROUND_PROPERLY(firework_box)
    ENTITY.FREEZE_ENTITY_POSITION(ped, false)

    firew:sleep(1000)

    ENTITY.FREEZE_ENTITY_POSITION(firework_box, true)
    STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_indep_fireworks")

    while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_indep_fireworks") do firew:yield() end

    GRAPHICS.USE_PARTICLE_FX_ASSET("scr_indep_fireworks")
    GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_indep_firework_trailburst", firework_box_pos.x, firework_box_pos.y, firework_box_pos.z + 1, 0, 0, 0, 10.0, true, true, true)

    GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_ON_ENTITY("scr_indep_firework_trailburst",firework_box, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0, 0, 0)

    firew:sleep(1500)
    GRAPHICS.USE_PARTICLE_FX_ASSET("scr_indep_fireworks")
    GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_ON_ENTITY("scr_indep_firework_trailburst",firework_box, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0, 0, 0)

    firew:sleep(1500)
    GRAPHICS.USE_PARTICLE_FX_ASSET("scr_indep_fireworks")
    GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_ON_ENTITY("scr_indep_firework_trailburst",firework_box, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0, 0, 0)

    firew:sleep(1500)
    GRAPHICS.USE_PARTICLE_FX_ASSET("scr_indep_fireworks")
    GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_ON_ENTITY("scr_indep_firework_trailburst",firework_box, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0, 0, 0)

    firew:sleep(1500)
    GRAPHICS.USE_PARTICLE_FX_ASSET("scr_indep_fireworks")
    GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_ON_ENTITY("scr_indep_firework_trailburst",firework_box, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0, 0, 0)

    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(firework_box, true, true)
    ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(firework_box)
    ENTITY.DELETE_ENTITY(firework_box)

    end)
end)

gentab:add_sameline()

gentab:add_button("broomstick", function()
    script.run_in_fiber(function (mk2ac1)
        local pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 0.52, 0.0)
        local broomstick = joaat("prop_tool_broom")
        local oppressor = joaat("oppressor2")
        while not STREAMING.HAS_MODEL_LOADED(broomstick) do		
            STREAMING.REQUEST_MODEL(broomstick)
            mk2ac1:yield()
        end
        while not STREAMING.HAS_MODEL_LOADED(oppressor) do	
            STREAMING.REQUEST_MODEL(oppressor)	
            mk2ac1:yield()
        end
        obj = OBJECT.CREATE_OBJECT(broomstick, pos.x,pos.y,pos.z, true, false, false)
        veh = VEHICLE.CREATE_VEHICLE(oppressor, pos.x,pos.y,pos.z, 0 , true, true, true)
        ENTITY.SET_ENTITY_VISIBLE(veh, false, false)
        PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), veh, -1)
        ENTITY.ATTACH_ENTITY_TO_ENTITY(obj, veh, 0, 0, 0, 0.3, -80.0, 0, 0, true, false, false, false, 0, true) 
    end)
end)

gentab:add_sameline()

local objectsix1 --注册为全局变量以便后续remove666
local objectsix2--注册为全局变量以便后续remove666
local objectsix3--注册为全局变量以便后续remove666
local object5201 --注册为全局变量以便后续remove520
local object5202--注册为全局变量以便后续remove520
local object5203--注册为全局变量以便后续remove520

local check666 = gentab:add_checkbox("Head666") --这只是一个复选框,代码往最后的循环脚本部分找

gentab:add_sameline()

local check520 = gentab:add_checkbox("Overhead 520") --这只是一个复选框,代码往最后的循环脚本部分找

gentab:add_sameline()

local check6 = gentab:add_checkbox("swim mode") --这只是一个复选框,代码往最后的循环脚本部分找

gentab:add_sameline()

local checkfirebreath = gentab:add_checkbox("fire breathing")--这只是一个复选框,代码往最后的循环脚本部分找

gentab:add_sameline()

local firemt = gentab:add_checkbox("Ghost Rider") --这只是一个复选框,代码往最后的循环脚本部分找


bigfireWings = {
    [1] = {pos = {[1] = 120, [2] =  75}},
    [2] = {pos = {[1] = 120, [2] = -75}},
    [3] = {pos = {[1] = 135, [2] =  75}},
    [4] = {pos = {[1] = 135, [2] = -75}},
    [5] = {pos = {[1] = 180, [2] =  75}},
    [6] = {pos = {[1] = 180, [2] = -75}},
    [7] = {pos = {[1] = 190, [2] =  75}},
    [8] = {pos = {[1] = 190, [2] = -75}},
    [9] = {pos = {[1] = 130, [2] =  75}},
    [10] = {pos = {[1] = 130, [2] = -75}},
    [11] = {pos = {[1] = 140, [2] =  75}},
    [12] = {pos = {[1] = 140, [2] = -75}},
    [13] = {pos = {[1] = 150, [2] =  75}},
    [14] = {pos = {[1] = 150, [2] = -75}},
    [15] = {pos = {[1] = 210, [2] =  75}},
    [16] = {pos = {[1] = 210, [2] = -75}},
    [17] = {pos = {[1] = 195, [2] =  75}},
    [18] = {pos = {[1] = 195, [2] = -75}},
    [19] = {pos = {[1] = 160, [2] =  75}},
    [20] = {pos = {[1] = 160, [2] = -75}},
    [21] = {pos = {[1] = 170, [2] =  75}},
    [22] = {pos = {[1] = 170, [2] = -75}},
    [23] = {pos = {[1] = 200, [2] =  75}},
    [24] = {pos = {[1] = 200, [2] = -75}},
}

gentab:add_sameline()

local checkfirew = gentab:add_checkbox("flame wings")

gentab:add_separator()

gentab:add_text("entity control") 

local vehforcefield = gentab:add_checkbox("Vehicle force field") --只是一个开关，代码往后面找

gentab:add_sameline()

local pedforcefield = gentab:add_checkbox("NPC force field") --只是一个开关，代码往后面找

gentab:add_sameline()

local forcefield = gentab:add_checkbox("Force field (vehicle + NPC)") --只是一个开关，代码往后面找

gentab:add_sameline()

local objforcefield = gentab:add_checkbox("Object force field") --只是一个开关，代码往后面找

gentab:add_sameline()

local vehboost = gentab:add_checkbox("Simple vehicle acceleration controlled by Shift key (test)") --只是一个开关，代码往后面找

gentab:add_text("Vehicle Batch Control") 

gentab:add_sameline()

local vehengdmg = gentab:add_checkbox("vehicle flameout") --只是一个开关，代码往后面找

gentab:add_sameline()

local vehfixr = gentab:add_checkbox("vehicle repair") --只是一个开关，代码往后面找

gentab:add_sameline()

local vehstopr = gentab:add_checkbox("vehicle stop") --只是一个开关，代码往后面找

gentab:add_sameline()

local vehjmpr = gentab:add_checkbox("vehicle jump") --只是一个开关，代码往后面找

gentab:add_sameline()

local vehdoorlk4p = gentab:add_checkbox("Lock the door for all players") --只是一个开关，代码往后面找

gentab:add_sameline()

local vehbr = gentab:add_checkbox("chaos mode") --只是一个开关，代码往后面找

gentab:add_text("NPC batch control") 

gentab:add_sameline()

local reactany = gentab:add_checkbox("interrupt a") --只是一个开关，代码往后面找

gentab:add_sameline()

local react1any = gentab:add_checkbox("fall a") --只是一个开关，代码往后面找

gentab:add_sameline()

local react2any = gentab:add_checkbox("kill a") --只是一个开关，代码往后面找

gentab:add_sameline()

local react3any = gentab:add_checkbox("burn a") --只是一个开关，代码往后面找

gentab:add_sameline()

local react4any = gentab:add_checkbox("take off a") --只是一个开关，代码往后面找

gentab:add_sameline()

local react5any = gentab:add_checkbox("Accepted as bodyguard a (unstable)") --只是一个开关，代码往后面找

gentab:add_sameline()

local revitalizationped = gentab:add_checkbox("resurrection (unstable)") --只是一个开关，代码往后面找

gentab:add_sameline()

local rmdied = gentab:add_checkbox("remove the body") --只是一个开关，代码往后面找

gentab:add_text("Hostile NPC batch control") 

gentab:add_sameline()

local reactanyac = gentab:add_checkbox("interrupt a1") --只是一个开关，代码往后面找

gentab:add_sameline()

local react1anyac = gentab:add_checkbox("fall a1") --只是一个开关，代码往后面找

gentab:add_sameline()

local react2anyac = gentab:add_checkbox("kill a1") --只是一个开关，代码往后面找

gentab:add_sameline()

local react3anyac = gentab:add_checkbox("burn a1") --只是一个开关，代码往后面找

gentab:add_sameline()

local react4anyac = gentab:add_checkbox("take off a1") --只是一个开关，代码往后面找

gentab:add_sameline()

local react5anyac = gentab:add_checkbox("Accepted as a bodyguard a1 (unstable)") --只是一个开关，代码往后面找

gentab:add_text("Being targeted by an NPC to automatically counterattack") 

gentab:add_sameline()

local aimreact = gentab:add_checkbox("interrupt b") --只是一个开关，代码往后面找

gentab:add_sameline()

local aimreact1 = gentab:add_checkbox("fall down b") --只是一个开关，代码往后面找

gentab:add_sameline()

local aimreact2 = gentab:add_checkbox("kill b") --只是一个开关，代码往后面找

gentab:add_sameline()

local aimreact3 = gentab:add_checkbox("burn b") --只是一个开关，代码往后面找

gentab:add_sameline()

local aimreact4 = gentab:add_checkbox("take off b") --只是一个开关，代码往后面找

gentab:add_sameline()

local aimreact5 = gentab:add_checkbox("accepted as a bodyguard b") --只是一个开关，代码往后面找

gentab:add_sameline()

local aimreact6 = gentab:add_checkbox("remove b") --只是一个开关，代码往后面找

gentab:add_text("NPC targets anyone and automatically counterattacks") 

gentab:add_sameline()

local aimreactany = gentab:add_checkbox("interrupt c") --只是一个开关，代码往后面找

gentab:add_sameline()

local aimreact1any = gentab:add_checkbox("fall c") --只是一个开关，代码往后面找

gentab:add_sameline()

local aimreact2any = gentab:add_checkbox("kill c") --只是一个开关，代码往后面找

gentab:add_sameline()

local aimreact3any = gentab:add_checkbox("burn c") --只是一个开关，代码往后面找

gentab:add_sameline()

local aimreact4any = gentab:add_checkbox("take off c") --只是一个开关，代码往后面找

gentab:add_sameline()

local aimreact5any = gentab:add_checkbox("received as a bodyguard c") --只是一个开关，代码往后面找

gentab:add_sameline()

local aimreact6any = gentab:add_checkbox("remove c") --只是一个开关，代码往后面找

local delallcam = gentab:add_checkbox("remove all cameras") --只是一个开关，代码往后面找

CamList = {   --从heist control抄的
    joaat("prop_cctv_cam_01a"),
    joaat("prop_cctv_cam_01b"),
    joaat("prop_cctv_cam_02a"),
    joaat("prop_cctv_cam_03a"),
    joaat("prop_cctv_cam_04a"),
    joaat("prop_cctv_cam_04c"),
    joaat("prop_cctv_cam_05a"),
    joaat("prop_cctv_cam_06a"),
    joaat("prop_cctv_cam_07a"),
    joaat("prop_cs_cctv"),
    joaat("p_cctv_s"),
    joaat("hei_prop_bank_cctv_01"),
    joaat("hei_prop_bank_cctv_02"),
    joaat("ch_prop_ch_cctv_cam_02a"),
    joaat("xm_prop_x17_server_farm_cctv_01"),
}

gentab:add_sameline()

gentab:add_button("Removed Perico hoplites", function()
    for _, ent in pairs(entities.get_all_peds_as_handles()) do
        if ENTITY.GET_ENTITY_MODEL(ent) == 193469166 then
            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(ent,true,true) --不执行这个下面会删除失败
            ENTITY.DELETE_ENTITY(ent)
        end
    end
end)

gentab:add_separator()

gentab:add_text("Industry function - medium and high risk") 

gentab:add_button("One-click completion of CEO warehouse shipments", function()
    locals.set_int("gb_contraband_sell","542","99999")
end)

gentab:add_sameline()

gentab:add_button("Motorcycle shipments can be completed with one click (unstable)", function()
    locals.set_int("gb_biker_contraband_sell","821","30")
end)

gentab:add_sameline()

gentab:add_button("One-click delivery of hallucinogens", function()
    locals.set_int("fm_content_acid_lab_sell",6596,9)
    locals.set_int("fm_content_acid_lab_sell",6597,10)
    locals.set_int("fm_content_acid_lab_sell",6530,2)
end)

local bkeasyms = gentab:add_checkbox("The motorcycle gang shipped only one truck")

gentab:add_sameline()

gentab:add_button("One-click completion of bunker shipment", function()
    gui.show_message("Autoship","It may show that the task failed, but you should get the money!")
    locals.set_int("gb_gunrunning","1980","0") --bunkerAutoComplete: {('1206', '774')}  LOCAL gb_gunrunning set to 0 to autocomplete 
    gui.show_message("Autoship","It may show that the task failed, but you should get the money!")
end)

gentab:add_sameline()

gentab:add_button("One-click completion of hangar (air freight) shipment", function()
    gui.show_message("Autoship","It may show that the task failed, but you should get the money!")
    local integer = locals.get_int("gb_smuggler", "3007")
    locals.set_int("gb_smuggler","2964",integer)
    gui.show_message("Autoship","It may show that the task failed, but you should get the money!")
end)

gentab:add_button("The motorcycle industry is full of raw materials", function()
    globals.set_int(1648657+1+1,1) --可卡因 --freemode.c  	if (func_12737(148, "OR_PSUP_DEL" /*Hey, the supplies you purchased have arrived at the ~a~. Remember, paying for them eats into profits!*/, &unk, false, -99, 0, 0, false, 0))
    globals.set_int(1648657+1+2,1) --冰毒
    globals.set_int(1648657+1+3,1) --大麻
    globals.set_int(1648657+1+4,1) --证件
    globals.set_int(1648657+1+0,1) --假钞
    gui.show_message("auto replenishment","Completed")
end)

gentab:add_sameline()

gentab:add_button("The bunker is full of raw materials", function()
    globals.set_int(1648657+1+5,1) --bunker
    gui.show_message("auto replenishment","Completed")
end)

gentab:add_sameline()

gentab:add_button("CEO warehouse staff purchase once", function()
    local playerid = globals.get_int(1574918) --疑似与MPPLY_LAST_MP_CHAR相等

    STATS.SET_PACKED_STAT_BOOL_CODE(32359,1,playerid)
    STATS.SET_PACKED_STAT_BOOL_CODE(32360,1,playerid)
    STATS.SET_PACKED_STAT_BOOL_CODE(32361,1,playerid)
    STATS.SET_PACKED_STAT_BOOL_CODE(32362,1,playerid)
    STATS.SET_PACKED_STAT_BOOL_CODE(32363,1,playerid)
end)

gentab:add_sameline()

gentab:add_button("Hangar staff restock once", function()
    local playerid = globals.get_int(1574918) --疑似与MPPLY_LAST_MP_CHAR相等

    STATS.SET_PACKED_STAT_BOOL_CODE(36828,1,playerid)
end)

local checkCEOcargo = gentab:add_checkbox("The single purchase quantity of locked warehouse staff")

gentab:add_sameline()

local inputCEOcargo = gentab:add_input_int("crates")

local check4 = gentab:add_checkbox("Lock hangar staff single purchase quantity is")

gentab:add_sameline()

local iputint3 = gentab:add_input_int("box")

gentab:add_button("Nightclub safe 300,000 cycles 10 times", function()
    script.run_in_fiber(function (ncsafeloop)
        local playerid = globals.get_int(1574918) --疑似与MPPLY_LAST_MP_CHAR相等
        local mpx = "MP0_"
        if playerid == 1 then 
            mpx = "MP1_" 
        end
        a2 =0
        while a2 < 10 do --循环次数
            a2 = a2 + 1
            gui.show_message("Executed times", a2)
            globals.set_int(262145 + 24227,300000) -- 	if (func_22904(MP_STAT_CLUB_SAFE_CASH_VALUE, -1) != Global_262145.f_24227)
            globals.set_int(262145 + 24223,300000) -- 	func_6(iParam0, iParam1, joaat("NIGHTCLUBINCOMEUPTOPOP100"), &(Global_262145.f_24223), true);
            STATS.STAT_SET_INT(joaat(mpx.."CLUB_POPULARITY"), 10000, true)
            STATS.STAT_SET_INT(joaat(mpx.."CLUB_PAY_TIME_LEFT"), -1, true)
            STATS.STAT_SET_INT(joaat(mpx.."CLUB_POPULARITY"), 100000, true)
            gui.show_message("warn", "This method is only used for occasional small recovery")
            ncsafeloop:sleep(10000) --执行间隔，单位ms
        end
    end)
end)

gentab:add_sameline()

local checklkw = gentab:add_checkbox("Casino carousels (the carousels may appear as other items, but you do get vehicles)")

local checkxsdped = gentab:add_checkbox("NPC drops 2000 yuan cycle (high risk)")

gentab:add_separator()
gentab:add_text("send")

gentab:add_button("Navigation Points (Particle Effects)", function()
    script.run_in_fiber(function (tp2wp)
        command.call("waypointtp",{}) --调用Yimmenu自身传送到导航点命令
        STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_rcbarry2") --小丑出现烟雾
        while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_rcbarry2") do
            STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_rcbarry2")
            tp2wp:yield()               
        end
        GRAPHICS.USE_PARTICLE_FX_ASSET("scr_rcbarry2")
        GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE("scr_clown_appears", PLAYER.PLAYER_PED_ID(), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0x8b93, 1.0, false, false, false, 0, 0, 0, 0)
    end)
end)

function tpfac() --传送到设施
    local Pos = HUD.GET_BLIP_COORDS(HUD.GET_FIRST_BLIP_INFO_ID(590))
    if HUD.DOES_BLIP_EXIST(HUD.GET_FIRST_BLIP_INFO_ID(590)) then
        PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(), Pos.x, Pos.y, Pos.z+4)
    end

end

gentab:add_button("Killer Whale Project Panel", function()
    script.run_in_fiber(function (callkos)
        local SubBlip = HUD.GET_FIRST_BLIP_INFO_ID(760)
        local SubControlBlip = HUD.GET_FIRST_BLIP_INFO_ID(773)
        if not HUD.DOES_BLIP_EXIST(SubBlip) and not HUD.DOES_BLIP_EXIST(SubControlBlip) then
            local PlayerPos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 0.0, 0.0)
            local Interior = INTERIOR.GET_INTERIOR_AT_COORDS(PlayerPos.x, PlayerPos.y, PlayerPos.z)
            if Interior ~= 281345 then
                globals.set_int(2794162 + 960, 1) --呼叫虎鲸 --freemode.c 			func_12047("HELP_SUBMA_P" /*Go to the Planning Screen on board your new Kosatka ~a~~s~ to begin The Cayo Perico Heist as a VIP, CEO or MC President. You can also request the Kosatka nearby via the Services section of the Interaction Menu.*/, "H_BLIP_SUB2" /*~BLIP_SUB2~*/, func_3011(PLAYER::PLAYER_ID()), -1, false, true);
                repeat callkos:yield() until HUD.DOES_BLIP_EXIST(SubBlip)
                PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(),1561.2369, 385.8771, -49.689915)
                PED.SET_PED_DESIRED_HEADING(PLAYER.PLAYER_PED_ID(), 175)
            end
        end
        PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(),1561.2369, 385.8771, -49.689915)
        PED.SET_PED_DESIRED_HEADING(PLAYER.PLAYER_PED_ID(), 175)
    end)
end)

gentab:add_button("facility", function()
    local PlayerPos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 0.52, 0.0)
    local intr = INTERIOR.GET_INTERIOR_AT_COORDS(PlayerPos.x, PlayerPos.y, PlayerPos.z)

    if intr == 269313 then 
        gui.show_message("no need to send","You are already in the facility")
    else
        tpfac()
    end
end)

gentab:add_sameline()

gentab:add_button("Facility Plan Screen", function()
    local PlayerPos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 0.52, 0.0)
    local intr = INTERIOR.GET_INTERIOR_AT_COORDS(PlayerPos.x, PlayerPos.y, PlayerPos.z)
    if intr == 269313 then 
        if HUD.DOES_BLIP_EXIST(HUD.GET_FIRST_BLIP_INFO_ID(428)) then
            PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(), 350.69284, 4872.308, -60.794243)
        end
    else
        gui.show_message("make sure you are in the facility","Please enter the facility before teleporting to the planning screen")
        tpfac()
    end
end)

--从MusinessBanager抄的
local NightclubPropertyInfo = {
    [1]  = {name = "La Mesa Nightclub",           coords = {x = 757.009,   y =  -1332.32,  z = 27.1802 }},
    [2]  = {name = "Mission Row Nightclub",       coords = {x = 345.7519,  y =  -978.8848, z = 29.2681 }},
    [3]  = {name = "Strawberry Nightclub",        coords = {x = -120.906,  y =  -1260.49,  z = 29.2088 }},
    [4]  = {name = "West Vinewood Nightclub",     coords = {x = 5.53709,   y =  221.35,    z = 107.6566}},
    [5]  = {name = "Cypress Flats Nightclub",     coords = {x = 871.47,    y =  -2099.57,  z = 30.3768 }},
    [6]  = {name = "LSIA Nightclub",              coords = {x = -676.625,  y =  -2458.15,  z = 13.8444 }},
    [7]  = {name = "Elysian Island Nightclub",    coords = {x = 195.534,   y =  -3168.88,  z = 5.7903  }},
    [8]  = {name = "Downtown Vinewood Nightclub", coords = {x = 373.05,    y =  252.13,    z = 102.9097}},
    [9]  = {name = "Del Perro Nightclub",         coords = {x = -1283.38,  y =  -649.916,  z = 26.5198 }},
    [10] = {name = "Vespucci Canals Nightclub",   coords = {x = -1174.85,  y =  -1152.3,   z = 5.56128 }},
}

-- Business / Other Online Work Stuff [[update]]
local function GetOnlineWorkOffset()
    -- GLOBAL_PLAYER_STAT
        local playerid = globals.get_int(1574918) --疑似与MPPLY_LAST_MP_CHAR相等
    return (1853988 + 1 + (playerid * 867) + 267)
end
local function GetNightClubHubOffset()
    return (GetOnlineWorkOffset() + 310)
end
local function GetNightClubOffset()
    return (GetOnlineWorkOffset() + 354) -- CLUB_OWNER_X
end

local function GetWarehouseOffset()
    return (GetOnlineWorkOffset() + 116) + 1
end

local function GetMCBusinessOffset()
    return (GetOnlineWorkOffset() + 193) + 1
end
local function GetNightClubPropertyID()
    return globals.get_int(GetNightClubOffset())
end

local function IsPlayerInNightclub()
    return (GetPlayerPropertyID() > 101) and (GetPlayerPropertyID() < 112)
end

function tpnc() --传送到夜总会
    local property = GetNightClubPropertyID()
    if property ~= 0  then
        local coords = NightclubPropertyInfo[property].coords
        PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(), coords.x, coords.y, coords.z)
    end
end

gentab:add_button("nightclub", function()
    tpnc()
end)

gentab:add_sameline()

gentab:add_button("Nightclub safe (enter the nightclub first)", function()
    PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(), -1615.6832, -3015.7546, -75.204994)
end)

gentab:add_button("gaming room", function()

    local Blip = HUD.GET_FIRST_BLIP_INFO_ID(740) -- Arcade Blip
    local Pos = HUD.GET_BLIP_COORDS(Blip)
    local Label = HUD.GET_FILENAME_FOR_AUDIO_CONVERSATION(ZONE.GET_NAME_OF_ZONE(Pos.x, Pos.y, Pos.z))

 if string.find(HUD.GET_FILENAME_FOR_AUDIO_CONVERSATION("MP_ARC_1"), Label) ~= nil then 
    ArcadePos = vec3:new(-245.9931, 6210.773, 31.939024)
    PED.SET_PED_DESIRED_HEADING(PLAYER.PLAYER_PED_ID(), -50)
 end
 if string.find(HUD.GET_FILENAME_FOR_AUDIO_CONVERSATION("MP_ARC_2"), Label) ~= nil then 
    ArcadePos = vec3:new(1695.5393, 4784.196, 41.94444)
    PED.SET_PED_DESIRED_HEADING(PLAYER.PLAYER_PED_ID(), -95)
 end
 if string.find(HUD.GET_FILENAME_FOR_AUDIO_CONVERSATION("MP_ARC_3"), Label) ~= nil then 
    ArcadePos = vec3:new(-115.45246, -1772.0801, 29.858917)
    PED.SET_PED_DESIRED_HEADING(PLAYER.PLAYER_PED_ID(), -125)
 end
 if string.find(HUD.GET_FILENAME_FOR_AUDIO_CONVERSATION("FMC_LOC_WSTVNWD"), Label) ~= nil then 
    ArcadePos = vec3:new(-600.911, 279.97433, 82.041245)
    PED.SET_PED_DESIRED_HEADING(PLAYER.PLAYER_PED_ID(), 80)
 end
 if string.find(HUD.GET_FILENAME_FOR_AUDIO_CONVERSATION("MP_ARC_5"), Label) ~= nil then 
    ArcadePos = vec3:new(-1269.7747, -304.4372, 37.001965)
    PED.SET_PED_DESIRED_HEADING(PLAYER.PLAYER_PED_ID(), 75)
 end
 if string.find(HUD.GET_FILENAME_FOR_AUDIO_CONVERSATION("MP_ARC_6"), Label) ~= nil then 
    ArcadePos = vec3:new(758.91815, -814.60864, 26.301702)
    PED.SET_PED_DESIRED_HEADING(PLAYER.PLAYER_PED_ID(), 90)

 end

  PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(),  ArcadePos.x, ArcadePos.y,  ArcadePos.z)

end)

gentab:add_sameline()

gentab:add_button("Arcade Plan Panel (Advanced Arcade)", function()
    PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(),  2711.773, -369.458, -54.781)
end)

gentab:add_separator()
gentab:add_text("miscellaneous")

gentab:add_button("Preview the Halloween Ghost Hunt", function()
    globals.set_int(262145+35064,1) --Ghost hunt enable
    globals.set_int(262145+35158,50000) --Ghost hunt GHOSTHUNT_CASH_REWARD
    gui.show_message("Ghosts will randomly spawn at a certain location","This event only takes place from 8:00 p.m. to 6:00 a.m. the next day")
end)

gentab:add_sameline()

gentab:add_button("Dax cooldown removed", function()
    local playerid = globals.get_int(1574918) --疑似与MPPLY_LAST_MP_CHAR相等
    local mpx = "MP0_"
    if playerid == 1 then 
        mpx = "MP1_" 
    end
    STATS.STAT_SET_INT(joaat(mpx.."XM22JUGGALOWORKCDTIMER"), -1, true)
end)

gentab:add_sameline()

gentab:add_button("Security Contract/Phone Assassination cooldown removed", function()
    globals.set_int(262145 + 31908, 0)   --tuneables_processing.c   	func_6(iParam0, iParam1, joaat("FIXER_SECURITY_CONTRACT_COOLDOWN_TIME") /* collision: FIXER_SECURITY_CONTRACT_COOLDOWN_TIME */, &(Global_262145.f_31908), true);
    globals.set_int(262145 + 31973, 0)   --tuneables_processing.c	func_6(iParam0, iParam1, -2036534141, &(Global_262145.f_31973), true);    	Global_262145.f_31973 = 500;
end)

gentab:add_sameline()

gentab:add_button("Removed CEO vehicle cooldown", function()
    globals.set_int(262145 + 13005, 0)   --tuneables_processing.c 	func_6(iParam0, iParam1, joaat("GB_CALL_VEHICLE_COOLDOWN") /* collision: GB_CALL_VEHICLE_COOLDOWN */, &(Global_262145.f_13005), true);
end)

gentab:add_sameline()

gentab:add_button("remove self bounty", function()
    globals.set_int(1+2359296+5150+13,2880000)   
end)

gentab:add_sameline()

gentab:add_button("Ka Yun retreats offline", function()
    if NETWORK.NETWORK_CAN_BAIL() then
        NETWORK.NETWORK_BAIL(0, 0, 0)
    end
end)

gentab:add_button("Skip an NPC dialogue", function()
    AUDIO.SKIP_TO_NEXT_SCRIPTED_CONVERSATION_LINE()
end)

gentab:add_sameline()

local checkbypassconv = gentab:add_checkbox("Automatically skip NPC dialogue")

gentab:add_sameline()

gentab:add_button("stop all local sounds", function()
    for i=-1,100 do
        AUDIO.STOP_SOUND(i)
        AUDIO.RELEASE_SOUND_ID(i)
    end
end)

gentab:add_sameline()

gentab:add_button("Generate ground speed bar", function()
    script.run_in_fiber(function (crtspeedm)
    objHash = joaat("stt_prop_track_speedup_t1")
    while not STREAMING.HAS_MODEL_LOADED(objHash) do	
        STREAMING.REQUEST_MODEL(objHash)
        crtspeedm:yield()
    end
    local selfpedPos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), false)
    local heading = ENTITY.GET_ENTITY_HEADING(PLAYER.PLAYER_PED_ID())
    local obj = OBJECT.CREATE_OBJECT(objHash, selfpedPos.x, selfpedPos.y, selfpedPos.z-0.2, true, true, false)
    ENTITY.SET_ENTITY_HEADING(obj, heading + 90)
    end)
end)

gentab:add_sameline()

gentab:add_button("Generate Air Acceleration Bar", function()
    script.run_in_fiber(function (crtspeedm)
    objHash = joaat("ar_prop_ar_speed_ring")
    while not STREAMING.HAS_MODEL_LOADED(objHash) do	
        STREAMING.REQUEST_MODEL(objHash)
        crtspeedm:yield()
    end
    local selfpedPos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), false)
    local heading = ENTITY.GET_ENTITY_HEADING(PLAYER.PLAYER_PED_ID())
    local obj = OBJECT.CREATE_OBJECT(objHash, selfpedPos.x, selfpedPos.y, selfpedPos.z-0.2, true, true, false)
    ENTITY.SET_ENTITY_HEADING(obj, heading)
    end)
end)

gentab:add_text("Visual effect")

gentab:add_sameline()

gentab:add_button("remove all visual effects", function()
    GRAPHICS.ANIMPOSTFX_STOP_ALL()
    GRAPHICS.SET_TIMECYCLE_MODIFIER("DEFAULT")

end)

gentab:add_sameline()

gentab:add_button("Visual Effects: Taking Drugs", function()
    GRAPHICS.ANIMPOSTFX_PLAY("DrugsDrivingIn", 5, true)
end)

gentab:add_sameline()

gentab:add_button("Vague", function()
    GRAPHICS.ANIMPOSTFX_PLAY("MenuMGSelectionIn", 5, true)
end)

gentab:add_sameline()

gentab:add_button("increase brightness", function()
    GRAPHICS.SET_TIMECYCLE_MODIFIER("AmbientPush")
end)

gentab:add_sameline()

gentab:add_button("heavy fog", function()
    GRAPHICS.SET_TIMECYCLE_MODIFIER("casino_main_floor_heist")
end)


gentab:add_sameline()

gentab:add_button("drunk", function()
    GRAPHICS.SET_TIMECYCLE_MODIFIER("Drunk")
end)

local check1 = gentab:add_checkbox("Remove transaction error warning") --只是一个开关，代码往后面找

gentab:add_sameline()

local checkmiss = gentab:add_checkbox("Removed Orca missile cooldown and increased range")--只是一个开关，代码往后面找
 
local checkzhongjia = gentab:add_checkbox("Request heavy armor spend (remove black money)")--只是一个开关，代码往后面找

gentab:add_sameline()

local iputintzhongjia = gentab:add_input_int("Dollar")

local checkfootaudio = gentab:add_checkbox("turn off footsteps") --只是一个开关，代码往后面找

gentab:add_sameline()

local checkpedaudio = gentab:add_checkbox("Turn off your own PED sound") --只是一个开关，代码往后面找

gentab:add_sameline()

local disableAIdmg = gentab:add_checkbox("Lock NPC Zero Damage") --只是一个开关，代码往后面找

gentab:add_sameline()

local checkSONAR = gentab:add_checkbox("Minimap showing sonar") --只是一个开关，代码往后面找

gentab:add_sameline()

local disalight = gentab:add_checkbox("global lights out") --只是一个开关，代码往后面找

gentab:add_sameline()

local DrawHost = gentab:add_checkbox("display host information") --只是一个开关，代码往后面找

local pedgun = gentab:add_checkbox("PED gun (shoots NPC)") --只是一个开关，代码往后面找

gentab:add_sameline()

local bsktgun = gentab:add_checkbox("basketball gun") --只是一个开关，代码往后面找

gentab:add_sameline()

local bballgun = gentab:add_checkbox("big ball gun") --只是一个开关，代码往后面找

gentab:add_sameline()

local drawcs = gentab:add_checkbox("Draw + Sight") --只是一个开关，代码往后面找

gentab:add_sameline()

local disablecops = gentab:add_checkbox("stop the police from being dispatched") --只是一个开关，代码往后面找

gentab:add_sameline()

local disapedheat = gentab:add_checkbox("No temperature (anti-thermal imaging)") --只是一个开关，代码往后面找

gentab:add_sameline()

local canafrdly = gentab:add_checkbox("Allow to attack teammate") --只是一个开关，代码往后面找

--------------------------------------------------------------------------------------- Players 页面

gui.get_tab(""):add_text("SCH LUA PLAYER OPTIONS -!!!!! NO FEEDBACK ACCEPTED!!!!!") 

local spcam = gui.get_tab(""):add_checkbox("Indirect viewing (not easily detected)")

gui.get_tab(""):add_sameline()

local vehgodr = gui.get_tab(""):add_checkbox("Gives vehicle invulnerability")

gui.get_tab(""):add_sameline()

local vehnoclr = gui.get_tab(""):add_checkbox("The vehicle is completely collision-free")

gui.get_tab(""):add_sameline()

gui.get_tab(""):add_button("repair vehicle", function()
    script.run_in_fiber(function (repvehr)
        if not PED.IS_PED_IN_ANY_VEHICLE(PLAYER.GET_PLAYER_PED(network.get_selected_player()),true) then
            gui.show_error("warn","Player is not in the vehicle")
        else
            tarveh = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED(network.get_selected_player()))
            if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(tarveh)  then
                local netid = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(tarveh)
                NETWORK.SET_NETWORK_ID_CAN_MIGRATE(netid, true)
                local time = os.time()
                while not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(tarveh) do
                    if os.time() - time >= 5 then
                        break
                    end
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(tarveh)
                    repvehr:yield()
                end
            end
            VEHICLE.SET_VEHICLE_FIXED(tarveh)
        end
    end)
end)
--[[
gui.get_tab(""):add_sameline()

gui.get_tab(""):add_button("remove载具", function()
    script.run_in_fiber(function (rmvehr)
        if not PED.IS_PED_IN_ANY_VEHICLE(PLAYER.GET_PLAYER_PED(network.get_selected_player()),true) then
            gui.show_error("warn","Player is not in the vehicle")
        else
            command.call( vehkick, {"PLAYER.GET_PLAYER_NAME(network.get_selected_player())"})
            tarveh = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED(network.get_selected_player()))
            if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(tarveh)  then
                local netid = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(tarveh)
                NETWORK.SET_NETWORK_ID_CAN_MIGRATE(netid, true)
                local time = os.time()
                while not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(tarveh) do
                    if os.time() - time >= 5 then
                        break
                    end
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(tarveh)
                    rmvehr:yield()
                end
            end
            ENTITY.DELETE_ENTITY(tarveh)
        end
    end)
end)


gui.get_tab(""):add_sameline()

gui.get_tab(""):add_button("德罗索", function()
    script.run_in_fiber(function (giftdls)
        local giftvehhash = joaat("deluxo")
        STREAMING.REQUEST_MODEL(giftvehhash)
        while STREAMING.HAS_MODEL_LOADED(giftvehhash) ~= 1 do
            STREAMING.REQUEST_MODEL(giftvehhash)
            giftdls:yield()
        end   
        local targpos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
        firemtcrtveh = VEHICLE.CREATE_VEHICLE(joaat("deluxo"), ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(),false).x, ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(),false).y, ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(),false).z, 0 , true, true, true)

        vehdls = VEHICLE.CREATE_VEHICLE(giftvehhash, targpos.x + 2, targpos.y, targpos.z, 0 , true, true, true)
        ENTITY.SET_ENTITY_INVINCIBLE(vehdls, true)
        VEHICLE.SET_VEHICLE_CAN_BE_VISIBLY_DAMAGED(vehdls, false)
    end)
end)
]]
gui.get_tab(""):add_sameline()

gui.get_tab(""):add_button("Teleport to player (particle effect)", function()
    script.run_in_fiber(function (ptfxtp2ply)
        local targpos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
        PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(), targpos.x, targpos.y, targpos.z)
        STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_rcbarry2") --小丑出现烟雾
        while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_rcbarry2") do
            STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_rcbarry2")
            ptfxtp2ply:yield()               
        end
        GRAPHICS.USE_PARTICLE_FX_ASSET("scr_rcbarry2")
        GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE("scr_clown_appears", PLAYER.PLAYER_PED_ID(), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0x8b93, 1.0, false, false, false, 0, 0, 0, 0)

    end)
end)

gui.get_tab(""):add_button("small cage", function()
    script.run_in_fiber(function (smallcage)
        local objHash = joaat("prop_gold_cont_01")
        STREAMING.REQUEST_MODEL(objHash)
        while not STREAMING.HAS_MODEL_LOADED(objHash) do		
            smallcage:yield()
        end
        local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
        local obj = OBJECT.CREATE_OBJECT(objHash, pos.x, pos.y, pos.z-1, true, true, false)
        ENTITY.FREEZE_ENTITY_POSITION(obj, true)
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(objHash)
    end)
end)

gui.get_tab(""):add_sameline()

gui.get_tab(""):add_button("fence cage", function()
    local objHash = joaat("prop_fnclink_03e")
    STREAMING.REQUEST_MODEL(objHash)

    local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)

    pos.z = pos.z - 1.0
    local object = {}

    object[1] = OBJECT.CREATE_OBJECT(objHash, pos.x - 1.5, pos.y + 1.5, pos.z,true, 1, 0)
    object[2] = OBJECT.CREATE_OBJECT(objHash, pos.x - 1.5, pos.y - 1.5, pos.z,true, 1, 0)

    object[3] = OBJECT.CREATE_OBJECT(objHash, pos.x + 1.5, pos.y + 1.5, pos.z,true, 1, 0)
    local rot_3 = ENTITY.GET_ENTITY_ROTATION(object[3], 2)
    rot_3.z = -90.0
    ENTITY.SET_ENTITY_ROTATION(object[3], rot_3.x, rot_3.y, rot_3.z, 1, true)

    object[4] = OBJECT.CREATE_OBJECT(objHash, pos.x - 1.5, pos.y + 1.5, pos.z,true, 1, 0)
    local rot_4 = ENTITY.GET_ENTITY_ROTATION(object[4], 2)
    rot_4.z = -90.0
    ENTITY.SET_ENTITY_ROTATION(object[4], rot_4.x, rot_4.y, rot_4.z, 1, true)
    ENTITY.IS_ENTITY_STATIC(object[1]) 
    ENTITY.IS_ENTITY_STATIC(object[2])
    ENTITY.IS_ENTITY_STATIC(object[3])
    ENTITY.IS_ENTITY_STATIC(object[4])
    ENTITY.SET_ENTITY_CAN_BE_DAMAGED(object[1], false) 
    ENTITY.SET_ENTITY_CAN_BE_DAMAGED(object[2], false) 
    ENTITY.SET_ENTITY_CAN_BE_DAMAGED(object[3], false) 
    ENTITY.SET_ENTITY_CAN_BE_DAMAGED(object[4], false) 

    for i = 1, 4 do ENTITY.FREEZE_ENTITY_POSITION(object[i], true) end
    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(objHash)
end)

gui.get_tab(""):add_sameline()

gui.get_tab(""):add_button("competitive tube cage", function()
    script.run_in_fiber(function (dubcage)
        local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
        STREAMING.REQUEST_MODEL(2081936690)
        while not STREAMING.HAS_MODEL_LOADED(2081936690) do		
            dubcage:sleep(100)
        end
        local cage_object = OBJECT.CREATE_OBJECT(2081936690, pos.x, pos.y, pos.z-5, true, true, false)
        local rot  = ENTITY.GET_ENTITY_ROTATION(cage_object)
        rot.y = 90
        ENTITY.SET_ENTITY_ROTATION(cage_object, rot.x,rot.y,rot.z,1,true)
        local cage_object2 = OBJECT.CREATE_OBJECT(2081936690, pos.x-5, pos.y+5, pos.z-5, true, true, false)
        local rot  = ENTITY.GET_ENTITY_ROTATION(cage_object2)
        rot.x = 90 
        ENTITY.SET_ENTITY_ROTATION(cage_object2, rot.x,rot.y,rot.z,2,true)
    end)
end)

gui.get_tab(""):add_sameline()

gui.get_tab(""):add_button("safe cage", function()
    script.run_in_fiber(function (safecage)
        local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
        local hash = 1089807209
        STREAMING.REQUEST_MODEL(hash)
        while not STREAMING.HAS_MODEL_LOADED(hash) do		
            STREAMING.REQUEST_MODEL(hash)
            safecage:yield()
        end
        local objectsfcage = {}
        objectsfcage[1] = OBJECT.CREATE_OBJECT(hash, pos.x - 0.9, pos.y, pos.z - 1, true, true, false) 
        objectsfcage[2] = OBJECT.CREATE_OBJECT(hash, pos.x + 0.9, pos.y, pos.z - 1, true, true, false) 
        objectsfcage[3] = OBJECT.CREATE_OBJECT(hash, pos.x, pos.y + 0.9, pos.z - 1, true, true, false) 
        objectsfcage[4] = OBJECT.CREATE_OBJECT(hash, pos.x, pos.y - 0.9, pos.z - 1, true, true, false) 
        objectsfcage[5] = OBJECT.CREATE_OBJECT(hash, pos.x - 0.9, pos.y, pos.z + 0.4 , true, true, false) 
        objectsfcage[6] = OBJECT.CREATE_OBJECT(hash, pos.x + 0.9, pos.y, pos.z + 0.4, true, true, false) 
        objectsfcage[7] = OBJECT.CREATE_OBJECT(hash, pos.x, pos.y + 0.9, pos.z + 0.4, true, true, false) 
        objectsfcage[8] = OBJECT.CREATE_OBJECT(hash, pos.x, pos.y - 0.9, pos.z + 0.4, true, true, false) 
        for i = 1, 8 do ENTITY.FREEZE_ENTITY_POSITION(objectsfcage[i], true) end
        safecage:sleep(100)
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(cage_object)
    end)
end)

gui.get_tab(""):add_sameline()

local pedvehctl = gui.get_tab(""):add_checkbox("Vehicle rotation")

gui.get_tab(""):add_sameline()

gui.get_tab(""):add_button("electric shock", function()
    local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
    MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z + 1, pos.x, pos.y, pos.z, 1000, true, joaat("weapon_stungun"), false, false, true, 1.0)
end)

gui.get_tab(""):add_sameline()

gui.get_tab(""):add_button("bombing", function()
    script.run_in_fiber(function (airst)
        local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
        airshash = joaat("vehicle_weapon_trailer_dualaa")
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z- 1 , pos.x, pos.y, pos.z - 1, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z- 1 , pos.x+2, pos.y, pos.z - 1, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z- 1 , pos.x-2, pos.y, pos.z - 1, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z- 1 , pos.x-2, pos.y-2, pos.z - 1, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z- 1 , pos.x-2, pos.y+2, pos.z - 1, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 1 , pos.x, pos.y, pos.z + 1, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 1 , pos.x+2, pos.y, pos.z + 1, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 1 , pos.x-2, pos.y, pos.z + 1, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 1 , pos.x-2, pos.y-2, pos.z + 1, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 1 , pos.x-2, pos.y+2, pos.z + 1, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 3 , pos.x, pos.y, pos.z + 3, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 3, pos.x+2, pos.y, pos.z + 3, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 3, pos.x-2, pos.y, pos.z + 3, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 3 , pos.x-2, pos.y-2, pos.z + 3, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 3 , pos.x-2, pos.y+2, pos.z + 3, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 5, pos.x, pos.y, pos.z + 5, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 5 , pos.x+2, pos.y, pos.z + 5, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 5 , pos.x-2, pos.y, pos.z + 5, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 5, pos.x-2, pos.y-2, pos.z + 5, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 5 , pos.x-2, pos.y+2, pos.z + 5, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 7 , pos.x, pos.y, pos.z + 7, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 7 , pos.x+2, pos.y, pos.z + 7, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 7 , pos.x-2, pos.y, pos.z + 7, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 7 , pos.x-2, pos.y-2, pos.z + 7, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 7 , pos.x-2, pos.y+2, pos.z + 7, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 9 , pos.x, pos.y, pos.z + 9, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 9 , pos.x+2, pos.y, pos.z + 9, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 9 , pos.x-2, pos.y, pos.z + 9, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 9 , pos.x-2, pos.y-2, pos.z + 9, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 9 , pos.x-2, pos.y+2, pos.z + 9, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 11 , pos.x, pos.y, pos.z + 11, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 11 , pos.x+2, pos.y, pos.z + 11, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 11 , pos.x-2, pos.y, pos.z + 11, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 11 , pos.x-2, pos.y-2, pos.z + 11, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 11 , pos.x-2, pos.y+2, pos.z + 11, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 13 , pos.x, pos.y, pos.z + 13, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 13 , pos.x+2, pos.y, pos.z + 13, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 13 , pos.x-2, pos.y, pos.z + 13, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 13 , pos.x-2, pos.y-2, pos.z + 13, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 13 , pos.x-2, pos.y+2, pos.z + 13, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 15 , pos.x, pos.y, pos.z + 15, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 15 , pos.x+2, pos.y, pos.z + 15, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 15 , pos.x-2, pos.y, pos.z + 15, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 15 , pos.x-2, pos.y-2, pos.z + 15, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 15 , pos.x-2, pos.y+2, pos.z + 15, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 17 , pos.x, pos.y, pos.z + 17, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 17 , pos.x+2, pos.y, pos.z + 17, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 17 , pos.x-2, pos.y, pos.z + 17, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 17 , pos.x-2, pos.y-2, pos.z + 17, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 17 , pos.x-2, pos.y+2, pos.z + 17, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 19 , pos.x, pos.y, pos.z + 19, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 19 , pos.x+2, pos.y, pos.z + 19, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 19 , pos.x-2, pos.y, pos.z + 19, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 19 , pos.x-2, pos.y-2, pos.z + 19, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 19 , pos.x-2, pos.y+2, pos.z + 19, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 21 , pos.x, pos.y, pos.z + 21, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 21 , pos.x+2, pos.y, pos.z + 21, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 21 , pos.x-2, pos.y, pos.z + 21, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 21 , pos.x-2, pos.y-2, pos.z + 21, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 21 , pos.x-2, pos.y+2, pos.z + 21, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 23 , pos.x, pos.y, pos.z + 23, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 23 , pos.x+2, pos.y, pos.z + 23, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 23 , pos.x-2, pos.y, pos.z + 23, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 23 , pos.x-2, pos.y-2, pos.z + 23, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 23 , pos.x-2, pos.y+2, pos.z + 23, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 25 , pos.x, pos.y, pos.z + 25, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 25 , pos.x+2, pos.y, pos.z + 25, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 25 , pos.x-2, pos.y, pos.z + 25, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 25 , pos.x-2, pos.y-2, pos.z + 25, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 25 , pos.x-2, pos.y+2, pos.z + 25, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 27 , pos.x, pos.y, pos.z + 27, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 27 , pos.x+2, pos.y, pos.z + 27, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 27 , pos.x-2, pos.y, pos.z + 27, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 27 , pos.x-2, pos.y-2, pos.z + 27, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 27 , pos.x-2, pos.y+2, pos.z + 27, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 29 , pos.x, pos.y, pos.z + 29, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 29 , pos.x+2, pos.y, pos.z + 29, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 29 , pos.x-2, pos.y, pos.z + 29, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 29 , pos.x-2, pos.y-2, pos.z + 29, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 29 , pos.x-2, pos.y+2, pos.z + 29, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 31 , pos.x, pos.y, pos.z + 31, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 31 , pos.x+2, pos.y, pos.z + 31, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 31 , pos.x-2, pos.y, pos.z + 31, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 31 , pos.x-2, pos.y-2, pos.z + 31, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 31 , pos.x-2, pos.y+2, pos.z + 31, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 33 , pos.x, pos.y, pos.z + 33, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 33 , pos.x+2, pos.y, pos.z + 33, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-22, pos.y, pos.z+ 33 , pos.x-2, pos.y, pos.z + 33, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 33 , pos.x-2, pos.y-2, pos.z + 33, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 33 , pos.x-2, pos.y+2, pos.z + 3, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 35 , pos.x, pos.y, pos.z + 35, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 35 , pos.x+2, pos.y, pos.z + 35, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 35 , pos.x-2, pos.y, pos.z + 35, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-22, pos.y-2, pos.z+ 35 , pos.x-2, pos.y-2, pos.z + 35, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 35 , pos.x-2, pos.y+2, pos.z + 35, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 37 , pos.x, pos.y, pos.z + 37, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 37 , pos.x+2, pos.y, pos.z + 37, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 37 , pos.x-2, pos.y, pos.z + 37, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 37 , pos.x-2, pos.y-2, pos.z + 37, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 37 , pos.x-2, pos.y+2, pos.z + 37, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 39 , pos.x, pos.y, pos.z + 39, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 39 , pos.x+2, pos.y, pos.z + 39, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 39 , pos.x-2, pos.y, pos.z + 39, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 39 , pos.x-2, pos.y-2, pos.z + 39, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 39 , pos.x-2, pos.y+2, pos.z + 39, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 41 , pos.x, pos.y, pos.z + 41, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 41 , pos.x+2, pos.y, pos.z + 41, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 41 , pos.x-2, pos.y, pos.z + 41, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 41 , pos.x-2, pos.y-2, pos.z + 41, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 41 , pos.x-2, pos.y+2, pos.z + 41, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 43 , pos.x, pos.y, pos.z + 43, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 43 , pos.x+2, pos.y, pos.z + 43, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 43 , pos.x-2, pos.y, pos.z + 43, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 43 , pos.x-2, pos.y-2, pos.z + 43, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 43 , pos.x-2, pos.y+2, pos.z + 43, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        airst:sleep(100)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z+ 45 , pos.x, pos.y, pos.z + 45, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x+2, pos.y, pos.z+ 45 , pos.x+2, pos.y, pos.z + 45, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y, pos.z+ 45 , pos.x-2, pos.y, pos.z + 45, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y-2, pos.z+ 45 , pos.x-2, pos.y-2, pos.z + 45, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x-2, pos.y+2, pos.z+ 45 , pos.x-2, pos.y+2, pos.z + 45, 10000, true, airshash, PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 10000)
    end)
end)

gui.get_tab(""):add_sameline()

local check8 = gui.get_tab(""):add_checkbox("circulating water column")

gui.get_tab(""):add_sameline()

local checknodmgexp = gui.get_tab(""):add_checkbox("Explosion without injury")

gui.get_tab(""):add_sameline()

local checkcollection1 = gui.get_tab(""):add_checkbox("cycle card")

local check2 = gui.get_tab(""):add_checkbox("Drop frame attack (as far away from the target as possible)")

gui.get_tab(""):add_sameline()

local check5 = gui.get_tab(""):add_checkbox("Particle effect bombing (as far away from the target as possible)")

gui.add_tab(""):add_sameline()

local checkspped = gui.get_tab(""):add_checkbox("Cycle brush PED")

gui.add_tab(""):add_sameline()

local checkxsdpednet = gui.add_tab(""):add_checkbox("NPC drops 2000 yuan cycle")

gui.add_tab(""):add_button("fragmentation crash", function()
    script.run_in_fiber(function (fragcrash)
        fraghash = joaat("prop_fragtest_cnst_04")
        STREAMING.REQUEST_MODEL(fraghash)
        local TargetCrds = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
        local crashstaff1 = OBJECT.CREATE_OBJECT(fraghash, TargetCrds.x, TargetCrds.y, TargetCrds.z, true, false, false)
            OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(object, 1, false)
        local crashstaff1 = OBJECT.CREATE_OBJECT(fraghash, TargetCrds.x, TargetCrds.y, TargetCrds.z, true, false, false)
            OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(object, 1, false)
        local crashstaff1 = OBJECT.CREATE_OBJECT(fraghash, TargetCrds.x, TargetCrds.y, TargetCrds.z, true, false, false)
            OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(object, 1, false)
        local crashstaff1 = OBJECT.CREATE_OBJECT(fraghash, TargetCrds.x, TargetCrds.y, TargetCrds.z, true, false, false)
            OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(object, 1, false)
        for i = 0, 100 do 
            local TargetPlayerPos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(crashstaff1, TargetPlayerPos.x, TargetPlayerPos.y, TargetPlayerPos.z, false, true, true)
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(crashstaff1, TargetPlayerPos.x, TargetPlayerPos.y, TargetPlayerPos.z, false, true, true)
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(crashstaff1, TargetPlayerPos.x, TargetPlayerPos.y, TargetPlayerPos.z, false, true, true)
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(crashstaff1, TargetPlayerPos.x, TargetPlayerPos.y, TargetPlayerPos.z, false, true, true)
            fragcrash:sleep(10)
            ENTITY.DELETE_ENTITY(crashstaff1)
            ENTITY.DELETE_ENTITY(crashstaff1)
            ENTITY.DELETE_ENTITY(crashstaff1)
            ENTITY.DELETE_ENTITY(crashstaff1)
        end
    end)
    script.run_in_fiber(function (fragcrash2)
        local TargetCrds = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
        fraghash = joaat("prop_fragtest_cnst_04")
        STREAMING.REQUEST_MODEL(fraghash)
        for i=1,10 do
            local object = OBJECT.CREATE_OBJECT(fraghash, TargetCrds.x, TargetCrds.y, TargetCrds.z, true, false, false)
            OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(object, 1, false)
            ENTITY.DELETE_ENTITY(object)
            local object = OBJECT.CREATE_OBJECT(fraghash, TargetCrds.x, TargetCrds.y, TargetCrds.z, true, false, false)
            OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(object, 1, false)
            ENTITY.DELETE_ENTITY(object)
            local object = OBJECT.CREATE_OBJECT(fraghash, TargetCrds.x, TargetCrds.y, TargetCrds.z, true, false, false)
            OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(object, 1, false)
            ENTITY.DELETE_ENTITY(object)
            local object = OBJECT.CREATE_OBJECT(fraghash, TargetCrds.x, TargetCrds.y, TargetCrds.z, true, false, false)
            OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(object, 1, false)
            ENTITY.DELETE_ENTITY(object)
            local object = OBJECT.CREATE_OBJECT(fraghash, TargetCrds.x, TargetCrds.y, TargetCrds.z, true, false, false)
            OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(object, 1, false)
            ENTITY.DELETE_ENTITY(object)
            local object = OBJECT.CREATE_OBJECT(fraghash, TargetCrds.x, TargetCrds.y, TargetCrds.z, true, false, false)
            OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(object, 1, false)
            ENTITY.DELETE_ENTITY(object)
            local object = OBJECT.CREATE_OBJECT(fraghash, TargetCrds.x, TargetCrds.y, TargetCrds.z, true, false, false)
            OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(object, 1, false)
            ENTITY.DELETE_ENTITY(object)
            local object = OBJECT.CREATE_OBJECT(fraghash, TargetCrds.x, TargetCrds.y, TargetCrds.z, true, false, false)
            OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(object, 1, false)
            ENTITY.DELETE_ENTITY(object)
            local object = OBJECT.CREATE_OBJECT(fraghash, TargetCrds.x, TargetCrds.y, TargetCrds.z, true, false, false)
            OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(object, 1, false)
            ENTITY.DELETE_ENTITY(object)
            local object = OBJECT.CREATE_OBJECT(fraghash, TargetCrds.x, TargetCrds.y, TargetCrds.z, true, false, false)
            OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(object, 1, false)
            fragcrash2:sleep(100)
            ENTITY.DELETE_ENTITY(object)
        end
    end)
end)

gui.add_tab(""):add_sameline()

local audiospam = gui.add_tab(""):add_checkbox("sound bombing")

gui.add_tab(""):add_button("launch upwards", function()
    script.run_in_fiber(function (launchply)

    local ped = PLAYER.GET_PLAYER_PED(network.get_selected_player())
    local tarveh = joaat("mule5")
    local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)

    STREAMING.REQUEST_MODEL(tarveh)
    while not STREAMING.HAS_MODEL_LOADED(tarveh) do		
        STREAMING.REQUEST_MODEL(tarveh)
        launchply:yield()
    end
    spd_veh = VEHICLE.CREATE_VEHICLE(tarveh, ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 1.0, -3.0).x,ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 1.0, -3.0).y,ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 1.0, -3.0).z, ENTITY.GET_ENTITY_HEADING(ped) , true, true, true)
	NETWORK.SET_NETWORK_ID_CAN_MIGRATE(NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(spd_veh),false)
    ENTITY.SET_ENTITY_VISIBLE(spd_veh, false)
    launchply:sleep(300)
    ENTITY.APPLY_FORCE_TO_ENTITY(spd_veh, 1, 0.0, 0.0, 1000.0, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
    end)
end)

gui.get_tab(""):add_sameline()

gui.add_tab(""):add_button("squeeze down", function()
    script.run_in_fiber(function (launchply)

    local ped = PLAYER.GET_PLAYER_PED(network.get_selected_player())
    local tarveh = joaat("mule5")
    local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)

    STREAMING.REQUEST_MODEL(tarveh)
    while not STREAMING.HAS_MODEL_LOADED(tarveh) do		
        STREAMING.REQUEST_MODEL(tarveh)
        launchply:yield()
    end
    spd_veh = VEHICLE.CREATE_VEHICLE(tarveh, ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 1.0, 3.0).x,ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 1.0, -3.0).y,ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 1.0, -3.0).z, ENTITY.GET_ENTITY_HEADING(ped) , true, true, true)
	NETWORK.SET_NETWORK_ID_CAN_MIGRATE(NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(spd_veh),false)
    ENTITY.SET_ENTITY_VISIBLE(spd_veh, false)
    launchply:sleep(300)
    ENTITY.APPLY_FORCE_TO_ENTITY(spd_veh, 1, 0.0, 0.0, -1000.0, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
    end)
end)

local plydist = gui.get_tab(""):add_input_float("distance (m)")

gentab:add_separator()
gentab:add_text("global options") 

gentab:add_button("global explosion", function()
    for i = 0, 31 do
            FIRE.ADD_OWNED_EXPLOSION(PLAYER.GET_PLAYER_PED(i), ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(i)).x, ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(i)).y, ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(i)).z, 82, 1, true, false, 100)
    end
end)

gentab:add_sameline()

gentab:add_button("Give away the Tyrant MK2", function()
    script.run_in_fiber(function (giftmk2)
        STREAMING.REQUEST_MODEL(joaat("oppressor2"))
        while STREAMING.HAS_MODEL_LOADED(joaat("oppressor2")) ~= 1 do
            STREAMING.REQUEST_MODEL(joaat("oppressor2"))
            giftmk2:yield()
        end   
        for i = 0, 31 do
            veh = VEHICLE.CREATE_VEHICLE(joaat("oppressor2"), ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(i)).x, ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(i)).y, ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(i)).z, 0 , true, true, true)
        end
    end)
end)

gentab:add_sameline()

gentab:add_button("Air defense alert", function()
    for pid = 0, 31 do
        AUDIO.PLAY_SOUND_FROM_COORD(-1, "Air_Defences_Activated", ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(i)).x, ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(i)).y, ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(i)).z, "DLC_sum20_Business_Battle_AC_Sounds", true, 999999999, true)
    end
end)

gentab:add_sameline()

gentab:add_button("apartment invitation", function()
    for pid = 0, 31 do
    network.trigger_script_event(1 << pid, {3592101251, 1, 0, -1, 4, 127, 0, 0, 0,PLAYER.GET_PLAYER_INDEX(), pid})
    end
end)

gentab:add_sameline()

gentab:add_button("PED collapse", function() --恶毒的东西
    script.run_in_fiber(function (pedpacrash)
        gui.show_message("Umbrella collapse","Please wait patiently until the character lands")
        PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(), -74.94, -818.58, 327)
        local spped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PLAYER.PLAYER_ID())
        local ppos = ENTITY.GET_ENTITY_COORDS(spped, true)
        for n = 0 , 5 do
            local object_hash = joaat("prop_logpile_06b")
            STREAMING.REQUEST_MODEL(object_hash)
              while not STREAMING.HAS_MODEL_LOADED(object_hash) do
                pedpacrash:yield()
            end
            PLAYER.SET_PLAYER_PARACHUTE_MODEL_OVERRIDE(PLAYER.PLAYER_ID(),object_hash)
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(spped, 0,0,500, false, true, true)
            WEAPON.GIVE_DELAYED_WEAPON_TO_PED(spped, 0xFBAB5776, 1000, false)
            pedpacrash:sleep(1000)
            for i = 0 , 20 do
                PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 144, 1.0)
                PED.FORCE_PED_TO_OPEN_PARACHUTE(spped)
            end
            pedpacrash:sleep(1000)
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(spped, ppos.x, ppos.y, ppos.z, false, true, true)
    
            local object_hash2 = joaat("prop_beach_parasol_03")
            STREAMING.REQUEST_MODEL(object_hash2)
              while not STREAMING.HAS_MODEL_LOADED(object_hash2) do
                pedpacrash:yield()
            end
            PLAYER.SET_PLAYER_PARACHUTE_MODEL_OVERRIDE(PLAYER.PLAYER_ID(),object_hash2)
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(spped, 0,0,500, 0, 0, 1)
            WEAPON.GIVE_DELAYED_WEAPON_TO_PED(spped, 0xFBAB5776, 1000, false)
            pedpacrash:sleep(1000)
            for i = 0 , 20 do
                PED.FORCE_PED_TO_OPEN_PARACHUTE(spped)
                PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 144, 1.0)
            end
            pedpacrash:sleep(1000)
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(spped, ppos.x, ppos.y, ppos.z, false, true, true)
        end
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(spped, ppos.x, ppos.y, ppos.z, false, true, true)    
    end)
end)

gentab:add_separator()
gentab:add_text("variable adjustment") 

gentab:add_text("NPC/vehicle force field range") 
gentab:add_sameline()
local ffrange = gentab:add_input_int("Force field radius (meters)")
ffrange:set_value(15)

gentab:add_text("NPC/vehicle batch control range") 
gentab:add_sameline()
local npcctrlr = gentab:add_input_int("Control radius (m)")
npcctrlr:set_value(200)

gentab:add_text("NPC targeting penalty area of ​​effect") 
gentab:add_sameline()
local npcaimprange = gentab:add_input_int("Penalty radius (meters)")
npcaimprange:set_value(1000)

gentab:add_separator()
gentab:add_text("debugging") 

local DrawInteriorID = gentab:add_checkbox("Show Interior ID") --只是一个开关，代码往后面找

gentab:add_sameline()

local desync = gentab:add_checkbox("cancel sync") --只是一个开关，代码往后面找

gentab:add_sameline()

local ptfxrm = gentab:add_checkbox("Clean up PTFX flame water column") --只是一个开关，代码往后面找

gentab:add_sameline()

local DECALrm = gentab:add_checkbox("Clean up traces on the surface of objects") --只是一个开关，代码往后面找

gentab:add_text("obj generation (Name)") 
gentab:add_sameline()
local iputobjname = gentab:add_input_string("objname")
gentab:add_sameline()
gentab:add_button("Generate N", function()
    script.run_in_fiber(function (cusobj2)
        objHash = joaat(iputobjname:get_value())
        while not STREAMING.HAS_MODEL_LOADED(objHash) do	
            STREAMING.REQUEST_MODEL(objHash)
            cusobj2:yield()
        end
        local selfpedPos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), false)
        local heading = ENTITY.GET_ENTITY_HEADING(PLAYER.PLAYER_PED_ID())
        local obj = OBJECT.CREATE_OBJECT(objHash, selfpedPos.x, selfpedPos.y, selfpedPos.z, true, true, false)
        ENTITY.SET_ENTITY_HEADING(obj, heading)
        end)
end)

gentab:add_text("obj generation (Hash)") 
gentab:add_sameline()
local iputobjhash = gentab:add_input_string("objhash")
gentab:add_sameline()
gentab:add_button("Generate H", function()
    script.run_in_fiber(function (cusobj1)
        objHash = iputobjhash:get_value()
        while not STREAMING.HAS_MODEL_LOADED(objHash) do	
            STREAMING.REQUEST_MODEL(objHash)
            cusobj1:yield()
        end
        local selfpedPos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), false)
        local heading = ENTITY.GET_ENTITY_HEADING(PLAYER.PLAYER_PED_ID())
        local obj = OBJECT.CREATE_OBJECT(objHash, selfpedPos.x, selfpedPos.y, selfpedPos.z, true, true, false)
        ENTITY.SET_ENTITY_HEADING(obj, heading)
        end)
end)

gentab:add_text("PTFX generation") ;gentab:add_sameline()
local iputptfxdic = gentab:add_input_string("PTFX Dic")
local iputptfxname = gentab:add_input_string("PTFX Name")
gentab:add_sameline()
gentab:add_button("generate ptfx", function()
    script.run_in_fiber(function (cusptfx)
        iputptfxdicval = iputptfxdic:get_value()
        iputptfxnameval = iputptfxname:get_value()
        STREAMING.REQUEST_NAMED_PTFX_ASSET(iputptfxdicval)
        while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(iputptfxdicval) do
            cusptfx:yield()
        end
        GRAPHICS.USE_PARTICLE_FX_ASSET(iputptfxdicval)
        --GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE(iputptfxnameval, PLAYER.PLAYER_PED_ID(), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0x8b93, 1.0, false, false, false, 0, 0, 0, 0)
        local tar1 = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
        GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(iputptfxnameval, tar1.x, tar1.y, tar1.z + 1, 0, 0, 0, 1.0, true, true, true)
    end)
end)

gui.get_tab(""):add_text("debugging") 

gui.get_tab(""):add_text("obj generation (Name)") 
gui.get_tab(""):add_sameline()
local iputobjnamer = gui.get_tab(""):add_input_string("objname")
gui.get_tab(""):add_sameline()
gui.get_tab(""):add_button("Generate N", function()
    script.run_in_fiber(function (cusobj2r)
        local targetplyped = PLAYER.GET_PLAYER_PED(network.get_selected_player())
        local remotePos = ENTITY.GET_ENTITY_COORDS(targetplyped, false)
        objHashr = joaat(iputobjnamer:get_value())
        while not STREAMING.HAS_MODEL_LOADED(objHashr) do	
            STREAMING.REQUEST_MODEL(objHashr)
            cusobj2r:yield()
        end
        local headingr = ENTITY.GET_ENTITY_HEADING(targetplyped)
        local objr = OBJECT.CREATE_OBJECT(objHashr, remotePos.x, remotePos.y, remotePos.z, true, true, false)
        ENTITY.SET_ENTITY_HEADING(objr, headingr)
        end)
end)

gui.get_tab(""):add_text("obj generation (Hash)") 
gui.get_tab(""):add_sameline()
local iputobjhashr = gui.get_tab(""):add_input_string("objhash")
gui.get_tab(""):add_sameline()
gui.get_tab(""):add_button("Generate H", function()
    script.run_in_fiber(function (cusobj1r)
        local targetplyped = PLAYER.GET_PLAYER_PED(network.get_selected_player())
        local remotePos = ENTITY.GET_ENTITY_COORDS(targetplyped, false)
        objHashr = iputobjhashr:get_value()
        while not STREAMING.HAS_MODEL_LOADED(objHashr) do	
            STREAMING.REQUEST_MODEL(objHashr)
            cusobj1r:yield()
        end
        local headingr = ENTITY.GET_ENTITY_HEADING(targetplyped)
        local objr = OBJECT.CREATE_OBJECT(objHashr, remotePos.x, remotePos.y, remotePos.z, true, true, false)
        ENTITY.SET_ENTITY_HEADING(objr, headingr)
        end)
end)

gui.get_tab(""):add_text("PTFX generation") ;gui.get_tab(""):add_sameline()
local iputptfxdicr = gui.get_tab(""):add_input_string("PTFX Dic")
local iputptfxnamer = gui.get_tab(""):add_input_string("PTFX Name")
gui.get_tab(""):add_sameline()
gui.get_tab(""):add_button("generate ptfx", function()
    script.run_in_fiber(function (cusptfxr)
        iputptfxdicvalr = iputptfxdicr:get_value()
        iputptfxnamevalr = iputptfxnamer:get_value()
        STREAMING.REQUEST_NAMED_PTFX_ASSET(iputptfxdicvalr)
        while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(iputptfxdicvalr) do
            cusptfxr:yield()
        end
        GRAPHICS.USE_PARTICLE_FX_ASSET(iputptfxdicvalr)
        local tar1 = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()))
        GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(iputptfxnamevalr, tar1.x, tar1.y, tar1.z + 1, 0, 0, 0, 1.0, true, true, true)
    end)
end)

--------------------------------------------------------------------------------------- 注册的循环脚本,主要用来实现Lua里面那些复选框的功能
--存放一些变量，阻止无限循环，间接实现 checkbox 的 on_enable() 和 on_disable()

local loopa1 = 0  --控制PED脚步声有无
local loopa2 = 0  --控制Head666
local loopa3 = 0  --控制PED所有声音有无
local loopa4 = 0  --控制sonar开关
local loopa5 = 0  --控制喷火
local loopa6 = 0  --控制火焰翅膀
local loopa7 = 0  --控制警察调度
local loopa8 = 0  --控制NPC零伤害
local loopa9 = 0  --控制取消同步
local loopa10 = 0  --控制Ghost Rider
local loopa11 = 0  --控制PED热量
local loopa12 = 0  --控制是否允许攻击队友
local loopa13 = 0  --控制观看
local loopa14 = 0  --控制远程Vehicle invincibility
local loopa15 = 0  --控制远程Vehicle without collision
local loopa16 = 0  --控制世界灯光开关
local loopa17 = 0  --控制Overhead 520
local loopa18 = 0  --控制载具锁门

--------------------------------------------------------------------------------------- 注册的循环脚本,主要用来实现Lua里面那些复选框的功能

script.register_looped("schlua-recoveryservice", function() 

    if  checkxsdped:is_enabled() then --NPC掉落2000元循环    --自身
        PED.SET_AMBIENT_PEDS_DROP_MONEY(true) --自由模式NPC是否掉钱
        local TargetPPos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), false)
        TargetPPos.z = TargetPPos.z + 10 --让 席桑达 生成在空中然后摔下来
        STREAMING.REQUEST_MODEL(3552233440)
        local PED1 = PED.CREATE_PED(28, 3552233440, TargetPPos.x, TargetPPos.y, TargetPPos.z, 0, true, true)--刷出的NPC是 席桑达
        PED.SET_PED_MONEY(PED1,2000) --上限就是2000,不能超过
        ENTITY.SET_ENTITY_HEALTH(PED1,1,true)--刷出的NPC 席桑达 血量只有 1
        script_util:sleep(300) --间隔 300 毫秒
    end

    if  checkxsdpednet:is_enabled() then --NPC掉落2000元循环    --玩家选项
        if PLAYER.GET_PLAYER_PED(network.get_selected_player()) == PLAYER.PLAYER_PED_ID() then --避免目标离开战局后作用于自己
            PED.SET_AMBIENT_PEDS_DROP_MONEY(true) --自由模式NPC是否掉钱
            local TargetPPos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
            TargetPPos.z = TargetPPos.z + 10 --让 席桑达 生成在空中然后摔下来
            STREAMING.REQUEST_MODEL(3552233440)
            local netxsdPed = PED.CREATE_PED(28, 3552233440, TargetPPos.x, TargetPPos.y, TargetPPos.z, 0, true, true)--刷出的NPC是 席桑达
            PED.SET_PED_MONEY(netxsdPed,2000) --上限就是2000,不能超过
            ENTITY.SET_ENTITY_HEALTH(netxsdPed,1,true)--刷出的NPC 席桑达 血量只有 1
            script_util:sleep(300) --间隔 300 毫秒

        else
            gui.show_message("stopped", "The target cannot be yourself!")
            checkxsdpednet:set_enabled(nil) --目标是自己，自动关掉开关
        end
    end

    if  checkcollection1:is_enabled() then --循环刷纸牌给玩家

        local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false) --获取目标玩家坐标
        coords.z = coords.z + 2.0
 
        create_object(joaat("vw_prop_vw_lux_card_01a"),coords)

        OBJECT.CREATE_AMBIENT_PICKUP(-1009939663, coords.x, coords.y, coords.z, 0, 1, joaat("vw_prop_vw_lux_card_01a"), false, true)
    end

end)

script.register_looped("schlua-dataservice", function() 

    if  check1:is_enabled() then --remove交易错误warn
        globals.set_int(4536677,0)   -- shop_controller.c 	 if (Global_4536677)    HUD::SET_WARNING_MESSAGE_WITH_HEADER("CTALERT_A" /*Alert*/, func_1372(Global_4536683), instructionalKey, 0, false, -1, 0, 0, true, 0);
        globals.set_int(4536679,0)   -- shop_controller.c   HUD::BEGIN_TEXT_COMMAND_THEFEED_POST("CTALERT_F_1" /*Rockstar game servers could not process this transaction. Please try again and check ~HUD_COLOUR_SOCIAL_CLUB~www.rockstargames.com/support~s~ for information about current issues, outages, or scheduled maintenance periods.*/);
        globals.set_int(4536678,0)  -- shop_controller.c   HUD::BEGIN_TEXT_COMMAND_THEFEED_POST("CTALERT_F_1" /*Rockstar game servers could not process this transaction. Please try again and check ~HUD_COLOUR_SOCIAL_CLUB~www.rockstargames.com/support~s~ for information about current issues, outages, or scheduled maintenance periods.*/);
    end

    if  checkCEOcargo:is_enabled() then--锁定CEO仓库进货数
        if inputCEOcargo:get_value() <= 111 then --判断一下有没有人一次进天文数字箱货物、或者乱按的

        globals.set_int(1890714+12,inputCEOcargo:get_value()) --核心代码 --freemode.c      func_17512("SRC_CRG_TICKER_1" /*~a~ Staff has sourced: ~n~1 Crate: ~a~*/, func_6676(hParam0), func_17513(Global_1890714.f_15), HUD_COLOUR_PURE_WHITE, HUD_COLOUR_PURE_WHITE);

        else
            gui.show_error("limit exceeded", "The number of purchases exceeds the upper limit of warehouse capacity")
            checkCEOcargo:set_enabled(nil)
        end
    end

    if  check4:is_enabled() then--锁定机库仓库进货数
        globals.set_int(1890730+6,iputint3:get_value()) --freemode.c   --  "HAN_CRG_TICKER_2"   -- func_10326("HAN_CRG_TICKER_1", str, HUD_COLOUR_PURE_WHITE, HUD_COLOUR_PURE_WHITE, false);
    end

    if  checklkw:is_enabled() then--锁定名钻赌场幸运轮盘奖品--只影响实际结果，不影响转盘显示
        locals.set_int("casino_lucky_wheel","290","18") --luckyWheelOutcome: {('276', '14')}  LOCAL casino_lucky_wheel reward numbers: https://pastebin.com/HsW6QS31 
        --char* func_180() // Position - 0x7354   --return "CAS_LW_VEHI" /*Congratulations!~n~You won the podium vehicle.*/;
        --你可以自定义代码中的18来获取其他物品。设定为18是展台载具，16衣服，17经验，19现金，4载具折扣，11神秘礼品，15 chips不认识是什么
    end

    if  bkeasyms:is_enabled() then--锁定摩托帮出货任务 
        if locals.get_int("gb_biker_contraband_sell",716) ~= 0 then
            locals.set_int("gb_biker_contraband_sell",716,0) -- gb_biker_contraband_sell.c	randomIntInRange = MISC::GET_RANDOM_INT_IN_RANGE(0, 13); --iLocal_699.f_17 = randomIntInRange;
        end
    end

    if checkmiss:is_enabled() then --虎鲸导弹 冷却、距离
        globals.set_int(262145 + 30394, 0) --tuneables_processing.c IH_SUBMARINE_MISSILES_COOLDOWN
        globals.set_int(262145 + 30395, 80000) --tuneables_processing.c IH_SUBMARINE_MISSILES_DISTANCE
    end

    if checkbypassconv:is_enabled() then  --跳过NPC对话
        if AUDIO.IS_SCRIPTED_CONVERSATION_ONGOING() then
            AUDIO.STOP_SCRIPTED_CONVERSATION(false)
        end
    end

    if checkzhongjia:is_enabled() then --锁定请求重甲花费
        if iputintzhongjia:get_value() <= 500 then --防止有人拿删除钱设置为负反向刷钱  乐
            gui.show_error("mistake", "The amount needs to be greater than 500")
            checkzhongjia:set_enabled(nil)
            else
                globals.set_int(262145 + 20468, iputintzhongjia:get_value())--核心代码 --am_pi_menu.c  func_1277("PIM_TBALLI" /*BALLISTIC EQUIPMENT SERVICES*/);
            end
    end
end)


defpttable = {}
defpscount2 = 1
defpscount = 200 --刷200个模型

script.register_looped("schlua-defps", function() 

    if  checkspped:is_enabled() then--刷模型
        local sppedtarget = PLAYER.GET_PLAYER_PED(network.get_selected_player())
        if sppedtarget ~= PLAYER.PLAYER_PED_ID() then --避免目标离开战局后作用于自己
            request_model(0x705E61F2)
            local pcrds = ENTITY.GET_ENTITY_COORDS(sppedtarget, false)
            local spped = PED.CREATE_PED(26, 0x705E61F2, pcrds.x, pcrds.y, pcrds.z -1 , 0, true, false)
            WEAPON.GIVE_WEAPON_TO_PED(spped,-270015777,80,true,true)
            ENTITY.SET_ENTITY_HEALTH(spped,1000,true)
            MISC.SET_RIOT_MODE_ENABLED(true)
            script_util:sleep(30)
        else
            gui.show_message("Drop frame attack stopped", "you are attacking yourself!")
            checkspped:set_enabled(nil) --目标是自己，自动关掉开关
        end
    end
    
    if  audiospam:is_enabled() then--声音轰炸
        local targetplyped = PLAYER.GET_PLAYER_PED(network.get_selected_player())
        local pcrds = ENTITY.GET_ENTITY_COORDS(targetplyped, false)
           -- AUDIO.PLAY_SOUND_FROM_COORD(-1, "Air_Defences_Activated", pcrds.x, pcrds.y, pcrds.z, "DLC_sum20_Business_Battle_AC_Sounds", true, 999999999, true)
            AUDIO.PLAY_SOUND_FROM_COORD(-1, 'Event_Message_Purple', pcrds.x, pcrds.y, pcrds.z, 'GTAO_FM_Events_Soundset', true, 1000, false)
            AUDIO.PLAY_SOUND_FROM_COORD(-1, '5s', pcrds.x, pcrds.y, pcrds.z, 'GTAO_FM_Events_Soundset', true, 1000, false)
            AUDIO.PLAY_SOUND_FROM_COORD(-1,"10s",pcrds.x,pcrds.y,pcrds.z,"MP_MISSION_COUNTDOWN_SOUNDSET",true, 70, false)
    end

    if  check2:is_enabled() then--卡死玩家
        local defpstarget = PLAYER.GET_PLAYER_PED(network.get_selected_player())
        local targetcoords = ENTITY.GET_ENTITY_COORDS(defpstarget)
        
        local hash = joaat("tug")
        STREAMING.REQUEST_MODEL(hash)
        while not STREAMING.HAS_MODEL_LOADED(hash) do script_util:yield() end
        
        for i = 1, defpscount do
            if defpstarget ~= PLAYER.PLAYER_PED_ID() then --避免目标离开战局后作用于自己
            
            defpttable[defpscount2] = VEHICLE.CREATE_VEHICLE(hash, targetcoords.x, targetcoords.y, targetcoords.z, 0, true, true, true)
        
            local netID = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(defpttable[defpscount2])
            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(defpttable[defpscount2])
            NETWORK.NETWORK_REQUEST_CONTROL_OF_NETWORK_ID(netID)
            NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(netID)
            NETWORK.SET_NETWORK_ID_CAN_MIGRATE(netID, false)
            NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(netID, pid, true)
            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(defpttable[defpscount2], true, false)
            ENTITY.SET_ENTITY_VISIBLE(defpttable[defpscount2], false, 0)
            else
                gui.show_message("Drop frame attack stopped", "you are attacking yourself!")
                check2:set_enabled(nil)--目标是自己，自动关掉开关
            end
        end
        end

        if  check5:is_enabled() then --粒子效果轰炸
            local defpstarget = PLAYER.GET_PLAYER_PED(network.get_selected_player())
            local tar1 = ENTITY.GET_ENTITY_COORDS(defpstarget)
            local ptfx = {dic = 'scr_rcbarry2', name = 'scr_clown_appears'}
        
            if defpstarget ~= PLAYER.PLAYER_PED_ID() then --避免目标离开战局后作用于自己
                STREAMING.REQUEST_NAMED_PTFX_ASSET(ptfx.dic)
                while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(ptfx.dic) do
                    script_util:yield()
                end
                GRAPHICS.USE_PARTICLE_FX_ASSET(ptfx.dic)
                GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD( ptfx.name, tar1.x, tar1.y, tar1.z + 1, 0, 0, 0, 10.0, true, true, true)
            else
                gui.show_message("ptfx bombing stopped", "you are attacking yourself!")
                check5:set_enabled(nil)--目标是自己，自动关掉开关
            end

        end

        if  check8:is_enabled() then --水柱
            local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false) --获取目标玩家坐标
            FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z - 2.0, 13, 1, true, false, 0, false)
        end

        if  checknodmgexp:is_enabled() then --循环无伤爆炸
            local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false) --获取目标玩家坐标
            FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z, 1, 1, true, true, 1, true)
        end

end)

script.register_looped("schlua-miscservice", function() 
    if  checkfootaudio:is_enabled() then --控制自己是否产生脚步声
        AUDIO.SET_PED_FOOTSTEPS_EVENTS_ENABLED(PLAYER.PLAYER_PED_ID(),false)
        if loopa1 == 0 then --这段代码只会在开启开关时执行一次，而不是循环
            gui.show_message("footstep control","Mute")
        end
        loopa1 = 1
    else
        if loopa1 == 1 then     --这段代码只会在关掉开关时执行一次，而不是循环               
        AUDIO.SET_PED_FOOTSTEPS_EVENTS_ENABLED(PLAYER.PLAYER_PED_ID(),true)
        gui.show_message("footstep control","with sound")
        loopa1 = 0
        end
    end

    if  checkSONAR:is_enabled() then --控制sonar开关
        if loopa4 == 0 then  --这段代码只会在开启开关时执行一次，而不是循环
            HUD.SET_MINIMAP_SONAR_SWEEP(true)
            gui.show_message("sonar","turn on")
        end
        loopa4 = 1
    else
        if loopa4 == 1 then   
            HUD.SET_MINIMAP_SONAR_SWEEP(false)        
            gui.show_message("sonar","closure")
            loopa4 = 0
        end
    end

    if  disalight:is_enabled() then --控制世界灯光开关
        if loopa16 == 0 then
            GRAPHICS.SET_ARTIFICIAL_LIGHTS_STATE(true)
        end
        loopa16 = 1
    else
        if loopa16 == 1 then   
            GRAPHICS.SET_ARTIFICIAL_LIGHTS_STATE(false)
            loopa16 = 0
        end
    end

    if  vehgodr:is_enabled() then --控制远程Vehicle invincibility
        if loopa14 == 0 then
            if not PED.IS_PED_IN_ANY_VEHICLE(PLAYER.GET_PLAYER_PED(network.get_selected_player()),true) then
                gui.show_error("warn","Player is not in the vehicle")
                vehgodr:set_enabled(nil)
                loopa14 = 0
            else
                tarveh = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED(network.get_selected_player()))
                if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(tarveh)  then --先请求控制才能 修改其他玩家的载具状态
                    local netid = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(tarveh)
                    NETWORK.SET_NETWORK_ID_CAN_MIGRATE(netid, true)
                    local time = os.time()
                    while not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(tarveh) do
                        if os.time() - time >= 5 then
                            break
                        end
                        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(tarveh)
                        script_util:yield()
                    end
                end
                --如果未被作弊者拦截,理论上应该请求控制成功了
                ENTITY.SET_ENTITY_PROOFS(tarveh, true, true, true, true, true, 0, 0, true) --似乎没啥用...
                ENTITY.SET_ENTITY_INVINCIBLE(tarveh, true)
                VEHICLE.SET_VEHICLE_CAN_BE_VISIBLY_DAMAGED(tarveh, false)
                gui.show_message("Vehicle invincibility","applied")
                loopa14 = 1
            end
        end
    else
        if loopa14 == 1 then   
            if not PED.IS_PED_IN_ANY_VEHICLE(PLAYER.GET_PLAYER_PED(network.get_selected_player()),true) then
                gui.show_error("warn","Player is not in the vehicle")
                vehgodr:set_enabled(nil)
                loopa14 = 0
            else
                tarveh = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED(network.get_selected_player()))
                if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(tarveh)  then
                    local netid = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(tarveh)
                    NETWORK.SET_NETWORK_ID_CAN_MIGRATE(netid, true)
                    local time = os.time()
                    while not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(tarveh) do
                        if os.time() - time >= 5 then
                            break
                        end
                        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(tarveh)
                        script_util:yield()
                    end
                end
                ENTITY.SET_ENTITY_PROOFS(tarveh, false, false, false, false, false, 0, 0, false)
                ENTITY.SET_ENTITY_INVINCIBLE(tarveh, false)
                VEHICLE.SET_VEHICLE_CAN_BE_VISIBLY_DAMAGED(tarveh, true)
                gui.show_message("Vehicle invincibility","Revoked")
                loopa14 = 0
            end
        end
    end

    if  vehnoclr:is_enabled() then --控制远程Vehicle without collision
        if loopa15 == 0 then
            if not PED.IS_PED_IN_ANY_VEHICLE(PLAYER.GET_PLAYER_PED(network.get_selected_player()),true) then
                gui.show_error("warn","Player is not in the vehicle")
                vehnoclr:set_enabled(nil)
                loopa14 = 0
            else
                local tarveh2 = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED(network.get_selected_player()))
                if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(tarveh2)  then
                    local netid = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(tarveh2)
                    NETWORK.SET_NETWORK_ID_CAN_MIGRATE(netid, true)
                    local time = os.time()
                    while not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(tarveh2) do
                        if os.time() - time >= 5 then
                            break
                        end
                        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(tarveh2)
                        script_util:yield()
                    end
                end
                ENTITY.SET_ENTITY_COLLISION(tarveh2,false,false)
                gui.show_message("Vehicle without collision","applied")
                loopa15 = 1
            end
        end
    else
        if loopa15 == 1 then
            if not PED.IS_PED_IN_ANY_VEHICLE(PLAYER.GET_PLAYER_PED(network.get_selected_player()),true) then
                gui.show_error("warn","Player is not in the vehicle")
                vehnoclr:set_enabled(nil)
                loopa15 = 0
            else
                tarveh2 = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED(network.get_selected_player()))
                if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(tarveh2)  then
                    local netid = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(tarveh2)
                    NETWORK.SET_NETWORK_ID_CAN_MIGRATE(netid, true)
                    local time = os.time()
                    while not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(tarveh2) do
                        if os.time() - time >= 5 then
                            break
                        end
                        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(tarveh2)
                        script_util:yield()
                    end
                end
                ENTITY.SET_ENTITY_COLLISION(tarveh2,true,true)
                gui.show_message("Vehicle without collision","Revoked")
                loopa15 = 0
            end
        end
    end

    if  spcam:is_enabled() then --控制观看开关
        local TargetPPos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
        STREAMING.SET_FOCUS_POS_AND_VEL(TargetPPos.x, TargetPPos.y, TargetPPos.z, 0.0, 0.0, 0.0)

        if loopa13 == 0 then
            specam = CAM.CREATE_CAM("DEFAULT_SCRIPTED_CAMERA", false)
			CAM.SET_CAM_ACTIVE(specam, true)
			CAM.RENDER_SCRIPT_CAMS(true, true, 500, true, true, false)
            loopa13 = 1
        end
        rotation = CAM.GET_GAMEPLAY_CAM_ROT(2)
        CAM.SET_CAM_ROT(specam, rotation.x, rotation.y, rotation.z, 2)
        CAM.SET_CAM_COORD(specam, TargetPPos.x, TargetPPos.y, TargetPPos.z+5)

    else
        if loopa13 == 1 then     
            CAM.SET_CAM_ACTIVE(specam, false)
			CAM.RENDER_SCRIPT_CAMS(false, true, 500, true, true, 0)
			CAM.DESTROY_CAM(specam, false)
			STREAMING.CLEAR_FOCUS()    
            loopa13 = 0
        end
    end

    if  checkpedaudio:is_enabled() then --控制自己的PED是否产生声音
        PLAYER.SET_PLAYER_NOISE_MULTIPLIER(PLAYER.PLAYER_ID(), 0.0)
        if loopa3 == 0 then
            gui.show_message("PED sound control","Mute")
        end
        loopa3 = 1
    else
        if loopa3 == 1 then                    
        PLAYER.SET_PLAYER_NOISE_MULTIPLIER(PLAYER.PLAYER_ID(), 1.0)
        gui.show_message("PED sound control","with sound")
        loopa3 = 0
        end
    end

    if  disableAIdmg:is_enabled() then --覆写NPC伤害
        PED.SET_AI_WEAPON_DAMAGE_MODIFIER(0.0)
        PED.SET_AI_MELEE_WEAPON_DAMAGE_MODIFIER(0.0)
        loopa8 = 1
    else
    if loopa8 == 1 then 
        PED.RESET_AI_WEAPON_DAMAGE_MODIFIER()
        PED.RESET_AI_MELEE_WEAPON_DAMAGE_MODIFIER()
        gui.show_message("prompt","NPC damage restored")
    loopa8 = 0
    end
    end

    if  check666:is_enabled() then --控制Head666生成与remove
        if loopa2 == 0 then
            local md6 = "prop_mp_num_6"
            local user_ped = PLAYER.PLAYER_PED_ID()
            md6hash = joaat(md6)
        
            STREAMING.REQUEST_MODEL(md6hash)
            while not STREAMING.HAS_MODEL_LOADED(md6hash) do		
                script_util:yield()
            end
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(md6hash)
        
            objectsix1 = OBJECT.CREATE_OBJECT(md6hash, 0.0,0.0,0, true, true, false)
            ENTITY.ATTACH_ENTITY_TO_ENTITY(objectsix1, user_ped, PED.GET_PED_BONE_INDEX(PLAYER.PLAYER_PED_ID(), 0), 0.0, 0, 1.7, 0, 0, 0, false, false, false, false, 2, true) 
        
            STREAMING.REQUEST_MODEL(md6hash)
            while not STREAMING.HAS_MODEL_LOADED(md6hash) do		
                script_util:yield()
            end
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(md6hash)
        
            objectsix2 = OBJECT.CREATE_OBJECT(md6hash, 0.0,0.0,0, true, true, false)
            ENTITY.ATTACH_ENTITY_TO_ENTITY(objectsix2, user_ped, PED.GET_PED_BONE_INDEX(PLAYER.PLAYER_PED_ID(), 0), 1.0, 0, 1.7, 0, 0, 0, false, false, false, false, 2, true) 
        
            STREAMING.REQUEST_MODEL(md6hash)
            while not STREAMING.HAS_MODEL_LOADED(md6hash) do		
                script_util:yield()
            end
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(md6hash)
        
            objectsix3 = OBJECT.CREATE_OBJECT(md6hash, 0.0,0.0,0, true, true, false)
            ENTITY.ATTACH_ENTITY_TO_ENTITY(objectsix3, user_ped, PED.GET_PED_BONE_INDEX(PLAYER.PLAYER_PED_ID(), 0), -1.0, 0, 1.7, 0, 0, 0, false, false, false, false, 2, true) 
        
            gui.show_message("Head666","generate")
        end
        loopa2 = 1
    else
        if loopa2 == 1 then 
            ENTITY.DELETE_ENTITY(objectsix1)
            ENTITY.DELETE_ENTITY(objectsix2)
            ENTITY.DELETE_ENTITY(objectsix3)
            gui.show_message("Head666","remove")
            loopa2 = 0
        end
    end

    if  check520:is_enabled() then --控制Overhead 520生成与remove
        if loopa17 == 0 then
            local num5 = "prop_mp_num_2"
            local num2 = "prop_mp_num_5"
            local num0 = "prop_mp_num_0"
            local user_ped = PLAYER.PLAYER_PED_ID()
            num5hash = joaat(num5)
            num2hash = joaat(num2)
            num0hash = joaat(num0)
        
            STREAMING.REQUEST_MODEL(num5hash)
            while not STREAMING.HAS_MODEL_LOADED(num5hash) do		
                script_util:yield()
            end
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(num5hash)
        
            object5201 = OBJECT.CREATE_OBJECT(num5hash, 0.0,0.0,0, true, true, false)
            ENTITY.ATTACH_ENTITY_TO_ENTITY(object5201, user_ped, PED.GET_PED_BONE_INDEX(PLAYER.PLAYER_PED_ID(), 0), 0.0, 0, 1.7, 0, 0, 0, false, false, false, false, 2, true) 
        
            STREAMING.REQUEST_MODEL(num2hash)
            while not STREAMING.HAS_MODEL_LOADED(num2hash) do		
                script_util:yield()
            end
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(num2hash)
        
            object5202 = OBJECT.CREATE_OBJECT(num2hash, 0.0,0.0,0, true, true, false)
            ENTITY.ATTACH_ENTITY_TO_ENTITY(object5202, user_ped, PED.GET_PED_BONE_INDEX(PLAYER.PLAYER_PED_ID(), 0),  -1.0, 0, 1.7, 0, 0, 0, false, false, false, false, 2, true) 
        
            STREAMING.REQUEST_MODEL(num0hash)
            while not STREAMING.HAS_MODEL_LOADED(num0hash) do		
                script_util:yield()
            end
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(num0hash)
        
            object5203 = OBJECT.CREATE_OBJECT(num0hash, 0.0,0.0,0, true, true, false)
            ENTITY.ATTACH_ENTITY_TO_ENTITY(object5203, user_ped, PED.GET_PED_BONE_INDEX(PLAYER.PLAYER_PED_ID(), 0),   1.0, 0, 1.7, 0, 0, 0, false, false, false, false, 2, true) 
        
            gui.show_message("Overhead 520","generate")
        end
        loopa17 = 1
    else
        if loopa17 == 1 then 
            ENTITY.DELETE_ENTITY(object5201)
            ENTITY.DELETE_ENTITY(object5202)
            ENTITY.DELETE_ENTITY(object5203)
            gui.show_message("Overhead 520","remove")
            loopa17 = 0
        end
    end

    if  firemt:is_enabled() then --控制Ghost Rider
        if loopa10 == 0 then
        while not STREAMING.HAS_MODEL_LOADED(joaat("sanctus")) do		
            STREAMING.REQUEST_MODEL(joaat("sanctus"))
            script_util:yield()
        end
        firemtcrtveh = VEHICLE.CREATE_VEHICLE(joaat("sanctus"), ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(),false).x, ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(),false).y, ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(),false).z, 0 , true, true, true)
        ENTITY.SET_ENTITY_RENDER_SCORCHED(firemtcrtveh,true) --烧焦效果
        ENTITY.SET_ENTITY_INVINCIBLE(firemtcrtveh,true)  --Vehicle invincibility
        VEHICLE.SET_VEHICLE_EXTRA_COLOURS(firemtcrtveh,30,15)
        PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(),firemtcrtveh,-1) --坐进载具
        script_util:sleep(500) 
        while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("core") do
            STREAMING.REQUEST_NAMED_PTFX_ASSET("core")
            script_util:yield()               
        end
        while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("weap_xs_vehicle_weapons") do
            STREAMING.REQUEST_NAMED_PTFX_ASSET("weap_xs_vehicle_weapons")
            script_util:yield()               
        end
        local vehbone3 = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(firemtcrtveh, "wheel_rr")
        local vehbone4 = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(firemtcrtveh, "wheel_rf")
        GRAPHICS.USE_PARTICLE_FX_ASSET("core")
        vehptfx6 = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE("fire_wrecked_plane_cockpit", firemtcrtveh, 0.0, 0.9, 0.0, 170.0, 0.0, 0.0, vehbone3, 1.0, false, false, false, 0, 0, 0, 0)
        GRAPHICS.USE_PARTICLE_FX_ASSET("core")
        vehptfx7 = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE("fire_wrecked_plane_cockpit", firemtcrtveh, 0.0, -0.9, -0.0, 170.0, 0.0, 0.0, vehbone3, 1.0, false, false, false, 0, 0, 0, 0)
        GRAPHICS.USE_PARTICLE_FX_ASSET("weap_xs_vehicle_weapons")
        vehptfx3 = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE("muz_xs_turret_flamethrower_looping", firemtcrtveh, 0.0, 0.7, 0.0, 170.0, 0.0, 0.0, vehbone3, 1.0, false, false, false, 0, 0, 0, 0)
        GRAPHICS.USE_PARTICLE_FX_ASSET("weap_xs_vehicle_weapons")
        vehptfx2 = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE("muz_xs_turret_flamethrower_looping", firemtcrtveh, 0.0, 0.0, 1.0, 170.0, 0.0, 0.0, vehbone3, 1.0, false, false, false, 0, 0, 0, 0)
        GRAPHICS.USE_PARTICLE_FX_ASSET("weap_xs_vehicle_weapons")
        vehptfx1 = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE("muz_xs_turret_flamethrower_looping", firemtcrtveh, 0.0, 0.7, 0.4, 170.0, 0.0, 0.0, vehbone3, 1.0, false, false, false, 0, 0, 0, 0)
        GRAPHICS.USE_PARTICLE_FX_ASSET("weap_xs_vehicle_weapons")
        vehptfx4 = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE("muz_xs_turret_flamethrower_looping", firemtcrtveh, -0.5, 0.7, 0.3, 180.0, 0.0, 0.0, vehbone3, 1.0, false, false, false, 0, 0, 0, 0)
        GRAPHICS.USE_PARTICLE_FX_ASSET("weap_xs_vehicle_weapons")
        vehptfx5 = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE("muz_xs_turret_flamethrower_looping", firemtcrtveh, 0.5, 0.7, 0.3, 180.0, 0.0, 0.0, vehbone3, 1.0, false, false, false, 0, 0, 0, 0)
        GRAPHICS.SET_PARTICLE_FX_LOOPED_COLOUR(vehptfx7, 100, 100, 100, false)
        GRAPHICS.SET_PARTICLE_FX_LOOPED_COLOUR(vehptfx6, 100, 100, 100, false)
        GRAPHICS.SET_PARTICLE_FX_LOOPED_COLOUR(vehptfx2, 100, 100, 100, false)
        GRAPHICS.SET_PARTICLE_FX_LOOPED_COLOUR(vehptfx3, 100, 100, 100, false)
        GRAPHICS.SET_PARTICLE_FX_LOOPED_COLOUR(vehptfx4, 100, 100, 100, false)
        GRAPHICS.SET_PARTICLE_FX_LOOPED_COLOUR(vehptfx5, 100, 100, 100, false)

        GRAPHICS.SET_PARTICLE_FX_LOOPED_COLOUR(vehptfx1, 200, 200, 200, false)
        
        gui.show_message("Ghost Rider","open")
        end
        loopa10 = 1
    else
        if loopa10 == 1 then 
            ENTITY.DELETE_ENTITY(firemtcrtveh)
            gui.show_message("Ghost Rider","close")
            loopa10 = 0
        end
    end

    if  check6:is_enabled() then --随处游泳
        PED.SET_PED_CONFIG_FLAG(PLAYER.PLAYER_PED_ID(), 65, 81) --锁定玩家状态为游泳
    end

    if vehboost:is_enabled() then --载具加速
        if PAD.IS_CONTROL_PRESSED(0, 352) and PED.IS_PED_IN_ANY_VEHICLE(PLAYER.PLAYER_PED_ID()) then --按下Shift且在载具中
            --https://docs.fivem.net/docs/game-references/controls/ 如需自定义，查询控制键位对应的数字，替换掉352即可
            local vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
            local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
            local camrot = CAM.GET_GAMEPLAY_CAM_ROT(0)  
            ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(vehicle, 1, 0, 1, 0, false, true, true, true)
        end
    end

    if  pedgun:is_enabled() then --NPC枪
        local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
        local camrot = CAM.GET_GAMEPLAY_CAM_ROT(0)  
        if PED.IS_PED_SHOOTING(PLAYER.PLAYER_PED_ID()) then 
            peds = PED.CREATE_RANDOM_PED(pos.x, pos.y, pos.z)    
            ENTITY.SET_ENTITY_ROTATION(peds, camrot.x, camrot.y, camrot.z, 1, false)    
            ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(peds, 1, 0, 1000, 0, false, true, true, true)
            ENTITY.SET_ENTITY_HEALTH(peds,1000,true)
        end
    end

    if  bsktgun:is_enabled() then --篮球枪
        local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
        local camrot = CAM.GET_GAMEPLAY_CAM_ROT(0)
        objhash = joaat("prop_bskball_01")
        while not STREAMING.HAS_MODEL_LOADED(objhash) do		
            STREAMING.REQUEST_MODEL(objhash)
            script_util:yield()
        end
        if PED.IS_PED_SHOOTING(PLAYER.PLAYER_PED_ID()) then 
            bskt = OBJECT.CREATE_OBJECT(objhash,pos.x, pos.y, pos.z, true, true, false)
            ENTITY.SET_ENTITY_ROTATION(bskt, camrot.x, camrot.y, camrot.z, 1, false)    
            ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(bskt, 1, 0, 1000, 0, false, true, true, true)
        end
    end

    if  bballgun:is_enabled() then --大球枪
        local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
        local camrot = CAM.GET_GAMEPLAY_CAM_ROT(0)
        objhash = joaat("v_ilev_exball_blue")
        while not STREAMING.HAS_MODEL_LOADED(objhash) do		
            STREAMING.REQUEST_MODEL(objhash)
            script_util:yield()
        end
        if PED.IS_PED_SHOOTING(PLAYER.PLAYER_PED_ID()) then 
            bskt = OBJECT.CREATE_OBJECT(objhash,pos.x, pos.y, pos.z, true, true, false)
            ENTITY.SET_ENTITY_ROTATION(bskt, camrot.x, camrot.y, camrot.z, 1, false)    
            ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(bskt, 1, 0, 1000, 0, false, true, true, true)
        end
    end

    if  pedvehctl:is_enabled() then --玩家选项-载具旋转
        if not PED.IS_PED_IN_ANY_VEHICLE(PLAYER.GET_PLAYER_PED(network.get_selected_player()),true) then
            gui.show_error("warn","Player is not in the vehicle")
        else
            tarveh = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED(network.get_selected_player()))
            if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(tarveh)  then
                local netid = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(tarveh)
                NETWORK.SET_NETWORK_ID_CAN_MIGRATE(netid, true)
                local time = os.time()
                while not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(tarveh) do
                    if os.time() - time >= 5 then
                        break
                    end
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(tarveh)
                    script_util:yield()
                end
            end
            ENTITY.APPLY_FORCE_TO_ENTITY(tarveh, 5, 0, 0, 150.0, 0, 0, 0, 0, true, false, true, false, true)
        end
    end

    if  drawcs:is_enabled() then --绘制准星
        HUD.BEGIN_TEXT_COMMAND_DISPLAY_TEXT("STRING") --The following were found in the decompiled script files: STRING, TWOSTRINGS, NUMBER, PERCENTAGE, FO_TWO_NUM, ESMINDOLLA, ESDOLLA, MTPHPER_XPNO, AHD_DIST, CMOD_STAT_0, CMOD_STAT_1, CMOD_STAT_2, CMOD_STAT_3, DFLT_MNU_OPT, F3A_TRAFDEST, ES_HELP_SOC3
        HUD.SET_TEXT_FONT(0)
        HUD.SET_TEXT_SCALE(0.3, 0.3) --Size range : 0F to 1.0F --p0 is unknown and doesn't seem to have an effect, yet in the game scripts it changes to 1.0F sometimes.
        HUD.SET_TEXT_OUTLINE()
        HUD.SET_TEXT_CENTRE(1)
        HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(string.format("+"))
        HUD.END_TEXT_COMMAND_DISPLAY_TEXT(0.5,0.485) --占坐标轴的比例
    end

    if  disablecops:is_enabled() then --控制是否派遣警察
        PLAYER.SET_DISPATCH_COPS_FOR_PLAYER(PLAYER.PLAYER_ID(), false)
        loopa7 = 1
    else
        if loopa7 == 1 then 
        PLAYER.SET_DISPATCH_COPS_FOR_PLAYER(PLAYER.PLAYER_ID(), true)
        gui.show_message("prompt","Police are dispatched when wanted")
        loopa7 = 0
        end
    end

    if  disapedheat:is_enabled() then --控制是否存在热量
        if loopa11 == 0 then 
            PED.SET_PED_HEATSCALE_OVERRIDE(PLAYER.PLAYER_ID(), 0)
            loopa11 = 1
        end
    else
        if loopa11 == 1 then 
            PED.SET_PED_HEATSCALE_OVERRIDE(PLAYER.PLAYER_ID(), 1)
            loopa11 = 0
        end
    end

    if  canafrdly:is_enabled() then --控制是否允许攻击队友
        if loopa12 == 0 then 
            PED.SET_CAN_ATTACK_FRIENDLY(PLAYER.PLAYER_ID(), true, false)
            loopa12 = 1
        end
    else
        if loopa12 == 1 then 
            PED.SET_CAN_ATTACK_FRIENDLY(PLAYER.PLAYER_ID(), false, false)
            loopa12 = 0
        end
    end

    if  desync:is_enabled() then --创建新手教程战局以取消与其他玩家同步
        if loopa9 == 0 then
            NETWORK.NETWORK_START_SOLO_TUTORIAL_SESSION()
            gui.show_message("cancel sync","Will unsync with all players")
        end
        loopa9 = 1
    else
        if loopa9 == 1 then                    
            NETWORK.NETWORK_END_TUTORIAL_SESSION()
            gui.show_message("cancel sync","close")
        loopa9 = 0
        end
    end

    if  ptfxrm:is_enabled() then --清理PTFX和火焰效果
        local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
        FIRE.STOP_FIRE_IN_RANGE(selfpos.x, selfpos.y, selfpos.z, 500)
        FIRE.STOP_ENTITY_FIRE(PLAYER.PLAYER_PED_ID())    
        GRAPHICS.REMOVE_PARTICLE_FX_IN_RANGE(selfpos.x, selfpos.y, selfpos.z, 1000)
        GRAPHICS.REMOVE_PARTICLE_FX_FROM_ENTITY(PLAYER.PLAYER_PED_ID())
    else
    end

    if  DECALrm:is_enabled() then --清理弹孔、血渍、油污等表面特征
        local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
        GRAPHICS.REMOVE_DECALS_IN_RANGE(selfpos.x, selfpos.y, selfpos.z, 100)
    else
    end

end)

script.register_looped("schlua-ectrlervice", function() 
    
    if  vehengdmg:is_enabled() then --控制载具引擎破坏
        local vehtable = entities.get_all_vehicles_as_handles()
        local vehisin = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
        for _, vehicle in pairs(vehtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
            local vehicle_pos = ENTITY.GET_ENTITY_COORDS(vehicle)
            if calcDistance(selfpos, vehicle_pos) <= npcctrlr:get_value() then
                if vehicle ~= vehisin then
                    VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, -4000)
                end
            end
        end
    end
        
    if  vehjmpr:is_enabled() then --控制载具跳跃
        local vehtable = entities.get_all_vehicles_as_handles()
        local vehisin = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
        for _, vehicle in pairs(vehtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
            local vehicle_pos = ENTITY.GET_ENTITY_COORDS(vehicle)
            if calcDistance(selfpos, vehicle_pos) <= npcctrlr:get_value() then
                if vehicle ~= vehisin then
                    ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 3, 0, 0, 10, 0.0, 0.0, 0.0, 0, true, false, true, false, true)
                end
            end
        end
        script_util:sleep(2500)
        ENTITY.SET_ENTITY_ROTATION(vehicle,0,0,0,2,true)
    end

    if  vehbr:is_enabled() then --控制载具混乱
        local vehtable = entities.get_all_vehicles_as_handles()
        local vehisin = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
        for _, vehicle in pairs(vehtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
            local vehicle_pos = ENTITY.GET_ENTITY_COORDS(vehicle)
            if calcDistance(selfpos, vehicle_pos) <= npcctrlr:get_value() then
                if vehicle ~= vehisin then
                    ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, math.random(0, 3), math.random(0, 3), math.random(-3, 1), 0.0, 0.0, 0.0, 0, true, false, true, false, true)
                end
            end
        end
    end
        
    if  vehdoorlk4p:is_enabled() then --控制载具锁门
        local vehtable = entities.get_all_vehicles_as_handles()
        local vehisin = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
        for _, vehicle in pairs(vehtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
            local vehicle_pos = ENTITY.GET_ENTITY_COORDS(vehicle)
            if calcDistance(selfpos, vehicle_pos) <= npcctrlr:get_value() then
                if vehicle ~= vehisin then
                    VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(vehicle, true)
                end
            end
        end
        loopa18 = 1
    else
        if loopa18 == 1 then
            local vehtable = entities.get_all_vehicles_as_handles()
            local vehisin = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
            for _, vehicle in pairs(vehtable) do
                local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
                local vehicle_pos = ENTITY.GET_ENTITY_COORDS(vehicle)
                if calcDistance(selfpos, vehicle_pos) <= npcctrlr:get_value() then
                    if vehicle ~= vehisin then
                        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(vehicle, false)
                    end
                end
            end
            gui.show_message("prompt","unlocked") 
        end
        loopa18 = 0
    end

    if  vehstopr:is_enabled() then --控制载具停止
        local vehtable = entities.get_all_vehicles_as_handles()
        local vehisin = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
        for _, vehicle in pairs(vehtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
            local vehicle_pos = ENTITY.GET_ENTITY_COORDS(vehicle)
            if calcDistance(selfpos, vehicle_pos) <= npcctrlr:get_value() then
                if vehicle ~= vehisin then
                    ENTITY.SET_ENTITY_VELOCITY(vehicle,0,0,0)
                end
            end
        end
    end

    if  vehfixr:is_enabled() then --控制载具修理
        local vehtable = entities.get_all_vehicles_as_handles()
        local vehisin = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
        for _, vehicle in pairs(vehtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
            local vehicle_pos = ENTITY.GET_ENTITY_COORDS(vehicle)
            if calcDistance(selfpos, vehicle_pos) <= npcctrlr:get_value() then
                VEHICLE.SET_VEHICLE_FIXED(vehicle)
            end
        end
    end

    if  vehforcefield:is_enabled() then --控制载具力场
        local vehtable = entities.get_all_vehicles_as_handles()
        local vehisin = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
        for _, vehicle in pairs(vehtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
            local vehicle_pos = ENTITY.GET_ENTITY_COORDS(vehicle)
            if calcDistance(selfpos, vehicle_pos) <= ffrange:get_value() then
                if vehicle ~= vehisin then
                    ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 3, 0, 0, 3, 0, 0, 0.5, 0, false, false, true, false, false)
                end
            end
        end
    end
    
    if  objforcefield:is_enabled() then --控制物体力场
        local onjtable = entities.get_all_objects_as_handles()
        local vehisin = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
        for _, aobj in pairs(onjtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
            local aobj_pos = ENTITY.GET_ENTITY_COORDS(aobj)
            if calcDistance(selfpos, aobj_pos) <= ffrange:get_value() then
                if aobj ~= vehisin then
                    ENTITY.APPLY_FORCE_TO_ENTITY(aobj, 3, 0, 0, 3, 0, 0, 0.5, 0, false, false, true, false, false)
                end
            end
        end
    end

    if  pedforcefield:is_enabled() then --控制NPC力场
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds)
            if calcDistance(selfpos, ped_pos) <= ffrange:get_value() and peds ~= PLAYER.PLAYER_PED_ID() then 
                if PED.IS_PED_IN_ANY_VEHICLE(peds) then
                    tarpensveh = PED.GET_VEHICLE_PED_IS_IN(peds)
                    ENTITY.APPLY_FORCE_TO_ENTITY(tarpensveh, 3, 0, 0, 2, 0, 0, 0.5, 0, false, false, true, false, false)
                else
                    ENTITY.APPLY_FORCE_TO_ENTITY(peds, 3, 0, 0, 2, 0, 0, 0.5, 0, false, false, true, false, false)
                end
            end
        end
    end
    
    if  forcefield:is_enabled() then --控制力场
        local vehtable = entities.get_all_vehicles_as_handles()
        local vehisin = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
        for _, vehicle in pairs(vehtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
            local vehicle_pos = ENTITY.GET_ENTITY_COORDS(vehicle)
            if calcDistance(selfpos, vehicle_pos) <= ffrange:get_value() then
                if vehicle ~= vehisin then
                    ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 3, 0, 0, 3, 0, 0, 0.5, 0, false, false, true, false, false)
                end
            end
        end
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds)
            if calcDistance(selfpos, ped_pos) <= ffrange:get_value() and peds ~= PLAYER.PLAYER_PED_ID() then 
                if PED.IS_PED_IN_ANY_VEHICLE(peds) then
                    tarpensveh = PED.GET_VEHICLE_PED_IS_IN(peds)
                    ENTITY.APPLY_FORCE_TO_ENTITY(tarpensveh, 3, 0, 0, 2, 0, 0, 0.5, 0, false, false, true, false, false)
                else
                    ENTITY.APPLY_FORCE_TO_ENTITY(peds, 3, 0, 0, 2, 0, 0, 0.5, 0, false, false, true, false, false)
                end
            end
        end
    end

    if  aimreact:is_enabled() then --控制NPC瞄准惩罚1-中断
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds)
            if PED.IS_PED_FACING_PED(peds, PLAYER.PLAYER_PED_ID(), 2) and ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(peds, PLAYER.PLAYER_PED_ID(), 17) and calcDistance(selfpos, ped_pos) <= npcaimprange:get_value()  and PED.GET_PED_CONFIG_FLAG(peds, 78, true) then 
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(peds)
            end
        end
    end

    if  aimreact1:is_enabled() then --控制NPC瞄准惩罚2 -摔倒
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds)
            if PED.IS_PED_FACING_PED(peds, PLAYER.PLAYER_PED_ID(), 2) and ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(peds, PLAYER.PLAYER_PED_ID(), 17) and calcDistance(selfpos, ped_pos) <= npcaimprange:get_value()  and PED.GET_PED_CONFIG_FLAG(peds, 78, true) then 
                PED.SET_PED_TO_RAGDOLL(peds, 5000, 0,0 , false, false, false)
            end
        end
    end

    if  aimreact2:is_enabled() then --控制NPC瞄准惩罚3 -死亡
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds)
            if PED.IS_PED_FACING_PED(peds, PLAYER.PLAYER_PED_ID(), 2) and ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(peds, PLAYER.PLAYER_PED_ID(), 17) and calcDistance(selfpos, ped_pos) <= npcaimprange:get_value()  and PED.GET_PED_CONFIG_FLAG(peds, 78, true) then 
                ENTITY.SET_ENTITY_HEALTH(peds,0,true)
            end
        end
    end

    if  aimreact3:is_enabled() then --控制NPC瞄准惩罚3 -燃烧
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds)
            if PED.IS_PED_FACING_PED(peds, PLAYER.PLAYER_PED_ID(), 2) and ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(peds, PLAYER.PLAYER_PED_ID(), 17) and calcDistance(selfpos, ped_pos) <= npcaimprange:get_value()  and PED.GET_PED_CONFIG_FLAG(peds, 78, true) then 
                FIRE.START_ENTITY_FIRE(peds)
                FIRE.START_SCRIPT_FIRE(ped_pos.x, ped_pos.y, ped_pos.z, 25, true)
                FIRE.ADD_EXPLOSION(ped_pos.x, ped_pos.y, ped_pos.z, 3, 1, false, false, 0, false);
            end
        end
    end

    if  aimreact6:is_enabled() then --控制NPC瞄准惩罚6 -remove
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds)
            if PED.IS_PED_FACING_PED(peds, PLAYER.PLAYER_PED_ID(), 2) and ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(peds, PLAYER.PLAYER_PED_ID(), 17) and calcDistance(selfpos, ped_pos) <= npcaimprange:get_value()  and PED.GET_PED_CONFIG_FLAG(peds, 78, true) then 
                ENTITY.SET_ENTITY_AS_MISSION_ENTITY(peds,true,true) --不执行这个下面会删除失败
                ENTITY.DELETE_ENTITY(peds)            
            end
        end
    end

    if  aimreact4:is_enabled() then --控制NPC瞄准惩罚4 -起飞
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds)
            if PED.IS_PED_FACING_PED(peds, PLAYER.PLAYER_PED_ID(), 2) and ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(peds, PLAYER.PLAYER_PED_ID(), 17) and calcDistance(selfpos, ped_pos) <= npcaimprange:get_value()  and PED.GET_PED_CONFIG_FLAG(peds, 78, true) then 
                if PED.IS_PED_IN_ANY_VEHICLE(peds) then
                    tarpensveh = PED.GET_VEHICLE_PED_IS_IN(peds)
                    ENTITY.APPLY_FORCE_TO_ENTITY(tarpensveh, 3, 0, 0, 2, 0, 0, 0.5, 0, false, false, true, false, false)
                else
                    ENTITY.APPLY_FORCE_TO_ENTITY(peds, 3, 0, 0, 2, 0, 0, 0.5, 0, false, false, true, false, false)
                end
            end
        end
    end
    
    if  aimreact5:is_enabled() then --控制NPC瞄准惩罚5 -收为保镖
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds)
            if PED.IS_PED_FACING_PED(peds, PLAYER.PLAYER_PED_ID(), 2) and ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(peds, PLAYER.PLAYER_PED_ID(), 17) and calcDistance(selfpos, ped_pos) <= npcaimprange:get_value()  and PED.GET_PED_CONFIG_FLAG(peds, 78, true) then 
                TASK.CLEAR_PED_TASKS(peds)
                PED.SET_PED_AS_GROUP_MEMBER(peds, PED.GET_PED_GROUP_INDEX(PLAYER.PLAYER_PED_ID()))
                PED.SET_PED_RELATIONSHIP_GROUP_HASH(peds, PED.GET_PED_RELATIONSHIP_GROUP_HASH(PLAYER.PLAYER_PED_ID()))
                PED.SET_PED_NEVER_LEAVES_GROUP(peds, true)
                PED.SET_CAN_ATTACK_FRIENDLY(peds, 0, 1)
                PED.SET_PED_COMBAT_ABILITY(peds, 2)
                PED.SET_PED_CAN_TELEPORT_TO_GROUP_LEADER(peds, PED.GET_PED_GROUP_INDEX(PLAYER.PLAYER_PED_ID()), true)
                PED.SET_PED_FLEE_ATTRIBUTES(peds, 512, true)
                PED.SET_PED_FLEE_ATTRIBUTES(peds, 1024, true)
                PED.SET_PED_FLEE_ATTRIBUTES(peds, 2048, true)
                PED.SET_PED_FLEE_ATTRIBUTES(peds, 16384, true)
                PED.SET_PED_FLEE_ATTRIBUTES(peds, 131072, true)
                PED.SET_PED_FLEE_ATTRIBUTES(peds, 262144, true)
                PED.SET_PED_COMBAT_ATTRIBUTES(peds, 5, true)
                PED.SET_PED_COMBAT_ATTRIBUTES(peds, 13, true)
                PED.SET_PED_CONFIG_FLAG(peds, 394, true)
                PED.SET_PED_CONFIG_FLAG(peds, 400, true)
                PED.SET_PED_CONFIG_FLAG(peds, 134, true)
                WEAPON.GIVE_WEAPON_TO_PED(peds, joaat("weapon_combating_mk2"), 9999, false, false)
                PED.SET_PED_ACCURACY(peds,100)
                TASK.TASK_COMBAT_HATED_TARGETS_AROUND_PED(PLAYER.PLAYER_PED_ID(), 100, 67108864)
                ENTITY.SET_ENTITY_HEALTH(peds,1000,true)
            end
        end
    end

    if  aimreactany:is_enabled() then --控制NPC瞄准任何人惩罚1-中断
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds)
            if calcDistance(selfpos, ped_pos) <= npcaimprange:get_value()  and PED.GET_PED_CONFIG_FLAG(peds, 78, true) and peds ~= PLAYER.PLAYER_PED_ID() then 
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(peds)
            end
        end
    end

    if  aimreact1any:is_enabled() then --控制NPC瞄准任何人惩罚2 -摔倒
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds)
            if calcDistance(selfpos, ped_pos) <= npcaimprange:get_value()  and PED.GET_PED_CONFIG_FLAG(peds, 78, true) and peds ~= PLAYER.PLAYER_PED_ID() then 
                PED.SET_PED_TO_RAGDOLL(peds, 5000, 0,0 , false, false, false)
            end
        end
    end

    if  aimreact2any:is_enabled() then --控制NPC瞄准任何人惩罚3 -死亡
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds)
            if calcDistance(selfpos, ped_pos) <= npcaimprange:get_value()  and PED.GET_PED_CONFIG_FLAG(peds, 78, true) and peds ~= PLAYER.PLAYER_PED_ID() then 
                ENTITY.SET_ENTITY_HEALTH(peds,0,true)
            end
        end
    end

    if  aimreact3any:is_enabled() then --控制NPC瞄准任何人惩罚3 -燃烧
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds)
            if calcDistance(selfpos, ped_pos) <= npcaimprange:get_value()  and PED.GET_PED_CONFIG_FLAG(peds, 78, true) and peds ~= PLAYER.PLAYER_PED_ID() then 
                FIRE.START_ENTITY_FIRE(peds)
                FIRE.START_SCRIPT_FIRE(ped_pos.x, ped_pos.y, ped_pos.z, 25, true)
                FIRE.ADD_EXPLOSION(ped_pos.x, ped_pos.y, ped_pos.z, 3, 1, false, false, 0, false);
            end
        end
    end

    if  aimreact6any:is_enabled() then --控制NPC瞄准任何人惩罚6 -remove
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds)
            if calcDistance(selfpos, ped_pos) <= npcaimprange:get_value()  and PED.GET_PED_CONFIG_FLAG(peds, 78, true) and peds ~= PLAYER.PLAYER_PED_ID() then 
                ENTITY.SET_ENTITY_AS_MISSION_ENTITY(peds,true,true) --不执行这个下面会删除失败
                ENTITY.DELETE_ENTITY(peds)            
            end
        end
    end

    if  aimreact4any:is_enabled() then --控制NPC瞄准任何人惩罚4 -起飞
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds)
            if calcDistance(selfpos, ped_pos) <= npcaimprange:get_value()  and PED.GET_PED_CONFIG_FLAG(peds, 78, true) and peds ~= PLAYER.PLAYER_PED_ID() then 
                if PED.IS_PED_IN_ANY_VEHICLE(peds) then
                    tarpensveh = PED.GET_VEHICLE_PED_IS_IN(peds)
                    ENTITY.APPLY_FORCE_TO_ENTITY(tarpensveh, 3, 0, 0, 2, 0, 0, 0.5, 0, false, false, true, false, false)
                else
                    ENTITY.APPLY_FORCE_TO_ENTITY(peds, 3, 0, 0, 2, 0, 0, 0.5, 0, false, false, true, false, false)
                end
            end
        end
    end

    if  aimreact5any:is_enabled() then --控制NPC瞄准任何人惩罚4 -收为保镖
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds)
            if calcDistance(selfpos, ped_pos) <= npcaimprange:get_value()  and PED.GET_PED_CONFIG_FLAG(peds, 78, true) and peds ~= PLAYER.PLAYER_PED_ID() then 
                TASK.CLEAR_PED_TASKS(peds)
                PED.SET_PED_AS_GROUP_MEMBER(peds, PED.GET_PED_GROUP_INDEX(PLAYER.PLAYER_PED_ID()))
                PED.SET_PED_RELATIONSHIP_GROUP_HASH(peds, PED.GET_PED_RELATIONSHIP_GROUP_HASH(PLAYER.PLAYER_PED_ID()))
                PED.SET_PED_NEVER_LEAVES_GROUP(peds, true)
                PED.SET_CAN_ATTACK_FRIENDLY(peds, 0, 1)
                PED.SET_PED_COMBAT_ABILITY(peds, 2)
                PED.SET_PED_CAN_TELEPORT_TO_GROUP_LEADER(peds, PED.GET_PED_GROUP_INDEX(PLAYER.PLAYER_PED_ID()), true)
                PED.SET_PED_FLEE_ATTRIBUTES(peds, 512, true)
                PED.SET_PED_FLEE_ATTRIBUTES(peds, 1024, true)
                PED.SET_PED_FLEE_ATTRIBUTES(peds, 2048, true)
                PED.SET_PED_FLEE_ATTRIBUTES(peds, 16384, true)
                PED.SET_PED_FLEE_ATTRIBUTES(peds, 131072, true)
                PED.SET_PED_FLEE_ATTRIBUTES(peds, 262144, true)
                PED.SET_PED_COMBAT_ATTRIBUTES(peds, 5, true)
                PED.SET_PED_COMBAT_ATTRIBUTES(peds, 13, true)
                PED.SET_PED_CONFIG_FLAG(peds, 394, true)
                PED.SET_PED_CONFIG_FLAG(peds, 400, true)
                PED.SET_PED_CONFIG_FLAG(peds, 134, true)
                WEAPON.GIVE_WEAPON_TO_PED(peds, joaat("weapon_combating_mk2"), 9999, false, false)
                PED.SET_PED_ACCURACY(peds,100)
                TASK.TASK_COMBAT_HATED_TARGETS_AROUND_PED(PLAYER.PLAYER_PED_ID(), 100, 67108864)
                ENTITY.SET_ENTITY_HEALTH(peds,1000,true)
            end
        end
    end

    if  delallcam:is_enabled() then --remove所有摄像头
        for _, ent in pairs(entities.get_all_objects_as_handles()) do
            for __, cam in pairs(CamList) do
                if ENTITY.GET_ENTITY_MODEL(ent) == cam then
                    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(ent,true,true) --不执行这个下面会删除失败 @nord123#9579
                    ENTITY.DELETE_ENTITY(ent)               
                end
            end
        end
    end

    if  reactany:is_enabled() then --控制NPC-中断
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds)
            if calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() and not PED.IS_PED_DEAD_OR_DYING(peds,1) then 
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(peds)
            end
        end
    end

    if  react1any:is_enabled() then --控制NPC -摔倒
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds)
            if calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() and not PED.IS_PED_DEAD_OR_DYING(peds,1) then 
                PED.SET_PED_TO_RAGDOLL(peds, 5000, 0,0 , false, false, false)
            end
        end
    end

    if  react2any:is_enabled() then --控制NPC -死亡
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds)
            if calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() and not PED.IS_PED_DEAD_OR_DYING(peds,1) then 
                ENTITY.SET_ENTITY_HEALTH(peds,0,true)
            end
        end
    end

    if  reactanyac:is_enabled() then --控制敌对NPC-中断
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds)
            if (PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PLAYER.PLAYER_PED_ID()) == 4 or PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PLAYER.PLAYER_PED_ID()) == 5) and calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() and not PED.IS_PED_DEAD_OR_DYING(peds,1) then 
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(peds)
            end
        end
    end

    if  react1anyac:is_enabled() then --控制敌对NPC -摔倒
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds)
            if (PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PLAYER.PLAYER_PED_ID()) == 4 or PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PLAYER.PLAYER_PED_ID()) == 5) and calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() and not PED.IS_PED_DEAD_OR_DYING(peds,1) then 
                PED.SET_PED_TO_RAGDOLL(peds, 5000, 0,0 , false, false, false)
            end
        end
    end

    if  react2anyac:is_enabled() then --控制敌对NPC -死亡
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds)
            if (PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PLAYER.PLAYER_PED_ID()) == 4 or PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PLAYER.PLAYER_PED_ID()) == 5) and calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() and not PED.IS_PED_DEAD_OR_DYING(peds,1) then 
                ENTITY.SET_ENTITY_HEALTH(peds,0,true)
            end
        end
    end

    if  rmdied:is_enabled() then --控制NPC -remove尸体
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds)
            if calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() and PED.IS_PED_DEAD_OR_DYING(peds,1) then 
                ENTITY.SET_ENTITY_AS_MISSION_ENTITY(peds,true,true) --不执行这个下面会删除失败
                ENTITY.DELETE_ENTITY(peds)
            end
        end
    end

    if  react3any:is_enabled() then --控制NPC -燃烧
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds)
            if calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() and not PED.IS_PED_DEAD_OR_DYING(peds,1) then 
                FIRE.START_ENTITY_FIRE(peds)
                FIRE.START_SCRIPT_FIRE(ped_pos.x, ped_pos.y, ped_pos.z, 25, true)
                FIRE.ADD_EXPLOSION(ped_pos.x, ped_pos.y, ped_pos.z, 3, 1, false, false, 0, false);
            end
        end
    end

    if  react4any:is_enabled() then --控制NPC-起飞
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds)
            if calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() then 
                if PED.IS_PED_IN_ANY_VEHICLE(peds) then
                    tarpensveh = PED.GET_VEHICLE_PED_IS_IN(peds)
                    ENTITY.APPLY_FORCE_TO_ENTITY(tarpensveh, 3, 0, 0, 2, 0, 0, 0.5, 0, false, false, true, false, false)
                else
                    ENTITY.APPLY_FORCE_TO_ENTITY(peds, 3, 0, 0, 2, 0, 0, 0.5, 0, false, false, true, false, false)
                end
            end
        end
    end

    if  react5any:is_enabled() then --控制NPC 收为保镖
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds)
            if calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() then 
                TASK.CLEAR_PED_TASKS(peds)
                PED.SET_PED_AS_GROUP_MEMBER(peds, PED.GET_PED_GROUP_INDEX(PLAYER.PLAYER_PED_ID()))
                PED.SET_PED_RELATIONSHIP_GROUP_HASH(peds, PED.GET_PED_RELATIONSHIP_GROUP_HASH(PLAYER.PLAYER_PED_ID()))
                PED.SET_PED_NEVER_LEAVES_GROUP(peds, true)
                PED.SET_CAN_ATTACK_FRIENDLY(peds, 0, 1)
                PED.SET_PED_COMBAT_ABILITY(peds, 2)
                PED.SET_PED_CAN_TELEPORT_TO_GROUP_LEADER(peds, PED.GET_PED_GROUP_INDEX(PLAYER.PLAYER_PED_ID()), true)
                PED.SET_PED_FLEE_ATTRIBUTES(peds, 512, true)
                PED.SET_PED_FLEE_ATTRIBUTES(peds, 1024, true)
                PED.SET_PED_FLEE_ATTRIBUTES(peds, 2048, true)
                PED.SET_PED_FLEE_ATTRIBUTES(peds, 16384, true)
                PED.SET_PED_FLEE_ATTRIBUTES(peds, 131072, true)
                PED.SET_PED_FLEE_ATTRIBUTES(peds, 262144, true)
                PED.SET_PED_COMBAT_ATTRIBUTES(peds, 5, true)
                PED.SET_PED_COMBAT_ATTRIBUTES(peds, 13, true)
                PED.SET_PED_CONFIG_FLAG(peds, 394, true)
                PED.SET_PED_CONFIG_FLAG(peds, 400, true)
                PED.SET_PED_CONFIG_FLAG(peds, 134, true)
                WEAPON.GIVE_WEAPON_TO_PED(peds, joaat("weapon_combating_mk2"), 9999, false, false)
                PED.SET_PED_ACCURACY(peds,100)
                TASK.TASK_COMBAT_HATED_TARGETS_AROUND_PED(PLAYER.PLAYER_PED_ID(), 100, 67108864)
                ENTITY.SET_ENTITY_HEALTH(peds,1000,true)
            end
        end
    end

    if  react3anyac:is_enabled() then --控制敌对NPC -燃烧
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds)
            if (PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PLAYER.PLAYER_PED_ID()) == 4 or PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PLAYER.PLAYER_PED_ID()) == 5) and calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() and not PED.IS_PED_DEAD_OR_DYING(peds,1) then 
                FIRE.START_ENTITY_FIRE(peds)
                FIRE.START_SCRIPT_FIRE(ped_pos.x, ped_pos.y, ped_pos.z, 25, true)
                FIRE.ADD_EXPLOSION(ped_pos.x, ped_pos.y, ped_pos.z, 3, 1, false, false, 0, false);
            end
        end
    end

    if  react4anyac:is_enabled() then --控制敌对NPC-起飞
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds)
            if (PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PLAYER.PLAYER_PED_ID()) == 4 or PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PLAYER.PLAYER_PED_ID()) == 5) and calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() then 
                if PED.IS_PED_IN_ANY_VEHICLE(peds) then
                    tarpensveh = PED.GET_VEHICLE_PED_IS_IN(peds)
                    ENTITY.APPLY_FORCE_TO_ENTITY(tarpensveh, 3, 0, 0, 2, 0, 0, 0.5, 0, false, false, true, false, false)
                else
                    ENTITY.APPLY_FORCE_TO_ENTITY(peds, 3, 0, 0, 2, 0, 0, 0.5, 0, false, false, true, false, false)
                end
            end
        end
    end

    if  react5anyac:is_enabled() then --控制敌对NPC 收为保镖
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds)
            if (PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PLAYER.PLAYER_PED_ID()) == 4 or PED.GET_RELATIONSHIP_BETWEEN_PEDS(peds, PLAYER.PLAYER_PED_ID()) == 5) and calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() then 
                TASK.CLEAR_PED_TASKS(peds)
                PED.SET_PED_AS_GROUP_MEMBER(peds, PED.GET_PED_GROUP_INDEX(PLAYER.PLAYER_PED_ID()))
                PED.SET_PED_RELATIONSHIP_GROUP_HASH(peds, PED.GET_PED_RELATIONSHIP_GROUP_HASH(PLAYER.PLAYER_PED_ID()))
                PED.SET_PED_NEVER_LEAVES_GROUP(peds, true)
                PED.SET_CAN_ATTACK_FRIENDLY(peds, 0, 1)
                PED.SET_PED_COMBAT_ABILITY(peds, 2)
                PED.SET_PED_CAN_TELEPORT_TO_GROUP_LEADER(peds, PED.GET_PED_GROUP_INDEX(PLAYER.PLAYER_PED_ID()), true)
                PED.SET_PED_FLEE_ATTRIBUTES(peds, 512, true)
                PED.SET_PED_FLEE_ATTRIBUTES(peds, 1024, true)
                PED.SET_PED_FLEE_ATTRIBUTES(peds, 2048, true)
                PED.SET_PED_FLEE_ATTRIBUTES(peds, 16384, true)
                PED.SET_PED_FLEE_ATTRIBUTES(peds, 131072, true)
                PED.SET_PED_FLEE_ATTRIBUTES(peds, 262144, true)
                PED.SET_PED_COMBAT_ATTRIBUTES(peds, 5, true)
                PED.SET_PED_COMBAT_ATTRIBUTES(peds, 13, true)
                PED.SET_PED_CONFIG_FLAG(peds, 394, true)
                PED.SET_PED_CONFIG_FLAG(peds, 400, true)
                PED.SET_PED_CONFIG_FLAG(peds, 134, true)
                WEAPON.GIVE_WEAPON_TO_PED(peds, joaat("weapon_combating_mk2"), 9999, false, false)
                PED.SET_PED_ACCURACY(peds,100)
                TASK.TASK_COMBAT_HATED_TARGETS_AROUND_PED(PLAYER.PLAYER_PED_ID(), 100, 67108864)
                ENTITY.SET_ENTITY_HEALTH(peds,1000,true)
            end
        end
    end

    if  revitalizationped:is_enabled() then --控制NPC-复活
        local pedtable = entities.get_all_peds_as_handles()
        for _, peds in pairs(pedtable) do
            local selfpos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
            local ped_pos = ENTITY.GET_ENTITY_COORDS(peds)
            if calcDistance(selfpos, ped_pos) <= npcctrlr:get_value() and peds ~= PLAYER.PLAYER_PED_ID() and PED.IS_PED_DEAD_OR_DYING(peds,1) then 
                ENTITY.SET_ENTITY_LOAD_COLLISION_FLAG(peds, true)
                ENTITY.SET_ENTITY_AS_MISSION_ENTITY(peds, true, false)
                ENTITY.SET_ENTITY_SHOULD_FREEZE_WAITING_ON_COLLISION(peds, true)
                ENTITY.SET_ENTITY_COLLISION(peds,true,true)
                PED.SET_PED_AS_GROUP_MEMBER(peds, PED.GET_PED_GROUP_INDEX(PLAYER.PLAYER_PED_ID()))
                PED.SET_PED_RELATIONSHIP_GROUP_HASH(peds, PED.GET_PED_RELATIONSHIP_GROUP_HASH(PLAYER.PLAYER_PED_ID()))
                PED.SET_PED_NEVER_LEAVES_GROUP(peds, true)
                PED.SET_CAN_ATTACK_FRIENDLY(peds, 0, 1)
                PED.SET_PED_COMBAT_ABILITY(peds, 2)
                PED.SET_PED_CAN_TELEPORT_TO_GROUP_LEADER(peds, PED.GET_PED_GROUP_INDEX(PLAYER.PLAYER_PED_ID()), true)
                PED.SET_PED_FLEE_ATTRIBUTES(peds, 512, true)
                PED.SET_PED_FLEE_ATTRIBUTES(peds, 1024, true)
                PED.SET_PED_FLEE_ATTRIBUTES(peds, 2048, true)
                PED.SET_PED_FLEE_ATTRIBUTES(peds, 16384, true)
                PED.SET_PED_FLEE_ATTRIBUTES(peds, 131072, true)
                PED.SET_PED_FLEE_ATTRIBUTES(peds, 262144, true)
                PED.SET_PED_COMBAT_ATTRIBUTES(peds, 5, true)
                PED.SET_PED_COMBAT_ATTRIBUTES(peds, 13, true)
                PED.SET_PED_CONFIG_FLAG(peds, 394, true)
                PED.SET_PED_CONFIG_FLAG(peds, 400, true)
                PED.SET_PED_CONFIG_FLAG(peds, 134, true)
                WEAPON.GIVE_WEAPON_TO_PED(peds, joaat("weapon_combating_mk2"), 9999, false, false)
                PED.SET_PED_ACCURACY(peds,100)
                TASK.TASK_COMBAT_HATED_TARGETS_AROUND_PED(PLAYER.PLAYER_PED_ID(), 100, 67108864)
                ENTITY.SET_ENTITY_HEALTH(peds,1000,true)
                PED.RESURRECT_PED(peds)

            end
        end
    end


end)

script.register_looped("schlua-ptfxservice", function() 

    if  checkfirebreath:is_enabled() then --不太好用的喷火功能
        if loopa5 == 0 then
            STREAMING.REQUEST_NAMED_PTFX_ASSET("weap_xs_vehicle_weapons")
            while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("weap_xs_vehicle_weapons") do
                STREAMING.REQUEST_NAMED_PTFX_ASSET("weap_xs_vehicle_weapons")
                script_util:yield()               
            end
            GRAPHICS.USE_PARTICLE_FX_ASSET("weap_xs_vehicle_weapons")
            local ptfxx = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE('muz_xs_turret_flamethrower_looping', PLAYER.PLAYER_PED_ID(), 0, 0.12, 0.58, 30, 0, 0, 0x8b93, 1.0 , false, false, false)
            GRAPHICS.SET_PARTICLE_FX_LOOPED_COLOUR(ptfxx, 255, 127, 80)    
        end
        loopa5 = 1
    else
        if loopa5 == 1 then 
            GRAPHICS.REMOVE_PARTICLE_FX(ptfxx, true)
            GRAPHICS.REMOVE_PARTICLE_FX_FROM_ENTITY(PLAYER.PLAYER_PED_ID())
            STREAMING.REMOVE_NAMED_PTFX_ASSET('weap_xs_vehicle_weapons')    
        end
        loopa5 = 0
    end 

    if  checkfirew:is_enabled() then --不太好用的火焰翅膀功能
        if loopa6 == 0 then
            if  ptfxAegg == nil then
                local obj1 = 1803116220  --外星蛋,用于附加火焰ptfx
        
                local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
    
                STREAMING.REQUEST_MODEL(obj1)
                while not STREAMING.HAS_MODEL_LOADED(obj1) do
                    STREAMING.REQUEST_MODEL(obj1)
                    script_util:yield() 
                end
    
                ptfxAegg = OBJECT.CREATE_OBJECT(obj1, pos.x, pos.y, pos.z, true, false, false)
    
                ENTITY.SET_ENTITY_COLLISION(ptfxAegg, false, false)
                STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(obj1)
            end
            for i = 1, #bigfireWings do
                STREAMING.REQUEST_NAMED_PTFX_ASSET("weap_xs_vehicle_weapons")
                while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("weap_xs_vehicle_weapons") do
                    STREAMING.REQUEST_NAMED_PTFX_ASSET("weap_xs_vehicle_weapons")
                    script_util:sleep(20)
                end
                GRAPHICS.USE_PARTICLE_FX_ASSET("weap_xs_vehicle_weapons")
                bigfireWings[i].ptfx = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY("muz_xs_turret_flamethrower_looping", ptfxAegg, 0, 0, 0.1, bigfireWings[i].pos[1], 0, bigfireWings[i].pos[2], 1, false, false, false)
        
                local rot = ENTITY.GET_ENTITY_ROTATION(PLAYER.PLAYER_PED_ID(), 2)
                ENTITY.ATTACH_ENTITY_TO_ENTITY(ptfxAegg, PLAYER.PLAYER_PED_ID(), -1, 0, 0, 0, rot.x, rot.y, rot.z, false, false, false, false, 0, false)
                ENTITY.SET_ENTITY_ROTATION(ptfxAegg, rot.x, rot.y, rot.z, 2, true)
                    for i = 1, #bigfireWings do
                        GRAPHICS.SET_PARTICLE_FX_LOOPED_SCALE(bigfireWings[i].ptfx, 0.6)
                        GRAPHICS.SET_PARTICLE_FX_LOOPED_COLOUR(bigfireWings[i].ptfx, 255, 127, 80)
        
                    end
                ENTITY.SET_ENTITY_VISIBLE(ptfxAegg, false) 
            end
        end
        loopa6 =1
    else
        if loopa6 == 1 then 
            for i = 1, #bigfireWings do
                if bigfireWings[i].ptfx then
                    GRAPHICS.REMOVE_PARTICLE_FX(bigfireWings[i].ptfx, true)
                    bigfireWings[i].ptfx = nil
                end
                if ptfxAegg then
                    ENTITY.DELETE_ENTITY(ptfxAegg)
                    ptfxAegg = nil
                end
            end
            STREAMING.REMOVE_NAMED_PTFX_ASSET('weap_xs_vehicle_weapons')
        end
        loopa6 = 0
    end

end)

script.register_looped("schlua-drawservice", function() 
    if  DrawHost:is_enabled() then
        screen_draw_text(string.format("war host:".. PLAYER.GET_PLAYER_NAME(NETWORK.NETWORK_GET_HOST_PLAYER_INDEX())),0.180,0.8, 0.4 , 0.4)
        if SCRIPT.HAS_SCRIPT_LOADED("freemode") then
        freemodehost = NETWORK.NETWORK_GET_HOST_OF_SCRIPT("freemode",-1,0)
        screen_draw_text(string.format("war script host:".. PLAYER.GET_PLAYER_NAME(freemodehost)),  0.180, 0.828, 0.4 , 0.4)
        end

        if SCRIPT.HAS_SCRIPT_LOADED("fm_mission_controller") or SCRIPT.HAS_SCRIPT_LOADED("fm_mission_controller_2020") then
            if SCRIPT.HAS_SCRIPT_LOADED("fm_mission_controller") then 
                fmmchost = NETWORK.NETWORK_GET_HOST_OF_SCRIPT("fm_mission_controller",-1,0)
                screen_draw_text(string.format("Task Script Host:".. PLAYER.GET_PLAYER_NAME(fmmchost)), 0.180, 0.910, 0.4 , 0.4)
            end
            if SCRIPT.HAS_SCRIPT_LOADED("fm_mission_controller") then 
                fmmc2020host = NETWORK.NETWORK_GET_HOST_OF_SCRIPT("fm_mission_controller_2020",-1,0)
                screen_draw_text(string.format("Task Script Host:".. PLAYER.GET_PLAYER_NAME(fmmc2020host)), 0.180, 0.910, 0.4 , 0.4)
            end
            
        end
    end

    if  DrawInteriorID:is_enabled() then
        local PlayerPos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0.0, 0.0, 0.0)
        local Interior = INTERIOR.GET_INTERIOR_AT_COORDS(PlayerPos.x, PlayerPos.y, PlayerPos.z)

        screen_draw_text(string.format("Interior ID:".. Interior),0.875,0.2, 0.4 , 0.4)
    end
end)

script.register_looped("schlua-testservice", function() 
    if gui.get_tab(""):is_selected() then
        local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), false)
        local targpos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
        distance = calcDistance(pos,targpos)
        formattedDistance = string.format("%.3f", distance)
        plydist:set_value(formattedDistance)
    end
end)
--[[
script.register_looped("schlua-verckservice", function() 
    script_util:sleep(60000)
    if NETWORK.GET_ONLINE_VERSION() ~= "1.67" then
        local start_time = os.time()
        local duration = 10  
        while os.time() - start_time < duration do
        local scaleForm = GRAPHICS.REQUEST_SCALEFORM_MOVIE("POPUP_WARNING")
        GRAPHICS.DRAW_RECT(.5, .5, 1, 1, 255, 20, 20, 255)
        GRAPHICS.BEGIN_SCALEFORM_MOVIE_METHOD(scaleForm, "SHOW_POPUP_WARNING")
        GRAPHICS.DRAW_SCALEFORM_MOVIE_FULLSCREEN(scaleForm, 0, 0, 0, 0, 0)
        GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_FLOAT(500.0)
        GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_TEXTURE_NAME_STRING("SCH LUAwarn")
        GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_TEXTURE_NAME_STRING("脚本不支持您的游戏版本,继续使用将损坏您的在线账户!")
        GRAPHICS.END_SCALEFORM_MOVIE_METHOD(scaleForm)
        script_util:sleep(10)
        end
    else
        script_util:sleep(6000000)
    end
end)
]]
--------------------------------------------------------------------------------------- 注册的循环脚本,主要用来实现Lua里面那些复选框的功能
---------------------------------------------------------------------------------------存储一些小发现、用不上的东西
--[[
    	Global_1574996 = etsParam0;   Global_1574996 战局切换状态 0:TRANSITION_STATE_EMPTY  freemode.c

        if NETWORK.GET_ONLINE_VERSION() ~= "1.67" then
   gui.show_error("SCH LUA", "游戏版本不受支持!仍然使用可能损坏游戏")
end


------------------------------------------------技工 呼叫 载具资产 freemode.c began

void func_12234(var uParam0, var uParam1, Blip* pblParam2, Blip* pblParam3, Blip* pblParam4, Blip* pblParam5, Blip* pblParam6, Blip* pblParam7, Blip* pblParam8) // Position - 0x42ED1D
{
	if (Global_2794162.f_928)
		if (Global_2794162.f_942)
			func_12267(uParam0, false, true, false, false, false, false, false, false);
		else
			func_12267(uParam0, false, false, false, false, false, false, false, false);

	if (Global_2794162.f_930 && !func_6130() || *uParam1 == 5 && Global_1648646 == 3)
		func_12267(uParam1, true, false, false, false, false, false, false, false);  //MOC

	func_12264(pblParam2);

	if (Global_2794162.f_938 && !func_5730() || *uParam1 == 5)
		func_12267(uParam1, false, false, true, false, false, false, false, false); //复仇者

	func_12258(pblParam3);

	if (Global_2794162.f_943 && !func_5020() || *uParam1 == 5 && Global_1648646 == 5)
		func_12267(uParam1, false, false, false, true, false, false, false, false);  //恐霸

	func_12255(pblParam4);

	if (Global_2794162.f_960 && !func_3870() || *uParam1 == 5 && Global_1648646 == 6)
		func_12267(uParam1, false, false, false, false, true, false, false, false);  //虎鲸

	func_12252(pblParam5);

	if (Global_2794162.f_972 && !func_10792() || *uParam1 == 5 && Global_1648646 == 7)
		func_12267(uParam1, false, false, false, false, false, true, false, false);

	func_12250(pblParam6);

	if (Global_2794162.f_944 && !func_2870() || *uParam1 == 5 && Global_1648646 == 8)
		func_12267(uParam1, false, false, false, false, false, false, false, true);  //致幻剂实验室

	func_12242(pblParam8);

	if (Global_2794162.f_994 && !func_10779() || *uParam1 == 5 && Global_1648646 == 9)
	{
		if (func_12240(PLAYER::PLAYER_ID()))
		{
			*uParam1 = 5;
			func_12239(false, false, true, false, true, false, false);  //致幻剂实验室 摩托车
			func_10001(false);
		}
	
		func_12267(uParam1, false, false, false, false, false, false, true, false);  
	}

	func_12235(pblParam7);
	return;
}
------------------------------------------------技工 呼叫 载具资产 end

]]
---------------------------------------------------------------------------------------存储一些小发现、用不上的东西


---------------------------------------------------------------------------------------以下是废弃的但又不想删的东西

--[[
gentab:add_sameline()

gentab:add_button("测试2", function()

    local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), true)
    while STREAMING.HAS_MODEL_LOADED(3613262246) ~= 1 do
        STREAMING.REQUEST_MODEL(3613262246)
        script_util:sleep(100)
    end
    while STREAMING.HAS_MODEL_LOADED(2155335200) ~= 1 do
        STREAMING.REQUEST_MODEL(2155335200)
        script_util:sleep(100)
    end
    while STREAMING.HAS_MODEL_LOADED(3026699584) ~= 1 do
        STREAMING.REQUEST_MODEL(3026699584)
        script_util:sleep(100)
    end
    while STREAMING.HAS_MODEL_LOADED(-1348598835) ~= 1 do
        STREAMING.REQUEST_MODEL(-1348598835)
        script_util:sleep(100)
    end
    local Object_pizza1 = OBJECT.CREATE_OBJECT(3613262246, pos.x,pos.y,pos.z, true, false, false)
    local crashstaff1 = OBJECT.CREATE_OBJECT(2155335200, pos.x,pos.y,pos.z, true, false, false)
    local Object_pizza3 = OBJECT.CREATE_OBJECT(3026699584, pos.x,pos.y,pos.z, true, false, false)
    local Object_pizza4 = OBJECT.CREATE_OBJECT(-1348598835, pos.x,pos.y,pos.z, true, false, false)
    for i = 0, 100 do 
        local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), true)
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(Object_pizza1, pos.x, pos.y, pos.z, false, true, true)
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(crashstaff1, pos.x, pos.y, pos.z, false, true, true)
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(Object_pizza3, pos.x, pos.y, pos.z, false, true, true)
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(Object_pizza4, pos.x, pos.y, pos.z, false, true, true)
        script_util:yield()
    end

end)

gentab:add_sameline()

gentab:add_button("测试3", function()

    local TargetPlayerPos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), true)
    local PED1 =     PED.CREATE_PED(26,joaat("cs_beverly"),TargetPlayerPos.x, TargetPlayerPos.y, TargetPlayerPos.z,0,true,true)
    ENTITY.SET_ENTITY_VISIBLE(PED1, false, 0)
    script_util:sleep(100)
    WEAPON.GIVE_WEAPON_TO_PED(PED1,-270015777,80,true,true)
    script_util:sleep(100)
    FIRE.ADD_OWNED_EXPLOSION(PLAYER.GET_PLAYER_PED(network.get_selected_player()), TargetPlayerPos.x, TargetPlayerPos.y, TargetPlayerPos.z, 2, 50, true, false, 0.0)

end)
]]

--[[
gui.get_tab(""):add_sameline()

gui.get_tab(""):add_button("武装动物崩溃", function()
    local TargetPPos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
    local PED1  = CreatePed(28,-1011537562,TargetPPos,0)
    local PED2  = CreatePed(28,-541762431,TargetPPos,0)
    local PED3  = CreatePed(28,1553815115,TargetPPos,0)

    WEAPON.GIVE_WEAPON_TO_PED(PED1,-1813897027,1,true,true)
    WEAPON.GIVE_WEAPON_TO_PED(PED2,-1813897027,1,true,true)
    WEAPON.GIVE_WEAPON_TO_PED(PED3,-1813897027,1,true,true)

    script_util:sleep(1000)
    TASK.TASK_THROW_PROJECTILE(PED1,TargetPPos.x,TargetPPos.y,TargetPPos.z,0,0)
    TASK.TASK_THROW_PROJECTILE(PED2,TargetPPos.x,TargetPPos.y,TargetPPos.z,0,0)
    TASK.TASK_THROW_PROJECTILE(PED3,TargetPPos.x,TargetPPos.y,TargetPPos.z,0,0)
    script_util:sleep(500)
    TASK.CLEAR_PED_TASKS(PED1)
    TASK.CLEAR_PED_TASKS(PED2)
    TASK.CLEAR_PED_TASKS(PED3)
    TASK.TASK_THROW_PROJECTILE(PED1,TargetPPos.x,TargetPPos.y,TargetPPos.z,0,0)
    TASK.TASK_THROW_PROJECTILE(PED2,TargetPPos.x,TargetPPos.y,TargetPPos.z,0,0)
    TASK.TASK_THROW_PROJECTILE(PED3,TargetPPos.x,TargetPPos.y,TargetPPos.z,0,0)

end)

gui.get_tab(""):add_sameline()

gui.get_tab(""):add_button("无效模型崩溃", function()
    local cord = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
    local a1 = create_object(-930879665, cord)
    local a2 = create_object(3613262246, cord)
    local b1 = create_object(452618762, cord)
    local b2 = create_object(3613262246, cord)
    local c1 = create_object(1888301071, cord)
    local c2 = create_object(-1011537562, cord)
    local c3 = create_object(-541762431, cord)
    for i = 1, 10 do
        request_model(-930879665)
        script_util:sleep(10)
        request_model(3613262246)
        script_util:sleep(10)
        request_model(452618762)
        script_util:sleep(300)
        request_model(1888301071)
        script_util:sleep(300)
        ENTITY.DELETE_ENTITY(a1)
        ENTITY.DELETE_ENTITY(a2)
        ENTITY.DELETE_ENTITY(b1)
        ENTITY.DELETE_ENTITY(b2)
        ENTITY.DELETE_ENTITY(c1)
        ENTITY.DELETE_ENTITY(c2)
        ENTITY.DELETE_ENTITY(c3)
        request_model(452618762)
        script_util:sleep(10)
        request_model(3613262246)
        script_util:sleep(10)
        request_model(-930879665)
        script_util:sleep(10)
        request_model(1888301071)
        script_util:sleep(10)
    end

end)
]]
--[[
gui.get_tab(""):add_sameline()

gui.get_tab(""):add_button("模型2", function()

local cord = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
local object = create_object(joaat("virgo"), cord)
local object = create_object(joaat("osiris"), cord)
local object = create_object(joaat("v_serv_firealarm"), cord)
local object = create_object(joaat("v_serv_bs_cond"), cord)
local object = create_object(joaat("v_serv_bs_foamx3"), cord)
local object = create_object(joaat("v_serv_ct_monitor07"), cord)
local object = create_object(joaat("v_serv_ct_monitor06"), cord)
local object = create_object(joaat("v_serv_ct_monitor05"), cord)
local object = create_object(joaat("v_serv_bs_gelx3"), cord)
local object = create_object(joaat("v_serv_ct_monitor01"), cord)
local object = create_object(joaat("feltzer3"), cord)
local object = create_object(joaat("v_serv_ct_monitor02"), cord)
local object = create_object(joaat("windsor"), cord)
local object = create_object(joaat("v_serv_ct_monitor04"), cord)
local object = create_object(joaat("v_serv_ct_monitor03"), cord)
local object = create_object(joaat("v_serv_bs_clutter"), cord)
ENTITY.SET_ENTITY_AS_MISSION_ENTITY(object, true, true)
ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(object, 1, 0.0, 10000.0, 0.0, 0.0, 0.0, 0.0, false, true, true, false, true)
ENTITY.SET_ENTITY_ROTATION(object, math.random(0, 360), math.random(0, 360), math.random(0, 360), 0, true)
ENTITY.SET_ENTITY_VELOCITY(object, math.random(-10, 10), math.random(-10, 10), math.random(30, 50))
ENTITY.ATTACH_ENTITY_TO_ENTITY(object, object, 0, 0, -1, 2.5, 0, 180, 0, 0, false, true, false, 0, true)
script_util:sleep(300)
MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(cord.x, cord.y, cord.z + 1, cord.x, cord.y, cord.z, 0, true, joaat("weapon_heavysniper_mk2"), PLAYER.GET_PLAYER_PED(network.get_selected_player()), false, true, 1.0)
ENTITY.DETACH_ENTITY(object, object)
--delete_by_handle(object)
end)

gui.get_tab(""):add_sameline()

gui.get_tab(""):add_button("模型4", function()
    local TTPed = PLAYER.GET_PLAYER_PED(network.get_selected_player())
    local TTPos = ENTITY.GET_ENTITY_COORDS(TTPed, true)
            local spped = PLAYER.PLAYER_PED_ID()
            local SelfPlayerPos = ENTITY.GET_ENTITY_COORDS(spped, true)
            SelfPlayerPos.x = SelfPlayerPos.x + 10
            TTPos.x = TTPos.x + 10
            local carc = CreateObject(joaat("apa_prop_flag_china"), TTPos, ENTITY.GET_ENTITY_HEADING(spped), true)
            local carcPos = ENTITY.GET_ENTITY_COORDS(vehicle, true)
            local pedc = CreatePed(26, joaat("A_C_HEN"), TTPos, 0)
            local pedcPos = ENTITY.GET_ENTITY_COORDS(vehicle, true)
            local ropec = PHYSICS.ADD_ROPE(TTPos.x, TTPos.y, TTPos.z, 0, 0, 0, 1, 1, 0.00300000000000000000000000000000000000000000000001, 1, 1, true, true, true, 1.0, true, 0)
            PHYSICS.ATTACH_ENTITIES_TO_ROPE(ropec,carc,pedc,carcPos.x, carcPos.y, carcPos.z ,pedcPos.x, pedcPos.y, pedcPos.z,2, false, false, 0, 0, "Center","Center")
            script_util:sleep(3500)
            PHYSICS.DELETE_CHILD_ROPE(ropec)
           -- ENTITY.DELETE_ENTITY(pedc)
    
end)

gui.get_tab(""):add_sameline()

gui.get_tab(""):add_button("模型3", function()
    pedp = PLAYER.GET_PLAYER_PED(network.get_selected_player())
    pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
    towtruck = CreateVehicle(-1323100960, pos, 0)
    skylift = CreateVehicle(-692292317, pos, 0)
    cargobob = CreateVehicle(4244420235, pos, 0)
    cargobob2 = CreateVehicle(4244420235, pos, 0)
    cargobob1 = CreateVehicle(4244420235, pos, 0)
    handler = CreateVehicle(444583674, pos, 0)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(cargobob, skylift, 0, 0, 0, 0.2, 0, 0, 0, false, true, false, 0, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(cargobob1, skylift, 0, 0, 0, -0.2, 0, 0, 0, false, true, false, 0, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(handler, skylift, 0, 0, 0, 0, 0, 0, 0, false, true, false, 0, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(towtruck, skylift, 0, 0, 0, 0, 0, 0, 0, false, true, false, 0, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(cargobob2, towtruck, 0, 0, 0, 0, 0, 0, 0, false, true, false, 0, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(skylift, pedp, 0, 0, 0, 0, 0, 0, 0, false, true, false, 0, true)

end)
]]
--[[
gentab:add_button("IN MD C", function()
    for i = 1, 10 do
		local cord = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
        STREAMING.REQUEST_MODEL(-930879665)
        script_util:sleep(10)
        STREAMING.REQUEST_MODEL(3613262246)
        script_util:sleep(10)
        STREAMING.REQUEST_MODEL(452618762)
        script_util:sleep(10)
        while not STREAMING.HAS_MODEL_LOADED(-930879665) do script_util:sleep() end
        while not STREAMING.HAS_MODEL_LOADED(3613262246) do script_util:sleep() end
        while not STREAMING.HAS_MODEL_LOADED(452618762) do script_util:sleep() end
        local a1 = create_object(-930879665, cord)
        script_util:sleep(10)
        local a2 = create_object(3613262246, cord)
        script_util:sleep(10)
        local b1 = create_object(452618762, cord)
        script_util:sleep(10)
        local b2 = create_object(3613262246, cord)
    end
end)

gentab:add_sameline()

gentab:add_button("测试5", function()
    local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
    coords.z = coords.z + 63
    local ufoModel = joaat("p_spinning_anus_s")
    while STREAMING.HAS_MODEL_LOADED(ufoModel) ~= 1 do
    
        STREAMING.REQUEST_MODEL(ufoModel)
        script_util:sleep(100)
        
    end
    local Object = OBJECT.CREATE_OBJECT(ufoModel, coords.x, coords.y, coords.z, TRUE, TRUE, FALSE)
    local player = PLAYER.GET_PLAYER_PED(network.get_selected_player())
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(player, false)

    if PED.IS_PED_IN_VEHICLE(player, vehicle, false) == 1 then 
        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(vehicle)
        VEHICLE.BRING_VEHICLE_TO_HALT(vehicle, 3, 4, false)
        VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, false, true, true)
        ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, 0.0, 0.0, 65, 0.0, 0.0, 0.0, 1, false, true, true, true, true)
        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(vehicle, true)

    else
        gui.show_message("错误","玩家不在载具中")
    end
end)


gentab:add_sameline()
]]--

--[[
gui.add_tab(""):add_button("载具状态崩溃", function()

    if PLAYER.GET_PLAYER_PED(network.get_selected_player()) ==PLAYER.PLAYER_PED_ID() then
        gui.show_message("prompt","你正试图崩溃自己")
        return
    end

    local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(network.get_selected_player()), false)
    for i = 0, 30 do
        vehw = CreateVehicle(joaat("banshee"),pos,ENTITY.GET_ENTITY_HEADING(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(network.get_selected_player())) - 180)
        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(vehw)
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(vehw, pos.x,pos.y,pos.z, ENTITY.GET_ENTITY_HEADING(PLAYER.GET_PLAYER_PED(network.get_selected_player())), 10)
        TASK.TASK_VEHICLE_TEMP_ACTION(PLAYER.GET_PLAYER_PED(network.get_selected_player()), vehw, 18, 777)
        TASK.TASK_VEHICLE_TEMP_ACTION(PLAYER.GET_PLAYER_PED(network.get_selected_player()), vehw, 17, 888)
        TASK.TASK_VEHICLE_TEMP_ACTION(PLAYER.GET_PLAYER_PED(network.get_selected_player()), vehw, 16, 999)
        script_util:sleep(500)
    end

end)
]]

--[[
script.register_looped("refreshpid", function()
    pid = network.get_selected_player()
  end)

gui.get_tab(""):add_button("TSE C", function()

    if pid == PLAYER.PLAYER_ID() then
        gui.show_message("prompt","不可对自己使用")
        return
     end
     local int_min = -2147483647
     local int_max = 2147483647
     network.trigger_script_event(1 << pid, {879177392, pid, 7264839016258354765, 10597, 73295, 3274114858851387039, 4862623901289893625, 54483})
     network.trigger_script_event(1 << pid, {879177392, pid, 7264839016258354765, 10597, 73295, 3274114858851387039, 4862623901289893625, 54483})
     network.trigger_script_event(1 << pid, {879177392, pid, 7264839016258354765, 10597, 73295, 3274114858851387039, 4862623901289893625, 54483})
     network.trigger_script_event(1 << pid, {879177392, pid, 7264839016258354765, 10597, 73295, 3274114858851387039, 4862623901289893625, 54483})
     network.trigger_script_event(1 << pid, {548471420, pid, 804923209, 1128590390, 136699892, -168325547, -814593329, 1630974017, 1101362956, 1510529262, 2, 1875285955, 633832161, -1097780228})
     network.trigger_script_event(1 << pid, {2765370640, pid, 3747643341, math.random(int_min, int_max), math.random(int_min, int_max), 
     math.random(int_min, int_max), math.random(int_min, int_max), math.random(int_min, int_max), math.random(int_min, int_max),
     math.random(int_min, int_max), pid, math.random(int_min, int_max), math.random(int_min, int_max), math.random(int_min, int_max)})
     network.trigger_script_event(1 << pid, { -555356783, pid ,85952,99999,52682274855,526822745 })
     network.trigger_script_event(1 << pid, { 526822748, pid ,78552,99999 ,7949161,789454312})
     network.trigger_script_event(1 << pid, { -66669983, pid ,526822748,555555, math.random(80521,2959749521) })
     network.trigger_script_event(1 << pid, { -1733737974, pid ,789522 ,59486,48512151,-9545440,5845131,848153,math.random(1,2959749),189958})
     network.trigger_script_event(1 << pid, { -1529596656, pid ,795221,59486,48512151,-9545440 , math.random(1,2959749) })
     network.trigger_script_event(1 << pid, { -8965204809, pid ,795221,59486,48512151,-9545440 })
     gui.show_message("正在发送脚本事件崩溃",pid)
     network.trigger_script_event(1 << pid, {495813132, pid, 0, 0, -12988, -99097, 0})
     network.trigger_script_event(1 << pid, {495813132, pid, -4640169, 0, 0, 0, -36565476, -53105203})
     network.trigger_script_event(1 << pid, {495813132, pid,  0, 1, 23135423, 3, 3, 4, 827870001, 5, 2022580431, 6, -918761645, 7, 1754244778, 8, 827870001, 9, 17})
 
 
     for i = 1, 50 do
        --network.trigger_script_event(1 << pid,{-642704387, pid, 782258655, math.random(int_min, int_max), math.random(int_min, int_max),math.random(int_min, int_max), math.random(int_min, int_max), math.random(int_min, int_max), math.random(int_min, int_max),math.random(int_min, int_max), pid, math.random(int_min, int_max), math.random(int_min, int_max), math.random(int_min, int_max) })
     end


    for i = 1, 15 do
        network.trigger_script_event(1 << pid, {891653640, 0, 81468, 96773, 84776, 2939, 20158,  14219,  38254,  22206})
        network.trigger_script_event(1 << pid, {1348481963, pid, math.random(int_min, int_max)})
        network.trigger_script_event(1 << pid,{-642704387, pid, 782258655, math.random(int_min, int_max), math.random(int_min, int_max),math.random(int_min, int_max), math.random(int_min, int_max), math.random(int_min, int_max), math.random(int_min, int_max),math.random(int_min, int_max), pid, math.random(int_min, int_max), math.random(int_min, int_max), math.random(int_min, int_max) })

        network.trigger_script_event(1 << pid, {-992162568, 0, 40778, 85683, 32561, 49696, 24000,  78834,  1860,  37655, math.random(int_min, int_max), math.random(int_min, int_max), -- Crash Event S1
        math.random(int_min, int_max), math.random(int_min, int_max), math.random(int_min, int_max), math.random(int_min, int_max),
        math.random(int_min, int_max), pid, math.random(int_min, int_max), math.random(int_min, int_max), math.random(int_min, int_max)})
        network.trigger_script_event(1 << pid, {891653640, 0, 81468, 96773, 84776, 2939, 20158,  14219,  38254,  22206})
    end
    network.trigger_script_event(1 << pid, {495813132, pid, 0, 0, -12988, -99097, 0})
    network.trigger_script_event(1 << pid, {495813132, pid, -4640169, 0, 0, 0, -36565476, -53105203})
    network.trigger_script_event(1 << pid, {495813132, pid,  0, 1, 23135423, 3, 3, 4, 827870001, 5, 2022580431, 6, -918761645, 7, 1754244778, 8, 827870001, 9, 17})

end)
]]

-- local checkmovefree = gentab:add_checkbox("战局切换时自由移动")

--[[  已被检测
gentab:add_button("remove赌场轮盘冷却", function()
    local playerid = globals.get_int(1574918) --疑似与MPPLY_LAST_MP_CHAR相等

local mpx = "MP0_"
if playerid == 1 then 
    mpx = "MP1_" 

end
    STATS.STAT_SET_INT(joaat(mpx.."LUCKY_WHEEL_NUM_SPIN"), 0, true)
    globals.set_int(262145+27382,1) -- 9960150 
    globals.set_int(262145+27383,1) -- -312420223
end)
]]--
