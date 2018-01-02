function table.merge(...)
    local result = {}
    local len = 0
    for _, t in ipairs({...}) do
        if type(t) == 'table' then
            for i, v in ipairs(t) do
                result[len + i] = v
            end
            for k, v in pairs(t) do
                if not(type(k) == 'number') then
                    result[k] = v
                end
            end
            len = len + #t
        else
            result[len + 1] = t
            len = len + 1
        end
    end
    return result
end

local function rem(t, del)
    local found = false
    for i,v in ipairs(t) do
        if v == del then
            table.remove(t, i)
            found = true
            break
        end
    end
    if not found then
        error("Couldn't find "..tostring(del))
    end
end

function table.removecontents(a, b)
    if type(b) == 'table' then
        for _,del in ipairs(b) do
            rem(a, del)
        end
    else
        rem(a, b)
    end
    return a
end
