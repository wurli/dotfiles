local get_case = function(str)
	for case, pattern in pairs({
		camel = "^[a-z][a-zA-Z0-9]*$",
		pascal = "^[A-Z][a-zA-Z0-9]*$",
		snake = "^[a-z_]+$",
	}) do
		if string.match(str, pattern) then
			return case
		end
	end
	return "unknown"
end

---@param str string
local char_type = function(str)
	if str == "" then
		return "e"
	elseif str:match("%u") then
		return "u"
	elseif str:match("%l") then
		return "l"
	elseif str:match("%d") then
		return "d"
	else
		return "p"
	end
end

---@param str string
local to_words = function(str)
	local words = {}
	local curr_word = ""
	local curr_char = ""
	local next_char = ""
	local collect = function()
		if #curr_word > 0 then
			table.insert(words, curr_word:lower())
			curr_word = ""
		end
	end
	for i = 1, #str do
		curr_char = str:sub(i, i)
		next_char = str:sub(i + 1, i + 1)

		local curr_type = char_type(curr_char)
		local next_type = char_type(next_char)
		local types = curr_type .. next_type

		if types == "lu" or types:match("d[ul]") then
			curr_word = curr_word .. curr_char
			collect()
		elseif types == "ul" then
			collect()
			curr_word = curr_word .. curr_char
		elseif curr_type == "p" then
			collect()
		else
			curr_word = curr_word .. curr_char
		end
	end
	collect()
	return words
end

local words_to_camel = function(words)
	local new_words = {}
	for i, word in ipairs(words) do
		if i == 1 then
			table.insert(new_words, word)
		elseif i > 1 then
			table.insert(new_words, word:sub(1, 1):upper() .. word:sub(2))
		end
	end
	return table.concat(new_words, "")
end

local words_to_snake = function(words)
	return table.concat(words, "_")
end

local words_to_pascal = function(words)
	local new_words = {}
	for _, word in ipairs(words) do
		table.insert(new_words, word:sub(1, 1):upper() .. word:sub(2))
	end
	return table.concat(new_words, "")
end

local cycle_case = function(str)
	local curr_case = get_case(str)
	local words = to_words(str)
	if curr_case == "camel" or curr_case == "pascal" or curr_case == "unknown" then
		return words_to_snake(words)
	elseif curr_case == "snake" then
		return words_to_pascal(words)
	-- I don't really use camel case
	-- elseif curr_case == "pascal" then
	--     return words_to_camel(words)
	else
		error("Unknown case for String: " .. str)
	end
end

-- for _, x in ipairs({ "EURConversion", "hi_there", "HiThere", "hiThere", "hi_?!The123re.Jacob" }) do
-- 	vim.print("Original:   " .. x)
-- 	vim.print("Case:       " .. get_case(x))
-- 	local words = to_words(x)
-- 	vim.print("Words:      " .. vim.inspect(words))
-- 	vim.print("To Camel:   " .. words_to_camel(words))
-- 	vim.print("To Snake:   " .. words_to_snake(words))
-- 	vim.print("To Pascal:  " .. words_to_pascal(words))
-- 	vim.print("Cycle Case: " .. cycle_case(x))
-- 	vim.print("-----")
-- end

return { cycle_case = cycle_case }
