local Knit = require(game:GetService("ReplicatedStorage").Packages.knit)

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local QuickFunctions = require(game.ReplicatedStorage.Modules.QuickFunctions)

local ShipCameraConfig = require(game.ReplicatedStorage.Configs.ShipCameraConfig)

local CameraController = Knit.CreateController({
	Name = "CameraController",
})

local function getPlayerShip()
	local playerShip
	local playerShips = QuickFunctions.returnTaggedAttribute("PlayerShip", "UserId", game.Players.LocalPlayer.UserId)

	for _, ship in ipairs(playerShips) do
		playerShip = ship
	end

	return ShipCameraConfig[playerShip.Name]
end

local cameraOffset
local camera = workspace.CurrentCamera -- This will change based off what ship they have equipped
local totalSpinY = 0

local function Bind(partToBind)
	local root = partToBind

	if not root then
		return
	end

	local delta = UserInputService:GetMouseDelta()
	local deltaX = delta.X * 0.5

	if UserInputService.GamepadEnabled then
		local gamepadState = UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1)
		for _, state in pairs(gamepadState) do
			if state.KeyCode.Name == "Thumbstick2" then
				delta = state.Position
				deltaX = state.Position.X * 1.5
				break
			end
		end
	end

	totalSpinY += deltaX
	local rootCFrame = CFrame.new(root.Position) * CFrame.Angles(0, math.rad(totalSpinY), 0)
	local cameraPosition = (rootCFrame * cameraOffset).Position
	camera.CFrame = CFrame.lookAt(cameraPosition, rootCFrame.Position)
end

function CameraController:BindToPart(partToBind)
	RunService:BindToRenderStep("IsometricCamera", Enum.RenderPriority.Camera.Value + 1, function()
		Bind(partToBind)
	end)
end

function CameraController:KnitStart()
	local PlayerShipCreatorService = Knit.GetService("PlayerShipCreatorService")

	PlayerShipCreatorService.Respawn:Connect(function()
		cameraOffset = getPlayerShip()
	end)
end

function CameraController:KnitInit() end

return CameraController
