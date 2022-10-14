-- luacheck: globals vector

local m_floor = math.floor

local in_bounds = math.in_bounds
local bound = math.bound

local mapblock_size = 16
local chunksize = m_floor(tonumber(minetest.settings:get("chunksize")) or 5)
local max_mapgen_limit = 31007
local mapgen_limit = m_floor(tonumber(minetest.settings:get("mapgen_limit"))) or max_mapgen_limit
local mapgen_limit_b = m_floor(bound(0, mapgen_limit, max_mapgen_limit) / mapblock_size)
local mapgen_limit_min = -mapgen_limit_b * mapblock_size
local mapgen_limit_max = (mapgen_limit_b + 1) * mapblock_size - 1

local map_min_i = mapgen_limit_min + (mapblock_size * chunksize)
local map_max_i = mapgen_limit_max - (mapblock_size * chunksize)

local v_add = vector.add
local v_copy = vector.copy
local v_new = vector.new
local v_sort = vector.sort
local v_sub = vector.subtract

local map_min_p = v_new(map_min_i, map_min_i, map_min_i)
local map_max_p = v_new(map_max_i, map_max_i, map_max_i)

function futil.get_bounds(pos, radius)
	return v_sub(pos, radius), v_add(pos, radius)
end

function futil.get_blockpos(pos)
    return v_new(m_floor(pos.x / 16), m_floor(pos.y / 16), m_floor(pos.z / 16))
end

function futil.get_block_bounds(blockpos)
    return v_new(blockpos.x * 16, blockpos.y * 16, blockpos.z * 16),
    v_new(blockpos.x * 16 + 15, blockpos.y * 16 + 15, blockpos.z * 16 + 15)
end

function futil.formspec_pos(pos)
	return ("%i,%i,%i"):format(pos.x, pos.y, pos.z)
end

function futil.iterate_area(minp, maxp)
	minp, maxp = v_sort(minp, maxp)
	local cur = table.copy(minp)
	cur.x = cur.x - 1
	return function()
		if cur.y > maxp.y then
			return
		end

		cur.x = cur.x + 1
		if cur.x > maxp.x then
			cur.x = minp.x
			cur.z = cur.z + 1
		end

		if cur.z > maxp.z then
			cur.z = minp.z
			cur.y = cur.y + 1
		end

		if cur.y <= maxp.y then
			return v_copy(cur)
		end
	end
end

function futil.iterate_volume(pos, radius)
	return futil.iterate_area(futil.get_bounds(pos, radius))
end

function futil.is_pos_in_bounds(minp, pos, maxp)
	minp, maxp = v_sort(minp, maxp)
	return (
		in_bounds(minp.x, pos.x, maxp.x) and
		in_bounds(minp.y, pos.y, maxp.y) and
		in_bounds(minp.z, pos.z, maxp.z)
	)
end

function futil.get_world_bounds()
	return map_min_p, map_max_p
end

function futil.is_inside_world_bounds(pos)
	return futil.is_pos_in_bounds(map_min_p, pos, map_max_p)
end

function futil.bound_position_to_world(pos)
	return v_new(
		bound(map_min_i, pos.x, map_max_i),
		bound(map_min_i, pos.y, map_max_i),
		bound(map_min_i, pos.z, map_max_i)
	)
end

function vector.volume(pos1, pos2)
	local minp, maxp = v_sort(pos1, pos2)
	return (maxp.x - minp.x + 1) * (maxp.y - minp.y + 1) * (maxp.z - minp.z + 1)
end
