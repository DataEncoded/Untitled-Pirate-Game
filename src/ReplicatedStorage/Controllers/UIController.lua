local Knit = require(game:GetService("ReplicatedStorage").Packages.knit)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIController = Knit.CreateController({
	Name = "UIController",
})

local RespawnButton

function UIController:KnitStart()
	local PlayerShipCreatorService = Knit.GetService("PlayerShipCreatorService")

	PlayerShipCreatorService.Respawn:Connect(function(clone)
		Knit.GetController("CameraController"):BindToPart(clone)
	end)

	RespawnButton.MouseButton1Click:Connect(function()
		PlayerShipCreatorService.Respawn:Fire()
	end)
end

function UIController:KnitInit()
	local player = game.Players.LocalPlayer
	local assets = ReplicatedStorage.Assets
	local RespawnUI = assets.UI.RespawnUI:Clone()
	RespawnUI.Parent = player.PlayerGui

	RespawnButton = RespawnUI.Background.Button
end

return UIController
