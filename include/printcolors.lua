local c = {}
c.RED =         '1;31'
c.GREEN =       '1;32'
c.YELLOW =      '1;33'
c.LIGHT_BLUE =  '1;34'
c.PINK =        '1;35'
c.CYAN =        '1;36'

c.DARK_RED =    '0;31'
c.DARK_GREEN =  '0;32'
c.BROWN =       '0;33'
c.BLUE =        '1;34'
c.PURPLE =      '0;35'
c.DARK_CYAN =   '0;36'

for k,v in pairs(c) do
    _G[k] = function(str)
        if c.is_ps1 then
            -- i also use this for my ps1 in bash
            -- so i just do the check in here.
            return '\\[\x1B['..v..'m\\]'..str..'\\[\x1B[0m\\]'
        else
            -- this is what usually is printed
            return '\x1B['..v..'m'..str..'\x1B[0m'
        end
    end
end

return c
