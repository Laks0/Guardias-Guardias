extends Node2D

export (Texture) var Move

var sel = false

func mouse_in(pos,w,h):
	var mouse = get_global_mouse_position()
	return mouse.x >= pos.x and mouse.y >= pos.y and mouse.x <= pos.x + w and mouse.y <= pos.y + h

func selable(f,t):
	if t.x >= f.x - 1 and t.x <= f.x + 1 and f.y == t.y:
		return true
	if t.y >= f.y - 1 and t.y <= f.y + 1 and f.x == t.x:
		return true
	return false

func set_up(pos,team):
	position = pos
	
	add_to_group(str(team))
	if team == 0:
		modulate = Color(.2,.2,.2)
	elif team == 1:
		modulate = Color(1,0,0)
	
	return 2

func fill():
	$Texture.value = $Texture.max_value

func empty():
	$Texture.value = 1

func pass_turn(t):
	if is_in_group(str(t)):
		$Texture.value += 1

func _process(delta):
	var Game = get_tree().get_root().get_node("Game")
	var mouse = get_global_mouse_position()
	var click = Input.is_action_just_pressed("Click")
	
	if sel:
		if click:
			if selable(Game.world_to_map(position),Game.world_to_map(mouse)):
				Game.select(self)
				sel = false
				remove_temp()
			else:
				sel = false
				remove_temp()
	
	if mouse_in(position,64,64) and click and $Texture.value >= $Texture.max_value and is_in_group(str(Game.turn)):
		new_sel()
		sel = true

func new_sel():
	var Game = get_tree().get_root().get_node("Game")
	#display
	for d in range(0,4):
		var s = Sprite.new()
		s.texture = Move
		s.modulate = Color(.1,.1,1,.3)
		if d == 0:
			s.position = Vector2(32-64,32)
		if d == 1:
			s.position = Vector2(32+64,32)
		if d == 2:
			s.position = Vector2(32,32-64)
		if d == 3:
			s.position = Vector2(32,32+64)
		
		s.z_index = 1
		
		var to = Game.world_to_map(s.position) + Game.world_to_map(position)
		if to.x <= len(Game.grid)-1 and to.y <= len(Game.grid[1])-1:
			if Game.grid[to.x][to.y] == 0:
				$Temp.add_child(s)

func remove_temp():
	for c in $Temp.get_children():
		$Temp.remove_child(c)