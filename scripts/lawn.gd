extends Node2D

@onready var hi_light = $hi_light
@onready var water_can = $watering_can
@onready var shovel = $shovel
@onready var compose = $compose
@onready var shooter_seed1 = $seed_slots/shooter_seed1
@onready var bloom_seed2 = $seed_slots/bloom_seed2
@onready var vine_seed3 = $seed_slots/vine_seed3
@onready var sun_value = $sun_value/Label
@onready var leaf_value = $leaf_value/Label
@onready var timer = $Timer
@onready var sun_timer = $sun_timer
@onready var cooldown_seed1 = $seed_slots/cooldown_bar_seed1/TextureProgressBar
@onready var cooldown_seed2 = $seed_slots/cooldown_bar_seed2/TextureProgressBar
@onready var cooldown_seed3 = $seed_slots/cooldown_bar_seed3/TextureProgressBar
@onready var cooldown_seed4 = $seed_slots/cooldown_bar_seed4/TextureProgressBar
@onready var cooldown_seed5 = $seed_slots/cooldown_bar_seed5/TextureProgressBar
@onready var cooldown_seed6 = $seed_slots/cooldown_bar_seed6/TextureProgressBar
@onready var speedx1 = $speedx1
@onready var speedx2 = $speedx2
@onready var speedx3 = $speedx3
@onready var speedx4 = $speedx4
@onready var score = $pausetext/score

var rng = RandomNumberGenerator.new()
var lawn_space = {}
var lawn_key_list = []
var current_seed = 0
var seed_list = [null, preload("res://scenes/pea_blaster.tscn"), preload("res://scenes/sun_bloom.tscn"), preload("res://scenes/vine_spike.tscn")]
var graft_num = 0
var current_graft = 0
var nothing = load("res://scenes/nothing.tscn").instantiate()
var graft_list = [nothing, nothing, nothing, nothing, nothing, nothing]
var water = false
var shove = false
var decom = false
var water_pos = Vector2(298, 22)
var shovel_pos = Vector2(348.29, 21)
var compose_pos = Vector2(396, 24)
var pos
var start_sun_time = 1
var particle = preload("res://scenes/particles_square.tscn")

func _ready():
	sun_value.text = str(global.sun_value)
	leaf_value.text = str(global.leaf_value)
	sun_timer.start()

func particle_effect(amount, ini_min, ini_max, gravity_y, z_in, spawn_pos, color):
	var particleee = particle.instantiate()
	particleee.get_child(0).color = color
	particleee.position = spawn_pos
	particleee.position.x += 16
	particleee.position.y += 14
	add_child(particleee)
	particleee.get_child(0).amount = amount
	particleee.get_child(0).emitting = true
	particleee.get_child(0).initial_velocity_min = ini_min
	particleee.get_child(0).initial_velocity_max = ini_max
	particleee.get_child(0).gravity.y = gravity_y
	particleee.get_child(0).z_index = z_in

func water_particle(x, y):
	var particleee = particle.instantiate()
	particleee.get_child(0).color = Color(0.4, 0.6, 0.7, 1)
	particleee.position = Vector2(x * 32, y * 32)
	particleee.position.x += 16
	add_child(particleee)
	particleee.get_child(0).amount = 8
	particleee.get_child(0).emitting = true
	particleee.get_child(0).initial_velocity_min = 10
	particleee.get_child(0).initial_velocity_max = 20
	particleee.get_child(0).direction.x = 0
	particleee.get_child(0).direction.y = 1
	particleee.get_child(0).gravity.y = 40
	particleee.get_child(0).explosiveness = 0
	particleee.get_child(0).z_index = 5

func enemy_spawning():
	var lane = rng.randi_range(1, 5)
	var pos_y
	match lane:
		1: pos_y = 199
		2: pos_y = 167
		3: pos_y = 135
		4: pos_y = 103
		5: pos_y = 71
	if rng.randf_range(0, 50000) < (global.danger_level):
		var slime = load("res://scenes/slime.tscn").instantiate()
		slime.position = Vector2(496, pos_y)
		add_child(slime)
		global.danger_level -= 1
	if global.slime_count > 10 and rng.randf_range(0, 50000) < (global.danger_level):
		for i in range(rng.randi_range(1, 5)):
			var fly = load("res://scenes/fly.tscn").instantiate()
			fly.position = Vector2(496 + rng.randi_range(-8, 30), pos_y)
			add_child(fly)
			global.danger_level -= 1
func water_func(event, x, y):
	if water and !event.pressed:
		if lawn_space.has(str(x)+str(y)) and lawn_space[str(x)+str(y)].state == 0:
			lawn_space[str(x)+str(y)].state = 1
			water_particle(x, y)
		water_can.position = water_pos
		water = false
		return
	if pos.x > 282 and pos.x < 319 and pos.y > 10 and pos.y < 38 and event.pressed and !water and !shove and !decom:
		water = true

func water_key_func(event):
	if (water and !event.pressed) or event.keycode != 87:
		water_can.position = water_pos
		water = false
		return
	if event.pressed and event.keycode == 87:
		water = true

func shovel_func(event):
	if shove and !event.pressed:
		shovel.position = shovel_pos
		shove = false
		shovel.z_index = 1
		return
	if pos.x > 331 and pos.x < 358 and pos.y > 9 and pos.y < 34 and event.pressed and !shove and !water and !decom:
		shovel.z_index += 1
		shove = true

func shovel_key_func(event):
	if (shove and !event.pressed) or event.keycode != 83:
		shovel.position = shovel_pos
		shove = false
		shovel.z_index = 1
		return
	if event.pressed and event.keycode == 83:
		shovel.z_index += 1
		shove = true

func decompose_func(event):
	if decom and !event.pressed:
		compose.position = compose_pos
		decom = false
		compose.z_index = 1
		return
	if pos.x > 382.5 and pos.x < 410.5 and pos.y > 12 and pos.y < 35 and event.pressed and !shove and !water and !decom:
		compose.z_index += 1
		decom = true

func decompose_key_func(event):
	if (decom and !event.pressed) or event.keycode != 68:
		compose.position = compose_pos
		decom = false
		compose.z_index = 1
		return
	if event.pressed and event.keycode == 68:
		compose.z_index += 1
		decom = true

func seed1_func(event):
	if !event.pressed:
		shooter_seed1.position = Vector2(80, 16)
		current_seed = 0
		shooter_seed1.z_index = 1
		return
	if pos.x > 64 and pos.x < 96 and pos.y > 0 and pos.y < 32 and event.pressed:
		shooter_seed1.z_index += 1
		current_seed = 1

func seed1_key_func(event):
	if (current_seed == 1 and !event.pressed) or event.keycode != 49:
		shooter_seed1.position = Vector2(80, 16)
		current_seed = 0
		shooter_seed1.z_index = 1
		return false
	if event.pressed and event.keycode == 49 and cooldown_seed1.value == 10000:
		shooter_seed1.z_index += 1
		current_seed = 1
		allbutone_slot_reset(1)
		return true

func seed2_func(event):
	if !event.pressed:
		bloom_seed2.position = Vector2(112, 16)
		current_seed = 0
		bloom_seed2.z_index = 1
		return
	if pos.x > 96 and pos.x < 128 and pos.y > 0 and pos.y < 32 and event.pressed:
		bloom_seed2.z_index += 1
		current_seed = 2

func seed2_key_func(event):
	if (current_seed == 2 and !event.pressed) or event.keycode != 50:
		bloom_seed2.position = Vector2(112, 16)
		current_seed = 0
		bloom_seed2.z_index = 1
		return false
	if event.pressed and event.keycode == 50 and cooldown_seed2.value == 10000:
		bloom_seed2.z_index += 1
		current_seed = 2
		allbutone_slot_reset(2)
		return true

func seed3_func(event):
	if !event.pressed:
		vine_seed3.position = Vector2(144, 16)
		current_seed = 0
		vine_seed3.z_index = 1
		return
	if pos.x > 128 and pos.x < 160 and pos.y > 0 and pos.y < 32 and event.pressed:
		vine_seed3.z_index += 1
		current_seed = 3

func seed3_key_func(event):
	if (current_seed == 3 and !event.pressed) or event.keycode != 51:
		vine_seed3.position = Vector2(144, 16)
		current_seed = 0
		vine_seed3.z_index = 1
		return false
	if event.pressed and event.keycode == 51 and cooldown_seed3.value == 10000:
		vine_seed3.z_index += 1
		current_seed = 3
		allbutone_slot_reset(3)
		return true

func graft1_func(event):
	if !event.pressed:
		graft_list[0].position = Vector2(80, 254)
		current_graft = 0
		graft_list[0].z_index = 0
		return
	if pos.x > 64 and pos.x < 96 and pos.y > 240 and pos.y < 270 and event.pressed:
		graft_list[0].z_index += 2
		current_graft = 1

func graft1_key_func(event):
	if (current_graft == 1 and !event.pressed) or event.keycode != 90:
		graft_list[0].position = Vector2(80, 254)
		current_graft = 0
		graft_list[0].z_index = 0
		return false
	if event.pressed and event.keycode == 90:
		graft_list[0].z_index += 2
		current_graft = 1
		allbutone_slot_reset(7)
		return true

func graft2_func(event):
	if !event.pressed:
		graft_list[1].position = Vector2(112, 254)
		current_graft = 0
		graft_list[1].z_index = 0
		return
	if pos.x > 96 and pos.x < 128 and pos.y > 240 and pos.y < 270 and event.pressed:
		graft_list[1].z_index += 2
		current_graft = 2

func graft2_key_func(event):
	if (current_graft == 2 and !event.pressed) or event.keycode != 88:
		graft_list[1].position = Vector2(112, 254)
		current_graft = 0
		graft_list[1].z_index = 0
		return false
	if event.pressed and event.keycode == 88:
		graft_list[1].z_index += 2
		current_graft = 2
		allbutone_slot_reset(8)
		return true

func graft3_func(event):
	if !event.pressed:
		graft_list[2].position = Vector2(144, 254)
		current_graft = 0
		graft_list[2].z_index = 0
		return
	if pos.x > 128 and pos.x < 160 and pos.y > 240 and pos.y < 270 and event.pressed:
		graft_list[2].z_index += 2
		current_graft = 3

func graft3_key_func(event):
	if (current_graft == 3 and !event.pressed) or event.keycode != 67:
		graft_list[2].position = Vector2(144, 254)
		current_graft = 0
		graft_list[2].z_index = 0
		return false
	if event.pressed and event.keycode == 67:
		graft_list[2].z_index += 2
		current_graft = 3
		allbutone_slot_reset(9)
		return true

func graft4_func(event):
	if !event.pressed:
		graft_list[3].position = Vector2(176, 254)
		current_graft = 0
		graft_list[3].z_index = 0
		return
	if pos.x > 160 and pos.x < 192 and pos.y > 240 and pos.y < 270 and event.pressed:
		graft_list[3].z_index += 2
		current_graft = 4

func graft4_key_func(event):
	if (current_graft == 4 and !event.pressed) or event.keycode != 86:
		graft_list[3].position = Vector2(176, 254)
		current_graft = 0
		graft_list[3].z_index = 0
		return false
	if event.pressed and event.keycode == 86:
		graft_list[3].z_index += 2
		current_graft = 4
		allbutone_slot_reset(10)
		return true

func graft5_func(event):
	if !event.pressed:
		graft_list[4].position = Vector2(208, 254)
		current_graft = 0
		graft_list[4].z_index = 0
		return
	if pos.x > 192 and pos.x < 224 and pos.y > 240 and pos.y < 270 and event.pressed:
		graft_list[4].z_index += 2
		current_graft = 5

func graft5_key_func(event):
	if (current_graft == 5 and !event.pressed) or event.keycode != 66:
		graft_list[4].position = Vector2(208, 254)
		current_graft = 0
		graft_list[4].z_index = 0
		return false
	if event.pressed and event.keycode == 66:
		graft_list[4].z_index += 2
		current_graft = 5
		allbutone_slot_reset(11)
		return true

func graft6_func(event):
	if !event.pressed:
		graft_list[5].position = Vector2(240, 254)
		current_graft = 0
		graft_list[5].z_index = 0
		return
	if pos.x > 224 and pos.x < 256 and pos.y > 240 and pos.y < 270 and event.pressed:
		graft_list[5].z_index += 2
		current_graft = 6

func graft6_key_func(event):
	if (current_graft == 6 and !event.pressed) or event.keycode != 78:
		graft_list[5].position = Vector2(240, 254)
		current_graft = 0
		graft_list[5].z_index = 0
		return false
	if event.pressed and event.keycode == 78:
		graft_list[5].z_index += 2
		current_graft = 6
		allbutone_slot_reset(12)
		return true

func allbutone_slot_reset(slot_button):
	if slot_button != 1:
		shooter_seed1.position = Vector2(80, 16)
		shooter_seed1.z_index = 1
	if slot_button != 2:
		bloom_seed2.position = Vector2(112, 16)
		bloom_seed2.z_index = 1
	if slot_button != 3:
		vine_seed3.position = Vector2(144, 16)
		vine_seed3.z_index = 1
	if slot_button != 4:
		pass
	if slot_button != 5:
		pass
	if slot_button != 6:
		pass
	if slot_button != 7:
		graft_list[0].position = Vector2(80, 254)
		graft_list[0].z_index = 1
	if slot_button != 8:
		graft_list[1].position = Vector2(112, 254)
		graft_list[1].z_index = 1
	if slot_button != 9:
		graft_list[2].position = Vector2(144, 254)
		graft_list[2].z_index = 1
	if slot_button != 10:
		graft_list[3].position = Vector2(176, 254)
		graft_list[3].z_index = 1
	if slot_button != 11:
		graft_list[4].position = Vector2(208, 254)
		graft_list[4].z_index = 1
	if slot_button != 12:
		graft_list[5].position = Vector2(240, 254)
		graft_list[5].z_index = 1

func slotkey(event):
	if seed1_key_func(event):
		return
	elif seed2_key_func(event):
		return
	elif seed3_key_func(event):
		return
	elif graft1_key_func(event):
		return
	elif graft2_key_func(event):
		return
	elif graft3_key_func(event):
		return
	elif graft4_key_func(event):
		return
	elif graft5_key_func(event):
		return
	elif graft6_key_func(event):
		return
	allbutone_slot_reset(0)

func speedkey(event):
	if event.keycode == 32 and !event.pressed:
		global.speed += 1
		if global.speed > 4:
			global.speed = 1

func _input(event):
	if global.you_lost:
		return
	if event is InputEventKey:
		water_key_func(event)
		shovel_key_func(event)
		decompose_key_func(event)
		slotkey(event)
		speedkey(event)
	
	if event is InputEventMouseButton:
		pos = event.position
		var x = int(pos.x / 32)
		var y = int((pos.y + 8)/32)
		
		#decompose plant from lawn
		if pos.x > 32 and pos.x < 448 and pos.y > 56 and pos.y < 216 and !event.pressed and decom and lawn_space.has(str(x) + str(y)):
			for i in len(lawn_key_list):
				if lawn_key_list[i] == (str(x) + str(y)):
					lawn_key_list.remove_at(i)
					break
			if lawn_space[str(x) + str(y)].state < 2:
				global.leaf_value_surplus += 2
			elif lawn_space[str(x) + str(y)].state >= 2:
				global.leaf_value_surplus += 10
			remove_child(lawn_space[str(x) + str(y)])
			lawn_space[str(x) + str(y)].queue_free()
			lawn_space.erase(str(x) + str(y))
		
		#shovel plant from lawn
		if pos.x > 32 and pos.x < 448 and pos.y > 56 and pos.y < 216 and !event.pressed and shove and lawn_space.has(str(x) + str(y)):
			if graft_num < 6:
				for i in range(6):
					if graft_list[i] == nothing:
						if lawn_space[str(x) + str(y)].state == 1:
							lawn_space[str(x) + str(y)].timer.paused = true
						get_node(lawn_space[str(x) + str(y)].name + "/hitbox/CollisionShape2D").disabled = true
						graft_list[i] = lawn_space[str(x) + str(y)]
						graft_list[i].name += "g"
						graft_list[i].position = Vector2(80 + (int(i) * 32), 254)
						break
				lawn_space.erase(str(x) + str(y))
				for i in len(lawn_key_list):
					if lawn_key_list[i] == (str(x) + str(y)):
						lawn_key_list.remove_at(i)
						break
				graft_num += 1
			elif graft_num == 6:
				lawn_space[str(x) + str(y)].dead = true
			if x % 2 == 1 and y % 2 == 0:
				particle_effect(5, 15, 30, 20, 10, Vector2(x * 32, y * 32), Color(0.55, 0.314, 0.196, 1))
			elif x % 2 == 1 and y % 2 == 1:
				particle_effect(5, 15, 30, 20, 10, Vector2(x * 32, y * 32), Color(0.71, 0.45, 0.16, 1))
			elif x % 2 == 0 and y % 2 == 0:
				particle_effect(5, 15, 30, 20, 10, Vector2(x * 32, y * 32), Color(0.71, 0.45, 0.16, 1))
			else:
				particle_effect(5, 15, 30, 20, 10, Vector2(x * 32, y * 32), Color(0.55, 0.314, 0.196, 1))
		
		#plant sun power up
		if pos.x > 32 and pos.x < 448 and pos.y > 56 and pos.y < 216 and !event.pressed and current_seed == 0 and !shove and water and !decom and ((str(x) + str(y)) in lawn_key_list) and lawn_space[str(x) + str(y)].state > 1:
			if global.sun_value - 50 >= 0:
				lawn_space[str(x) + str(y)].state += 1
				global.sun_value_deficit += 50
				water_particle(x, y)
			elif !event.pressed:
				get_node("sun_value").modulate.g = 0.2
				get_node("sun_value").modulate.b = 0.2
		
		if pos.x > 32 and pos.x < 448 and pos.y > 56 and pos.y < 216 and !event.pressed and current_seed == 0 and !shove and water and !decom and ((str(x) + str(y)) in lawn_key_list) and lawn_space[str(x) + str(y)].state == 1:
			if global.leaf_value >= 10:
				lawn_space[str(x) + str(y)].state += 1
				global.leaf_value_deficit += 10
				water_particle(x, y)
			elif !event.pressed:
				get_node("leaf_value").modulate.g = 0.2
				get_node("leaf_value").modulate.b = 0.2
		
		water_func(event, x, y)
		shovel_func(event)
		decompose_func(event)
		#print("pos: " + str(pos))
		
		#combine plant in lawn with plant from graft
		if pos.x > 32 and pos.x < 448 and pos.y > 56 and pos.y < 216 and !event.pressed and current_graft != 0 and graft_list[current_graft - 1].name != "nothing" and (str(x) + str(y)) in lawn_space and graft_list[current_graft - 1].state > 1:
			var combinee = lawn_space[str(x) + str(y)]
			var combiner = graft_list[current_graft - 1]
			print(combinee.name)
			print(combiner.name)
			if combinee.name.get_slice("_", 0) == "1" and combinee.state > 1:
				if combiner.name.get_slice("_", 0) == "1" and global.leaf_value >= 20:
					global.leaf_value_deficit += 20
					combinee.queue_free()
					graft_list[current_graft - 1].queue_free()
					graft_list[current_graft - 1] = nothing
					graft_num -= 1
					current_graft = 0
					var instance = load("res://scenes/pea_pea_blaster.tscn").instantiate()
					instance.position = hi_light.position
					instance.name = "11_" + str(x) + str(y)
					instance.state = 2
					instance.last_state = 1
					lawn_space[str(x) + str(y)] = instance
					add_child(instance)
				elif combiner.name.get_slice("_", 0) == "1" and global.leaf_value < 20:
					get_node("leaf_value").modulate.g = 0.2
					get_node("leaf_value").modulate.b = 0.2
				elif combiner.name.get_slice("_", 0) == "3" and global.leaf_value >= 20:
					global.leaf_value_deficit += 20
					combinee.queue_free()
					graft_list[current_graft - 1].queue_free()
					graft_list[current_graft - 1] = nothing
					graft_num -= 1
					current_graft = 0
					var instance = load("res://scenes/spike_blaster.tscn").instantiate()
					instance.position = hi_light.position
					instance.name = "13_" + str(x) + str(y)
					instance.state = 2
					instance.last_state = 1
					lawn_space[str(x) + str(y)] = instance
					add_child(instance)
				elif combiner.name.get_slice("_", 0) == "3" and global.leaf_value < 20:
					get_node("leaf_value").modulate.g = 0.2
					get_node("leaf_value").modulate.b = 0.2
			if combinee.name.get_slice("_", 0) == "2" and combinee.state > 1:
				if combiner.name.get_slice("_", 0) == "3" and global.leaf_value >= 20:
					global.leaf_value_deficit += 20
					combinee.queue_free()
					graft_list[current_graft - 1].queue_free()
					graft_list[current_graft - 1] = nothing
					graft_num -= 1
					current_graft = 0
					var instance = load("res://scenes/rose_bloom.tscn").instantiate()
					instance.position = hi_light.position
					instance.name = "23_" + str(x) + str(y)
					instance.state = 2
					instance.last_state = 1
					lawn_space[str(x) + str(y)] = instance
					add_child(instance)
				elif combiner.name.get_slice("_", 0) == "1" and global.leaf_value < 20:
					get_node("leaf_value").modulate.g = 0.2
					get_node("leaf_value").modulate.b = 0.2
			if combinee.name.get_slice("_", 0) == "3" and combinee.state > 1:
				if combiner.name.get_slice("_", 0) == "1" and global.leaf_value >= 20:
					global.leaf_value_deficit += 20
					combinee.queue_free()
					graft_list[current_graft - 1].queue_free()
					graft_list[current_graft - 1] = nothing
					graft_num -= 1
					current_graft = 0
					var instance = load("res://scenes/spike_blaster.tscn").instantiate()
					instance.position = hi_light.position
					instance.name = "13_" + str(x) + str(y)
					instance.state = 2
					instance.last_state = 1
					lawn_space[str(x) + str(y)] = instance
					add_child(instance)
				elif combiner.name.get_slice("_", 0) == "1" and global.leaf_value < 20:
					get_node("leaf_value").modulate.g = 0.2
					get_node("leaf_value").modulate.b = 0.2
				if combiner.name.get_slice("_", 0) == "2" and global.leaf_value >= 20:
					global.leaf_value_deficit += 20
					combinee.queue_free()
					graft_list[current_graft - 1].queue_free()
					graft_list[current_graft - 1] = nothing
					graft_num -= 1
					current_graft = 0
					var instance = load("res://scenes/rose_bloom.tscn").instantiate()
					instance.position = hi_light.position
					instance.name = "23_" + str(x) + str(y)
					instance.state = 2
					instance.last_state = 1
					lawn_space[str(x) + str(y)] = instance
					add_child(instance)
				elif combiner.name.get_slice("_", 0) == "2" and global.leaf_value < 20:
					get_node("leaf_value").modulate.g = 0.2
					get_node("leaf_value").modulate.b = 0.2
		if (str(x) + str(y)) in lawn_space and !event.pressed:
			current_graft = 0
			current_seed = 0
			allbutone_slot_reset(0)
			return
			
		#add plant in lawn from graft slot
		if pos.x > 32 and pos.x < 448 and pos.y > 56 and pos.y < 216 and !event.pressed and current_graft != 0 and graft_list[current_graft - 1].name != "nothing":
			graft_list[current_graft - 1].position = hi_light.position
			graft_list[current_graft - 1].z_index = 0
			get_node(graft_list[current_graft - 1].name + "/hitbox/CollisionShape2D").disabled = false
			if graft_list[current_graft - 1].state == 1:
				graft_list[current_graft - 1].timer.paused = false
			lawn_space[str(x) + str(y)] = graft_list[current_graft - 1]
			lawn_space[str(x) + str(y)].name = graft_list[current_graft - 1].name.get_slice("_", 0) + "_" + str(x) + str(y)
			lawn_key_list.append(str(x) + str(y))
			graft_list[current_graft - 1] = nothing
			graft_num -= 1
			current_graft = 0
			if x % 2 == 1 and y % 2 == 0:
				particle_effect(5, 15, 30, 20, 10, Vector2(x * 32, y * 32), Color(0.55, 0.314, 0.196, 1))
			elif x % 2 == 1 and y % 2 == 1:
				particle_effect(5, 15, 30, 20, 10, Vector2(x * 32, y * 32), Color(0.71, 0.45, 0.16, 1))
			elif x % 2 == 0 and y % 2 == 0:
				particle_effect(5, 15, 30, 20, 10, Vector2(x * 32, y * 32), Color(0.71, 0.45, 0.16, 1))
			else:
				particle_effect(5, 15, 30, 20, 10, Vector2(x * 32, y * 32), Color(0.55, 0.314, 0.196, 1))
		
		#add plant in lawn from seed slot
		if pos.x > 32 and pos.x < 448 and pos.y > 56 and pos.y < 216:
			match current_seed:
				1:
					if (global.sun_value - 125 >= 0) and !event.pressed:
						global.sun_value_deficit += 125
					elif !event.pressed:
						current_seed = 0
						get_node("sun_value").modulate.g = 0.2
						get_node("sun_value").modulate.b = 0.2
				2:
					if (global.sun_value - 75 >= 0) and !event.pressed:
						global.sun_value_deficit += 75
					elif !event.pressed:
						current_seed = 0
						get_node("sun_value").modulate.g = 0.2
						get_node("sun_value").modulate.b = 0.2
				3:
					if (global.sun_value - 100 >= 0) and !event.pressed:
						global.sun_value_deficit += 100
					elif !event.pressed:
						current_seed = 0
						get_node("sun_value").modulate.g = 0.2
						get_node("sun_value").modulate.b = 0.2
		
		if pos.x > 32 and pos.x < 448 and pos.y > 56 and pos.y < 216 and !event.pressed and current_seed != 0:
			var instance = seed_list[current_seed].instantiate()
			instance.position = hi_light.position
			instance.name = str(current_seed) + "_" + str(x) + str(y)
			instance.state = 0
			instance.last_state = 1
			lawn_space[str(x) + str(y)] = instance
			add_child(instance)
			lawn_key_list.append(str(x) + str(y))
			match current_seed:
				1:
					cooldown_seed1.value = 0
				2:
					cooldown_seed2.value = 0
				3:
					cooldown_seed3.value = 0
				4:
					cooldown_seed4.value = 0
				5:
					cooldown_seed5.value = 0
				6:
					cooldown_seed6.value = 0
			global.danger_level += 1
			allbutone_slot_reset(0)
			current_seed = 0
		
		if cooldown_seed1.value == 10000:
			seed1_func(event)
		if cooldown_seed2.value == 10000:
			seed2_func(event)
		if cooldown_seed3.value == 10000:
			seed3_func(event)
		graft1_func(event)
		graft2_func(event)
		graft3_func(event)
		graft4_func(event)
		graft5_func(event)
		graft6_func(event)
		
	#hilight
	elif event is InputEventMouseMotion:
		pos = event.position
		if pos.x > 32 and pos.x < 448 and pos.y > 56 and pos.y < 216:
			hi_light.position = Vector2(16 + 32 * int(pos.x / 32), 8 + 32 * int((pos.y + 8) / 32))
		else:
			hi_light.position = Vector2(-50, -50)

func _physics_process(delta):
	enemy_spawning()
	if water:
		water_can.position = get_global_mouse_position()
	elif shove:
		shovel.position = get_global_mouse_position() + Vector2(10, -10)
	elif decom:
		compose.position = get_global_mouse_position()
	elif current_seed == 1:
		shooter_seed1.position = get_global_mouse_position()
	elif current_seed == 2:
		bloom_seed2.position = get_global_mouse_position()
	elif current_seed == 3:
		vine_seed3.position = get_global_mouse_position()
	elif current_graft == 1:
		graft_list[0].position = get_global_mouse_position()
	elif current_graft == 2:
		graft_list[1].position = get_global_mouse_position()
	elif current_graft == 3:
		graft_list[2].position = get_global_mouse_position()
	elif current_graft == 4:
		graft_list[3].position = get_global_mouse_position()
	elif current_graft == 5:
		graft_list[4].position = get_global_mouse_position()
	elif current_graft == 6:
		graft_list[5].position = get_global_mouse_position()
	
	if global.danger_level > 0:
		global.danger_level += 3 * delta * global.speed
	
	sun_value.text = str(global.sun_value)
	leaf_value.text = str(global.leaf_value)
	
	clamp(get_node("sun_value").modulate.g, 0, 1)
	clamp(get_node("sun_value").modulate.r, 0, 1)
	clamp(get_node("sun_value").modulate.b, 0, 1)
	
	clamp(get_node("leaf_value").modulate.g, 0, 1)
	clamp(get_node("leaf_value").modulate.r, 0, 1)
	clamp(get_node("leaf_value").modulate.b, 0, 1)
	
	if global.sun_value_deficit > 0:
		global.sun_value -= 5
		global.sun_value_deficit -= 5
		get_node("sun_value").modulate.r = 1
		get_node("sun_value").modulate.g = 0.2
		get_node("sun_value").modulate.b = 0.2
	
	if global.sun_value_surplus > 0:
		global.sun_value += 5
		global.sun_value_surplus -= 5
		get_node("sun_value").modulate.r = 0.2
		get_node("sun_value").modulate.g = 1
		get_node("sun_value").modulate.b = 0.2
	
	if get_node("sun_value").modulate.r < 1:
		get_node("sun_value").modulate.r += 0.01 * global.speed
	
	if get_node("sun_value").modulate.g < 1:
		get_node("sun_value").modulate.g += 0.01 * global.speed
	
	if get_node("sun_value").modulate.b < 1:
		get_node("sun_value").modulate.b += 0.01 * global.speed
	
	if global.leaf_value_deficit > 0:
		global.leaf_value -= 1
		global.leaf_value_deficit -= 1
		get_node("leaf_value").modulate.r = 1
		get_node("leaf_value").modulate.g = 0.2
		get_node("leaf_value").modulate.b = 0.2
	
	if global.leaf_value_surplus > 0:
		global.leaf_value += 1
		global.leaf_value_surplus -= 1
		get_node("leaf_value").modulate.r = 0.2
		get_node("leaf_value").modulate.g = 1
		get_node("leaf_value").modulate.b = 0.2
	
	if get_node("leaf_value").modulate.r < 1:
		get_node("leaf_value").modulate.r += 0.01 * global.speed
	
	if get_node("leaf_value").modulate.g < 1:
		get_node("leaf_value").modulate.g += 0.01 * global.speed
	
	if get_node("leaf_value").modulate.b < 1:
		get_node("leaf_value").modulate.b += 0.01 * global.speed
	
	cooldown_seed1.value += 20 * global.speed
	cooldown_seed2.value += 20 * global.speed
	cooldown_seed3.value += 20 * global.speed
	cooldown_seed4.value += 20 * global.speed
	cooldown_seed5.value += 20 * global.speed
	cooldown_seed6.value += 20 * global.speed
	
	if global.speed == 1:
		speedx1.modulate = Color(1, 1, 1, 1)
		speedx2.modulate = Color(0.5, 0.5, 0.5, 1)
		speedx3.modulate = Color(0.5, 0.5, 0.5, 1)
		speedx4.modulate = Color(0.5, 0.5, 0.5, 1)
	elif global.speed == 2:
		speedx1.modulate = Color(0.5, 0.5, 0.5, 1)
		speedx2.modulate = Color(1, 1, 1, 1)
		speedx3.modulate = Color(0.5, 0.5, 0.5, 1)
		speedx4.modulate = Color(0.5, 0.5, 0.5, 1)
	elif global.speed == 3:
		speedx1.modulate = Color(0.5, 0.5, 0.5, 1)
		speedx2.modulate = Color(0.5, 0.5, 0.5, 1)
		speedx3.modulate = Color(1, 1, 1, 1)
		speedx4.modulate = Color(0.5, 0.5, 0.5, 1)
	elif global.speed == 4:
		speedx1.modulate = Color(0.5, 0.5, 0.5, 1)
		speedx2.modulate = Color(0.5, 0.5, 0.5, 1)
		speedx3.modulate = Color(0.5, 0.5, 0.5, 1)
		speedx4.modulate = Color(1, 1, 1, 1)
	
	sun_timer.start(sun_timer.time_left - (delta * (global.speed - 1)))
	if sun_timer.time_left < 0.5:
		sun_timer.emit_signal("timeout")
	
	score.text = "Current Score: " + str(int(global.danger_level))

func _on_timer_timeout():
	for i in lawn_key_list:
		if lawn_space[i].dead:
			if lawn_space[i].state < 2:
				global.leaf_value_surplus += 2
			elif lawn_space[i].state >= 2:
				global.leaf_value_surplus += 10
			lawn_space[i].queue_free()
			lawn_space.erase(i)
			global.danger_level -= 1
			for j in len(lawn_key_list):
				if lawn_key_list[j] == i:
					lawn_key_list.remove_at(j)
					break

func _on_sun_timer_timeout():
	if global.danger_level == 0:
		return
	var sun_drop = load("res://scenes/sun_drop.tscn").instantiate()
	sun_drop.position = self.position + Vector2(rng.randi_range(80, 400), -10)
	add_child(sun_drop)
	if start_sun_time < 20:
		start_sun_time += 0.5
	sun_timer.wait_time = start_sun_time
	sun_timer.start()

func _on_button_speed_1_button_up():
	global.speed = 1

func _on_button_speed_2_button_up():
	global.speed = 2

func _on_button_speed_3_button_up():
	global.speed = 3

func _on_button_speed_4_button_up():
	global.speed = 4

func _on_button_restart_button_up():
	allbutone_slot_reset(0)
	get_tree().paused = false
	global.speed = 1
	global.sun_value = 300
	global.sun_value_deficit = 0
	global.sun_value_surplus = 0
	global.leaf_value = 100
	global.leaf_value_deficit = 0
	global.leaf_value_surplus = 0
	global.danger_level = 0
	global.slime_count = 0
	global.you_lost = false
	get_tree().reload_current_scene()

func _on_dead_area_area_entered(area):
	if area.name == "enemy" or area.name == "enemy_fly":
		get_tree().paused = true
		global.you_lost = true
		get_node("dead").visible = true
		#get_node("pausetext").visible = false
		#get_node("non_pause").visible = false

