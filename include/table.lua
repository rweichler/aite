function table.merge(...)
    local result = {}
    local len = 0
    for _, t in ipairs({...}) do
        for i, v in ipairs(t) do
            result[len + i] = v
        end
        len = len + #t
    end
    return result
end
