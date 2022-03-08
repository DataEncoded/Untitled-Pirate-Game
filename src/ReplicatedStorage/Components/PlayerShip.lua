local Knit = require(game:GetService("ReplicatedStorage").Packages.knit)
local Component = require(game:GetService("ReplicatedStorage").Packages.component)

local PlayerShip = Component.new {Tag = "PlayerShip"}

function PlayerShip:Construct()
    if self.Instance:GetAttribute("UserId") == game.Players.LocalPlayer.UserId then
        self.control = true
    end
end

local function renderStep(instance, dt)

    local relativePosition = Knit.GetController("PlayerShipMovementController").getInputRelativeToCamera(instance)

end

function PlayerShip:Start()
    if self.control then
        self.RenderPriority = Enum.RenderPriority.Input.Value

        function PlayerShip:RenderSteppedUpdate(dt)
            renderStep(self.Instance, dt)
        end

    end
end

return PlayerShip