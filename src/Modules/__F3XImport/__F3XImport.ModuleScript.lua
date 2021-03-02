local module = {}

function module.escalatedFunction(player, model, location, modelname) -- relocates models
	local rr = game:GetService("ReplicatedStorage").raidRoleplay
	local assets = rr.Assets.F3XImportTempFolder
	--print(model, model.Parent, location)
	if model.Parent == assets then -- security check
		--print("is secure")
		--print(location)
		if location == "workspace" then
			--print("workspace")
			model.Parent = workspace
			return
		elseif location == "setsfolder" then
			model.Name = modelname
			model.Parent = rr.Modules.Sets.SetsFolder.PrivateSets:FindFirstChild(player.Name)
			return
		end
	end
end

function module.loadServer(core)
	local coretab = core.getCoreTable()
	local folder = Instance.new("Folder", coretab["assetfold"])
	folder.Name = "F3XImportTempFolder"
end

function module.escalatedEvent(player, creation_id) -- (slightly) Modified F3X import code
	local core = require(game:GetService("ReplicatedStorage").raidRoleplay.Assets.Core)
	local coretab = core.getCoreTable()
	local tempfold = coretab["assetfold"].F3XImportTempFolder
	local HttpService = game:GetService('HttpService')
	local Workspace = game:GetService('Workspace')
	local export_base_url = 'http://www.f3xteam.com/bt/export/%s';
	
	------------------------------------------
	-- Load external dependencies
	------------------------------------------
	local SerializationV1 = require(script.SerializationV1)
	local SerializationV2 = require(script.SerializationV2)
	local SerializationV3 = require(script.SerializationV3)
	
	------------------------------------------
	-- Define functions that are depended-upon
	------------------------------------------
	-- Try to download the creation
	local creation_data;
	local download_attempt, download_error = ypcall( function ()
		creation_data = HttpService:GetAsync( export_base_url:format( creation_id ) );
	end );

	-- Fail graciously
	if not download_attempt and download_error == 'Http requests are not enabled' then
		print 'Import from Building Tools by F3X: Please enable HTTP requests (see http://wiki.roblox.com/index.php?title=Sending_HTTP_requests#Http_requests_are_not_enabled)';
		--showGUI( 'Please enable HTTP requests (see Output)', 'Got it' );
		script.ReturnModel:FireClient(player, 'Please enable HTTP requests (see Output)')
	end;
	if not download_attempt then
		print( 'Import from Building Tools by F3X (download request error): ' .. tostring( download_error ) );
		--showGUI( "We couldn't get your creation", 'Oh' );
		script.ReturnModel:FireClient(player, "We couldn't get your creation")
	end;
	if not ( creation_data and type( creation_data ) == 'string' and creation_data:len() > 0 ) then
		--showGUI( "We couldn't get your creation", ':(' );
		script.ReturnModel:FireClient(player, "We couldn't get your creation")
	end;
	if not pcall( function () creation_data = HttpService:JSONDecode( creation_data ); end ) then
		--showGUI( "We couldn't get your creation", ":'(" );
		script.ReturnModel:FireClient(player, "We couldn't get your creation")
	end;

	-- Create a container to hold the creation
	local Container = Instance.new( 'Model', tempfold );
	Container.Name = 'BTExport';

	-- Inflate legacy v1 export data
	if creation_data.version == 1 then
		SerializationV1(creation_data, Container)
		Container:MakeJoints()
		script.ReturnModel:FireClient(player, Container)

	-- Parse builds with serialization format version 2
	elseif creation_data.Version == 2 then
		-- Inflate the build data
		local Parts = SerializationV2.InflateBuildData(creation_data);

		-- Parent the build into the export container
		for _, Part in pairs(Parts) do
			Part.Parent = Container;
		end;

		-- Finalize the import
		Container:MakeJoints();
		script.ReturnModel:FireClient(player, Container)

	-- Parse builds with serialization format version 3
	elseif creation_data.Version == 3 then
		-- Inflate the build data
		local Parts = SerializationV3.InflateBuildData(creation_data);

		-- Parent the build into the export container
		for _, Part in pairs(Parts) do
			Part.Parent = Container;
		end;

		-- Finalize the import
		Container:MakeJoints();
		script.ReturnModel:FireClient(player, Container)
		
	end;
	
	-- F3X Import compat with PartOwnership here
	local core = require(game:GetService("ReplicatedStorage").raidRoleplay.Assets.Core)
	local coretab = core.getCoreTable()
	if coretab["modules"]:FindFirstChild("PartOwnership") ~= nil then
		require(coretab["modules"].PartOwnership).ownModel(player, Container)
	end
end

function module.load(core)
	local coretab = core.getCoreTable()
	local mainui = script:WaitForChild("Import"):Clone()
	core.makeDraggable(mainui)
	local ui = mainui:WaitForChild("Import")
	local rem = script:WaitForChild("ReturnModel")
	local setsintMain = script:WaitForChild("SetsIntegration")
	local namesetMain = script:WaitForChild("Composition")
	mainui.Parent = coretab["ui"]
	local connect
	local function showui()
		mainui.Visible = true
		-- Reset state back to default
		ui.ImportName.Visible = true
		ui.FinishButton.Visible = true
		ui.ErrorBox.Visible = false
		ui.Hint.Visible = true
	end
	
	local function errorui(text)
		ui.ErrorBox.Visible = true
		ui.ErrorBox.Text = "ERROR: " .. text
		ui.FinishButton.Visible = false
		ui.Hint.Visible = false
		ui.ImportName.Visible = false
		mainui.Visible = true
		wait(6)
		mainui.Visible = false
	end
	
	ui:WaitForChild("FinishButton").MouseButton1Click:Connect(function()
		local text = ui.ImportName.Text
		mainui.Visible = false
		if string.len(text) == 4 then
			core.escalateEvent(script, text) -- JANK CODE BELOW HERE
			
			local gotreturn = false
			connect = rem.OnClientEvent:Connect(function(d)
				if not gotreturn then -- sanity check
					--print("HELLO WE GOT THE RETURN")
					gotreturn = true
					if typeof(d) == "string" then -- oopsie we had an error
						--print("STRING ERROR BAD ERROR")
						errorui(d)
					else -- we got a model back (hopefully)
						-- SETS INTEGRATION CHECK HERE
						local function normal()
							core.escalateFunction(script, d, "workspace")
							local parts = {}
							local f3xtools = {} -- table to store the f3xs we add our model to the selection of
							--print("NOT AN ERROR")
							
							for i, v in pairs(d:GetDescendants()) do
								if v:IsA("BasePart") or v:IsA("UnionOperation") then
									table.insert(parts, v)
								end
							end
							
							local tool = game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Tool")
							if tool ~= nil and tool:FindFirstChild("SyncAPI") ~= nil then -- if the player was holding a tool, and it was f3x
								--print("WE FIND F3X IN PLAYER OOGA CHAKA")
								-- get that one
								table.insert(f3xtools, tool)
							else -- otherwise just get any and all f3x the player has and set their selections
								--print("NO F3X IN PLAYER :'(")
								for i, v in pairs(game:GetService("Players").LocalPlayer.Backpack:GetChildren()) do
									if v:FindFirstChild("SyncAPI") ~= nil then
										--print("WE FIND F3X IN DA BACKAPK!!!")
										table.insert(f3xtools, v)
									end
								end
							end
							
							for i, v in pairs(f3xtools) do -- actually do stuff here
								--print("GOING THROUGH F3X TOOL")
								if v:FindFirstChild("Core") ~= nil and v.Core:FindFirstChild("Selection") ~= nil then
									--print("VALID")
									local selectmod = require(v.Core.Selection)
									selectmod.Clear(true) -- clear the selection
									selectmod.Add(parts, true) -- add the new parts in to it
								end
							end
						end
						
						if coretab["modules"]:FindFirstChild("Sets") ~= nil then
							local check = setsintMain:Clone()
							check.Parent = coretab["ui"]
							check.Visible = true
							check.SetsIntegration.AddToSets.MouseButton1Click:Connect(function()
								check:Destroy()
								local nameset = namesetMain:Clone()
								nameset.Parent = coretab["ui"]
								nameset.Visible = true
								nameset.Composition.FinishButton.MouseButton1Click:Connect(function()
									if #nameset.Composition.CompName.Text <= 35 and #nameset.Composition.CompName.Text > 0 then
										d.Name = nameset.Composition.CompName.Text
										core.escalateFunction(script, d, "setsfolder", d.Name)
										nameset:Destroy()
										local setsscript = coretab["modules"].Sets
										local playerprivfolder = setsscript.SetsFolder.PrivateSets[game:GetService("Players").LocalPlayer.Name]
										local bindable = setsscript.Assets:FindFirstChild("RegisterNewSet")
										if bindable == nil then
											warn("Could not find bindable for integration. Player will have to reset.")
										else
											bindable:Fire(d)
										end
									elseif #nameset.Composition.CompName.Text > 35 then
										nameset.Composition.CompName.Text = "The maximum name length is 35 characters"
									end
								end)
								nameset.TopBar.CloseButton.MouseButton1Click:Connect(function()
									nameset:Destroy()
								end)
							end)
							check.SetsIntegration.Paste.MouseButton1Click:Connect(function() -- if they want to insert ingame, just do the normal stuff
								normal()
								check:Destroy()
							end)
							check.TopBar.CloseButton.MouseButton1Click:Connect(function()
								check:Destroy()
							end)
						else -- if there is no sets
							normal()
						end
	 				end
				end
			end)
			
			wait(5)
			
			if not gotreturn then
				connect:Disconnect()
				
				errorui("No return code was given from F3X Import. This is most likely caused by the f3xteam website being down, and there is nothing that I or the game developers can do.")
			end
			
		else
			errorui("Invalid F3X Import Code Given")
		end
	end)
	
	mainui:WaitForChild("TopBar"):WaitForChild("CloseButton").MouseButton1Click:Connect(function()
		mainui.Visible = false
	end)
	
	core.createUIButton("F3X Import", showui, "aac")
end

return module
