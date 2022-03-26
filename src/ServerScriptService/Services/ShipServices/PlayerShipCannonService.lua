--Get Packages
local Knit = require(game:GetService("ReplicatedStorage").Packages.knit)
local Workspace = game:GetService("Workspace")

local QuickFunctions = require(game.ReplicatedStorage.Modules.QuickFunctions)

local PlayerShipCannonService = Knit.CreateService({
	Name = "PlayerShipCannonService",
	Client = {
		--Signal that the client sends when wanting to respawn
		Fire = Knit.CreateSignal(),
	},
})

function PlayerShipCannonService:KnitStart()

    self.Client.Fire:Connect(function(player, position)
        if position then
            --TODO: Check that the cannon is within the desired angle
            local playerShips = QuickFunctions:returnTaggedAttribute("PlayerShip", "UserId", player.UserId)

            if #playerShips == 1 then
                self.Client.Fire:FireAll(playerShips[1].Position, position)
            end

        end
    end)

end


return PlayerShipCannonService