--[[
chatCommands only implements one function, which is "addChatCommand"
nil core.addChatCommand(commandName, function, priority, requirementLevel)
The command name is a string, the function is the function to call when the command name is run, the priority is the priority
incase multiple modules attempt to write to the same priority, and the requirementLevel is an optional variable that will set what
permission level can use the command.

>>> If the security module is not enabled, commands will be disabled that do not have a requirementLevel of 0

Keep in mind, you should never trust the security level of the client, and sanity check them before allowing them to run anything if the
command is on the client.
]]

return {}