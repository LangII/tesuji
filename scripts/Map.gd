extends TileMap

export var MAP_SIZE_X = 48
export var MAP_SIZE_Y = 48
# Number of tile cells converted to terrain at instance.
export var CELL_INST = 16
# Minimum radius of terrain cell expansion from instance.
export var RAD_MIN = 2
# Maximum radius of terrain cell expansion from instance.
export var RAD_MAX = 8

var map_size = Vector2(
		MAP_SIZE_X + RAD_MAX * 2,
		MAP_SIZE_Y + RAD_MAX * 2)

# Establish empty containers to sort terrain and non-terrain tiles.
var terr_tiles = []
var empty_tiles = []

# Array used to create world border collision wall.  Empty array is for
# converting to global coordinates.
var border_corners_world = []
var border_corners_map = [
		Vector2(0 - map_size.x * 0.3, 0 - map_size.y * 0.3),
		Vector2(map_size.x * 1.3, 0 - map_size.y * 0.3),
		Vector2(map_size.x * 1.3, map_size.y * 1.3),
		Vector2(0 - map_size.x * 0.3, map_size.y * 1.3)]

###############################################################################

func _ready():
	
	randomize()
	
	# Establish array "empty_tiles" of all possible tiles.
	for x in range(map_size.x):
		for y in range(map_size.y):
			empty_tiles.append(Vector2(x, y))
	
	# Sets designated number ("CELL_INST") of "tile_01" (terrain)
	# cells at random positions through out screen.
	for i in range(CELL_INST):
		set_cell(rand_range(RAD_MAX, map_size.x-RAD_MAX), \
		rand_range(RAD_MAX, map_size.y-RAD_MAX), 0)
	
	# Establish array "terr_tiles" of all designated "tile_01" tiles.
	terr_tiles = get_used_cells_by_id(0)
	
	# Uses function "quad_eq" to turn "empty_tiles" within radius of
	# instanced "terr_tiles" into "terr_tiles".
	for terr in terr_tiles:
		# For each instanced "terr_tile" establish a random radius
		# "circle" between "RAD_MIN" AND "RAD_MAX".
		var circle = rand_range(RAD_MIN, RAD_MAX)
		for empty in empty_tiles:
			if _quad_equate(terr, empty, circle):
				set_cell(empty.x, empty.y, 0)
	
	# Updates arrays "terr_tiles" and "empty_tiles".
	terr_tiles = get_used_cells_by_id(0)
	for each in terr_tiles:
		empty_tiles.erase(each)
	
	# Convert "border_corners_map" to global coordinates.  Then create the
	# world border collision.
	for each in border_corners_map:
		border_corners_world.append(map_to_world(each))
	$Perimeter/Collision.set_polygon(border_corners_world)
	

###############################################################################
###############################################################################

#func _process(delta):
#	pass

###############################################################################
###############################################################################
###############################################################################

"""
Signal from:
	- self
Parameters:
	- c = Center point of circle, in "array" type as "x, y"
		coordinates.
	- p = Point on circumference of circle with center point
		"c", in "array" type as "x, y" coordinates.
	- r = Designated radius of circle, in "int" type.
Output:
	Uses quadratic equation to determine if the distance
	between "c" and "p" is less than "r".  If so the
	return is "bool - true", if not return is "bool -
	false".
"""
func _quad_equate(c, p, r):
	return pow((c[0]-p[0]),2) + pow((c[1]-p[1]),2) <= pow(r,2)

"""
Signal from:
	- $bullet_01
Parameters:
	- pos = An array of Vector2s of positions from
		/root/Main/bullet_01/bullet_pos_left (& right).
Output:
	Resets the terrain tiles from "pos" to "-1".
"""
func _terrain_collide(pos):
	for each in pos:
		set_cellv(world_to_map(each), -1)
