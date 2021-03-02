-- Return the unapply function for a specified toolname
local unapply = {}
local SE = script:WaitForChild("SyncAPI"):WaitForChild("ServerEndpoint")

unapply["Move Tool"] = function(Record)
	local Changes = {};
	for _, entry in pairs(Record) do
		table.insert(Changes, { Part = entry[1], CFrame = entry[2] });
	end;
	
	SE:InvokeServer('SyncMove', Changes);
end
unapply["clone"] = function(Record)
	SE:InvokeServer('Remove', Record.Clones);
end
unapply["delete"] = function(Record)
	SE:InvokeServer('UndoRemove', Record.Parts)
end
unapply["newpart"] = function(Record)
	SE:InvokeServer('Remove', { Record.Part });
end
unapply["Resize Tool"] = function(Record)
	-- Put together the change request
	local Changes = {};
	for _, Entry in pairs(Record) do
		table.insert(Changes, { Part = Entry[1], Size = Entry[2], CFrame = Entry[3] });
	end;

	-- Send the change request
	SE:InvokeServer('SyncResize', Changes);
end;
unapply["Rotate Tool"] = function(Record)
	local Changes = {};
	for _, entry in pairs(Record) do
		table.insert(Changes, { Part = entry[1], CFrame = entry[2] });
	end;
	SE:InvokeServer('SyncRotate', Changes);
end
unapply["Paint Tool"] = function(Record)
	local Changes = {}
	
    for _, Entry in ipairs(Record) do
	    table.insert(Changes, {
	        Part = Entry[1],
	        Color = Entry[2],
	        UnionColoring = Entry[3]
	    })
	end
	
    -- Push changes
    SE:InvokeServer('SyncColor', Changes)
end
unapply["Surface Tool"] = function(Record)
	local Changes = {};
	for _, entry in pairs(Record) do
		table.insert(Changes, { Part = entry[1], Surfaces = entry[2] });
	end;
	SE:InvokeServer('SyncSurface', Changes);
end
unapply["Material Tool"] = function(Record)
	local Changes = {};
	for _, entry in pairs(Record) do
		table.insert(Changes, { Part = entry[1], [entry[2]] = entry[3] });
	end;
	SE:InvokeServer('SyncMaterial', Changes);
end
unapply["Anchor Tool"] = function(Record)
	SE:InvokeServer('SyncAnchor', Record.Before);
end
unapply["Collision Tool"] = function(Record)
	SE:InvokeServer('SyncCollision', Record.Before);
end
unapply["Mesh Create"] = function(Record)
	SE:InvokeServer('Remove', Record.Meshes);
end
unapply["Mesh Destroy"] = function(Record)
	SE:InvokeServer('UndoRemove', Record.Meshes);
end
unapply["Mesh Edit"] = function(Record)
	local Changes = {};
	for _, entry in pairs(Record) do
		Changes[entry[1]] = entry[2]
	end;
	SE:InvokeServer('SyncMesh', Changes);
end
unapply["Texture Create"] = function(Record)
	SE:InvokeServer('Remove', Record.Textures);
end
unapply["Texture Destroy"] = function(Record)
	SE:InvokeServer('UndoRemove', Record.Textures);
end
unapply["Texture Edit"] = function(Record)
	SE:InvokeServer('SyncTexture', Record.Before);
end
unapply["Weld Create"] = function(Record)
	SE:InvokeServer('RemoveWelds', Record.Welds);
end
unapply["Weld Destroy"] = function(Record)
	SE:InvokeServer('UndoRemovedWelds', Record.Welds);
end
unapply["Decorate Create"] = function(Record)
	SE:InvokeServer('Remove', Record.Decorations);
end
unapply["Decorate Destroy"] = function(Record)
	SE:InvokeServer('UndoRemove', Record.Decorations);
end
unapply["Decorate Edit"] = function(Record)
	SE:InvokeServer('SyncDecorate', Record.Before);
end
unapply["Lighting Create"] = function(Record)
	SE:InvokeServer('Remove', Record.Lights);
end
unapply["Lighting Destroy"] = function(Record)
	SE:InvokeServer('UndoRemove', Record.Lights);
end
unapply["Lighting Edit"] = function(Record)
	SE:InvokeServer('SyncLighting', Record.Before);
end

return unapply
