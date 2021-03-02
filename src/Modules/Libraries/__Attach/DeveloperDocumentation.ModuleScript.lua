--[[
The Attach module is responsible for creating the functions that allow for the hijacking of other module scripts in order to manipulate
variables. It is used, for example, to intercept a variety of F3X functions to allow features such as PartOwnership to operate.

There are the options to add a function to be run before and after the function that has been attached, and the option to replace the
function entirely.

Functions:
core.AttachBeforeRun(Module, FunctionName, Function, Priority)
Functions added through this will run before the actual / replacement function is called, and will be run in order of highest priority
to lowest priority. The FunctionName must be the name of the function (metatable or value itself) that is being intercepted from the
given Module.

core.AttachIntercept(Module, FunctionName, Function, Priority)
In comparison to BeforeRun and AfterRun, the Intercept function will only allow one function to operate as the replacement for the
original function inside of the module passed. The function with the highest priority will be the function run in place of the original
function.

For AttachBeforeRun and AttachIntercept, it is generally the best idea to return the values passed in the same format that they were sent,
or else other functions in the stack may error due to unexpected argument differences.

core.AttachAfterRun(Module, FunctionName, Function, Priority)
AttachBeforeRun behaves the exact same as AttachBeforeRun and AttachIntercept, but instead the function will be called with the returns
of the AttachIntercept function / the original module function.

core.getAttachments(Module)
Returns the attachments for a certain module.

All functions return the Attachment table for that module.
]]

return {}