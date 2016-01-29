--	Binary space partitioning dungeon generator by Ilya Kolbin ( iskolbin@gmail.com )
--
--	Used for dungeon-like level generation 

local FREE, WALL = 0, 1
local random, floor = math.random, math.floor
local pi, cos, sin, ln = math.pi, math.cos, math.sin, math.log

local gauss = function()
	local u, v = random(), 2*pi*random()
	while u == 0 do 
		u = random() 
	end
	local c = (-2*ln(u))^0.5
	return c*cos(v), c*sin(v)
end

local newGrid = function( w, h, c )
	assert( w and h )
	local grid = {}
	for x = 1, w do
		grid[x] = {}
		for y = 1, h do
			grid[x][y] = c
		end
	end
	return grid
end

local grandomInt = function( minx, maxx )
	local x = gauss() * (1/6) + 0.5
	if     x < 0 then x = 0
	elseif x > 1  then x = 1
	end
	
	return floor( minx + x * (maxx-minx) )
end

local function splitTree( x, y, w, h, l, kwargs )
	if w < 4 or h < 4 or l > (kwargs.maxl or 5) then
		return {x,y,w,h}
	else
		local random
		if kwargs.random == 'gauss' then
			random = grandomInt
		else
			random = kwargs.random or math.random
		end
		
		if w > h then
			local x_ = random( 2, w-1 )
			return {splitTree( x, y, x_, h, l+1, kwargs ), splitTree( x+x_+1, y, w-x_-1, h, l+1, kwargs )}
		else
			local y_ = random( 2, h-1 )
			return {splitTree( x, y, w, y_, l+1, kwargs ), splitTree( x, y+y_+1, w, h-y_-1, l+1, kwargs )}
		end
	end
end

local function drawDungeon( room, grid )
	if room[4] then
		for x = room[1]+1, room[1]+room[3]-1 do
			for y = room[2]+1, room[2]+room[4]-1 do
				grid[x][y] = FREE
			end
		end
	else
		drawDungeon( room[1], grid )
		drawDungeon( room[2], grid )
	end
end
	

return function( kwargs )
	assert( kwargs )
	local grid = kwargs.grid
	local w, h
	
	if not grid then
		w, h = kwargs.w, kwargs.h
		grid = newGrid( w, h, kwargs.invert and FREE or WALL )
	else
		w, h = #grid, #grid[1]
	end
	
	local minx, miny, maxx, maxy = kwargs.minx or 2, kwargs.miny or 2, kwargs.maxx or w-1, kwargs.maxy or h-1
	local minw, minh = kwargs.minw or 4, kwargs.minh or 4
	
	local tree = splitTree( 1, 1, maxx-minx+1, maxy-miny+1, 0, kwargs )
	
	drawDungeon( tree, grid )
	
	return grid
end

