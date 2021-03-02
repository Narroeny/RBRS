--[[
	This script will document the various functions required in modules, and the functions available from the Core.
	
	>>>>>>> TERMINOLOGY:
	
	tab or coretable refers to the global table with the list of common values as well as useful information and objects that modules
	may need, like the Core module of the current player's F3X.
	
	>>>>>>> FUNCTIONS THAT CORE WILL CALL:
	
	module.load(core):
	This function will be called by the Core when the system is initialized. The only thing passed will be the Core script itself,
	to increase the ease of accessing the functions provided by the Core.
	
	module.escalatedEvent(player, ...):
	After a clientsided part of your module calls the privilige escalation remote along with itself and the arguments, this will be called. Event
	version. Read the PRIVILIGE ESCALATION section.
	
	module.escalatedFunction(player, ...):
	Same as above, but the function version.
	
	module.f3xEquipped(coretab):
	This function will be run whenenver the F3X tool is equipped, even if it is equipped multiple times.
	
	module.f3xFirstEquipped(coretab):
	This function will be called when someone equips a new F3X tool for the first time.
	
	module.f3xHistoryUpdated(coretab):
	This function will be called whenever the f3x History is updated. See the coretab for special options.
	Just to note, this has a bug as of v1.0.0m3 INDEV2 that involves the provided functions not passing as well as some of the less
	important items of the table.
	
	module.loadServer(core):
	The equivalent to module.Load, but serverside!
	
	module.f3xSelectionUpdated(coretab):
	Whenever the selection changes, this will be called. SelectionCount is the amount of parts currently selected.
		
	>>>>>>> FUNCTIONS PROVIDED BY CORE:
	
	button core.createUIButton(text, func, buttonname):
	This function allows a button to be easily created inside of the UI. The first argument is the button text, and the second argument 
	is the function to call when the button is clicked. Ex: module:createUIButton("Reset", killplayerfunction())
	The button name is provided in order to allow you control over the sorting of the buttons. This is handled internally inside of the 
	code for the time being. This function then returns back the button to the player.
	
	void core.escalateEvent(mod, ...):
	Read PRIVILIGE ESCALATION
	
	... = core.escalateFunction(mod, ...):
	Read PRIVILIGE ESCALATION
	
	int prank = core.getPlayerRank(p):
	Gets the rank of the local player, or if a player is provided, the rank of that player in the group as defined in the global Config.
	
	void core.lockUIClosed(closechat):
	Locks the sliding UI shut. Will also remove the chat based upon what is passed with closechat.
	
	void core.unlockUIClosed():
	Unlocks the sliding UI.
	
	void core.calculateScrollingFrameSize(scrollFrame, disableX):
	Updates the canvas size of a scrolling frame to fit all elements. disableX will cause the X size to not change.
	
	tab core.automaticScrollFrameUpdate(scrollFrame, disableX):
	Sets up a hook to automatically call calculateScrollingFrameSize whenever the needed CanvasSize changes.
	Table returned is a table with RBXScriptSignals, which you ***need*** to call :Disconnect() on if you destroy the 
	UI (or a parent) that you called automaticScrollFrameUpdate on
	
	
	void core.addLog({["Text"] = log_entry_text, ["Count"] = number for part count search, ["ButtonText"] = undo_text_name, ["Module"] = mod}, ["ToolName"] = string):
	A dictionary is expected. The text is required, but everything else is optional.
	The count is for sorting by number, and the button text and module are used for the optional button that
	can be attached next to the logs (such as a button to undo a player action). This button will
	only be available to those who are admins as defined by the configuration.
	ToolName is used to specifiy specific ToolNames for the log manually, like in the case of having the log be the Move Tool manually.
	ToolName will not override specific tools, such as delete, clone, newpart, and Weld Tool.
	
	string time = core.getUTCTime():
	Small convenience function that returns the current time for you in the format of h:m:s. Used internally to make
	logs.
	
	tuple (string toolname or nil), (int partcount), (tab allparts), special = core.historyUnpack(log):
	This unpacks the F3X history log provided, and returns back the action done, as well as a part count. nil is selection.
	"Move Tool"
	"Resize Tool"
	"Rotate Tool"
	"Paint Tool"
	"Surface Tool"
	"Material Tool"
	"Anchor Tool"
	"Collision Tool"
	"Mesh Create" -- Special returns are "Mesh Create", "Mesh Destroy", or "Mesh Edit"
	"Texture Tool" -- Special returns are "Texture Create", "Texture Destroy", or "Texture Edit"
	"Weld Tool" -- Special returns are "Weld Create, Weld Destroy"
	"Lighting Tool" -- Special returns are "Lighting Create", "Lighting Destroy", or "Lighting Edit"
	"Decorate Tool" -- Special returns are "Decorate Create", "Decorate Destroy", or "Decorate Edit"
	"delete"
	"clone"
	"newpart"

	The special variable is used on cases where a tool may have multiple different history records, such as the case of the Mesh Tool.

	dict coretable = core.getCoreTable(toadd):
	Passes some common objects back. The toadd variable, mainly used internally, allows you to quickly add the things to the table.
	Check the "OBJECTS PASSED BY CORETABLE" section.
	
	void core.blur(status):
	Adds a blur to the player (size 50, blur effect.) Simply a convenience function with some extra safety code to make sure that 
	it doesn't stick on the player.
	
	string core.getVer():
	Returns the current version of raidRoleplay loaded ingame.
	
	bool core.isAdmin(p):
	Returns true if the player passed is an admin according to the configuration. Will default to local player if no player is provided.

	void core.makeDraggable(frame):
	When provided a UI frame, this function will make the frame a draggable object.

	void core.sendNotification(text):
	Sends text to the server. Client logs will automatically have "Player [name] " appended to the start of the message. Messages will only appear to
	admins as of now.
	
	tab core.createToggle(frame):
	Will turn a frame into a toggle switch dependent on the theme currently being used.
	
	>>>>>>> OBJECTS PASSED BY CORETABLE:
	
	"core" - The core script
	"ui" - The raidRoleplay UI. Clientside only
	"buttonframe" - The raidRoleplay button frame. Clientside only
	"mainfold" - The raidRoleplay folder in ReplicatedStorage
	"modules" - The folder where modules are contained.
	"assetfold" - The raidRoleplay Assets folder (under the mainfold)
	"cancelbut" - A generic cancel button that pieces of code can use. Appears as an X on the bottom right. Clientside only
	"ThemeFolder" - Theme folder
	"Frame" - Theme background
	"Button" - Theme button
	"Box" - Theme textbox entry
	"MainText" - Theme's text (primary)
	"SubText" - Theme's text (secondary)
	
	ONLY AVAILABLE WHEN F3X RELATED FUNCTION (see FUNCTIONS THAT CORE WILL CALL):
	
	"f3x" - the F3X tool itself when referenced
	"fhist" - the F3X History module from that tool
	"fcore" - the F3X Core module from that tool
	"fselect" - the F3X Selection module from that tool
	"newfhist" - the latest history log added to that F3X tool. May not be up to date if collected through anything other than .f3xHistoryUpdated
	"fsyncapi" - The SyncAPI remote function from F3X.
	
	>>>>>>> OBJECT LOCATIONS:
	
	Core:
	game:GetService("ReplicatedStorage").raidRoleplay.Assets.Core
	
	>>>>>>> THEMES AND UIs INSIDE OF raidRoleplay:
	
	The theme engine is current in development and may change, but themes are stored inside of the "Themes" folder inside of the primary script.
	A theme should have a frame with the theme's name, and then the following assets inside of it:
	Background
	ButtonArea
	EntryArea
	ToggleArea
	TopBar
	OpenLogo
	MainText
	SubText
	
	UIs for raidRoleplay should be made with the themeing engine in mind, and shouldn't include close buttons and such. The frame used for UIs
	should also be transparent, as the theme engine will add the background dynamically. See set-name for a good example of how to implement
	this.
	
	Frames inside of a UI will be automatically modified (and these are where the UIs should be stored.) However, it is the responsibility of the
	modulescript to move the UI inside of the raidRoleplayUI object (see coretable)
	
	The frame, if it has a background transparency of 1, will not have the top bar added to it. The themeing engine also changes the layout of the UI
	objects.
	
	Suppose we have a frame named "GUI" inside of the Module.
	"GUI"
	|
	-> Your UI elements
	
	This GUI will convert into this format.
	"GUI"
	|
	->"GUI"
	|	|
	|	-> "Your UI elements"
	|
	->"TopBar"
		|
		-> "CloseButton"
		
	This is how you access the theme close button, as well as your own UI.
	
	Because of how on/off switches can change between themes, you have to instantiate these manually through the UI by calling the "createToggle"
	function of core, which will return you a metatable with the following events:
	Activated - when turned on
	Deactivated - when turned off
	MouseButton1Click - fires when clicked on in general
	
	and the following functions:
	new(switch) - Create toggle switch
	Activate - turns on toggle switch (and calls Activated)
	Deactivate - turns off toggle switch (and calls Deactivated)
	Destroy - deletes toggle area
	
	and the following value:
	Status - false or true, true == enabled
	
	Many of these assets can be found in the CoreTable, if you need to do themeing manually.
	
	As a final note, if an object has a child named "doNotTheme" in it, the specific object will not be themed.
	
	>>>>>>> PRIVILIGE ESCALATION:
	
	On the client, simply call core.escalateEvent or core.escalateFunction as you would any other event, except the first argument should be the
	module that is calling. On the server side, ensure that the module you passed has a corresponding module.escalatedEvent /
	module.escalatedFunction.
]]