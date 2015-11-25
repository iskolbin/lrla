--	Celluar automata dungeon generator by Ilya Kolbin ( iskolbin@gmail.com )
--
--	Used for cave-like level generation 

local random = math.random

local FREE, WALL, NEXT_FREE, NEXT_WALL = 0, 1, 2, 3
local DEFAULT_ITERATIONS = 5
local DEFAULT_DENSITY = 0.45
local DEFAULT_CUTOFF = function( grid, x, y )
	local w, h = #grid, #grid[1]
	local R1 = grid[x][y]
	
	if grid[x-1][y-1] > 0 then R1 = R1 + 1 end
	if grid[x-1][y+1] > 0 then R1 = R1 + 1 end
	if grid[x+1][y-1] > 0 then R1 = R1 + 1 end
	if grid[x+1][y+1] > 0 then R1 = R1 + 1 end
	
	if grid[x-1][y] > 0 then R1 = R1 + 1 end
	if grid[x+1][y] > 0 then R1 = R1 + 1 end
	if grid[x][y-1] > 0 then R1 = R1 + 1 end
	if grid[x][y+1] > 0 then R1 = R1 + 1 end
	
	if R1 >= 5 then
		grid[x][y] = grid[x][y] > 0 and NEXT_WALL or -NEXT_WALL
	else
		grid[x][y] = grid[x][y] > 0 and NEXT_FREE or -NEXT_FREE
	end
end

return function( kwargs )
	assert( kwargs )
	local grid = kwargs.grid
	local w, h
	if not grid then
		w, h = kwargs.w, kwargs.h
		assert( w and h )
		local density = kwargs.density or DEFAULT_DENSITY
		grid = {{}}

		for x = 2, w-1 do
			grid[x] = {WALL}
			for y = 2, h-1 do
				grid[x][y] = ( random() < density ) and WALL or FREE
			end
			grid[x][h] = WALL
		end
		
		grid[w] = {}
		for y = 1, h do grid[1][y], grid[w][y] = WALL, WALL end
	else
		w, h = #grid, #grid[1]
	end
		
	local cutoff = kwargs.cutoff or DEFAULT_CUTOFF
	local iterations = kwargs.iterations or DEFAULT_ITERATIONS
	local update = kwargs.update
	
	for i = 1, iterations do
		if update then
			cutoff = update( cuttof, i )
		end
		
		for x = 2, w-1 do
			for y = 2, h-1 do
				cutoff( grid, x, y )
			end
		end
		
		for x = 2, w-1 do
			for y = 2, h-1 do
				local c = grid[x][y]
				if c == NEXT_FREE or c == -NEXT_FREE then
					grid[x][y] = FREE
				else
					grid[x][y] = WALL
				end
			end
		end
	end
	
	return grid
end
