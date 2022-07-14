local Knit = require(game:GetService("ReplicatedStorage").Packages.knit)

local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Cannonball = require(ReplicatedStorage.Modules.CannonBall)
local QuickFunctions = require(ReplicatedStorage.Modules.QuickFunctions)

local Camera = workspace.CurrentCamera

--Init in KnitStart to not cause errors
local PlayerShip
local PlayerShipCannonService

local PlayerShipCannonController = Knit.CreateController({
	Name = "PlayerShipCannonController",
	targetedShip = nil,
})

local function getPlayerShip(): PVInstance | nil
	local playerShip = QuickFunctions.returnTaggedAttribute("PlayerShip", "UserId", game.Players.LocalPlayer.UserId)

	--If player ship acting strange, exit function
	if #playerShip ~= 1 then
		return nil
	else
		return playerShip[1]
	end
end

local function updateTargetedShip(target)
	PlayerShipCannonController.targetedShip = target
	PlayerShipCannonController.targetIcon.Parent = target
end

--Takes input, raycasts it, attempts to find a model with a ship tag at hit position. If it finds it update targeted ship
local function watchTargetInput(inputPosition)
	local unitRay = Camera:ViewportPointToRay(inputPosition.X, inputPosition.Y)

	--TODO: Add water to raycast blacklist
	local hit = Workspace:Raycast(unitRay.Origin, unitRay.Direction * 500)
	if not hit or not hit.Instance then
		return
	end

	local target = hit.Instance:FindFirstAncestorOfClass("Model")

	if CollectionService:HasTag(target, "Ship") or CollectionService:HasTag(target, "PlayerShip") then
		updateTargetedShip(target)
	end
end

--Ensure targeted ship stays in view or lose them
local function watchTargetedShipLeave()
	if PlayerShipCannonController.targetedShip then
		local _, bounds = Camera:WorldToScreenPoint(PlayerShipCannonController.targetedShip:GetPivot().Position)

		if not bounds then
			updateTargetedShip(nil)
		end
	end
end

local function fireCannon(_, inputState, _)
	if inputState == Enum.UserInputState.Begin then
		local localPlayerShip = getPlayerShip()
		if PlayerShipCannonController.targetedShip and localPlayerShip then
			local _ = PlayerShip:FromInstance(localPlayerShip)

			PlayerShipCannonService.Fire:Fire(PlayerShipCannonController.targetedShip:GetPivot().Position)
		end
	end
end

local function inputLocationFormat(locationOrInput, processed)
	if not processed then
		--Don't handle processed input
		if typeof(locationOrInput) == "Vector2" then
			--Location, not input. Simply pass input through
			watchTargetInput(locationOrInput)
		elseif locationOrInput["UserInputType"] then
			--Input, check if it's a mouse
			if locationOrInput.UserInputType == Enum.UserInputType.MouseButton1 then
				--It's a mouse, send the mouse location
				watchTargetInput(UserInputService:GetMouseLocation())
			end
		end
	end
end

function PlayerShipCannonController:enable()
	RunService:BindToRenderStep("TargetShipLeave", 2000, watchTargetedShipLeave) --Last
	--Use userinputservice so that touch works
	self.touchInput = UserInputService.TouchTapInWorld:Connect(inputLocationFormat)
	self.mouseInput = UserInputService.InputBegan:Connect(inputLocationFormat)
	ContextActionService:BindAction("Fire", fireCannon, false, Enum.KeyCode.Space, Enum.KeyCode.ButtonR2)
end

function PlayerShipCannonController:disable()
	RunService:UnbindFromRenderStep("TargetShipLeave")
	self.touchInput:Disconnect()
	self.mouseInput:Disconnect()
	ContextActionService:UnbindAction("Fire")
end

function PlayerShipCannonController:KnitStart()
	PlayerShipCannonController.targetIcon = ReplicatedStorage.Assets.UI.TargetUI:Clone()
	PlayerShip = require(ReplicatedStorage.Components.PlayerShip)

	PlayerShipCannonService = Knit.GetService("PlayerShipCannonService")

	PlayerShipCannonService.Fire:Connect(function(startPos, pos, ignore)
		local params = OverlapParams.new()
		params.FilterType = Enum.RaycastFilterType.Blacklist
		params.FilterDescendantsInstances = { ignore }

		local ball = Cannonball.new()

		if ignore == getPlayerShip() then
			--Firing shot locally as localship is actually shooting
			startPos = getPlayerShip():GetPivot().Position
		end

		ball:fireAtPosition(startPos, pos, false, params)
	end)
end

return PlayerShipCannonController
