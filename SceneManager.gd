extends Node2D

@export var PlayerScene : PackedScene
var player_names = []
var player_order_ids = []
var current_choice = null
# Called when the node enters the scene tree for the first time.
func _ready():
	var index = 0
	for i in GameManager.players:
		var current_player = PlayerScene.instantiate()
		current_player.name = str(GameManager.players[i].id)
		player_names.append(GameManager.players[i].name)
		player_order_ids.append(GameManager.players[i].id)
		add_child(current_player)
		for spawn in get_tree().get_nodes_in_group("PlayerSpawnPoint"):
			if spawn.name == str(index):
				current_player.global_position = spawn.global_position
		index += 1
	print(player_names)
	print(player_order_ids)
	print(GameManager.players)
	$Control/Label.text = "Whose turn it is:\n" + player_names[min(1,GameManager.order)] + "\n The order is " + str(min(1,GameManager.order))
	show_screen.rpc_id(player_order_ids[min(1,GameManager.order)])
	
	pass # Replace with function body.
	
@rpc("any_peer")
func show_screen():
	$Control.show()

@rpc("any_peer")
func hide_screen():
	$Control.hide()

@rpc("any_peer")
func send_data(id, order):
	if !GameManager.player_choices.has(id):
		GameManager.player_choices[id] = {"choice" : current_choice}
		GameManager.order = order
	update_label()

@rpc("any_peer")
func finish_round():
	pass

func update_label():
	$Control/Label.text = "Whose turn it is:\n" + player_names[min(1,GameManager.order)] + "\n The order is " + str(GameManager.order)

func _on_rock_pressed():
	print(player_names[min(1,GameManager.order)] + " choose rock!")
	current_choice = "rock"

func _on_paper_pressed():
	print(player_names[min(1,GameManager.order)] + " choose paper!") # Replace with function body.
	current_choice = "paper"

func _on_scissors_pressed():
	print(player_names[min(1,GameManager.order)] + " choose scissors!") # Replace with function body.
	current_choice = "scissors"
	

func _on_submit_pressed():
	if (current_choice != null):
		# Updating your own screen
		if (GameManager.order < 2):
			GameManager.order += 1
			update_label()
			$Control.hide()
			#########################
			print(player_names[min(1,GameManager.order)] + " confirmed his choice!")
			send_data.rpc_id(player_order_ids[min(1,GameManager.order)], player_order_ids[min(1,GameManager.order)], min(1,GameManager.order))
			print("Done Sending Data!")
			print("Print Order is " + str(min(1,GameManager.order)))
			update_label()
			show_screen.rpc_id(player_order_ids[min(1,GameManager.order)])
			#hide_screen.rpc_id(player_order_ids[(GameManager.order-1)])
		else:
			print("ENDING THE GAME")
			print(GameManager.player_choices)
			pass
