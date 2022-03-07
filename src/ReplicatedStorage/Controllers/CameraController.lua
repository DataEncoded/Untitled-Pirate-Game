local Knit = require(game:GetService("ReplicatedStorage").Packages.knit)

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local CameraController = Knit.CreateController({
	Name = "CameraController",
})

local player
local camera = workspace.CurrentCamera
local cameraOffset = CFrame.new(30, 50, 30) -- This will change based off what ship they have equipped
local totalSpinY = 0

local function Bind()
	local character = player.Character
	local root = character and character.PrimaryPart

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
				deltaX = state.Position.X
				break
			end
		end
	end

	totalSpinY += deltaX
	local rootCFrame = CFrame.new(root.Position) * CFrame.Angles(0, math.rad(totalSpinY), 0)
	local cameraPosition = (rootCFrame * cameraOffset).Position
	camera.CFrame = CFrame.lookAt(cameraPosition, rootCFrame.Position)
end

function CameraController:KnitStart() end

function CameraController:KnitInit()
	player = game.Players.LocalPlayer
	RunService:BindToRenderStep("IsometricCamera", Enum.RenderPriority.Camera.Value + 1, Bind)
end

return CameraController
