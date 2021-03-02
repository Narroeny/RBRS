--[[
(some of) Datastore service, but with wrappers with pcall to loop performing requests until they don't fail
Also only emulates writing to datastore in case of studio

Along with the data, this module returns an error code and the error message in that order.
The error message is default, but these are the error codes:

0 - Successful
1 - Size limit error
2 - Throttle error (if we're throttling for over 3 minutes)
3 - Enable API access in Studio
4 - Key not found

Also has two internal flags on the top of the module, disable writing in studio and/or printing out when any requests are made.
]]

return {}