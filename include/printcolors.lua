local c = {}
c.GREEN = '1;32'
c.CYAN = '1;36'
c.DARK_RED = '0;31'
c.RED = '1;31'
c.PURPLE = '1;35'
c.YELLOW = '1;33'

for k,v in pairs(c) do
    _G[k] = function(str)
        return '\x1B['..v..'m'..str..'\x1B[0m'
    end
end
