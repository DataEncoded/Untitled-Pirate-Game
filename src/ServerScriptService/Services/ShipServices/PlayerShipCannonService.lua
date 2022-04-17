--Get Packages
local Knit = require(game:GetService("ReplicatedStorage").Packages.knit)
local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Component = require(game:GetService("ReplicatedStorage").Packages.component)
local Promise = require(game:GetService("ReplicatedStorage").Packages.promise)

local QuickFunctions = require(game.ReplicatedStorage.Modules.QuickFunctions)

local Components = ReplicatedStorage.Components
local shipComponent


local PlayerShipCannonService = Knit.CreateService({
	Name = "PlayerShipCannonService",
	Client = {
		--Signal that the client sends when wanting to respawn
		Fire = Knit.CreateSignal(),
	},
})

local function hitDetection(playerShip, startPos, endPos)

    local params = OverlapParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = playerShip


    local function loopFunction(quadPosition)
        local result = QuickFunctions.hitDetection(quadPosition, params)
        if result then
            
            local ship = shipComponent:FromInstance(result)

            if ship then
                --TODO: CANNON DAMAGE CHANGING DEPENDING ON CUSTOMIZATION
                ship:takeDamage(5)
            end

            return true
        end
    end


    local promise = QuickFunctions.loopOverQuad(startPos, endPos, nil, loopFunction)
    
end

function PlayerShipCannonService:KnitStart()

    local cooldown = {}

    --Wait and listen for cancel, and when cooldown is active add player to cooldown table
    local function playerFireCooldown(player: Player, waitTime: number)
        return Promise.new(function(resolve, reject, cancel)
            cooldown[player] = true
            
            for i = 0, waitTime, 0.1 do
                task.wait(0.1)
                if cancel() then 
                    break 
                end
            end

            cooldown[player] = nil
        end)
    end

    self.Client.Fire:Connect(function(player, position)
        if position then
            --TODO: Check that the cannon is within the desired angle
            local playerShips = QuickFunctions.returnTaggedAttribute("PlayerShip", "UserId", player.UserId)

            if #playerShips == 1 and not cooldown[player] then
                self.Client.Fire:FireAll(playerShips[1]:GetPivot().Position, position, playerShips[1])

                --TODO: Add specific time for cannon reload
                playerFireCooldown(player, 3)

                hitDetection(playerShips, playerShips[1]:GetPivot().Position, position)
            end

        end
    end)
    
    shipComponent = require(Components.Ship)

end


return PlayerShipCannonService