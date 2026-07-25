## UMBRAL Feel Prototype 01 — scene root.
##
## Drives the debug readout and turns a click into a world destination. It is
## deliberately NOT a game manager, and there is no autoload: neither job has any
## reason to outlive this scene. See PROTOTYPE_ARCHITECTURE.md section 6.

extends Node3D

## How far a destination click can reach.
const CLICK_RANGE := 500.0
## A click further than this from the navigation mesh is off-mesh: the 50 degree
## ramp, the tops of pillars, anything outside the baked region.
const NAV_SNAP_TOLERANCE := 1.0
## How long the red "unreachable" marker stays up.
const REJECT_FLASH_SECONDS := 0.7
const REJECT_MATERIAL := preload("res://reject_material.tres")

@onready var _player: PrototypePlayer = $Player
@onready var _label: Label = $HUD/Panel/Margin/DebugLabel
@onready var _marker: Node3D = $DestinationMarker
@onready var _nav_region: NavigationRegion3D = $NavRegion
@onready var _marker_disc: MeshInstance3D = $DestinationMarker/Disc
@onready var _marker_post: MeshInstance3D = $DestinationMarker/Post

var _marker_ok_material: Material
var _reject_timer := 0.0
var _nav_ready := false

const CONTROLS_CLICK := "Left click: move   ·   Hold right mouse + drag: orbit   ·   Mouse wheel: zoom\nArrow keys: orbit   ·   F4: path debug   ·   F3: cameras   ·   F2: control modes   ·   F1: reset"
const CONTROLS_DIRECT := "WASD: move (cancels path)   ·   Mouse: look   ·   Wheel: zoom   ·   Shift: sprint   ·   Space: jump\nF4: path debug   ·   F3: cameras   ·   F2: control modes   ·   F1: reset   ·   Esc: free mouse"


func _ready() -> void:
	_player.destination_requested.connect(_on_destination_requested)
	_marker_ok_material = _marker_disc.get_surface_override_material(0)
	_bake_navigation.call_deferred()


## Baked once at startup rather than shipped pre-baked, so edits to the greybox
## cannot silently desync from the navigation mesh.
##
## MUST NOT run inside _ready(): CSGShape3D builds its mesh on a deferred call,
## so baking any earlier parses a scene containing only the ground plane and
## produces a flat navmesh with no obstacles in it at all. Measured: 126
## polygons and straight-line paths through every wall.
func _bake_navigation() -> void:
	# Two physics frames, not one process frame. This waits for BOTH conditions:
	# CSGShape3D has run its deferred mesh build, and the navigation map has
	# completed its first synchronisation. Pushing the baked mesh before the map
	# has synced is silently discarded.
	await get_tree().physics_frame
	await get_tree().physics_frame
	_nav_region.bake_navigation_mesh(false)
	# bake_navigation_mesh() fills the NavigationMesh RESOURCE but does not push
	# the result to the navigation server. Without this the region sits on the
	# map reporting 342 polygons while every server query returns the origin.
	NavigationServer3D.region_set_navigation_mesh(
			_nav_region.get_rid(), _nav_region.navigation_mesh)
	await get_tree().physics_frame
	_nav_ready = true
	# The marker is teleported, never simulated, so it must not be interpolated.
	_marker.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	_marker.visible = false


## The player reports WHERE ON SCREEN the request happened; the world lookup
## belongs here. Rejects anything the player could not stand on, which is what
## keeps the steep ramp and the pillars from being valid destinations.
func _on_destination_requested(screen_position: Vector2) -> void:
	var camera := _player.camera
	var from := camera.project_ray_origin(screen_position)
	var to := from + camera.project_ray_normal(screen_position) * CLICK_RANGE

	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [_player.get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return
	if hit.normal.angle_to(Vector3.UP) > _player.floor_max_angle:
		return
	request_destination(hit.position)


## Applies the navigation checks and drives the marker. Returns true if the
## point was accepted. Shared by clicks, touches and the test harness.
func request_destination(point: Vector3) -> bool:
	if not _nav_ready:
		return false
	var map := get_world_3d().navigation_map
	var closest := NavigationServer3D.map_get_closest_point(map, point)
	var on_mesh := closest.distance_to(point) <= NAV_SNAP_TOLERANCE
	var reachable := on_mesh
	if on_mesh and _player.use_navigation:
		var route := NavigationServer3D.map_get_path(
				map, _player.global_position, closest, true)
		reachable = route.size() > 0 \
				and route[route.size() - 1].distance_to(closest) <= NAV_SNAP_TOLERANCE

	_marker.global_position = point
	_marker.reset_physics_interpolation()
	_marker.visible = true

	if not reachable:
		# Reject rather than silently resolving to somewhere else. See
		# NAVIGATION_TEST.md for why this is the smaller useful test.
		_player.clear_destination()
		_set_marker_rejected(true)
		_reject_timer = REJECT_FLASH_SECONDS
		return false

	_reject_timer = 0.0
	_set_marker_rejected(false)
	_player.set_destination(point)
	return true


func is_navigation_ready() -> bool:
	return _nav_ready


func _set_marker_rejected(rejected: bool) -> void:
	var material := REJECT_MATERIAL if rejected else _marker_ok_material
	_marker_disc.set_surface_override_material(0, material)
	_marker_post.set_surface_override_material(0, material)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_path_debug"):
		_player.set_path_debug(not _player.path_debug_enabled())


func _process(delta: float) -> void:
	if _reject_timer > 0.0:
		_reject_timer -= delta
		_marker.visible = true
		if _reject_timer <= 0.0:
			_set_marker_rejected(false)
	else:
		_marker.visible = _player.has_destination()

	var slope := _player.slope_degrees()
	var slope_text := "—" if slope < 0.0 else "%5.1f°" % slope
	var distance := _player.distance_to_destination()
	var distance_text := "—" if distance < 0.0 else "%5.2f m" % distance
	var zoom_text := ""
	if _player.camera_is_zoomable():
		zoom_text = "   zoom %3.0f%%" % (100.0 * _player.camera_zoom_normalised())
	var path_length := _player.remaining_path_length()
	var path_text := "—"
	if path_length >= 0.0:
		path_text = "%5.2f m over %d pts" % [path_length, _player.remaining_path_points()]
	elif _reject_timer > 0.0:
		path_text = "UNREACHABLE"
	var controls := CONTROLS_CLICK if _player.control_mode == PrototypePlayer.ControlMode.CLICK_TO_MOVE \
			else CONTROLS_DIRECT

	_label.text = "\n".join([
		"camera     %s" % _player.camera_preset_label(),
		"distance   %5.2f m%s" % [_player.current_distance(), zoom_text],
		"pitch      %5.1f°" % _player.camera_pitch_degrees(),
		"fov        %5.1f°" % _player.camera.fov,
		"mode       %s" % _player.control_mode_name(),
		"nav        %s" % _player.navigation_state_name(),
		"path       %s" % path_text,
		"fps        %5d" % Engine.get_frames_per_second(),
		"speed      %5.2f m/s" % _player.horizontal_speed(),
		"vertical   %5.2f m/s" % _player.vertical_speed(),
		"state      %s" % _player.state_name(),
		"grounded   %s" % ("yes" if _player.is_on_floor() else "no"),
		"slope      %s" % slope_text,
		"step max   %5.2f m%s" % [
			_player.max_step_height, "   <-- STEPPING" if _player.stepped_this_frame() else ""],
		"coyote     %5.3f s" % _player.coyote_remaining(),
		"to dest    %s" % distance_text,
		"sprint     %s" % ("on" if _player.is_sprinting() else "off"),
		"",
		controls,
	])
