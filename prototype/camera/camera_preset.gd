## One camera perspective, as data.
##
## The Camera & Perspective Laboratory exists to answer a design question: from
## what perspective should the player experience UMBRAL? Making each perspective
## a Resource means the answer is edited in the Inspector — while the game is
## running — rather than in code. Nothing here touches the player controller.
##
## Disposable, like the rest of the prototype.

class_name CameraPreset
extends Resource

## Shown on the debug HUD.
@export var preset_name := "Unnamed"

@export_group("Framing")
## Metres from the look pivot to the camera, before obstruction avoidance.
@export_range(0.5, 40.0, 0.1) var distance := 5.0
## Height of the look pivot above the character's feet.
@export_range(0.0, 8.0, 0.05) var height := 1.5
## Lateral offset of the pivot. Positive is to the camera's right.
## Zero for every non-over-the-shoulder perspective.
@export_range(-3.0, 3.0, 0.05) var shoulder_offset := 0.0

@export_group("Pitch")
## Resting pitch, applied instantly when this preset becomes active.
## Negative looks down at the character from above.
@export_range(-89.0, 89.0, 0.5) var pitch_degrees := -14.0
## Narrow the range to keep a perspective committed to its own character. A
## high strategy view that can be levelled out to eye height is no longer a
## high strategy view, and the comparison stops being clean.
@export_range(-89.0, 89.0, 1.0) var pitch_min_degrees := -68.0
@export_range(-89.0, 89.0, 1.0) var pitch_max_degrees := 32.0

@export_group("Lens")
## Vertical field of view in degrees (Godot's Camera3D defaults to Keep Height).
## Longer lenses (smaller values) flatten distance and suit high views.
@export_range(20.0, 120.0, 1.0) var fov := 75.0
## Added to fov while sprinting. The cheapest speed cue available; worth less
## the further away the camera sits.
@export_range(0.0, 40.0, 0.5) var fov_sprint_add := 9.0

@export_group("Response")
## How fast the rig chases the character. Lower is laggier and heavier.
@export_range(0.5, 40.0, 0.5) var damping := 14.0

@export_group("Zoom")
## Only the Hybrid World preset enables this. A, B and C stay fixed so they
## remain clean comparison points.
@export var zoom_enabled := false
## Closest the wheel can pull in. Must stay far enough out that the view never
## becomes over-the-shoulder.
@export_range(1.0, 40.0, 0.1) var zoom_min_distance := 9.0
## Furthest the wheel can push out. Must stay close enough to read the character.
@export_range(1.0, 60.0, 0.1) var zoom_max_distance := 20.0
## Fraction of the whole zoom range travelled per wheel notch.
@export_range(0.01, 0.5, 0.01) var zoom_step := 0.08
## Higher reaches the target zoom faster. Frame-rate independent.
@export_range(0.5, 30.0, 0.5) var zoom_response := 9.0
## Pitch is coupled to zoom: pulling in flattens the view, pushing out steepens
## it, which is what keeps the ground readable at distance.
@export_range(-89.0, 89.0, 0.5) var pitch_at_min_zoom := -27.0
@export_range(-89.0, 89.0, 0.5) var pitch_at_max_zoom := -50.0
## Lens lengthens as the camera pulls back, so the far view flattens rather than
## turning into a fisheye.
@export_range(20.0, 120.0, 0.5) var fov_at_min_zoom := 62.0
@export_range(20.0, 120.0, 0.5) var fov_at_max_zoom := 50.0

@export_group("Obstruction")
## When true the SpringArm3D pulls the camera in through geometry. Distant,
## steeply pitched views mostly look over terrain rather than through it, and
## leaving this on makes them pop against scenery in a way that would be
## mistaken for the perspective itself feeling bad.
@export var avoid_obstructions := true


# --- Zoom curve. `distance`, `pitch_degrees` and `fov` remain the authored
# --- values used whenever zoom_enabled is false.

## Normalised zoom position (0 = closest, 1 = furthest) matching `distance`.
func start_zoom_t() -> float:
	var span := zoom_max_distance - zoom_min_distance
	if absf(span) < 0.001:
		return 0.0
	return clampf((distance - zoom_min_distance) / span, 0.0, 1.0)


func distance_at(t: float) -> float:
	return lerpf(zoom_min_distance, zoom_max_distance, clampf(t, 0.0, 1.0))


## Degrees.
func pitch_at(t: float) -> float:
	return lerpf(pitch_at_min_zoom, pitch_at_max_zoom, clampf(t, 0.0, 1.0))


func fov_at(t: float) -> float:
	return lerpf(fov_at_min_zoom, fov_at_max_zoom, clampf(t, 0.0, 1.0))
