local Knit = require(game:GetService("ReplicatedStorage").Packages.knit)
local Loader = require(game:GetService("ReplicatedStorage").Packages.loader)

Knit.AddControllersDeep(game:GetService("ReplicatedStorage").Controllers)

--Knit start, print status and then load components
Knit.Start()
	:andThen(function()
		print("[ KNIT ] CLIENT STARTED")
		Loader.LoadDescendants(game:GetService("ReplicatedStorage").Components)
	end)
	:catch(warn)

