local Knit = require(game:GetService("ReplicatedStorage").Packages.knit)

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

--If something breaks after changing the ships from meshes to models, it's this.
local function getNearShips(): { PVInstance }
    --Heavily dependant on PlayerShip tag
    local ships = CollectionService:GetTagged("PlayerShip")

    local playerShip = getPlayerShip()
    
    --If player ship acting strange, exit function
    if not playerShip then
        return {}
    end

    local distanceDict = {}
    local results = {}

    for _, v in ipairs(ships) do
        if not (v == playerShip) then

            --bounds is a bool value depending on if the value is within the screen
            local _, bounds = Camera:WorldToScreenPoint(v.Position)

            if bounds then

                local shipPosition = v.Position

                distanceDict[v] = (playerShip.Position - shipPosition).Magnitude
                
            end
        end
    end

    --Now loop through distance dict and construct results

    for ship, distance in pairs(distanceDict) do
        if #results > 0 then

            local success = false

            for i = 1, #results do
                local targetShip = results[i]

                if distance <= distanceDict[targetShip] then

                    table.insert(results, i, ship)

                    success = true

                    break
                end
            end

            --Furthest Distance, insert at end
            if not success then 
                table.insert(results, ship)
            end

        else
            
            table.insert(results, ship)
        end
    end

    --Finally return result after all that filtering
    return results

end

local function updateTargetedShip(target)
    PlayerShipCannonController.targetedShip = target
    PlayerShipCannonController.targetIcon.Parent = target
end

local function watchSwitchInput(actionName, inputState, _)
    if inputState == Enum.UserInputState.Begin then
        if actionName == "LeftSwitch" or actionName == "RightSwitch" then
            local ships = getNearShips()

            --Variables for reducing code-paste
            local overflow  --Used to determine what the selection should go to when moving to the opposite side
            local default   --Used when there is no targeted ship
            local move      --Used when there is a targeted ship

            if actionName == "LeftSwitch" then
                overflow = #ships
                default = 1
                move = function(i)
                    return i - 1
                end
            elseif actionName == "RightSwitch" then
                overflow = 1
                default = #ships
                move = function(i)
                    return i + 1
                end
            end

            if #ships > 0 then
                if not PlayerShipCannonController.targetedShip then
                    updateTargetedShip(ships[default])
                else
                    
                    for i, v in ipairs(ships) do
                        if v == PlayerShipCannonController.targetedShip then
                            if i == default then

                                --At the bottom/top, move to the top/bottom
                                updateTargetedShip(ships[overflow])
                                break

                            else
                                
                                --Not at bottom/top, simply move left/right
                                updateTargetedShip(ships[move(i)])
                                break
                            end
                        end
                    end
                end
            end        
        end
    end
end

--Ensure targeted ship stays in view or lose them
local function watchTargetedShipLeave()
    if PlayerShipCannonController.targetedShip then

        local _, bounds = Camera:WorldToScreenPoint(PlayerShipCannonController.targetedShip.Position)

        if not bounds then
            updateTargetedShip(nil)
        end
    end
end

local function fireCannon(_, inputState, _)
    if inputState == Enum.UserInputState.Begin then
        local localPlayerShip = getPlayerShip()
        if PlayerShipCannonController.targetedShip and localPlayerShip  then
            local playerShip = PlayerShip:FromInstance(localPlayerShip)

            PlayerShipCannonService.Fire:Fire(PlayerShipCannonController.targetedShip.Position)
        end
    end
end

function PlayerShipCannonController:enable()
    RunService:BindToRenderStep("TargetShipLeave", 2000, watchTargetedShipLeave) --Last
    ContextActionService:BindAction("LeftSwitch", watchSwitchInput, false, Enum.KeyCode.Q, Enum.KeyCode.Left, Enum.KeyCode.ButtonL1)
    ContextActionService:BindAction("RightSwitch", watchSwitchInput, false, Enum.KeyCode.E, Enum.KeyCode.Right, Enum.KeyCode.ButtonR1)
    ContextActionService:BindAction("Fire", fireCannon, false, Enum.KeyCode.Space, Enum.KeyCode.ButtonR2)

end

function PlayerShipCannonController:disable()
    RunService:UnbindFromRenderStep("TargetShipLeave")
    ContextActionService:UnbindAction("LeftSwitch")
    ContextActionService:UnbindAction("RightSwitch")
    ContextActionService:UnbindAction("Fire")
end

function PlayerShipCannonController:KnitStart()
    PlayerShipCannonController.targetIcon = ReplicatedStorage.Assets.UI.TargetUI:Clone()
    PlayerShip = require(ReplicatedStorage.Components.PlayerShip)

    PlayerShipCannonService = Knit.GetService("PlayerShipCannonService")

    PlayerShipCannonService.Fire:Connect(function(startPos, pos, ignore)
        local params = OverlapParams.new()
        params.FilterType = Enum.RaycastFilterType.Blacklist
        params.FilterDescendantsInstances = {ignore}

        local ball = Cannonball.new()
        ball:fireAtPosition(startPos, pos, false, params)
    end)
end

return PlayerShipCannonController