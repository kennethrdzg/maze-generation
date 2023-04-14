extends TileMap

const room_size: int = 4

var room_width: int
var room_height: int

var stack: Array[Vector2i] = []
var visited_rooms: Array[Array] = []

var wait_time = 1

enum {
	BLACK, 
	WHITE
}

signal maze_finished
signal maze_cleared

@onready var speed_slider: HSlider = get_node("UI/HBoxContainer/Panel2/CenterContainer/HBoxContainer/HSlider")
@onready var reset_button: Button = get_node("UI/HBoxContainer/Button")

func _ready():
	room_width = ProjectSettings.get("display/window/size/viewport_width") / cell_quadrant_size / room_size
	room_height = ProjectSettings.get("display/window/size/viewport_height") / cell_quadrant_size / room_size
	build_maze()

func build_room(room: Vector2i): 
	var xx = room.x
	var yy = room.y
	for i in range(4): 
		for j in range(4): 
			if get_cell_source_id(0, Vector2i(xx * 4 + i, yy * 4 + j)) != -1: 
				continue
			if i == 0 or i == 3 or j == 0 or j == 3: 
				set_cell(0, Vector2i(xx * 4 + i, yy * 4 + j), 0, Vector2i(BLACK, 0))
			else: 
				set_cell(0, Vector2i(xx * 4 + i, yy * 4 + j), 0, Vector2i(WHITE, 0))
				
func get_neighbors(room: Vector2i) -> Array[Vector2i]: 
	var neighbors: Array[Vector2i] = []
	var xx = room.x
	var yy = room.y
	if xx > 0 and not visited_rooms[xx - 1][yy]: 
		neighbors.append(Vector2i(xx - 1, yy))
	if xx < room_width - 1 and not visited_rooms[xx + 1][yy]: 
		neighbors.append(Vector2i(xx + 1, yy))
	if yy > 0 and not visited_rooms[xx][yy - 1]: 
		neighbors.append(Vector2i(xx, yy - 1))
	if yy < room_height - 1 and not visited_rooms[xx][yy + 1]: 
		neighbors.append(Vector2i(xx, yy + 1))
	return neighbors
	
func update_room(room: Vector2i, neighbor: Vector2i): 
	var xx = room.x
	var yy = room.y
	if neighbor.x < room.x:
		set_cell(0, Vector2i(xx * 4, yy * 4 + 1), 0, Vector2i(WHITE, 0))
		set_cell(0, Vector2i(xx * 4, yy * 4 + 2), 0, Vector2i(WHITE, 0))
		set_cell(0, Vector2i(xx * 4 - 1, yy * 4 + 1), 0, Vector2i(WHITE, 0))
		set_cell(0, Vector2i(xx * 4 - 1, yy * 4 + 2), 0, Vector2i(WHITE, 0))
	if neighbor.x > room.x: 
		set_cell(0, Vector2i(xx * 4 + 3, yy * 4 + 1), 0, Vector2i(WHITE, 0))
		set_cell(0, Vector2i(xx * 4 + 3, yy * 4 + 2), 0, Vector2i(WHITE, 0))
		set_cell(0, Vector2i(xx * 4 + 4, yy * 4 + 1), 0, Vector2i(WHITE, 0))
		set_cell(0, Vector2i(xx * 4 + 4, yy * 4 + 2), 0, Vector2i(WHITE, 0))
	if neighbor.y < room.y: 
		set_cell(0, Vector2i(xx * 4 + 1, yy * 4), 0, Vector2i(WHITE, 0))
		set_cell(0, Vector2i(xx * 4 + 2, yy * 4), 0, Vector2i(WHITE, 0))
		set_cell(0, Vector2i(xx * 4 + 1, yy * 4 - 1), 0, Vector2i(WHITE, 0))
		set_cell(0, Vector2i(xx * 4 + 2, yy * 4 - 1), 0, Vector2i(WHITE, 0))
	if neighbor.y > room.y: 
		set_cell(0, Vector2i(xx * 4 + 1, yy * 4 + 3), 0, Vector2i(WHITE, 0))
		set_cell(0, Vector2i(xx * 4 + 2, yy * 4 + 3), 0, Vector2i(WHITE, 0))
		set_cell(0, Vector2i(xx * 4 + 1, yy * 4 + 4), 0, Vector2i(WHITE, 0))
		set_cell(0, Vector2i(xx * 4 + 2, yy * 4 + 4), 0, Vector2i(WHITE, 0))

func build_maze(): 
	for i in range(room_width): 
		visited_rooms.append([])
		for j in range(room_height): 
			visited_rooms[i].append(false)
	var start_room: Vector2i = Vector2i(randi_range(0, room_width - 1), randi_range(0, room_height - 1))
	stack.append(start_room)
	var count = 0
	while stack.size() > 0: 
		var current_room: Vector2i = stack.back()
		count += 1
		var xx = current_room.x
		var yy = current_room.y
		if not visited_rooms[xx][yy]: 
			build_room(current_room)
			visited_rooms[xx][yy] = true
			await  get_tree().create_timer(wait_time).timeout
		var neighbors = get_neighbors(current_room)
		if neighbors.size() > 0: 
			var neighbor = neighbors.pick_random()
			update_room(current_room, neighbor)
			stack.append(neighbor)
		else: 
			stack.pop_back()
	emit_signal("maze_finished")
		#if count > 3: 
		#	break
func _on_maze_finished():
	reset_button.disabled = false

func clear_maze(): 
	visited_rooms.clear()
	for i in range(room_width * 4): 
		for j in range(room_height * 4): 
			set_cell(0, Vector2i(i, j), -1)
	emit_signal("maze_cleared")

func _on_button_pressed():
	clear_maze()
	reset_button.disabled = true


func _on_maze_cleared():
	build_maze()


func _on_h_slider_value_changed(value):
	wait_time = 1 - value


func _on_exit_button_pressed():
	get_tree().change_scene_to_file("res://Menus/start_menu.tscn")
