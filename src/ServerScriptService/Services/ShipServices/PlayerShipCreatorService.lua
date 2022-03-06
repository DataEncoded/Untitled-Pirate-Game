--Get Packages
local Knit = require(game:GetService("ReplicatedStorage").Packages.knit)
local Workspace = game:GetService("Workspace")
local Option = require(game:GetService("ReplicatedStorage").Packages.option)

--Get Services
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerShipCreatorService = Knit.CreateService({
	Name = "PlayerShipCreatorService",
	Client = {
		--Signal that the client sends when wanting to respawn
		Respawn = Knit.CreateSignal(),
	},
})

--Utility Functions

--[[
    returnTaggedAttribute

    Description:
        Returns all objects that have [tag] and have attribute [attribute] as [value]

    Parameters:
        [String]    tag         The tag to search
        [String]    attribute   The attribute to search
        [any]       value       The value attribute should match

    Returns:
        Table of objects that match the parameters

]]
--
local function returnTaggedAttribute(tag: string, attribute: string, value: any): { PVInstance }
	local tagged = CollectionService:GetTagged(tag)

	local matches = {}

	for _, v in ipairs(tagged) do
		if v:GetAttribute(attribute) and v:GetAttribute(attribute) == value then
			table.insert(matches, v)
		end
	end

	return matches
end

--KnitInit Functions
--
--Remove ships of players who are leaving
function PlayerShipCreatorService:KnitInit()
	Players.PlayerRemoving:Connect(function(player)
		local playerShips = returnTaggedAttribute("PlayerShip", "UserId", player.UserId)

		for _, ship in ipairs(playerShips) do
			ship:Destroy()
		end
	end)
end

--KnitStart Functions
--
--Listen to the respawn signal and ensure a ship can be spawned
function PlayerShipCreatorService:KnitStart()
	self.Client.Respawn:Connect(function(player)
		if #returnTaggedAttribute("PlayerShip", "UserId", player.UserId) == 0 then
			--TODO: Ship Selection
			local clone = ReplicatedStorage.Assets.Ships.Raft:Clone()

            clone:SetAttribute("UserId", player.UserId)
			CollectionService:AddTag(clone, "PlayerShip")

			--TODO: Location Selection
			clone.Parent = Workspace

			clone.Anchored = false

			clone:SetNetworkOwner(player)
		end
	end)
end

return PlayerShipCreatorService
