local Knit = require(game:GetService("ReplicatedStorage").Packages.knit)
local Workspace = game:GetService("Workspace")
local Component = require(game:GetService("ReplicatedStorage").Packages.component)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CannonBallModule = require(ReplicatedStorage.Modules.CannonBall)

local Ship = Component.new({ Tag = "Ship" })

--TODO, AI


function Ship:Construct()
		
		--TODO: HEALTH AND SINKING SYSTEM
		self.health = 20
end

function Ship:Start()

end

function Ship:Stop()

end

function Ship:takeDamage(damage)
	self.health -= damage
	print(self.health)
	--TODO: LOGIC FOR SINKING
end

function Ship:fireCannons(position, cannonType)
	local Cannonball = CannonBallModule.new()
	Cannonball:fireAtPosition(self.Instance:GetPivot().Position, position)
end

return Ship
