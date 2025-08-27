extends Node3D

var maxSteer
var enginePower
@onready var boost_timer: Timer = $BoostTimer
@onready var drift_timer: Timer = $DriftTimer
@onready var camera_3d: Camera3D = $Holder/CameraHolder/Camera3D
@onready var holder: Node3D = $Holder
@onready var player_input: MultiplayerSynchronizer = $PlayerInput

var isDrifting = false
var VehicleType
var vehicle
@export var steering:float
@export var engine_force:float
@export var stats:VehicleStats


@export var player := 1 :
	set(id):
		player = id
		# Give authority over the player input to the appropriate peer.
		$PlayerInput.set_multiplayer_authority(id)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stats = load("res://Stats/Car.tres")
	maxSteer = stats.maxSteer
	enginePower = stats.enginePower
	VehicleType = stats.vehicleType
	vehicle = VehicleType.instantiate()
	add_child(vehicle)
	if player == multiplayer.get_unique_id():
		$Holder/CameraHolder/Camera3D.current = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if vehicle != null:
		vehicle.engine_force = engine_force
		vehicle.steering = steering
		holder.global_transform = vehicle.global_transform
	if Input.is_action_pressed("Drift") and !isDrifting and steering != 0 and engine_force > 0:
		drift_timer.start()
		isDrifting = true
	if isDrifting and Input.is_action_just_released("Drift"):
		isDrifting = false
	if isDrifting:
		maxSteer = 0.5
	else:
		maxSteer = 0.8
	steering = move_toward(steering, player_input.S_Input * maxSteer, delta * 2.5)
	engine_force = player_input.EF_Input * enginePower


func _on_boost_timer_timeout() -> void:
	enginePower = 300
	camera_3d.fov = 75

func _on_drift_timer_timeout() -> void:
	if isDrifting:
		enginePower = 1200
		boost_timer.start()
		camera_3d.fov = 90
		isDrifting = false
		print("Whoosh")
