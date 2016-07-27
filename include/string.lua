

function string.has_prefix(str, prefix)
    return prefix == string.sub(str, 1, #prefix)
end

function string.has_suffix(str, suffix)
    return suffix == string.sub(str, #str - #suffix + 1, #str)
end

function string.split(self, sep)
    local fields = {}
    local pattern = string.format("([^%s]+)", sep)
    string.gsub(self, pattern, function(c) fields[#fields+1] = c end)
    return fields
end
