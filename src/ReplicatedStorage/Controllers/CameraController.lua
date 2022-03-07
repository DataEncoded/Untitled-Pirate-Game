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
	local delta = UserInputService:GetMouseDelta()

	if not character then
		return
	end

	totalSpinY += delta.X * 0.5
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
