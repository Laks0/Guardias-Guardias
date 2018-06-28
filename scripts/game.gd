extends TileMap

export (PackedScene) var Melee
export (PackedScene) var Guard
export (PackedScene) var Fort

var players = []
var turn = 0

var frt

var sel = false
var celSeld = 0

const GRID_S = 64
var grid = []

func _on_Pass_turn_pressed():
	for n in self.get_children():
		if n.is_in_group("Unit") or n.is_in_group("Fort"):
			n.pass_turn(turn)
	
	if turn == 0:
		turn = 1
		$Turn.modulate = Color(1,0,0)
	else:
		turn = 0
		$Turn.modulate = Color(0,0,0)
	sel = false
	
	$Turn.text = "Player " + str(turn) + "'s turn"

func _on_Guard_pressed():
	var g = Melee.instance()
	add_child(g)
	grid[celSeld.x][celSeld.y] = g.set_up(celSeld*GRID_S,turn)
	sel = false
	frt.empty()

func _on_RealGuard_pressed():
	var g = Guard.instance()
	add_child(g)
	grid[celSeld.x][celSeld.y] = g.set_up(celSeld*GRID_S,turn)
	sel = false
	frt.empty()

func _on_Fort_pressed():
	var f = Fort.instance()
	add_child(f)
	grid[celSeld.x][celSeld.y] = f.set_up(celSeld*GRID_S,turn)
	sel = false
	frt.empty()

func _on_TextureButton_pressed():
	sel = false
	$Sprite.visible = false

func _ready():
	for i in range(0, 1):
		var p = [25]
		players.append(p)
	
	for x in range(1,floor(1280/GRID_S+1)):
		var r = []
		for y in range(1,floor(720/GRID_S+2)):
			r.append(0)
		grid.append(r)
	
	for i in range(0,2):
		var f = Fort.instance()
		var pos = Vector2(0,len(grid[1])/2-1)
		if i == 1:
			pos.x = len(grid) - 1
		grid[pos.x][pos.y] = f.set_up(pos*GRID_S,i)
		add_child(f)
		f.fill()

func _process(delta):
	$Sprite.visible = sel

func select(from):
	frt = from
	var mouse = get_global_mouse_position()
	celSeld = world_to_map(get_global_mouse_position())
	if grid[celSeld.x][celSeld.y] == 0:
		sel = true
		$Sprite.position = celSeld * GRID_S
		for s in $Sprite.get_children():
			s.position.x = 74
			if s.position.x + $Sprite.position.x > 1280 - 200:
				s.position.x = -210