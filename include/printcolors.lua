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
        return '\x1B['..v..'m'..str..'\x1B[0m'
    end
end
