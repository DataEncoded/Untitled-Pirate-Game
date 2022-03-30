local QuickFunctions = {}

local Promise = require(game:GetService("ReplicatedStorage").Packages.promise)

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

function QuickFunctions.returnTaggedAttribute(tag: string, attribute: string, value: any): { PVInstance }
	local tagged = CollectionService:GetTagged(tag)

	local matches = {}

	for _, v in ipairs(tagged) do
		if v:GetAttribute(attribute) and v:GetAttribute(attribute) == value then
			table.insert(matches, v)
		end
	end

	return matches
end

function QuickFunctions.quadBezier(t, p0, p1, p2)
	return (1 - t) ^ 2 * p0 + 2 * (1 - t) * t * p1 + t ^ 2 * p2
end

--[[
    loopOverQuad

    Description:
        Loops over quadBezier using startPos and endPos for calculations
        Runs startFunc before the loop starts, loopFunc in the loop and endFunc after the loop

    Parameters:
        [Vector3]    startPos   The place that the quadBezier starts
        [Vector3]    endPos     The place that the quadBezier ends
        [function]   startFunc  A function that's ran before the loop
        [function]   loopFunc   A function that's ran in the loop
        [function]   loopFunc   A function that's ran after the loop

    Returns:
        Promise of the code allowing cancellations

]]

function QuickFunctions.loopOverQuad(
	startPos: Vector3,
	endPos: Vector3,
	startFunc: nil | () -> nil,
	loopFunc: nil | (Vector3) -> nil,
	endFunc: nil | () -> nil
)
	return Promise.new(function(resolve, _, cancel)
		local cancelBool = false

        --Turn cancelBool to true to cancel out of the loop
		cancel(function()
			cancelBool = true
		end)

		if startFunc then
			startFunc()
		end

        --Set alias for start and end position for simplicity
		local p0 = startPos
		local p2 = endPos

		--Get magnitude
		local distance = (p0 - p2).Magnitude

		--Do offset calculation
		local offset = Vector3.new((p2.X - p0.X) / 2, distance / 4, (p2.Z - p0.Z) / 2)
		offset = offset + p0

        --Set alias for offset for simplicity
		local p1 = offset

        --Do calculation to determine how long the cannon will take to move
		local timeToMove = distance / 200

		for i = 0, timeToMove, 0.01 do

            --Cancel bool returns if the promise is cancelled
			if cancelBool then
				return
			end

            --If there is a loopFunc, pass the parameter of the quadBezier location
			if loopFunc then
				loopFunc(QuickFunctions.quadBezier((i / timeToMove), p0, p1, p2))
			end

            --The loop is normalized to increase by 0.01 seconds so only wait that
			task.wait(0.01)
		end

		if endFunc then
			endFunc()
		end

		resolve()
	end)
end

return QuickFunctions
