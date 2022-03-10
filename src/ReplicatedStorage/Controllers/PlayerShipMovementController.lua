local Workspace = game:GetService("Workspace")
local Knit = require(game:GetService("ReplicatedStorage").Packages.knit)

local PlayerShipMovementController = Knit.CreateController({ Name = "PlayerShipMovementController" })

local ControlModule = require(
	game.Players.LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"):WaitForChild("ControlModule")
)

local camera = Workspace.CurrentCamera

--Get the input direction of an object relative to the camera
function PlayerShipMovementController.getInputRelativeToCamera(object)
	--Ensure there is no rotation from the Y value
	local cameraCframe = CFrame.new(Vector3.new(camera.CFrame.Position.X, object.Position.Y, camera.CFrame.Position.Z))

	return cameraCframe:VectorToWorldSpace(ControlModule:GetMoveVector())
end

function PlayerShipMovementController.moveVector()
	return ControlModule:GetMoveVector()
end

function PlayerShipMovementController:KnitStart()
	local creator = Knit.GetService("PlayerShipCreatorService")
	creator.Respawn:Fire()
end

return PlayerShipMovementController
