local bsp = require 'bsp'
local asciigrid = require 'asciigrid'

print( asciigrid.encode( bsp{ w = 40, h = 30 }, {invertY = true, [0] = '.', [1] = '#' } )) 
