extends VehicleBody3D

var maxSteer = 0.8
var enginePower = 300
@onready var boost_timer: Timer = $BoostTimer
@onready var drift_timer: Timer = $DriftTimer
@onready var camera_3d: Camera3D = $CameraHolder/Camera3D
var isDrifting = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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


func _on_boost_timer_timeout() -> void:
	enginePower = 300
	camera_3d.fov = 75

func _on_drift_timer_timeout() -> void:
	if isDrifting:
		enginePower = 600
		boost_timer.start()
		camera_3d.fov = 90
		isDrifting = false
		print("Whoosh")
