--[[
>>>>>MODULES<<<<<<
INSTALLATION INSTRUCTIONS:
EASY:
For easy installation, install/update the RBRS Setup Tool, which will help automatically configure your RBRS installation.
https://www.roblox.com/library/5804626696/raidRoleplay-Updater

ADVANCED:
Configuration options for modules should be directly parented to the module itself. Go through each module, and find the configuration
option inside of it.

Disable modules by dragging them into the DeactivatedModules folder.

For extra help, see the bottom of the Dev Forum post, which can be found in the description of the model.
(There are very strange limitations on how the dev forum link can be posted)

NEW DEVELOPERS:
Read the following below, especially the Core section.

After requiring the submodule, the Core script will search and call the client function of the module (if it is the client), or
call the server function (if it is the server calling). Additionally, if a module has a init function, that will be called independent
of whether the module is running on the server or client. init will always be called before server / client.

For accessing the Core from the module, the Core will be passed as the first and only module when server / client / init are called.

Modules by default are organized into one of three folders, F3X, Libraries, and Roleplay.

Additionally, optional values can be passed with the modules as a part of the table:

	module["Description"] = "An example description of what the module does"

	module["ServerRequirements"] = {
		["FunctionName"] = true,
		"FunctionNameThatWeWaitFor",
	}
	Function name that will be waited for before server is called
	The value is whether or not the dependency is a hard dependency. If it is not a hard dependency, a stub function
	will automatically be added to core that does not do anything after five seconds. This stub function will always return 0.
	
	module["ClientRequirements"] = {
		["FunctionName"] = true,
		"FunctionNameThatWeWaitFor",
	}
	
	module["InitRequirements"] = {
		["FunctionName"] = true,
		"FunctionNameThatWeWaitFor",
	}
	-- Init requirements will by both client and server before running.
	-- You should not use this unless if the function you are waiting for will be on both the client and server
	
	- Alternatively, you can just add the function name as a value without an index, and Core will assume that it is a hard
	- dependency.
	
	module["ConfigurationDescription"] = {
		["ConfigurationIndexName"] = "This will be used to describe the configuration option by the plugin.
	}
	
	module["ConfigurationSpecial"] = {
		["ModuleThatReturnsADictionary"] = { -- To note, default values are shown below.
			["IndexModifiable"] = false
			["IndexExpectedType"] = number
			["ValueModifiable"] = true
			["ValueExpected"] = {"string", "number"} -- ValueExpected is a way to allow multiple types of values from the plugin.
			-- The default value for ValueExpected will be the data type of the key getting 
			["NewIndexAddable"] = false
			[ReferenceToFolderParent] = {
				-- This is used in order to allow users to drag and drop elements in and out of the index location by the plugin
				["Description"] = ""
			}
		}
	} This will be used to determine what values can be changed by the user, and what they are expected to be.

If your module provides a large amount of functions, or the purpose/usage is unclear, it is recommended to create documentation.
Please include "return {}" at the bottom of your documentation to prevent errors.

>>>>>WRITING CONFIGURATIONS<<<<<

Configurations need to be a dictionary returned from a ModuleScript named "Configuration" directly parented to the module it is relevant to.
Other than that, the module itself will hold the extra information required for the Configuration to work properly in the plugin.
If a configuration value is something such as what items are included in a folder, see ConfigurationSpecial.

>>>>>CORE<<<<<

Values provided by Core aren't meant to be overwritten.

Core.script is the ModuleScript of Core itself.
Core.Environment is a folder that you are intended to put temporary files or other objects into (located in ReplicatedStorage)
(alias Core.env)
Core.ClientEnvironment is the LocalScript that is inside of the player character for RBRS, and is the preferred place to store
temporary events (such as bindables)
(alias Core.clientenv)
Core.LoadedModules is where modules that are required by Core are stored (assuming that they have an init, server, or client func,)
to allow for reading and writing by other modules when required.

The functions provided by Core are not intended to be overwritten, and are always available once init/server/client is called.

nil Core:addFunction(string, function, number, string)
Core:addFunction is the primary function provided by Core, and it allows a module to add a function that will be accessible by all
other modules inside of the RBRS installation.
The first argument is the name of the function, 
The second argument is the function that will be called
The third argument is the priority (which will control what functions overwrite what). This will default to 1.
The last number is an internal variable used when initing required modules that are parented to Core, and is not needed by other
modules.

nil Core:waitForRequirements(variant)
Core:waitForRequirements is mostly used internally in order to wait for a module's requirements before it's functions are called.
It can be called by a module with either a string (in which the code will assume the dependency is a hard dependency,) or it can
be called in the same format as the Requirements tables that are attached to modules (see above)

nil Core:initMod(instance)
When passed a ModuleScript, initMod will initialize and call the functions of a module script. It is not recommended to call this,
especially on module scripts that have already been inited, as that can result in very unpredictable behavior.

nil Core:setGlobal(string, value, priority)
Sets a global with the defined value and string into the Core with a certain priority. If priority is not provided, it will default to 1.
If the priority is true, it will overwrite anyways.

variant, number Core:getGlobal(string)
Returns a RBRS global value that was set by :setGlobal, as well as the priority value of that global.

Documentations for other functions should be in a module called DeveloperDocumentations inside of the module, or viewable with the plugin.
For finding what functions are available, if the Debug and ChatCommands modules are enabled, the command "[prefix]dumpfunctions" will
dump the functions that have been added to Core at runtime (printing it into the client console)
]]