extends Node2D

func _on_attack_area_area_entered(area):
	if area:
		pass
	self.queue_free()

func _on_timer_timeout():
	self.queue_free()
