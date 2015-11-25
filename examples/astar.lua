local asciigrid = require'asciigrid'
local astar = require'astar'

local s = [[
####.....###.#####....#####
..#.......#...........#....
......#...#......#....#....
.....##...#.....vvv...#....
....#......##..#...........
...###.........#..TT.......
.....#.^^..................
....#T..0......0.00........]]

local decoder = {invertY = true, indexXY = true, 
	['#'] = math.huge,
	['^'] = 0.2,
	['v'] = 0.4,
	['0'] = 0.5,
	['T'] = 0.7,
	['.'] = 0.1,
	['*'] = 0.0,
}

local encoder = {invertY = true, indexXY = true,
	[math.huge] = '#',
	[0.2] = '^',
	[0.4] = 'v',
	[0.5] = '0',
	[0.7] = 'T',
	[0.1] = '.',
	[0.0] = '*',
}

local grid = asciigrid.decode( s, decoder )

print( 'MAP' )
print( s )
print()
print( 'PATH' )
for x, y in astar( grid, 1, 1, 26, 7 ) do
	grid[x][y] = 0.0
end


print( asciigrid.encode( grid, encoder ))
