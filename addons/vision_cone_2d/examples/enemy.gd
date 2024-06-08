extends CharacterBody2D

@export var vision_renderer: Polygon2D
@export var alert_color: Color

@export_group("Rotation")
@export var is_rotating = false
@export var rotation_speed = 0.1
@export var rotation_angle = 90

@export_group("Movement")
@export var move_on_path: PathFollow2D
@export var movement_speed = 0.1
@onready var pos_start = position.x

@onready var original_color = vision_renderer.color if vision_renderer else Color.WHITE
@onready var rot_start = rotation

@onready var player = get_parent().get_node("Player")
	
@export var is_alerted = false
@export var is_searching = false

@export var speed = 100
var player_position
var target_position

func _on_vision_cone_area_body_entered(body: Node2D) -> void:
	print("%s is seeing %s" % [self, body])
	vision_renderer.color = alert_color
	is_alerted = true
	is_searching = true


func _on_vision_cone_area_body_exited(body: Node2D) -> void:
	print("%s stopped seeing %s" % [self, body])
	vision_renderer.color = original_color
	is_alerted = false

func _physics_process(delta: float) -> void:
	if is_rotating:
		rotation = rot_start + sin(Time.get_ticks_msec()/1000. * rotation_speed) * deg_to_rad(rotation_angle/2.)
	if move_on_path:
		move_on_path.progress += movement_speed
		global_position = move_on_path.position
		rotation = move_on_path.rotation
	if is_alerted:
		is_rotating = false
		player_position = player.position
		target_position = (player_position - position).normalized()
	if is_searching:
		if position.distance_to(player_position) > 3:
			print("cherche")
			velocity = target_position * speed
			move_and_slide()
			look_at(player_position)
			is_rotating = false
		else:
			print("Idle")
			is_alerted = false
			is_searching = false
			is_rotating = true
