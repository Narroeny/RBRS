wait(5) -- i'm lazy and don't want to write a 5050135103501305 character long statement so were just gonna do this
local Core = game:GetService("ReplicatedStorage").raidRoleplay.Assets.Core
local ServerEndpoint = Core.Logs.Unapply.SyncAPI.ServerEndpoint
-- this is really disgusting but idk a better way lol
local SyncAPI = ServerEndpoint.Parent;
local Tool = SyncAPI.Parent;

-- Start the server-side sync module
SyncModule = require(SyncAPI:WaitForChild 'SyncModule');

-- Provide functionality to the server API endpoint instance
ServerEndpoint.OnServerInvoke = function (Client, ...)
	local core = require(Core)
	if core.isAdmin(Client) then
		return SyncModule.PerformAction(Client, ...);
	else
		core.sendNotification(Client.Name .. " is likely an exploiter; they attempted to use the built in F3X modules of raidRoleplay without being an admin!")
		core.addLog({["Text"] = Client.Name .. " is likely an exploiter; they attempted to use the built in F3X modules of raidRoleplay without being an admin!"})
	end
end;