extends KinematicBody2D

export (Texture) var movement

var turn = true
var sel = false

var oRad = 3
var rad = 0

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
	
	if team == 1:
		$AnimatedSprite.modulate = Color(1,0,0)
		$AnimatedSprite.scale.x = -1
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
				else:
					var dir = Vector2(-1,0)
					if to.y < from.y:
						dir = Vector2(0,-1)
					if to.y > from.y:
						dir = Vector2(0,1)
					if to.x > from.x:
						dir = Vector2(1,0)
					shoot(to,dir)
	
	if click and turn and rad > 0:
		sel = mouse_in(position,64,64)
		remove_temp()
		new_sel()
	
	if rad <= 0:
		sel = false
	
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
				if Game.grid[to.x][to.y] != 0:
					s.modulate = Color(1,1,0,.5)
				if Game.grid[to.x][to.y] != 3:
					$Temp.add_child(s)

func shoot(pos,d):
	var Game = get_tree().get_root().get_node("Game")
	var e
	var cpos = Game.world_to_map(position)
	var blocked = false
	var killed = false
	
	while cpos != pos:
		for c in Game.get_children():
			if c.is_in_group("Unit") and c.is_in_group(str(1-Game.turn)) and c.is_in_group("Guard") and c.position == Game.map_to_world(cpos) and !blocked:
				Game.remove_child(c)
				killed = true
				var gridPos = Game.world_to_map(c.position)
				Game.grid[gridPos.x][gridPos.y] = 0
				if c.dir == d * -1:
					blocked = true
					print("blocked")
					break
		cpos += d
	
	if !blocked:
		for c in Game.get_children():
			if c.is_in_group("Unit") or c.is_in_group("Fort"):
				if c.is_in_group(str(1-Game.turn)) and c.position == Game.map_to_world(pos):
					Game.remove_child(c)
					Game.grid[pos.x][pos.y] = 0
					killed = true
					if c.is_in_group("Fort"):
						Game.players[1-Game.turn] -= 1
	
	if killed:
		rad = 0