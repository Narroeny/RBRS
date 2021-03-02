--[[
Similar to the PriorityTable, ReplicatingTable is a table wrapper that makes it so that the contents of a table will replicate automatically.

nil core.wrapReplicatingTable(tab, replicationTag, replicateClient)
The main function of wrapReplicatingTable wraps the table and sets up the metatables, as well as the events to deal with table replication.
To make a ReplicatingTable, have a table on the client and the server, and then call this function with a string as the replicationTag.
This will be used to set up the events of the table. Both the server and the client have to init the replicatingTable.
When the table is wrapped, the tables will be combined where the server will overwrite the client.

Allowing client replication is not recommended, especially because exploiters will be able to take the RemoteEvent and fire to it.

nil tab:Destroy() -- Server only
The Destroy function properly disposes of the RemoteEvent that is created on the server. Will also replicate to client, removing
the events from the client, and removing the metatable.

Values in the replicatingTable:
.__changedBind - The bindable used to signal when the table has changed
.Changed - The RBXScriptSignal that is activated when the changedBind fires. Fires with the index and new value
.__replicateClient - The replicateClient value of the table
.__changedEvent - The remote events used to signal that the table was updated.
.__trueValues - Where the original/added values of the table are stored, this shouldn't need to be access by scripts
using the wrapper as the index will automatically return the value from the table.

IMPORTANT NOTE:
Because of how replication works, you can not send Instances through the tables, and indexes must be strings.
]]

return {}