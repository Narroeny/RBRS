--[[
This module provides the functions and methods required to establish client -> server communication.

This module adds several functions to Core, with the primary non standard function being
createListener

createListener usage:
Core.createRemoteListener(functionName, function, priority)
Priority is optional, but functionName and function are required, and depending in which context the function was called (client/server)
it will set up a function for client <-> server communication.

This module also implements the functions expected of a RemoteEvent / RemoteFunction into the core, where the usage is the same as normal
except that the first (or second argument, if the first argument is the player) is the name of the function that we will be calling on the
other end.

Server functions:
void Core:FireClient(player, functionName, ...)
void Core:FireAllClients(functionName, ...)
variant Core:InvokeClient(player, functionName, ...)

Client functions:
void Core:FireServer(functionName, ...)
variant Core:InvokeServer(player, functionName, ...)
]]

return {}