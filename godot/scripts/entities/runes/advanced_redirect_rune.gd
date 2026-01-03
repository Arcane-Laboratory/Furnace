extends RedirectRune
class_name AdvancedRedirectRune
## Advanced Redirect Rune - like normal redirect, but direction can be changed during active phase


## Whether this rune can be edited during active phase (always true for advanced redirect)
var is_editable_in_active_phase: bool = true


func _on_rune_ready() -> void:
	rune_type = "advanced_redirect"
	_update_direction_visual()
	
	# Add a visual distinction from regular redirect
	_add_advanced_indicator()


## Add a visual marker to distinguish from regular redirect rune
func _add_advanced_indicator() -> void:
	# Add small corner markers to indicate "advanced"
	var marker := ColorRect.new()
	marker.name = "AdvancedMarker"
	marker.offset_left = -12.0
	marker.offset_top = -12.0
	marker.offset_right = -8.0
	marker.offset_bottom = -8.0
	marker.color = Color(0.2, 0.2, 0.2, 1.0)
	add_child(marker)
	
	var marker2 := ColorRect.new()
	marker2.name = "AdvancedMarker2"
	marker2.offset_left = 8.0
	marker2.offset_top = -12.0
	marker2.offset_right = 12.0
	marker2.offset_bottom = -8.0
	marker2.color = Color(0.2, 0.2, 0.2, 1.0)
	add_child(marker2)
