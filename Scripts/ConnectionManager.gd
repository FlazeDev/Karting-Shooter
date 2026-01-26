extends Node

var peer := NodeTunnelPeer.new()
const PLAYER = preload("res://Scenes/vehicle.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	peer.connect_to_relay("eu_central.nodetunnel.io:8080", "2xuocgq5rz83t71")
	multiplayer.multiplayer_peer = peer
	
	await peer.authenticated
	print("authenticated!")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_host_pressed() -> void:
	peer.host_room(true, "")
	
	await peer.room_connected
	DisplayServer.clipboard_set(peer.room_id)
	$"../CanvasLayer".hide()
	
	multiplayer.peer_connected.connect(
		func(pid):
			print("Player " + str(pid) + " has joined the game")
			add_player(pid)
	)
	add_player()
	

func _on_join_pressed() -> void:
	peer.join_room($"../CanvasLayer/Join ID".text)
	
	await peer.room_connected
	$"../CanvasLayer".hide()

func exit_game(pid):
	multiplayer.peer_disconnected.connect(del_player)
	del_player(pid)

func add_player(pid = 1):
	var player  = PLAYER.instantiate()
	player.name = str(pid)
	$"../Players".call_deferred("add_child", player)
	

	
func del_player(pid):
	rpc("_del_player", pid)

@rpc("any_peer", "call_local")
func _del_player(pid):
	$"../Players".get_node(str(pid)).queue_free()
