extends KinematicBody2D

# Rate of ship rotation.
export var ROT_SPEED = 3
# Rate of ship acceleration.
export var THRUST = 150
# Top speed.
export var VEL_MAX = 200
# Drag applied upon collision bounce.
export var ELASTICITY = 0.25

# Creates variable referencing "bullet_01" scene.
onready var Bullet01 = preload('res://scenes/Bullet01.tscn')

# Establish working variables.
var acc = Vector2()
var vel = Vector2()
var pos = Vector2()
var rot = 0
var world_size = Vector2()

###############################################################################

func _ready():
	# Sets starting point for ship at center of screen.
	world_size = get_node('/root/Main/Map').map_size
	pos = world_size * 0.1 # ???
	set_position(pos)

###############################################################################
###############################################################################

func _physics_process(delta):
	
	# Key inputs to rotate ship.
	if Input.is_action_pressed('ui_left'):
		rot -= ROT_SPEED * delta
	elif Input.is_action_pressed('ui_right'):
		rot += ROT_SPEED * delta
	
	# Key inputs to adjust motion of ship.
	if Input.is_action_pressed('ui_up'):
		acc = Vector2(-THRUST, 0).rotated(rot)
	elif Input.is_action_pressed('ui_down'):
		acc = Vector2(THRUST/2, 0).rotated(rot)
	# Else statement needed to cancel acceleration increase when
	# key is depressed.
	else:
		acc = Vector2(0, 0)
	
	# Key input to shoot bullet.
	if Input.is_action_pressed('ui_select'):
		# Stalls bullet shoot if last bullet shoot was within "Wait Time" of 
		# "$ship_bullet_timer".
		if $BulletTimer.get_time_left() == 0:
			_shoot()
	
	# Use "clamped" method to apply top speed.
	vel = vel.clamped(VEL_MAX)
	vel += acc * delta
	
	# Apply adjustments of rotation and motion to ship.
	set_rotation(rot - PI/2)
	
	var collision = move_and_collide(vel * delta)
	
	# Detect collision with terrain.
	if collision:
		vel = vel.bounce(collision.normal) * ELASTICITY
	

###############################################################################
###############################################################################
###############################################################################

"""
Signal from:
	- self
Output:
	"ship" shoots "bullet_01".
"""
func _shoot():
	# Start the timer of the bullet's life cycle.
	$BulletTimer.start()
	# Creates the bullet.
	var b = Bullet01.instance()
	# Makes the created bullet a child of "ship_bullet_container".
	$BulletContainer.add_child(b)
	# Sends signal to bullet to start location and trajectory.
	b._start_at(get_rotation(), $BulletSpawn.global_position)
