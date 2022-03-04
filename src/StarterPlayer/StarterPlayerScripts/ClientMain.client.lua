local Knit = require(game:GetService("ReplicatedStorage").Packages.knit)
local Loader = require(game:GetService("ReplicatedStorage").Packages.loader)

script.Parent:WaitForChild("Controller")
Knit.AddControllersDeep(script.Parent.Controllers)

--Knit start, print status and then load components
Knit.Start()
	:andThen(function()
		print("[ KNIT ] CLIENT STARTED")
		Loader.LoadDescendants(script.Parent.Components)
	end)
	:catch(warn)
