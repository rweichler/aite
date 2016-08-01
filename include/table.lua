function table.merge(...)
    local result = {}
    local len = 0
    for _, t in ipairs({...}) do
        if type(t) == 'table' then
            for i, v in ipairs(t) do
                result[len + i] = v
            end
            len = len + #t
        else
            result[len + 1] = t
            len = len + 1
        end
    end
    return result
end
