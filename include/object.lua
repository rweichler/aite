local obj = {}

function obj:new()
    return self:subclass({})
end

function obj:subclass(sub)
    setmetatable(sub, {
        __index = function(t, k)
            local field = 'get_'..k
            local get_func = rawget(t, field) or self[field]
            if get_func then
                return get_func(t)
            else
                return self[k]
            end
        end,
        __newindex = function(t, k, v)
            local set_func = t['set_'..k]
            if set_func then
                set_func(t, v)
            else
                rawset(t, k, v)
            end
        end,
        __call = function(t, ...)
            return t:new(...)
        end
    })
    sub.super = self
    return sub
end

object = obj:new()
