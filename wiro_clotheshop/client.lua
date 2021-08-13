
local drawable_names = {"face", "masks", "hair", "torsos", "legs", "bags", "shoes", "neck", "undershirts", "vest", "decals", "jackets"}
local prop_names = {"hats", "glasses", "earrings", "mouth", "lhand", "rhand", "watches", "braclets"}
local head_overlays = {"Blemishes","FacialHair","Eyebrows","Ageing","Makeup","Blush","Complexion","SunDamage","Lipstick","MolesFreckles","ChestHair","BodyBlemishes","AddBodyBlemishes"}
local face_features = {"Nose_Width","Nose_Peak_Hight","Nose_Peak_Lenght","Nose_Bone_High","Nose_Peak_Lowering","Nose_Bone_Twist","EyeBrown_High","EyeBrown_Forward","Cheeks_Bone_High","Cheeks_Bone_Width","Cheeks_Width","Eyes_Openning","Lips_Thickness","Jaw_Bone_Width","Jaw_Bone_Back_Lenght","Chimp_Bone_Lowering","Chimp_Bone_Lenght","Chimp_Bone_Width","Chimp_Hole","Neck_Thikness"}

local hasAlreadyEnteredMarker, lastZone, currentAction, currentActionMsg, hasPaid


Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

function SetDisplay(bool)
    SetNuiFocus(bool, bool)
    RefreshUI()
    SendNUIMessage({
        status = bool,
        type = "ui",
    })
end


local lastSkin
RegisterNetEvent('wiro_clotheshop:open')
AddEventHandler('wiro_clotheshop:open', function()
    TriggerEvent('skinchanger:getSkin', function(skin)
		lastSkin = skin
	end)
    SetDisplay(true)
end)

function RefreshUI()
    hairColors = {}
    --[[
    for i = 0, GetNumHairColors()-1 do
        local outR, outG, outB= GetPedHairRgbColor(i)
        hairColors[i] = {outR, outG, outB}
    end

    SendNUIMessage({
        type="colors",
        hairColors=hairColors,
        hairColor=GetPedHair()
    })
    ]]
    SendNUIMessage({
        type = "menutotals",
        drawTotal = GetDrawablesTotal(),
        propDrawTotal = GetPropDrawablesTotal(),
        textureTotal = GetTextureTotals(),
        -- headoverlayTotal = GetHeadOverlayTotals(),
    })
    SendNUIMessage({
        type = "clothesmenudata",
        drawables = GetDrawables(),
        props = GetProps(),
        drawtextures = GetDrawTextures(),
        proptextures = GetPropTextures(),
        skin = GetSkin(),
        oldPed = oldPed,
    })
end

function RefreshUITextures()
    SendNUIMessage({
        type = "menutotals",
        drawTotal = GetDrawablesTotal(),
        propDrawTotal = GetPropDrawablesTotal(),
        textureTotal = GetTextureTotals(),
        -- headoverlayTotal = GetHeadOverlayTotals(),
    })
end

RegisterNUICallback('exit', function()
    SetDisplay(false)
    DeleteCam()
end)


function GetSkin()
    for i = 1, #frm_skins do
        if (GetHashKey(frm_skins[i]) == GetEntityModel(PlayerPedId())) then
            return {name="skin_male", value=i}
        end
    end
    for i = 1, #fr_skins do
        if (GetHashKey(fr_skins[i]) == GetEntityModel(PlayerPedId())) then
            return {name="skin_female", value=i}
        end
    end
    return false
end

function GetDrawables()         -- drawable_names tablosundaki yani tüm kıyafetlerin max değerini alır
    drawables = {}
    local model = GetEntityModel(PlayerPedId())
    local mpPed = false
    if (model == `mp_f_freemode_01` or model == `mp_m_freemode_01`) then
        mpPed = true
    end
    for i = 0, #drawable_names-1 do
        if mpPed and drawable_names[i+1] == "undershirts" and GetPedDrawableVariation(PlayerPedId(), i) == -1 then
            SetPedComponentVariation(PlayerPedId(), i, 15, 0, 2)
        end
        drawables[i] = {drawable_names[i+1], GetPedDrawableVariation(PlayerPedId(), i)}
    end
    return drawables
end

function GetProps()
    props = {}
    for i = 0, #prop_names-1 do
        props[i] = {prop_names[i+1], GetPedPropIndex(PlayerPedId(), i)}
    end
    return props
end

function GetDrawTextures()
    textures = {}
    for i = 0, #drawable_names-1 do
        table.insert(textures, {drawable_names[i+1]  .. "tex", GetPedTextureVariation(PlayerPedId(), i)})
    end
    return textures
end

function GetPropTextures()
    textures = {}
    for i = 0, #prop_names-1 do
        table.insert(textures, {prop_names[i+1], GetPedPropTextureIndex(PlayerPedId(), i)})
    end
    return textures
end

function GetDrawablesTotal()
    drawables = {}
    for i = 0, #drawable_names - 1 do
        drawables[i] = {drawable_names[i+1], GetNumberOfPedDrawableVariations(PlayerPedId(), i)}
    end
    return drawables
end

function GetPropDrawablesTotal()
    props = {}
    for i = 0, #prop_names - 1 do
        props[i] = {prop_names[i+1], GetNumberOfPedPropDrawableVariations(PlayerPedId(), i)}
    end
    return props
end

function GetTextureTotals()
    local values = {}
    local draw = GetDrawables()
    local props = GetProps()

    for idx = 0, #draw-1 do
        local name = draw[idx][1]
        local value = draw[idx][2]
        values[name .."tex"] = GetNumberOfPedTextureVariations(PlayerPedId(), idx, value)
    end

    for idx = 0, #props-1 do
        local name = props[idx][1]
        local value = props[idx][2]
        values[name.. "tex"] = GetNumberOfPedPropTextureVariations(PlayerPedId(), idx, value)
    end
    return values
end

function GetPedHair()
    local hairColor = {}
    hairColor[1] = GetPedHairColor(player)
    hairColor[2] = GetPedHairHighlightColor(player)
    return hairColor
end

-- Wiro Cam Controls
local last = nil
RegisterNUICallback('cam', function(data)
    if last ~= data.cam then 
        CreateCam(0.0, 0.0, 0.0, 0.0, 0.0, GetEntityHeading(PlayerPedId()) - 180.0)
        SwitchCam(data.cam)
    else
        DeleteCam()
        last = nil
    end
end)

function CreateCam(x, y, z, rotx, roty, rotz)
    entcords = GetEntityCoords(PlayerPedId())
	if not DoesCamExist(cam) then
        cam = 	CreateCamWithParams(
            'DEFAULT_SCRIPTED_CAMERA', 
            entcords.x - x, 
            entcords.y - y, 
            entcords.z - z, 
            rotx,
            roty, 
            rotz, 
            90.0,
            true, 
            true
        )
	end
	RenderScriptCams(true, true, 500, true, true)
end

function DeleteCam()
	SetCamActive(cam, false)
	RenderScriptCams(false, true, 500, true, true)
	cam = nil
    DestroyCam(cam)
end

function TogRotation()
    local pedRot = GetEntityHeading(PlayerPedId())+90 % 360
    SetEntityHeading(PlayerPedId(), math.floor(pedRot / 90) * 90.0)
end

function SwitchCam(name)
    if name == "cam" then
        TogRotation()
        return
    end

    local pos = GetEntityCoords(PlayerPedId(), true)
    local bonepos = false
    if (name == "head") then
        bonepos = GetPedBoneCoords(PlayerPedId(), 31086)
        bonepos = vector3(bonepos.x - 0.1, bonepos.y + 0.4, bonepos.z + 0.05)
    end
    if (name == "torso") then
        bonepos = GetPedBoneCoords(PlayerPedId(), 11816)
        bonepos = vector3(bonepos.x - 0.4, bonepos.y + 1.2, bonepos.z + 0.2)
    end
    if (name == "leg") then
        bonepos = GetPedBoneCoords(PlayerPedId(), 46078)
        bonepos = vector3(bonepos.x - 0.1, bonepos.y + 1, bonepos.z)
    end

    SetCamCoord(cam, bonepos.x, bonepos.y, bonepos.z)
    SetCamRot(cam, 0.0, 0.0, 180.0)
    last = name
end

-- Wiro İkon controls

local toggleClothing = {}
function ToggleProps(data)
    local name = data["name"]

    selectedValue = has_value(drawable_names, name)
    if (selectedValue > -1) then
        if (toggleClothing[name] ~= nil) then
            SetPedComponentVariation(
                PlayerPedId(),
                tonumber(selectedValue),
                tonumber(toggleClothing[name][1]),
                tonumber(toggleClothing[name][2]), 2)
            toggleClothing[name] = nil
        else
            toggleClothing[name] = {
                GetPedDrawableVariation(PlayerPedId(), tonumber(selectedValue)),
                GetPedTextureVariation(PlayerPedId(), tonumber(selectedValue))
            }

            local value = -1
            if name == "undershirts" or name == "torsos" then
                gust = not gust
                value = 15
                if name == "undershirts" and GetEntityModel(PlayerPedId()) == GetHashKey('mp_f_freemode_01') then
                    value = -1
                end
            end
            if name == "legs" then
                gshirt = not gshirt
                value = 14
            end

            SetPedComponentVariation(
                PlayerPedId(),
                tonumber(selectedValue),
                value, 0, 2)
            end
    else
        selectedValue = has_value(prop_names, name)
        if (selectedValue > -1) then
            if (toggleClothing[name] ~= nil) then
                SetPedPropIndex(
                    PlayerPedId(),
                    tonumber(selectedValue),
                    tonumber(toggleClothing[name][1]),
                    tonumber(toggleClothing[name][2]), true)
                toggleClothing[name] = nil
            else
                toggleClothing[name] = {
                    GetPedPropIndex(PlayerPedId(), tonumber(selectedValue)),
                    GetPedPropTextureIndex(PlayerPedId(), tonumber(selectedValue))
                }
                ClearPedProp(PlayerPedId(), tonumber(selectedValue))
            end
        end
    end
end

function has_value (tab, val)
    for index = 1, #tab do
        if tab[index] == val then
            return index-1
        end
    end
    return -1
end

-- Kıyafet değişme işlemleri

RegisterNUICallback('toggleclothes', function(data, cb)
    ToggleProps(data)
    cb('ok')
end)

RegisterNUICallback('updateclothes', function(data, cb)
    Citizen.Wait(0)
    SetPedArmour(PlayerPedId(),0.0)
    toggleClothing[data["name"]] = nil
    selectedValue = has_value(drawable_names, data["name"])
    if (selectedValue > -1) then
	
    TriggerEvent('skinchanger:getSkin', function(skin2)
        --print(skin2.chain_1)
	  if selectedValue == 11 then
	   skin2.torso_1 = tonumber(data["value"])
	   skin2.torso_2 = tonumber(data["texture"])
	  elseif selectedValue == 2 then
	   skin2.hair_1 = tonumber(data["value"])
	   skin2.hair_2 = tonumber(data["texture"])   
	  elseif selectedValue == 8 then
	   skin2.tshirt_1 = tonumber(data["value"])
	   skin2.tshirt_2 = tonumber(data["texture"])	   
	  elseif selectedValue == 3 then
	   skin2.arms = tonumber(data["value"])	 
	  elseif selectedValue == 4 then
	   skin2.pants_1 = tonumber(data["value"])	 
	   skin2.pants_2 = tonumber(data["texture"])	   
	  elseif selectedValue == 6 then
	   skin2.shoes_1 = tonumber(data["value"])	 
	   skin2.shoes_2 = tonumber(data["texture"])	
	  elseif selectedValue == 10 then
	   skin2.decals_1 = tonumber(data["value"])	 
	   skin2.decals_2 = tonumber(data["texture"])	
	  elseif selectedValue == 1 then
	   skin2.mask_1 = tonumber(data["value"])	 
	   skin2.mask_2 = tonumber(data["texture"])
	  elseif selectedValue == 5 then
	   skin2.bags_1 = tonumber(data["value"])	 
       skin2.bags_2 = tonumber(data["texture"])
      elseif selectedValue == 7 then
        skin2.chain_1 = tonumber(data["value"])	 
        skin2.chain_2 = tonumber(data["texture"])
	  elseif selectedValue == 9 then
	   skin2.bproof_1 = tonumber(data["value"])	 
	   skin2.bproof_2 = tonumber(data["texture"])
	  end
	   TriggerEvent("skinchanger:loadSkin",skin2)	  
	end)
        cb({
            GetNumberOfPedTextureVariations(PlayerPedId(), tonumber(selectedValue), tonumber(data["value"]))
        })
    else
        selectedValue = has_value(prop_names, data["name"])
        if (tonumber(data["value"]) == -1) then
            ClearPedProp(PlayerPedId(), tonumber(selectedValue))
        else
    TriggerEvent('skinchanger:getSkin', function(skin2)
	  if selectedValue == 1 then
	   skin2.glasses_1 = tonumber(data["value"])
	   skin2.glasses_2 = tonumber(data["texture"])
      elseif selectedValue == 2 then
        if tonumber(data["value"]) == 0 then
            skin2.ears_1 = -1
            skin2.ears_2 = tonumber(data["texture"])
        else
            skin2.ears_1 = tonumber(data["value"])
            skin2.ears_2 = tonumber(data["texture"])
        end
      elseif selectedValue == 0 then
        if tonumber(data["value"]) == 0 then
            skin2.helmet_1 = -1
            skin2.helmet_2 = tonumber(data["texture"])
        else
            skin2.helmet_1 = tonumber(data["value"])
            skin2.helmet_2 = tonumber(data["texture"])
        end
      elseif selectedValue == 6 then
        if tonumber(data["value"]) == 0 then
            skin2.watches_1 = -1
            skin2.watches_2 = tonumber(data["texture"])
        else
            skin2.watches_1 = tonumber(data["value"])
            skin2.watches_2 = tonumber(data["texture"])
        end	
	  elseif selectedValue == 7 then
	   skin2.bracelets_1 = tonumber(data["value"])	 
	   skin2.bracelets_2 = tonumber(data["texture"])		   
	  end
	   TriggerEvent("skinchanger:loadSkin",skin2)
	end)
			end
        cb({
            GetNumberOfPedPropTextureVariations(
                PlayerPedId(),
                tonumber(selectedValue),
                tonumber(data["value"])
            )
        })
    end
end)

-- Satın alım vs.

RegisterNUICallback('iptal', function(data, cb)
    SetDisplay(false)
    DeleteCam()
    TriggerEvent('skinchanger:loadSkin', lastSkin)
end)

RegisterNUICallback('satinal', function(data, cb)
    SetDisplay(false)
    DeleteCam()
    TriggerServerEvent('wiro_clotheshop:balance', lastSkin)
    TriggerEvent('skinchanger:getSkin', function(skin)
		TriggerServerEvent('wiro_clotheshop:savegobrr', skin)
	end)
end)

RegisterNUICallback('yon', function(data, cb)
    SetEntityHeading(PlayerPedId(), GetEntityHeading(PlayerPedId()) + data.yon)
end)

-- Create Blips
Citizen.CreateThread(function()
	for k,v in ipairs(Config.Shops) do
		local blip = AddBlipForCoord(v)

		SetBlipSprite (blip, 73)
		SetBlipColour (blip, 47)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName('STRING')
		AddTextComponentSubstringPlayerName("Kıyafet Mağazası")
		EndTextCommandSetBlipName(blip)
	end
end)

-- Enter / Exit marker events & draw markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local playerCoords, isInMarker, currentZone, letSleep = GetEntityCoords(PlayerPedId()), false, nil, true

		for k,v in pairs(Config.Shops) do
			local distance = #(playerCoords - v)

			if distance < Config.DrawDistance then
				letSleep = false
				DrawMarker(Config.MarkerType, v, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, nil, nil, false)

				if distance < Config.MarkerSize.x then
					isInMarker, currentZone = true, k
				end
			end
		end

		if (isInMarker and not hasAlreadyEnteredMarker) or (isInMarker and lastZone ~= currentZone) then
			hasAlreadyEnteredMarker, lastZone = true, currentZone
			TriggerEvent('wiro_clotheshop:hasEnteredMarker', currentZone)
		end

		if not isInMarker and hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = false
			TriggerEvent('wiro_clotheshop:hasExitedMarker', lastZone)
		end

		if letSleep then
			Citizen.Wait(500)
		end
	end
end)

AddEventHandler('wiro_clotheshop:hasEnteredMarker', function(zone)
	currentAction     = 'shop_menu'
	currentActionData = {}
end)

AddEventHandler('wiro_clotheshop:hasExitedMarker', function(zone)
	currentAction = nil
end)


-- Key controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if currentAction then

			if IsControlJustReleased(0, 38) then
				if currentAction == 'shop_menu' then
					TriggerEvent('wiro_clotheshop:open')
				end

				currentAction = nil
			end
		else
			Citizen.Wait(500)
		end
	end
end)