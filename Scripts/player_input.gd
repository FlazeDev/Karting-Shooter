extends MultiplayerSynchronizer

@export var EF_Input = 0
@export var S_Input = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
func _enter_tree() -> void:
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	S_Input =  Input.get_axis("Right", "Left")
	EF_Input = Input.get_axis("Backward", "Forward")
