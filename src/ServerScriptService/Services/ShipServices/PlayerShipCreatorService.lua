--Get Packages
local Knit = require(game:GetService("ReplicatedStorage").Packages.knit)
local Workspace = game:GetService("Workspace")

--Get Services
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local QuickFunctions = require(game.ReplicatedStorage.Modules.QuickFunctions)

local PlayerShipCreatorService = Knit.CreateService({
	Name = "PlayerShipCreatorService",
	Client = {
		--Signal that the client sends when wanting to respawn
		Respawn = Knit.CreateSignal(),
	},
})

--KnitInit Functions
--
--Remove ships of players who are leaving
function PlayerShipCreatorService:KnitInit()
	Players.PlayerRemoving:Connect(function(player)
		local playerShips = QuickFunctions.returnTaggedAttribute("PlayerShip", "UserId", player.UserId)

		for _, ship in ipairs(playerShips) do
			ship:Destroy()
		end
	end)
end

--KnitStart Functions
--
--Listen to the respawn signal and ensure a ship can be spawned
function PlayerShipCreatorService:KnitStart()
	self.Client.Respawn:Connect(function(player)
		if #QuickFunctions.returnTaggedAttribute("PlayerShip", "UserId", player.UserId) == 0 then
			--TODO: Ship Selection
			local clone = ReplicatedStorage.Assets.Ships.Raft:Clone()
			local nameUI = clone:FindFirstChild("NameUI")

			if not nameUI then
				nameUI = ReplicatedStorage.Assets.UI.NameUI:Clone()
			end

			clone:SetAttribute("UserId", player.UserId)
			CollectionService:AddTag(clone, "PlayerShip")

			nameUI.Background.NameLabel.Text = player.Name
			nameUI.Parent = clone

			--TODO: Location Selection
			clone.Parent = Workspace

			clone.Anchored = false

			clone:SetNetworkOwner(player)

			self.Client.Respawn:Fire(player, clone)
		end
	end)
end

return PlayerShipCreatorService
