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

local to_words = function(str)
    local words = {}
    local last_word = ""
    for i = 1, #str do
        local char = str:sub(i, i)
        if char:match("%u") and #last_word > 0 then
            table.insert(words, last_word)
            last_word = char:lower()
        elseif char == "_" then
            if #last_word > 0 then
                table.insert(words, last_word)
                last_word = ""
            end
        else
            last_word = last_word .. char:lower()
        end
    end
    if #last_word > 0 then
        table.insert(words, last_word)
    end
    return words
end


local words_to_camel = function(words)
    for i, word in ipairs(words) do
        if i > 1 then
            words[i] = word:sub(1, 1):upper() .. word:sub(2)
        end
    end
    return table.concat(words, "")
end

local words_to_snake = function(words)
    return table.concat(words, "_")
end

local words_to_pascal = function(words)
    for i, word in ipairs(words) do
        words[i] = word:sub(1, 1):upper() .. word:sub(2)
    end
    return table.concat(words, "")
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
        error("Unknown case for string: " .. str)
    end
end

-- for _, x in ipairs({ "hi_there", "HiThere", "hiThere", "hi_?!The123re.Jacob" }) do
--     vim.print("Original:   " .. x)
--     vim.print("Case:       " .. get_case(x))
--     local words = to_words(x)
--     vim.print("Words:      " .. vim.inspect(words))
--     vim.print("To Camel:   " .. words_to_camel(words))
--     vim.print("To Snake:   " .. words_to_snake(words))
--     vim.print("To Pascal:  " .. words_to_pascal(words))
--     vim.print("Cycle Case: " .. cycle_case(x))
--     vim.print("-----")
-- end

return { cycle_case = cycle_case }
