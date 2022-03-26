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
function Cannonball:fireAtPosition(startPosition: Vector3, position: Vector3, keepAlive: bool | nil)
	self.firePromise = self:_fireAtPosition(startPosition, position)

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
function Cannonball:_fireAtPosition(startPosition, position)
	return Promise.new(function(resolve, _, cancel)
		local cancelBool = false
		cancel(function()
			cancelBool = true
		end)

		self.ball.Parent = workspace

		self.ball:PivotTo(CFrame.new(startPosition))

		local p0 = startPosition
		local p2 = position

		--Get magnitude
		local distance = (p0 - p2).Magnitude

		--Do offset calculation
		local offset = Vector3.new((p2.X - p0.X) / 2, distance / 4, (p2.Z - p0.Z) / 2)
		offset = offset + p0

		local p1 = offset

		local timeToMove = distance / 200

		for i = 0, timeToMove, 0.01 do
			if cancelBool then
				return
			end

			self.ball:PivotTo(CFrame.new(QuickFunctions:quadBezier((i / timeToMove), p0, p1, p2)))
			task.wait(0.01)
		end

		self.ball:PivotTo(CFrame.new(position))
		resolve()
	end)
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
