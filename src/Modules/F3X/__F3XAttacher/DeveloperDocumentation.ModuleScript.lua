--[[
F3XAttacher is a module that automates attaching to F3X functions for modules that manipulate certain values / functions of F3X.
It has one primary function, which is responsible for adding the function to the attachment table for the F3X module.
nil core.addF3XAttachment("ModuleName", "FunctionName", "Type", function, priority)
Type is either "Before", "Intercept", or "Run". Any attachment added will be added to currently equipped F3X.

Additionally, it has a function core.attachNewF3X(func), which will fire when a new F3X is added for manual modification.
The function that is passed will be called with two arguments, the first being the F3X tool itself.
The second is a table in the following format of all of the default module hooks (see below)
{
	["Core"] = {
		["Script"] = ModuleScriptInstance
		["Data"] = required ModuleScript
	}
}
THis function will also be called with all current F3X blocks.

Out of courtesy for other modules, please send the return data of the function in the same format as it was sent to the module originally,
to prevent errors from arising.

List of F3X modules that are supported by the module:
Client:
	Core - A variety of F3X features are tied directly into the Core. See F3X code.
]]

return {}
