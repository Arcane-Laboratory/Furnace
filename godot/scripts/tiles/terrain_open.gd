extends TileBase
## Open terrain tile - buildable and crossable


func _ready() -> void:
	super._ready()
	set_terrain_type(TerrainType.OPEN)
