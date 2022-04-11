local Knit = require(game:GetService("ReplicatedStorage").Packages.knit)
local Workspace = game:GetService("Workspace")
local Component = require(game:GetService("ReplicatedStorage").Packages.component)

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerShipCannonController = Knit.GetController("PlayerShipCannonController")

local ShipAlignConfig = require(ReplicatedStorage.Configs.ShipAlignConfig)
local CannonBallModule = require(ReplicatedStorage.Modules.CannonBall)

local PlayerShip = Component.new({ Tag = "PlayerShip" })

function PlayerShip:Construct()
	if self.Instance:GetAttribute("UserId") == game.Players.LocalPlayer.UserId then
		self.control = true
		self.inputAttachment = Instance.new("Attachment")
		self.inputAttachment.Parent = Workspace.Terrain

		local shipAttachment = Instance.new("Attachment")
		shipAttachment.Parent = self.Instance.PrimaryPart

		local configRef = ShipAlignConfig[self.Instance.Name]

		if configRef and configRef["Attachment"] then
			shipAttachment.Orientation = configRef["Attachment"]
		end

		local shipToInput = Instance.new("AlignPosition")

		shipToInput.Attachment0 = shipAttachment
		shipToInput.Attachment1 = self.inputAttachment

		shipToInput.Parent = self.Instance

		shipToInput.Responsiveness = 25

		self.alignPart = Instance.new("Part")
		self.alignPart.Parent = workspace
		self.alignPart.Anchored = true

		self.alignPart.Transparency = 1

		local alignAttachment = Instance.new("Attachment")
		alignAttachment.Parent = self.alignPart

		self.shipToAlign = Instance.new("AlignOrientation")

		self.shipToAlign.Attachment0 = shipAttachment
		self.shipToAlign.Attachment1 = alignAttachment

		if configRef and configRef["Torque"] then
			self.shipToAlign.MaxTorque = configRef["Torque"]
		end

		self.shipToAlign.Parent = self.Instance

		self.Instance.PrimaryPart.CanCollide = false
	end
end

local function renderStep(self)
	local velocity = Knit.GetController("PlayerShipMovementController").getInputRelativeToCamera(self.Instance.PrimaryPart)

	local selfPivot = self.Instance:GetPivot().Position

	self.Instance:PivotTo(CFrame.new(selfPivot * Vector3.new(1, 0, 1)) * self.Instance:GetPivot().Rotation)

	local position = velocity * Vector3.new(5, 1, 5) + selfPivot

	self.inputAttachment.WorldCFrame = CFrame.new(position, velocity)

	if not (Knit.GetController("PlayerShipMovementController").moveVector() == Vector3.new(0, 0, 0)) then
		self.alignPart.CFrame = CFrame.lookAt(selfPivot, self.inputAttachment.WorldPosition)
			* CFrame.Angles(0, math.rad(180), 0)
	else
		self.alignPart.Orientation = self.alignPart.Orientation * Vector3.new(0, 1, 1)
	end
end

function PlayerShip:Start()
	if self.control then
		self.RenderPriority = Enum.RenderPriority.Input.Value

		RunService:BindToRenderStep("ShipControl", Enum.RenderPriority.Input.Value, function()
			renderStep(self)
		end)
		PlayerShipCannonController:enable()
	end
end

function PlayerShip:Stop()
	if self.control then
		RunService:UnbindFromRenderStep("ShipControl")

		PlayerShipCannonController:disable()
	end
end

function PlayerShip:fireCannons(position, cannonType)
	local Cannonball = CannonBallModule.new()
	Cannonball:fireAtPosition(self.Instance:GetPivot().Position, position)
end

return PlayerShip
