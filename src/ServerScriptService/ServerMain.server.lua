local Knit = require(game:GetService("ReplicatedStorage").Packages.knit)
local Loader = require(game:GetService("ReplicatedStorage").Packages.loader)

Knit.AddServicesDeep(script.Parent.Services)

Knit.Start()
	:andThen(function()
		print("[ KNIT ] SERVER STARTED")
		Loader.LoadDescendants(script.Parent.Components)
	end)
	:catch(warn)
