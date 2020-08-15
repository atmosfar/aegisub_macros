-- modified from aegisub example code and rosettacode.org

local tr = aegisub.gettext

script_name = tr"Wrap text"
script_description = tr"Wrap text by adding linebreaks"
script_author = "brian"
script_version = "1"

function splittokens(s)
    local res = {}
    for w in s:gmatch("%S+") do
        res[#res+1] = w
    end
    return res
end
 
function textwrap(text, linewidth)
    if not linewidth then
        linewidth = 30
    end
 
    local spaceleft = linewidth
    local res = {}
    local line = {}
 
    for _, word in ipairs(splittokens(text)) do
        if #word + 1 > spaceleft then
            table.insert(res, table.concat(line, ' '))
            line = {word}
            spaceleft = linewidth - #word
        else
            table.insert(line, word)
            spaceleft = spaceleft - (#word + 1)
        end
    end
 
    table.insert(res, table.concat(line, ' '))
    return table.concat(res, '\\n')
end

function wrap_text(subs, sel)
    for _, i in ipairs(sel) do
        local line = subs[i]
        line.text = textwrap(line.text)
        subs[i] = line
    end
    aegisub.set_undo_point(tr"wrap text")
end

aegisub.register_macro(script_name, script_description, wrap_text)
