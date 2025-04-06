extends Node2D

## it is not used

var navigation_mesh: NavigationPolygon
var region_rid: RID

func _ready() -> void:
	navigation_mesh = NavigationPolygon.new()
	region_rid = NavigationServer2D.region_create()

	# Enable the region and set it to the default navigation map.
	NavigationServer2D.region_set_enabled(region_rid, true)
	NavigationServer2D.region_set_map(region_rid, get_world_2d().get_navigation_map())

	# Add vertices for a convex polygon.
	navigation_mesh.vertices = PackedVector2Array([
		Vector2(0.0, 0.0),
		Vector2(100.0, 0.0),
		Vector2(100.0, 100.0),
		Vector2(0.0, 100.0),
	])

	# Add indices for the polygon.
	navigation_mesh.add_polygon(
		PackedInt32Array([0, 1, 2, 3])
	)

	NavigationServer2D.region_set_navigation_polygon(region_rid, navigation_mesh)
