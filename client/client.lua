local RSGCore = exports['rsg-core']:GetCoreObject()

local GetHashKey = joaat
-- Tables --
local pedstable = {}
local promptstable = {}
local blipsTable = {}
local JobsDone = {}
local JobCount = 0
local DropCount = 0
local BlipScale = 0.10

-- Checks --
local hasJob = false
local PickedUp = false
local AttachedProp = false

-- Blips & Prompts --
local dropBlip
local jobBlip
local closestJob = {}

-----------------------------------------
-- EXTRA 
-----------------------------------------
-- REMOVE PROPS COMMAND --
if Config.StuckPropCommand then
    RegisterCommand('propstuck', function()
        for k, v in pairs(GetGamePool('CObject')) do
            if IsEntityAttachedToEntity(PlayerPedId(), v) then
                SetEntityAsMissionEntity(v, true, true)
                DeleteObject(v)
                DeleteEntity(v)
            end
        end
    end)
end

--------------------------
-- PED SPAWNING
--------------------------

local function _GET_DEFAULT_RELATIONSHIP_GROUP_HASH ( iParam0 )
    return Citizen.InvokeNative( 0x3CC4A718C258BDD0 , iParam0 );
end

local function SET_PED_RELATIONSHIP_GROUP_HASH ( iVar0, iParam0 )
    return Citizen.InvokeNative( 0xC80A74AC829DDD92, iVar0, _GET_DEFAULT_RELATIONSHIP_GROUP_HASH( iParam0 ) )
end

local function modelrequest( model )
    CreateThread(function()
        RequestModel( model )
    end)
end

local function createJobNPC(model, position, heading)
    modelrequest(GetHashKey(model))

    while not HasModelLoaded(GetHashKey(model)) do
        Wait(500)
    end

    local npc = CreatePed(GetHashKey(model), position.x, position.y, position.z - 1, heading, false, false, 0, 0)

    while not DoesEntityExist(npc) do
        Wait(500)
    end

    exports['rsg-target']:AddTargetModel(model, {
        options = {
            {
                type = "client",
                event = "danglr-bricklayer:OpenJobMenu",
                icon = "fas fa-person-digging",
                style = "",
                label = "Brick Job",
            },
        },
        distance = 2.5
    })

    Citizen.InvokeNative(0x283978A15512B2FE, npc, true)
    FreezeEntityPosition(npc, false)
    SetEntityInvincible(npc, true)
    TaskStandStill(npc, -1)
    Wait(100)
    SET_PED_RELATIONSHIP_GROUP_HASH(npc, GetHashKey(model))
    SetEntityCanBeDamagedByRelationshipGroup(npc, false, `PLAYER`)
    SetEntityAsMissionEntity(npc, true, true)
    SetModelAsNoLongerNeeded(GetHashKey(model))
    table.insert(pedstable, npc)
end

-- Función para la gestión de blips
local function createBlip(model, position, sprite, scale, text)
    local blip = N_0x554d9d53f696d002(1664425300, position.x, position.y, position.z)
    SetBlipSprite(blip, sprite, scale)
    SetBlipScale(blip, BlipScale)
    Citizen.InvokeNative(0x9CB1A1623062F402, blip, text)
    table.insert(blipsTable, blip)
    return blip
end

--------------------------------------
-- FUNCTIONS
--------------------------------------

local function PickupBrickLocation()
    local player = PlayerPedId()
    local playercoords = GetEntityCoords(player)
    PickupLocation = math.random(1, #Config.Locations[closestJob]["BrickLocations"])

    if Config.Prints then
        print(closestJob)
    end

    jobBlip = N_0x554d9d53f696d002(1664425300, Config.Locations[closestJob]["BrickLocations"][PickupLocation].coords.x, Config.Locations[closestJob]["BrickLocations"][PickupLocation].coords.y, Config.Locations[closestJob]["BrickLocations"][PickupLocation].coords.z)

    SetBlipSprite(jobBlip, 1116438174, 1)
    SetBlipScale(jobBlip, 0.05)

    lib.notify({ title = 'Error', description = 'Go Grab A Brick', type = 'error' })
    --TriggerEvent('rNotify:NotifyLeft', "          Go grab a brick", "", "generic_textures", "tick", 4500)
end

local function DropBrickLocation()
    local player = PlayerPedId()
    local playercoords = GetEntityCoords(player)
    DropLocation = math.random(1, #Config.Locations[closestJob]["DropLocations"])

    dropBlip = N_0x554d9d53f696d002(1664425300, Config.Locations[closestJob]["DropLocations"][DropLocation].coords.x, Config.Locations[closestJob]["DropLocations"][DropLocation].coords.y, Config.Locations[closestJob]["DropLocations"][DropLocation].coords.z)

    SetBlipSprite(dropBlip, 1116438174, 0.5)
    SetBlipScale(dropBlip, 0.10)
    
    lib.notify({ title = 'Error', description = 'Head Over To Where This Brick Is Needed', type = 'error' })
end

--------------------------------------
-- THREADS 
--------------------------------------
CreateThread(function()
    for z, x in pairs(Config.JobNpc) do
        createJobNPC(Config.JobNpc[z]["Model"], Config.JobNpc[z]["Pos"], Config.JobNpc[z]["Heading"])
        createBlip(Config.JobNpc[z]["Model"], Config.JobNpc[z]["Pos"], 2305242038, 0.5, "Brick Layer Job")
    end
end)

CreateThread(function()
    while true do
        Wait(50)
        if hasJob then
            local player = PlayerPedId()
            local coords = GetEntityCoords(player)
            if not PickedUp then
                
            elseif PickedUp and not IsPedRagdoll(player) then
                if Config.DisableSprintJump then
                    DisableControlAction(0, 0x8FFC75D6, true) -- Shift
                    DisableControlAction(0, 0xD9D0E1C0, true) -- Spacebar
                end
                local coordsA = coords
                local coordsB = vector3(Config.Locations[closestJob]["DropLocations"][DropLocation].coords.x, Config.Locations[closestJob]["DropLocations"][DropLocation].coords.y, Config.Locations[closestJob]["DropLocations"][DropLocation].coords.z)
                local distance = #(coordsA - coordsB)
                if distance < 1.5  then
                    lib.showTextUI("["..Config.Key.."] | Place Brick", {
                        position = "top-center",
                        icon = 'fa-solid fa-bars',
                        style = {
                            borderRadius = 0,
                            backgroundColor = '#de9602',
                            color = 'white'
                        }
                    })
                    if IsControlJustReleased(0, RSGCore.Shared.Keybinds[Config.Key]) then
                        local success
                        if not Config.DoMiniGame then
                            success = true
                        else
                            success = lib.skillCheck({{areaSize = 50, speedMultiplier = 0.5}}, {'w', 'a', 's', 'd'})
                        end
                        if success then
                            TriggerEvent('danglr-bricklayer:DropBrick')
                            Wait(500)
                        else
                            SetPedToRagdoll(player, 1000, 1000, 0, 0, 0, 0)
                            lib.notify({ title = '¡Intentar otra vez!', description = '¿Nunca has recogido plantas antes?', type = 'error' })
                        end
                    end
                else
                    lib.hideTextUI()
                end
            end
        end
    end
end)

--------------------------------------
-- EVENTS
--------------------------------------

RegisterNetEvent('danglr-bricklayer:StartJob', function()
    local player = PlayerPedId()
    local coords = GetEntityCoords(player)

    if not hasJob then
        for k, v in pairs(Config.Locations) do
            if Config.Prints then
                print(k)
            end
            local coordsA = coords
            local coordsB = vector3(Config.Locations[k]["Location"].x, Config.Locations[k]["Location"].y, Config.Locations[k]["Location"].z)
            local distance = #(coordsA - coordsB)
            if distance < 5 then
                closestJob = k
            end
        end
        PickupBrickLocation()
        hasJob = true

        if Config.Prints then
            print(hasJob)
        end

    else
        lib.notify({ title = 'Error', description = 'You already have this job!', type = 'error' })
    end
end)

RegisterNetEvent('danglr-bricklayer:EndJob', function()
    if hasJob then
        hasJob = false
        JobCount = 0
        DropCount = 0

        RemoveBlip(jobBlip)
        RemoveBlip(dropBlip)

        if Config.Prints then
            print(hasJob)
        end
    end

    --TriggerEvent('rNotify:NotifyLeft', "You Have Finished The Job", "", "generic_textures", "tick", 4500)
    lib.notify({ title = 'Error', description = 'You have stopped working!', type = 'error' })
end)

RegisterNetEvent('danglr-bricklayer:CollectPaycheck', function()
    print("Drop Count: "..DropCount)

    TriggerServerEvent('danglr-bricklayer:GetDropCount', DropCount)
    Wait(100)
    if DropCount ~= 0 then
        RSGCore.Functions.TriggerCallback('danglr-bricklayer:CheckIfPaycheckCollected', function(hasBeenPaid)
            if hasBeenPaid then
                TriggerEvent('danglr-bricklayer:EndJob')
                lib.notify({ title = 'Error', description = 'You have been paid for your work!', type = 'error' })
                if Config.Prints then
                    print(hasBeenPaid)
                end

            else -- Paid the money after initial check IE attempted to exploit
                lib.notify({ title = 'Error', description = 'You have been paid for your work!', type = 'error' })
                if Config.Prints then
                    print(hasBeenPaid)
                end

            end
        end, source)
    else
            lib.notify({ title = 'Error', description = 'You didn\'t do any work!', type = 'error' })
    end
end)

RegisterNetEvent('danglr-bricklayer:PickupBrick', function()
    local coords = GetEntityCoords(PlayerPedId())
    if hasJob then
        if not PickedUp then
            PickedUp = true
            local BrickProp = CreateObject(GetHashKey("p_brick01x"), coords.x, coords.y, coords.z, 1, 0, 1)
            SetEntityAsMissionEntity(BrickProp, true, true)
            RequestAnimDict("mech_loco_m@generic@carry@ped@walk")
            while not HasAnimDictLoaded("mech_loco_m@generic@carry@ped@walk") do
                Wait(100)
            end
            TaskPlayAnim(PlayerPedId(), "mech_loco_m@generic@carry@ped@walk", "idle", 2.0, -2.0, -1, 67109393, 0.0, false, 1245184, false, "UpperbodyFixup_filter", false)
            Citizen.InvokeNative(0x6B9BBD38AB0796DF, BrickProp, PlayerPedId(), GetEntityBoneIndexByName(PlayerPedId(),"SKEL_L_Hand"), 0.1, 0.08, 0.07, 35.0, 90.0, 0, true, true, false, true, 1, true)
            AttachedProp = true                                                                                                 ---         X      Y     Z    90.0, 0 = angle of prop
            RemoveBlip(jobBlip)

            Wait(500)
            for _,v in pairs(promptstable) do
                PromptDelete(promptstable[v].PickupBrickPrompt)
            end

            DropBrickLocation()
        end
    end
end)

RegisterNetEvent('danglr-bricklayer:DropBrick', function()
    local coords = GetEntityCoords(PlayerPedId())

    if hasJob and DropCount <= Config.DropCount then
        -- REMOVES THE BRICK PROP --
        for k, v in pairs(GetGamePool('CObject')) do
            if IsEntityAttachedToEntity(PlayerPedId(), v) then
                SetEntityAsMissionEntity(v, true, true)
                DeleteObject(v)
                DeleteEntity(v)
            end
        end
        ClearPedTasks(PlayerPedId())
        Wait(100)
        PickedUp = false

        -- START ANIMATION --
        TaskStartScenarioInPlace(PlayerPedId(), GetHashKey('world_player_dynamic_kneel'), -1, true, false, false, false)
        RSGCore.Functions.Progressbar("placebrick", "Placing Brick...", (Config.PlaceTime * 1000), false, true, {
            disableMovement = true,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function() -- Done

            DropCount = DropCount + 1

            if Config.Prints then
                print("Drop Count: "..DropCount)
            end

            RemoveBlip(dropBlip)

            Wait(100)

            if DropCount < Config.DropCount then
                PickupBrickLocation()
            else
                lib.notify({ title = 'Work Completed!', description = 'Go Get Your Check!', type = 'error' })
            end
        end)
    else
        lib.notify({ title = 'Work done!', description = 'Collect Your Check!', type = 'error' })
    end
end)

--------------------------------------
-- JOB MENU
--------------------------------------

RegisterNetEvent('danglr-bricklayer:OpenJobMenu', function()

    if not hasJob then
        lib.registerContext({
            id = 'brick_menu',
            title ='Brick Layer Job',
            options ={
            {
                title = "Start Brick Layer Job",
                description = "",
                event = 'danglr-bricklayer:StartJob'
            },
            }
        })
        lib.showContext('brick_menu')

    elseif hasJob then
        lib.registerContext({
            id = 'brick_2menu',
            title ='Brick Layer Job',
            options ={
            {
                title =  "Finish Job",
                description = "",
                event = 'danglr-bricklayer:CollectPaycheck'
            },
            }
        })
        lib.showContext('brick_2menu')
    end
end)

------------------------------------
-- RESOURCE START / STOP
------------------------------------

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for _,v in pairs(pedstable) do
            DeletePed(v)
        end
        for _,v in pairs(blipsTable) do
            RemoveBlip(v)
        end
        for k,_ in pairs(promptstable) do
			PromptDelete(promptstable[k].name)
		end
        RemoveBlip(jobBlip)
        RemoveBlip(dropBlip)
        lib.hideTextUI()
    end
end)