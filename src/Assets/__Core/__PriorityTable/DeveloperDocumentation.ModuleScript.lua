--[[ 
Allows you to wrap a table with functions to deal with managing the priority of that table.
To use it, run the wrap function (wrapPriorityTable) on the table, and then simply add a dictionary or value to the original table at a 
certain index, and then that value will only be overwritten when the Priority value of the dictionary entry (which defaults to 1) is 
higher than the current entry. (IF USING A MULTIPLE VALUES TABLE, USE THE FUNCTIONS BELOW INSTEAD)

READING THE TRUE TABLE

When a value is inserted, it gets converted always (if it is not already) into a dictionary named .trueValues inside of the original
functions. trueValues contains the information of the original table, and so you can find your priority table entry at
tab[index]["trueValues"][numericalindex], where the numericalindex is included if it is a multipleValues table.

This is usually not needed, as simply indexing the original table with the index will return the contents of the trueValues
table for that index.

TABLE FUNCTIONS

tab:getpriority("index", numericalindex) -- Returns the priority of the entry at that index. NumericalIndex is required if the table
is a MultipleValues table, and is a number.

NON MULTIPLE VALUE TABLE FUNCTIONS -----------------

There are a few functions for non MultipleValue tables (see below,) and these functions are only usable by nonMultipleValue tables.

tab:replace("index", value) -- This will always replace the value in the current table regardless of Priority, maintaining the same
priority.

Non multiple value table format:
["TablePassed"] = {
	.trueValues = {
		["DataEntered1"] = {
			["Priority"] = 2,
			["Value"] = "hi",
			},
		["DataEntered2"] = {
			["Priority"] = 2,
			["Value"] = "hi",
			},
		}
	}
	.Changed = event
	(index and newindex metamethods attached to this table)
}

MULTIPLEVALUE TABLES ---------------------

Optionally, pass true to the second argument (multipleVals) and the table will not overwrite old entries, and will instead sort them in a
numerical array based upon their priority. This means that indexes will *not* be preserved.
When using multipleVals, you insert into the table as normal (setting the index to the val of the main table,) or using the :insert()
method. You also can use additional functions (see below)

Multiplevalue table format:
["TablePassed"] = {
	.trueValues = {
		["DataEntered1"] = {
			{
				["Priority"] = 2,
				["Value"] = "hi",
			},
			{
				["Priority"] = -1,
				["Value"] = "after",
			},
		},
		["DataEntered2"] = {
			{
				["Priority"] = 2,
				["Value"] = "hello again",
			},
			{
				["Priority"] = -1,
				["Value"] = "after but in 2",
			},
		},
	}
	.Changed = event
	(index and newindex metamethods attached to this table)
}

MULTIPLEVALUE TABLE FUNCTIONS ---------------

There are a few functions provided by the wrapper to tables for multipleval tables, which are: 

tab:get("index") which will return all numerical index = value table for the given table entry

tab:set("index", numericalindex, value) which will replace the value in that sublist's numerical index while maintaining priority
(unless if one is provided in value)

tab:insert("index", value) will insert a new value into the sub-priority-table

tab:remove("index", numericalindex) which will remove the numericalindex out of the table of "index".
An array of numericalindex can also be passed, in which all values will be removed.

tab:sort("index") is also available, but isn't required externally in most uses.
These functions are only usable if the PriorityTable is a MultipleVals table.

tab:rawget("index") is the same thing as get, but will always get the tables instead of returning only index=value when a value
was inserted into the table.

tab:findfromval("index", value, "valueName", false) finds the elements of a priorityTable with a specific value
the first two arguments are required, and the third object will specify the index of the value in the table, which will be
"Value" by default. The fourth argument defines whether to return just the first found element, or all elements with that value.
If the fourth argument is given, it will return an array of numbers instead of just one number.

----------------------------

This also supports writing in non dictionary values, but they will not have any sort of priorty checking, and will default to 1.
This does mean that table library will be broken unless if you call it on the trueValues table of the original table.
Finally, this also provides a value .Changed which will fire when a value is added with the index and value

]]

-- Also don't try to set .trueValues or anything with two underscores lol

return {}