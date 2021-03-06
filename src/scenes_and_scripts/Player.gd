extends KinematicBody2D

signal health_changed
signal player_killed

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Read.")
	life_points = 6

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

const gravity = 980
export (int) var speed = 100
export (int) var jump_power = -350
export (int) var jump_extra = -500
var on_glide = false
export (int) var glide = 30

var velocity = Vector2()

var current_color : String = "blue"
var life_points : int

func life_change(hit : int):
	life_points += hit
	if life_points <= 0:
		print("Dead")
		emit_signal("player_killed")
	elif life_points > 6:
		life_points = 6
	print("life_points " + String(life_points))
	emit_signal("health_changed", life_points)

func get_input(delta):
	if is_on_floor():
		on_glide = false
		velocity.x = 0
	if Input.is_action_pressed("right"):
		velocity.x = speed
		if is_on_floor():
			$Icon.play(current_color + "_walk")
		$Icon.flip_h = false
	elif Input.is_action_pressed("left"):
		velocity.x = -speed
		if is_on_floor():
			$Icon.play(current_color + "_walk")
		$Icon.flip_h = true
	else:
		$Icon.play(current_color + "_idle")
	if Input.is_action_just_pressed("jump"):
		$Icon.play(current_color + "_idle")
		if is_on_floor():
			velocity.y = jump_power
	if Input.is_action_pressed("jump"):
		if velocity.y < 0:
			velocity.y += delta * jump_extra
		elif (velocity.y >= 0) and (not on_glide):
			on_glide = true
	if Input.is_action_just_released("jump"):
		if on_glide:
			on_glide = false
	if Input.is_action_just_pressed("turn_light_red"):
		set_color("red")
	if Input.is_action_just_pressed("turn_light_yellow"):
		set_color("yellow")
	if Input.is_action_just_pressed("turn_light_blue"):
		set_color("blue")
	if Input.is_action_just_pressed("cycle_light_color"):
		life_change(-1)
		match current_color:
			"red":
				set_color("yellow")
			"yellow":
				set_color("blue")
			"blue":
				set_color("red")

func _physics_process(delta):
	get_input(delta)
	if on_glide:
		velocity.y = glide
	else:
		velocity.y += delta * gravity
	velocity = move_and_slide(velocity, Vector2(0,-1))


func _on_LightRange_body_entered(body):
	if "Enemy" in body.name:
		print(body.name + " found.")
		body.in_range(self, true)
	if "ColorBlock" in body.name:
		print(body.name + " found.")
		body.in_range(self, true)


func _on_LightRange_body_exited(body):
	if "Enemy" in body.name:
		print(body.name + " leaved.")
		body.in_range(self, false)
	if "ColorBlock" in body.name:
		print(body.name + " leaved.")
		body.in_range(self, false)

func set_color(color : String):
	match color:
		"red":
			$Light.set_color(Color(1,0,0,1))
		"yellow":
			$Light.set_color(Color(0.5,0.5,0,1))
		"blue":
			$Light.set_color(Color(0,0,1,1))
	current_color = color

func compare_color(color : String):
	return color == current_color
