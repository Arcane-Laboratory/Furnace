extends TileBase
## Rock terrain tile - unbuildable and impassable


func _ready() -> void:
	super._ready()
	set_terrain_type(TerrainType.ROCK)
