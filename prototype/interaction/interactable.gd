## An object that can be clicked and worked on.
##
## Objects own their own BEHAVIOUR and their own FEEDBACK. They know nothing
## about the player, the camera or navigation. The player owns orchestration and
## drives this through begin/set_progress/complete/cancel. There is no manager.
##
## Expected children: `Visual` (Node3D of MeshInstance3Ds), `ProgressRing`,
## `RangeRing`. Disposable prototype code.

class_name Interactable
extends StaticBody3D

signal interaction_completed(interactable: Interactable)

enum VisualState { AVAILABLE, HOVERED, ACTIVE, COMPLETED }

@export var profile: InteractionProfile

@onready var visual: Node3D = $Visual
@onready var progress_ring: MeshInstance3D = $ProgressRing
@onready var range_ring: MeshInstance3D = $RangeRing

var _state: VisualState = VisualState.AVAILABLE
var _meshes: Array[MeshInstance3D] = []
var _materials: Array[StandardMaterial3D] = []
var _base_colours: Array[Color] = []
var _visual_base_scale := Vector3.ONE
var _reset_timer := 0.0
var _pulse := 0.0


func _ready() -> void:
	if profile == null:
		profile = InteractionProfile.new()
	_visual_base_scale = visual.scale
	_collect_meshes(visual)
	progress_ring.visible = false
	range_ring.visible = false
	range_ring.scale = Vector3(profile.interaction_range, 1.0, profile.interaction_range)
	_apply_tint()


## Each mesh gets its own material copy so tinting one object never bleeds into
## another that happened to share a material resource.
func _collect_meshes(node: Node) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			var mesh_instance := child as MeshInstance3D
			var source := mesh_instance.get_active_material(0)
			if source is StandardMaterial3D:
				var copy := (source as StandardMaterial3D).duplicate() as StandardMaterial3D
				mesh_instance.set_surface_override_material(0, copy)
				_meshes.append(mesh_instance)
				_materials.append(copy)
				_base_colours.append(copy.albedo_color)
		_collect_meshes(child)


func _process(delta: float) -> void:
	if _state == VisualState.COMPLETED and profile.reset_seconds > 0.0:
		_reset_timer -= delta
		if _reset_timer <= 0.0:
			_set_state(VisualState.AVAILABLE)

	if _state == VisualState.ACTIVE and profile.pulse_speed > 0.0:
		_pulse += delta * profile.pulse_speed * TAU
		var factor := 1.0 + sin(_pulse) * profile.pulse_amount
		visual.scale = _visual_base_scale * factor
	elif visual.scale != _visual_base_scale:
		visual.scale = visual.scale.lerp(_visual_base_scale, 1.0 - exp(-12.0 * delta))


# ------------------------------------------------------------- player API ----

func is_available() -> bool:
	return _state != VisualState.COMPLETED


func interaction_range() -> float:
	return profile.interaction_range


## Where the character should stand: inside range, on the near side.
func approach_point_from(origin: Vector3) -> Vector3:
	var away := origin - global_position
	away.y = 0.0
	if away.length_squared() < 0.0001:
		away = Vector3.FORWARD
	var distance: float = profile.interaction_range * profile.approach_fraction
	return global_position + away.normalized() * distance


func set_hovered(hovered: bool) -> void:
	if _state == VisualState.AVAILABLE and hovered:
		_set_state(VisualState.HOVERED)
	elif _state == VisualState.HOVERED and not hovered:
		_set_state(VisualState.AVAILABLE)


func begin_interaction() -> void:
	_pulse = 0.0
	_set_state(VisualState.ACTIVE)
	progress_ring.visible = true
	set_progress(0.0)


func set_progress(t: float) -> void:
	var clamped := clampf(t, 0.0, 1.0)
	progress_ring.scale = Vector3(
			lerpf(0.15, 1.0, clamped), 1.0, lerpf(0.15, 1.0, clamped))


func cancel_interaction() -> void:
	progress_ring.visible = false
	if _state == VisualState.ACTIVE:
		_set_state(VisualState.AVAILABLE)


func complete_interaction() -> void:
	progress_ring.visible = false
	_set_state(VisualState.COMPLETED)
	_reset_timer = profile.reset_seconds
	# The visible "something happened" beat. Deliberately just a pop and a
	# colour change: no felling, no resources, no inventory.
	var tween := create_tween()
	tween.tween_property(visual, "scale", _visual_base_scale * 1.18, 0.08)
	tween.tween_property(visual, "scale", _visual_base_scale, 0.22) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	interaction_completed.emit(self)


func show_range(shown: bool) -> void:
	range_ring.scale = Vector3(profile.interaction_range, 1.0, profile.interaction_range)
	range_ring.visible = shown


func state_name() -> String:
	match _state:
		VisualState.HOVERED: return "hovered"
		VisualState.ACTIVE: return "active"
		VisualState.COMPLETED: return "completed"
		_: return "available"


# ------------------------------------------------------------------ visual ---

func _set_state(new_state: VisualState) -> void:
	_state = new_state
	_apply_tint()


func _apply_tint() -> void:
	var tint := Color.WHITE
	var strength := 0.0
	match _state:
		VisualState.HOVERED:
			tint = profile.hover_tint
			strength = profile.tint_strength * 0.6
		VisualState.ACTIVE:
			tint = profile.active_tint
			strength = profile.tint_strength
		VisualState.COMPLETED:
			tint = profile.complete_tint
			strength = profile.tint_strength
	for i in _materials.size():
		_materials[i].albedo_color = _base_colours[i].lerp(tint, strength)
