extends Node3D

var maxSteer
var enginePower
@onready var boost_timer: Timer = $BoostTimer
@onready var drift_timer: Timer = $DriftTimer
@onready var holder: Node3D = $Holder
@onready var cam: Camera3D = $Holder/CameraHolder/Camera3D


var isDrifting = false
var VehicleType : PackedScene
var vehicle
@export var steering:float
@export var engine_force:float
@export var stats:VehicleStats

@onready var ball = preload("res://Scenes/ball.tscn")

var shoot_res
		# Give authority over the player input to the appropriate peer.
# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	maxSteer = stats.maxSteer
	enginePower = stats.enginePower
	VehicleType = stats.vehicleType
	spawn_vehicle()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if vehicle != null:
		vehicle.engine_force = engine_force
		vehicle.steering = steering
		holder.global_position = vehicle.global_position
		holder.rotation.y = vehicle.rotation.y
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("Flip"):
			vehicle.rotation.x = 0
			vehicle.rotation.z = 0
		if Input.is_action_pressed("Drift") and !isDrifting and steering != 0 and engine_force > 0:
			drift_timer.start()
			isDrifting = true
		if isDrifting and Input.is_action_just_released("Drift"):
			isDrifting = false
		if isDrifting:
			maxSteer = 0.5
		else:
			maxSteer = 0.8
		steering = move_toward(steering, Input.get_axis("Right", "Left") * maxSteer, delta * 2.5)
		engine_force = Input.get_axis("Backward", "Forward") * enginePower
		if Input.is_action_just_pressed("Shoot"):
			shoot()
		cam.current = is_multiplayer_authority()

func _on_boost_timer_timeout() -> void:
	enginePower = 300
	cam.fov = 75

func _on_drift_timer_timeout() -> void:
	if isDrifting:
		enginePower = 1200
		boost_timer.start()
		cam.fov = 90
		isDrifting = false
		print("Whoosh")
		
func spawn_vehicle():
	vehicle = VehicleType.instantiate()
	add_child(vehicle)

func shoot():
		var mouse_pos = get_viewport().get_mouse_position()
		var ray_length = 100
		var from = cam.project_ray_origin(mouse_pos)
		var to = from + cam.project_ray_normal(mouse_pos) * ray_length
		var space = get_world_3d().direct_space_state
		var ray_query = PhysicsRayQueryParameters3D.new()
		ray_query.from = from
		ray_query.to = to
		shoot_res = space.intersect_ray(ray_query)
		print(shoot_res)
		
		if !shoot_res.is_empty():
			rpc_shoot.rpc(shoot_res)

@rpc("call_local")
func rpc_shoot(res):
	var instance = ball.instantiate()
	instance.position = res["position"]
	$"../../".add_child(instance)
