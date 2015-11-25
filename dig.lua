--	Digger dungeon generator by Ilya Kolbin ( iskolbin@gmail.com )
--
--	Used for digging-cave-like level generation 

local FREE, WALL, NEXT_FREE, NEXT_WALL = 0, 1, 2, 3

return function( kwargs )
	local random = math.random
	local grid = kwargs.grid
	local w, h
	
	if not grid then
		grid = {}
		w, h = kwargs.w, kwargs.h
		for x = 1, w do
			grid[x] = {}
			for y = 1, h do
				grid[x][y] = WALL
			end
		end
	else
		w, h = #grid, #grid[1]
	end
	
	local cx, cy = kwargs.cx or math.floor( w/2 ), kwargs.cy or math.floor( h/2 )
	local minx, miny, maxx, maxy = kwargs.minx or 2, kwargs.miny or 2, kwargs.maxx or w-1, kwargs.maxy or h-1
	local diggers = kwargs.diggers or (5 + random( 5 ))
	local iterations = kwargs.iterations or (w*h/diggers)*(density or 0.5)
	
	local probVer, probHor
	
	if kwargs.mode == 'noscale' or kwargs.mode == nil then
		probVer, probHor = 0.5, 0.5
	elseif kwargs.mode == 'scale' then
		if w > h then
			probVer = h^2/(w+h)^2
			probHor = 1 - probVer
		else
			probHor = w^2/(w+h)^2
			probVer = 1 - probHor
		end
	end
	
	local probLeft = 0.5 * probHor
	local probRight = probLeft + 0.5 * probHor
	local probUp = probRight + 0.5 * probVer

	for i = 1, diggers do
		local x, y = cx, cy
		for j = 1, iterations do 
			grid[x][y] = FREE
			local r = random()
			if     r < probLeft and x < maxx then x = x + 1
			elseif r < probRight and x > minx then x = x - 1
			elseif r < probUp and y < maxy then y = y + 1
			elseif y > miny then y = y - 1
			end
		end
	end
	
	return grid
end
