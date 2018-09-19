extends Area2D

export var SPEED = 200

onready var Map = get_node('/root/Main/Map')

var vel = Vector2()

###############################################################################

func _ready():
	pass

###############################################################################
###############################################################################

func _process(delta):
	position += vel * delta

###############################################################################
###############################################################################
###############################################################################

"""
Signal from:
	- /root/Main/Ship
Parameters:
	- dir = A Vector2 of direction.
	- pos + A Vector2 of global position.
Output:
	Sets bullet's position, direction, and velocity.
"""
func _start_at(dir, pos):
	# Set bullet's position and direction.
	set_position(pos)
	set_rotation(dir)
	# Set bullet's velocity.
	vel = Vector2(SPEED, 0).rotated(dir - PI/2)

"""
Signal from:
	- $bullet_01_timer
Output:
	Bullet's lifetime ends.
"""
func _on_bullet_01_timer_timeout():
	queue_free()

"""
Signal from:
	- self
Parameters:
	- body = NA
Output:
	Bullet sends signal to "/root/Main._terrain_collide" as array of
	bullet_pos_right (& left) positions. Function then deletes bullet.
"""
func _on_bullet_01_body_entered(body):
	# Find function "_terrain_collide" through node tree and sends parameters
	# from bullet positions.
	Map._terrain_collide([$Collision/PosRight.global_position, \
			$Collision/PosLeft.global_position])
	# Delete bullet.
	queue_free()