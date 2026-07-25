## UMBRAL Feel Prototype 01 — scene root.
##
## Drives the debug readout and turns a click into a world destination. It is
## deliberately NOT a game manager, and there is no autoload: neither job has any
## reason to outlive this scene. See PROTOTYPE_ARCHITECTURE.md section 6.

extends Node3D

## How far a destination click can reach.
const CLICK_RANGE := 500.0

@onready var _player: PrototypePlayer = $Player
@onready var _label: Label = $HUD/Panel/Margin/DebugLabel
@onready var _marker: Node3D = $DestinationMarker

const CONTROLS_CLICK := "Left click: move   ·   Hold right mouse + drag: orbit   ·   Mouse wheel: zoom\nArrow keys: orbit   ·   F3: compare camera presets   ·   F2: compare control modes   ·   F1: reset"
const CONTROLS_DIRECT := "WASD: move   ·   Mouse: look   ·   Mouse wheel: zoom   ·   Shift: sprint   ·   Space: jump\nF3: compare camera presets   ·   F2: compare control modes   ·   F1: reset   ·   Esc: free mouse"


func _ready() -> void:
	_player.destination_requested.connect(_on_destination_requested)
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

	_player.set_destination(hit.position)
	_marker.global_position = hit.position
	_marker.reset_physics_interpolation()
	_marker.visible = true


func _process(_delta: float) -> void:
	_marker.visible = _player.has_destination()

	var slope := _player.slope_degrees()
	var slope_text := "—" if slope < 0.0 else "%5.1f°" % slope
	var distance := _player.distance_to_destination()
	var distance_text := "—" if distance < 0.0 else "%5.2f m" % distance
	var zoom_text := ""
	if _player.camera_is_zoomable():
		zoom_text = "   zoom %3.0f%%" % (100.0 * _player.camera_zoom_normalised())
	var controls := CONTROLS_CLICK if _player.control_mode == PrototypePlayer.ControlMode.CLICK_TO_MOVE \
			else CONTROLS_DIRECT

	_label.text = "\n".join([
		"camera     %s" % _player.camera_preset_label(),
		"distance   %5.2f m%s" % [_player.current_distance(), zoom_text],
		"pitch      %5.1f°" % _player.camera_pitch_degrees(),
		"fov        %5.1f°" % _player.camera.fov,
		"mode       %s" % _player.control_mode_name(),
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
