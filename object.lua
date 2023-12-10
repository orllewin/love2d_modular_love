-- Playdate CoreLibs: Object
-- Copyright (C) 2015 Panic, Inc.

-- loosely based on http://replayism.com/code/barebones-lua-class/

Object = {}
Object.__index = Object
Object.class = Object
Object.className = 'Object'

--override to initialize 
function Object:init(...) end


-- override to base a subclass on an already existing table (see CoreLibs: Sprites)
function Object.baseObject()
	return {}
end


local __NewClass = {}

function class(ClassName, properties, namespace)
		__NewClass.className = ClassName
		__NewClass.properties = properties
		__NewClass.namespace = namespace    
	return __NewClass
end


function __NewClass.extends(Parent)

	if type(Parent) == 'string' then
				Parent = _G[Parent]
		elseif Parent == nil then 
			Parent = Object
	end
	local Child = __NewClass.properties or {}
	Child.__index = Child
	Child.class = Child
	Child.className = __NewClass.className
	Child.super = Parent
	
	-- lua doesn't walk the metatable chain for these, but we want them to inherit:
	Child.__gc 			= Parent.__gc
	Child.__newindex 	= Parent.__newindex
	Child.__mode 		= Parent.__mode
	Child.__tostring 	= Parent.__tostring
	Child.__len 		= Parent.__len
	Child.__unm 		= Parent.__unm
	Child.__add 		= Parent.__add
	Child.__sub 		= Parent.__sub
	Child.__mul 		= Parent.__mul
	Child.__div 		= Parent.__div
	Child.__mod 		= Parent.__mod
	Child.__pow 		= Parent.__pow
	Child.__concat 		= Parent.__concat
	Child.__eq 			= Parent.__eq
	Child.__lt 			= Parent.__lt
	Child.__le 			= Parent.__le
	
	local mt = {
		__index = Parent,
		__call = function(self, ...)
			local instance = Child.baseObject()
			setmetatable(instance, Child)
--			instance.__index = instance
-- 			instance.class = instance
			instance.super = Child
			Child.init(instance, ...)
			return instance
		end
		}
	
	setmetatable(Child, mt)

	if (__NewClass.namespace ~= nil) then
		__NewClass.namespace[__NewClass.className] = Child
	else
		_G[__NewClass.className] = Child
	end
	
	__NewClass.properties = nil
	__NewClass.className = nil
	__NewClass.namespace = nil
end

-- Returns a boolean value that indicates whether the receiver is an instance of Class or an instance of any class that Class inherits from
function Object:isa(Class)
	local isa = false
	local currentClass = self
	
	while (currentClass ~= nil) and (isa == false) do
		if (currentClass == Class) then
			isa = true
		else
			currentClass = currentClass.super
		end
	end
	return isa
end


-- function Object:tableDump([indent], [table])
-- debugging convenience function that prints all of the objects key/value pairs, and the key/value pairs for all superclasses
function Object:tableDump(indent, table)

	local function printFormattedKeyValue(indent, k, v)
		v = v or ''
		print(string.rep('  ', indent) .. k .. ': ' .. tostring(v))
	end

	table = table or self
	local indent = indent or 0
	local super = nil
	
	for k, v in pairs(table) do
		if k == '__index' or k == 'class' or k == 'isa' or k == 'init' or k == 'tableDump' or k == 'baseObject' or k == 'className' then
				-- do nothing
			elseif k == 'super' then
			super = v
		elseif type(v) == 'table' then
			printFormattedKeyValue(indent, k)
			Object.tableDump(v, indent+1, v)
		else
			printFormattedKeyValue(indent, k, v)
		end
	end
	
	if super ~= nil and super.className ~= 'Object' then
		print()
		printFormattedKeyValue(indent, 'super (' .. super.className .. ')')
		super.tableDump(super, indent+1)
	end
end


-- printTable(...) is just like print but formats tables

local insert = table.insert
local sort   = table.sort
local concat = table.concat
local unpack = table.unpack
local function repeatString(s,t)
	local chars = {}
	for i=1,t do
		chars[i] = s
	end
	return concat(chars)
end

-- based on compareAnyTypes from http://lua-users.org/wiki/SortedIteration
local function sortAny(val1, val2)
		local type1,type2 = type(val1), type(val2)
		local num1,num2  = tonumber(val1), tonumber(val2)
		
		if num1 and num2 then
				return num1 < num2
		elseif type1 ~= type2 then
				return type1 < type2
		elseif type1 == 'string'  then
				return val1 < val2
		elseif type1 == 'boolean' then
				return val1
		else
				return tostring(val1) < tostring(val2)
		end
end

-- from https://www.lua.org/pil/19.3.html
local function pairsByKey(t, f)
	local a = {}
	for n in pairs(t) do insert(a, n) end
	sort(a, f or sortAny)
	local i = 0 -- iterator variable
	local iter = function() -- iterator function
		i = i + 1
		if a[i] == nil then return nil
		else return a[i], t[a[i]] end
	end
	return iter
end

local encounteredTables = nil -- {}
local function tableToString(o,path,t)
	path = path or '/'
	if encounteredTables[o] then
		return 'reference: '..encounteredTables[o]
	end
	encounteredTables[o] = path
	
	t = t or 1
	local lines = {'{'}
	local tabs = repeatString('\t', t)
	t = t + 1
	
	local line = #lines + 1
	for k,v in pairsByKey(o) do
		local ktype = type(k)
		local vtype = type(v)
		
		local key = ''
		if ktype ~= 'number' then
			key = '['..tostring(k)..'] = '
		end
		
		local value
		if vtype == 'table' then
			value = tableToString(v, path..k..'/', t)
		else
			value = tostring(v)
		end
		lines[line] = tabs..key..value..','
		
		line = line + 1
	end
	lines[line] = repeatString('\t', t-2)..'}'
	return concat(lines, '\n')
end

function printTable(...)
	encounteredTables = {}
	local args = {...}
	for i=1,#args do
		local a = args[i]
		if type(a) == 'table' then
			-- encounteredTables[a] = '/'..i
			args[i] = tableToString(a)
		end
	end
	print(unpack(args))
	encounteredTables = nil
end
