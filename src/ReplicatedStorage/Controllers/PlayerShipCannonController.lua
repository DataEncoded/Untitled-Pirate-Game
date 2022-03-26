local Knit = require(game:GetService("ReplicatedStorage").Packages.knit)

local ContextActionService = game:GetService("ContextActionService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local QuickFunctions = require(ReplicatedStorage.Modules.QuickFunctions)

local Camera = workspace.CurrentCamera

local PlayerShipCannonController = Knit.CreateController({
	Name = "PlayerShipCannonController",
    targetedShip = nil,
})


--If something breaks after changing the ships from meshes to models, it's this.
local function getNearShips(): { PVInstance }
    --Heavily dependant on PlayerShip tag
    local ships = CollectionService:GetTagged("PlayerShip")

    local playerShip = QuickFunctions:returnTaggedAttribute("PlayerShip", "UserId", game.Players.LocalPlayer.UserId)
    
    --If player ship acting strange, exit function
    if #playerShip ~= 1 then
        return {}
    else
        playerShip = playerShip[1]
    end

    local distanceDict = {}
    local results = {}

    for _, v in ipairs(ships) do
        if not (v == playerShip) then

            --bounds is a bool value depending on if the value is within the screen
            local _, bounds = Camera:WorldToScreenPoint(v.Position)

            if bounds then

                local shipPosition = v.Position

                distanceDict[v] = (playerShip.Position - shipPosition).Magnitude
                
            end
        end
    end

    --Now loop through distance dict and construct results

    for ship, distance in pairs(distanceDict) do
        if #results > 0 then

            local success = false

            for i = 1, #results do
                local targetShip = results[i]

                if distance <= distanceDict[targetShip] then

                    table.insert(results, i, ship)

                    success = true

                    break
                end
            end

            --Furthest Distance, insert at end
            if not success then 
                table.insert(results, ship)
            end

        else
            
            table.insert(results, ship)
        end
    end

    --Finally return result after all that filtering
    return results

end

local function watchSwitchInput(actionName, inputState, inputOption)
    if actionName == "LeftSwitch" then

    end
end

function PlayerShipCannonController:enable()

end

function PlayerShipCannonController:disable()

end

return PlayerShipCannonController