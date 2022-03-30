--Get Packages
local Knit = require(game:GetService("ReplicatedStorage").Packages.knit)
local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")

local QuickFunctions = require(game.ReplicatedStorage.Modules.QuickFunctions)

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
        local result = QuickFunctions.hitDetection(quadPosition, params, "PlayerShip")
        if result then
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
                self.Client.Fire:FireAll(playerShips[1].Position, position)
                hitDetection(playerShips, playerShips[1].Position, position)
            end

        end
    end)

end


return PlayerShipCannonService