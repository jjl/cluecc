-- clue/crt.lua
--
-- Clue C runtime library
--
-- © 2008 David Given.
-- Clue is licensed under the Revised BSD open source license. To get the
-- full license text, see the README file.
--
-- $Id$

local print = print
local unpack = unpack
local ipairs = ipairs
local string_char = string.char
local string_byte = string.byte
local string_sub = string.sub
local string_find = string.find
local string_len = string.len
local math_floor = math.floor
local bit = bit
local bit32 = bit32

if (not bit) and (not bit32) then
	bit = require("bit")
end

local ZERO = string_char(0)

module "clue.crt"

local initializer_list = {}
function add_initializer(i)
	initializer_list[#initializer_list + 1] = i
end

function run_initializers()
	-- Foul, foul hack. Run all initializers twice to resolve mutually
	-- dependent function references.
	 
	for _, i in ipairs(initializer_list) do
		i()
	end
	for _, i in ipairs(initializer_list) do
		i()
	end

	initializer_list = {}
end

local READ_FN = 1
local WRITE_FN = 2
local OFFSET_FN = 3
local TOSTRING_FN = 4

local DATA_I = 1
local OFFSET_I = 2

function ptrtostring(po, pd)
	local s = {}
	while true do
		local c = pd[po]
		if (c == 0) then
			break;
		else
			s[#s+1] = c
		end
		po = po + 1
	end
	
	return string_char(unpack(s))
end
	
-- Construct a string array.

function newstring(s)
	local len = string_len(s)
	local s = {string_byte(s, 1, len)}
	s[#s+1] = 0
	return s
end

-- Number operations.

function int(v)
	return math_floor(v)
end

-- Bit operations.

if bit then
	local bit_bnot = bit.bnot
	local bit_band = bit.band
	local bit_bor = bit.bor
	local bit_bxor = bit.bxor
	local bit_lshift = bit.lshift
	local bit_rshift = bit.rshift
	local bit_arshift = bit.arshift
	
	function shl(v, shift)
		return bit_lshift(v, shift)
	end
	
	function shr(v, shift)
		return bit_rshift(v, shift)
	end
	
	function logor(v1, v2)
		return bit_bor(v1, v2)
	end
	
	function logand(v1, v2)
		return bit_band(v1, v2)
	end
	
	function logxor(v1, v2)
		return bit_bxor(v1, v2)
	end
else
	local bit32_bnot = bit32.bnot
	local bit32_band = bit32.band
	local bit32_bor = bit32.bor
	local bit32_bxor = bit32.bxor
	local bit32_lshift = bit32.lshift
	local bit32_rshift = bit32.rshift
	local bit32_arshift = bit32.arshift
	
	function shl(v, shift)
		return bit32_lshift(v, shift)
	end
	
	function shr(v, shift)
		return bit32_rshift(v, shift)
	end
	
	function logor(v1, v2)
		return bit32_bor(v1, v2)
	end
	
	function logand(v1, v2)
		return bit32_band(v1, v2)
	end
	
	function logxor(v1, v2)
		return bit32_bxor(v1, v2)
	end
end

-- Boolean operations.

function booland(v1, v2)
	v1 = (v1 ~= nil) and (v1 ~= 0)
	v2 = (v2 ~= nil) and (v2 ~= 0) 
	return (v1 and v2) and 1 or 0
end

function boolor(v1, v2)
	v1 = (v1 ~= nil) and (v1 ~= 0)
	v2 = (v2 ~= nil) and (v2 ~= 0) 
	return (v1 or v2) and 1 or 0
end

