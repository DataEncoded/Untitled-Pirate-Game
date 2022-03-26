local Knit = require(game:GetService("ReplicatedStorage").Packages.knit)

local ContextActionService = game:GetService("ContextActionService")
local CollectionService = game:GetService("CollectionService")

local Camera = workspace.CurrentCamera

local PlayerShipCannonController = Knit.CreateController({
	Name = "PlayerShipCannonController",
    targetedShip = nil,
})

local function getNearShips(): { PVInstance }
    local ships = CollectionService:GetTagged("PlayerShip")

    local results = {}

    for _, v in ipairs(ships) do
        local _, bounds = Camera:WorldToScreenPoint()
        if bounds then

            

            if #results > 0 then
                --Loop through all results to find correct position
                for i = 1, #results do
                    
                end
            end

        end
    end

end

local function watchSwitchInput(actionName, inputState, inputOption)
    if actionName == "LeftSwitch" then

    end
end

function PlayerShipCannonController:enable()

    ContextActionService
end

function PlayerShipCannonController:disable()

end

return PlayerShipCannonController