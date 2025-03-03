local QuickFunctions = {}

local CollectionService = game:GetService("CollectionService")

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

function QuickFunctions:returnTaggedAttribute(tag: string, attribute: string, value: any): { PVInstance }
	local tagged = CollectionService:GetTagged(tag)

	local matches = {}

	for _, v in ipairs(tagged) do
		if v:GetAttribute(attribute) and v:GetAttribute(attribute) == value then
			table.insert(matches, v)
		end
	end

	return matches
end

return QuickFunctions
