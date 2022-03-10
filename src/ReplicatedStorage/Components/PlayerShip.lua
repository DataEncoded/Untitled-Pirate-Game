local Knit = require(game:GetService("ReplicatedStorage").Packages.knit)
local Workspace = game:GetService("Workspace")
local Component = require(game:GetService("ReplicatedStorage").Packages.component)

local PlayerShip = Component.new {Tag = "PlayerShip"}

function PlayerShip:Construct()
    if self.Instance:GetAttribute("UserId") == game.Players.LocalPlayer.UserId then
        self.control = true
        self.inputAttachment = Instance.new("Attachment", Workspace.Terrain)
        self.physicsPart = Instance.new("Part")
        self.physicsAttachment = Instance.new("Attachment", self.physicsPart)

        local shipAttachment = Instance.new("Attachment", self.Instance)

        local physicsToInput = Instance.new("AlignPosition")

        physicsToInput.Attachment0 = self.physicsAttachment
        physicsToInput.Attachment1 = self.inputAttachment

        physicsToInput.Parent = self.physicsAttachment

        self.physicsPart.Parent = workspace
        self.physicsPart.CanCollide = false

        self.physicsPart.Transparency = 1
        
        local shipToPhysics = Instance.new("AlignPosition")

        shipToPhysics.Attachment0 = shipAttachment
        shipToPhysics.Attachment1 = self.physicsAttachment

        shipToPhysics.Parent = self.Instance

        physicsToInput.Responsiveness = 25
        shipToPhysics.Responsiveness = 8

        local align = Instance.new("AlignOrientation")

        align.Attachment0 = shipAttachment
        align.Attachment1 = self.inputAttachment

        align.Parent = self.Instance

        self.Instance.CanCollide = false
    
    end
end

local function renderStep(self, dt)

    local relativePosition = Knit.GetController("PlayerShipMovementController").getInputRelativeToCamera(self.Instance)

    
    print(Knit.GetController("PlayerShipMovementController").moveVector() == Vector3.new(0, 0, 0))

    self.physicsPart.Position = Vector3.new(self.physicsPart.Position.X, 0, self.physicsPart.Position.Z)

    self.Instance.Position = self.Instance.Position * Vector3.new(1, 0, 1)

    --self.Instance.CFrame = CFrame.new(self.Instance.CFrame.Position, self.inputAttachment.WorldPosition)

    local position = relativePosition * Vector3.new(5, 1, 5) + self.Instance.Position

    self.inputAttachment.WorldCFrame = CFrame.new(position)


    

end

function PlayerShip:Start()
    if self.control then
        self.RenderPriority = Enum.RenderPriority.Input.Value

        function PlayerShip:RenderSteppedUpdate(dt)
            renderStep(self, dt)
        end

    end
end

return PlayerShip