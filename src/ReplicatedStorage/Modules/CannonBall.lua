--Superclass for cannonballs
local Cannonball = {}
Cannonball.__index = Cannonball

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local QuickFunctions = require(ReplicatedStorage.Modules.QuickFunctions)

local Promise = require(game:GetService("ReplicatedStorage").Packages.promise)

function Cannonball.new()
	local self = {}
	setmetatable(self, Cannonball)
	self.ball = Instance.new("Part")
	self.ball.Size = Vector3.new(2, 2, 2)
	self.ball.Shape = 0 --Sphere
	self.ball.BrickColor = BrickColor.new("Smokey grey")
	self.ball.CanCollide = false
	self.ball.Anchored = true

	local trail = Instance.new("Trail")
	trail.Parent = self.ball

	return self
end

--Wrapper for _fireAtPosition's promises
function Cannonball:fireAtPosition(startPosition: Vector3, position: Vector3, keepAlive: bool | nil, params: OverlapParams)
	self.firePromise = self:_fireAtPosition(startPosition, position, params)

	if not keepAlive then
		self.fireWatch = self.firePromise:andThen(function()
			self:Destroy()
		end)
	end
end

function Cannonball:stopFire()
	if self.firePromise and self.firePromise.Status == "Started" then
		self.firePromise:cancel()
	end
end

--Wrapped around to prevent mishandeling
function Cannonball:_fireAtPosition(startPosition, position, overlapParams)
	overlapParams.FilterDescendantsInstances = {overlapParams.FilterDescendantsInstances[1], self.ball}


	local function startFunc()
		self.ball.Parent = workspace
	
		self.ball:PivotTo(CFrame.new(startPosition))
	end

	local function loopFunc(quadPos)

		self.ball:PivotTo(CFrame.new(quadPos))

		if QuickFunctions.hitDetection(quadPos, overlapParams) then
			--TODO: Add explosion effect

			self:Destroy()
			return true
		end

	end

	local function endFunc()

		--Ensure automatic killing hasn't already cleaned up
		if self and self.ball then
			self.ball:PivotTo(CFrame.new(position))
		end
	end

	return QuickFunctions.loopOverQuad(startPosition, position, startFunc, loopFunc, endFunc)
end

function Cannonball:Destroy()
	if self.ball then
		self.ball:Destroy()
	end
	self.ball = nil

	if self.firePromise and self.firePromise.Status == "Started" then
		self.firePromise:cancel()
	end
	self.firePromise = nil

	if self.fireWatch and self.fireWatch.Status == "Started" then
		self.fireWatch:cancel()
	end
	self.fireWatch = nil
end

return Cannonball
