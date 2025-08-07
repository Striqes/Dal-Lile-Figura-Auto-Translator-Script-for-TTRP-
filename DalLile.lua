-- HOW TO USE

-- type in '\le' after the words you want translated

-- example: 
--      "Welcome to Lily's End. Welcome\le would mean welcome in the Dal Lile Language."
-- would turn into:
--      "Fáilte to Lily's End. Fáilte would mean welcome in the Dal Lile Language"

-- Toggle on the Auto Translator and not type \le

-- Action wheel stuff. Copy paste it on your script.lua or your current action wheel or smth :>
-- local page = action_wheel:newPage()
-- action_wheel:setPage(page)
-- toggleTranslator = page:newAction():title("Toggle Auto Translator Dal Lile"):item("minecraft:Paper"):setOnToggle(Dal_Lile.toggle_translator):setToggled(false)


local M = {}

-- Categorized phrase dictionary
local phrase_categories = {
    greetings = {
        ["good morning"] = "Eirigh seimh",
        ["good night"] = "Eirigh Codladh",
        ["thank you"] = "Raibh maith",
        ["peace be with you"] = "Líonas leat",
        ["so long"] = "Líonas leat",
        ["good bye"] = "Líonas leat",
        ["be safe"] = "Líonas leat",
        ["it's fine"] = "Suaimhneas ort",
        ["it's okay"] = "Suaimhneas ort",
        ["i see you"] = "Feicim thú"
    },
    nicknames = {
        ["my hearth"] = "mo thien",
        ["flower of my eye"] = "lus sul",
        ["little ant"] = "seanganin",
        ["guilty dog"] = "Madra fliuch",
        ["breath of my life"] = "Aneil mo shaoil",
        ["little warrior"] = "Curamachin",
        ["my moon"] = "Mo yeallach"
    },
    titles = {
        ["crown prince"] = "Caelan",
        ["grand duchess"] = "Silvenar",
        ["the queens consort"] = "Liorean"
    },
    love = {
        ["i love you"] = "Ta ghra thu",
        ["you are my soul"] = "Mo anam thu"
    },
    hate = {
        ["i hate you"] = "Ta fuath agam duit",
        ["my heart burns because of you"] = "Is doite mo chroi leat"
    },
    proverbs = {
        ["slow down"] = "Téigh go mall"
    },
    poetic = {
        ["the wind was listening"] = "Bhí an ghaoth ag éisteacht"
    }
}

local phrase_dictionary = {}
for _, category in pairs(phrase_categories) do
    for k, v in pairs(category) do
        phrase_dictionary[k] = v
    end
end

-- Word dictionary (lowercase keys only for input)
local word_categories = {
    greetings = {
        ["hello"] = "léana",
        ["greetings"] = "léana",
        ["hi"] = "léana",
        ["hey"] = "léana",
        ["welcome"] = "fáilte",
        ["thanks"] = "raibh maith",
        ["goodbye"] = "líonas leat",
        ["bye"] = "líonas leat",
    },
    nicknames = {
        ["children"] = "lilean",
        ["runt"] = "giolcach",
        ["twig"] = "giolcach",
        ["snapdragon"] = "gearrog",
        ["overconfident"] = "capall gan broga",
        ["workaholic"] = "seanganin",
    },

    words_of_kin = {
        ["mother"] = "maithair",
        ["mama"] = "mahti",
        ["mum"] = "mahti",
        ["mom"] = "mahti",
        ["father"] = "athair",
        ["papa"] = "athair",
        ["dad"] = "athair",
        ["son"] = "mac",
        ["daughter"] = "inion",
        ["child"] = "leanbh",
        ["brother"] = "jearthair",
        ["sister"] = "jeirfiur",
        ["sibling"] = "celiecrann",
        ["family"] = "clann",
        ["grandmother"] = "seanmhathair",
        ["grandfather"] = "seanathair",
    },
    
    royalty = {
        ["queen"] = "talenai",
        ["king"] = "maerun",
        ["heir"] = "caelan",
        ["prince"] = "elarin",
        ["princess"] = "selune",
        ["duchess"] = "silvenar"
    }
}

local word_dictionary = {}
for _, category in pairs(word_categories) do
    for k, v in pairs(category) do
        word_dictionary[k] = v
    end
end


local function preserveCase(original, translation)
    if original == original:upper() then
        return translation:upper()
    elseif original:sub(1,1):upper() == original:sub(1,1) then
        return translation:sub(1,1):upper() .. translation:sub(2)
    else
        return translation
    end
end


local function replacePhrases(text)
    local lower_text = text:lower()

    for phrase, translation in pairs(phrase_dictionary) do
        local escaped = phrase:gsub("([%%%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
        local lower_phrase = escaped:lower()

        local start_pos = 1
        while true do
            local s, e = lower_text:find(lower_phrase, start_pos, true)
            if not s then break end

            text = text:sub(1, s - 1) .. translation .. text:sub(e + 1)
            lower_text = text:lower()
            start_pos = s + #translation
        end
    end

    return text
end


local function replaceWords(text)
    return text:gsub("(%f[%a])(%w+)(%f[%A])", function(a, word, c)
        local base = word:lower()
        local translated = word_dictionary[base]
        if translated then
            return a .. preserveCase(word, translated) .. c
        else
            return a .. word .. c
        end
    end)
end

-- Full translator: phrases first, then individual words
local function translateText(text)
    text = replacePhrases(text)
    text = replaceWords(text)
    return text
end

local translator_enabled = false
function M.toggle_translator(state)
    translator_enabled = not translator_enabled
    print("Auto Translator is now " .. (translator_enabled and "ON" or "OFF"))
end

-- Chat message event
function events.chat_send_message(msg)
    if msg:sub(1, 1) == "/" then return msg end

    local split_pos = msg:find("\\le", 1, true)

    if translator_enabled then
        -- Translate everything
        if split_pos then
            local before = msg:sub(1, split_pos - 1)
            local after = msg:sub(split_pos + 3)
            return translateText(before) .. after
        else
            return translateText(msg)
        end
    else
        -- Only translate if \le is used
        if split_pos then
            local before = msg:sub(1, split_pos - 1)
            local after = msg:sub(split_pos + 3)
            return translateText(before) .. after
        else
            return msg
        end
    end
end

return M