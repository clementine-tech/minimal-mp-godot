extends CharacterBody2D
 
func _enter_tree():
	set_multiplayer_authority(1)
 
func _physics_process(delta):
	if is_multiplayer_authority():
		var dum = Dumster.new()
		var vel_change = dum.random_vec()
		velocity = velocity + Vector2(vel_change[0], vel_change[1])
	move_and_slide()
