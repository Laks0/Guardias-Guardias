extends KinematicBody2D

export (Texture) var movement

var turn = true
var sel = false

var oRad = 2
var rad = 0

var dir = Vector2(1,0)

var click = false

func mouse_in(pos,w,h):
	var mouse = get_global_mouse_position()
	return mouse.x >= pos.x and mouse.y >= pos.y and mouse.x <= pos.x + w and mouse.y <= pos.y + h

func movable(f,t,r):
	if f.x == t.x and t.y >= f.y-r and t.y <= f.y + r:
		return true
	if f.y == t.y and t.x >= f.x-r and t.x <= f.x + r:
		return true
	return false

func set_up(pos,team):
	add_to_group(str(team))
	position = pos
	
	$AnimatedSprite.animation = "D3"
	
	if team == 1:
		$AnimatedSprite.modulate = Color(1,0,0)
		dir = Vector2(-1,0)
		$AnimatedSprite.animation = "D1"
	else:
		$AnimatedSprite.modulate = Color(.2,.2,.2)
	
	return 1

func _process(delta):
	click = Input.is_action_just_pressed("Click")
	var mouse = get_global_mouse_position()
	var Game = get_tree().get_root().get_node("Game")
	
	if sel:
		if click:
			var to = Game.world_to_map(mouse)
			var from = Game.world_to_map(position)
			
			if mouse_in(position,64,64):
				change_dir()
			
			if movable(from,to,rad):
				if Game.grid[to.x][to.y] == 0:
					rad -= abs(to.x-from.x) + abs(to.y-from.y)
					remove_temp()
					new_sel()
					
					position = to * 64
					Game.grid[to.x][to.y] = 1
					Game.grid[from.x][from.y] = 0
					Game.sel = false
					Game.get_node("Sprite").visible = false
	
	if click and turn:# and rad > 0:
		sel = mouse_in(position,64,64)
		remove_temp()
		new_sel()
	
#	if rad <= 0: 
#		sel = false
	
	if not sel:
		remove_temp()

func pass_turn(t):
	turn = not turn
	sel = false
	rad = oRad

func remove_temp():
	for s in $Temp.get_children():
		$Temp.remove_child(s)

func new_sel():
	var Game = get_tree().get_root().get_node("Game")
	#display
	for d in range(0,4):
		for r in range(1,rad+1):
			var s = Sprite.new()
			s.texture = movement
			s.modulate = Color(.1,.1,1,.3)
			if d == 0:
				s.position = Vector2(32-r*64,32)
			if d == 1:
				s.position = Vector2(32+r*64,32)
			if d == 2:
				s.position = Vector2(32,32-r*64)
			if d == 3:
				s.position = Vector2(32,32+r*64)
			
			s.z_index = 1
			
			var to = Game.world_to_map(s.position) + Game.world_to_map(position)
			if to.x <= len(Game.grid)-1 and to.y <= len(Game.grid[1])-1:
				if Game.grid[to.x][to.y] == 0:
					$Temp.add_child(s)

func change_dir():
	if dir == Vector2(-1,0):
		dir = Vector2(0,-1)
		$AnimatedSprite.animation = "D2"
	elif dir == Vector2(0,-1):
		dir = Vector2(1,0)
		$AnimatedSprite.animation = "D3"
	elif dir == Vector2(1,0):
		dir = Vector2(0,1)
		$AnimatedSprite.animation = "D4"
	elif dir == Vector2(0,1):
		dir = Vector2(-1,0)
		$AnimatedSprite.animation = "D1"