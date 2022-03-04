local Knit = require(game:GetService("ReplicatedStorage").Packages.knit)

Knit.Start()
	:andThen(function()
		print("[ KNIT ] SERVER STARTED")
	end)
	:catch(warn)
