--Get Packages
local Knit = require(game:GetService("ReplicatedStorage").Packages.knit)
local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Component = require(game:GetService("ReplicatedStorage").Packages.component)

local QuickFunctions = require(game.ReplicatedStorage.Modules.QuickFunctions)

local Components = ReplicatedStorage.Components
local shipComponent


local PlayerShipCannonService = Knit.CreateService({
	Name = "PlayerShipCannonService",
	Client = {
		--Signal that the client sends when wanting to respawn
		Fire = Knit.CreateSignal(),
	},
})

local function hitDetection(playerShip, startPos, endPos)

    local params = OverlapParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = playerShip


    local function loopFunction(quadPosition)
        local result = QuickFunctions.hitDetection(quadPosition, params)
        if result then
            
            local ship = shipComponent:FromInstance(result)

            if ship then
                --TODO: CANNON DAMAGE CHANGING DEPENDING ON CUSTOMIZATION
                ship:takeDamage(5)
            end

            return true
        end
    end


    local promise = QuickFunctions.loopOverQuad(startPos, endPos, nil, loopFunction)
    
end

function PlayerShipCannonService:KnitStart()

    self.Client.Fire:Connect(function(player, position)
        if position then
            --TODO: Check that the cannon is within the desired angle
            local playerShips = QuickFunctions.returnTaggedAttribute("PlayerShip", "UserId", player.UserId)

            if #playerShips == 1 then
                self.Client.Fire:FireAll(playerShips[1]:GetPivot().Position, position, playerShips[1])
                hitDetection(playerShips, playerShips[1]:GetPivot().Position, position)
            end

        end
    end)
    
    shipComponent = require(Components.Ship)

end


return PlayerShipCannonService