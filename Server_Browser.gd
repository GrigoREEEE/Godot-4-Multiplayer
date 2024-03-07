extends Control
signal found_sever
signal server_removed

var broadcast_timer : Timer
var broadcaster : PacketPeerUDP
var listener : PacketPeerUDP

var room_info : Dictionary = {"name": "name", "player_count": 0}
@export var listen_port = 1234
@export var broadcast_port = 2345
@export var broadcast_adress : String = "10.0.0.255"
# Called when the node enters the scene tree for the first time.
func _ready():
	broadcast_timer = $broadcast_timer
	setup()

func set_up_broadcast(name):
	room_info.name = name
	room_info.player_count = GameManager.players.size()
	
	broadcaster = PacketPeerUDP.new()
	broadcaster.set_broadcast_enabled(true)
	broadcaster.set_dest_address(broadcast_adress, listen_port)
	
	var ok = broadcaster.bind(broadcast_port)
	
	if ok == OK:
		print("Bound to Broadcast Port " + str(broadcast_port) + " Successful!")
	else:
		print("Fail to bound to Broadcast Port!")
	broadcast_timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if listener.get_available_packet_count() > 0:
		var server_ip = listener.get_packet_ip()
		var server_port = listener.get_packet_port()
		var bytes = listener.get_packet()
		var data = bytes.get_string_from_ascii()
		var room_info = JSON.parse_string(data)
		print("Server IP: " + server_ip + "\n Server IP: " + str(server_port) + "\n Room Info:" + room_info)

func _on_broadcast_timer_timeout():
	print("Broadcasting Game!")
	room_info.player_count = GameManager.players.size()
	var data = JSON.stringify(room_info)
	var packet = data.to_ascii_buffer()
	broadcaster.put_packet(packet)
	
	pass # Replace with function body.

func cleanup():
	listener.clsoe()
	$broadcast_timer.stop()
	if broadcaster != null:
		broadcaster.close()
		
func setup():
	listener = PacketPeerUDP.new()
	var ok = listener.bind(listen_port)
	if ok == OK:
		print("Bound to Listen Port " + str(listen_port) + " Successful!")
	else:
		print("Fail to bound to Listen Port!")

func exit_tree():
	cleanup()
