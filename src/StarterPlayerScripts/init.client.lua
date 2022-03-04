local Knit = require(game:GetService("ReplicatedStorage").Packages.knit)

Knit.Start()
	:andThen(function()
		print("[ KNIT ] CLIENT STARTED")
	end)
	:catch(warn)
