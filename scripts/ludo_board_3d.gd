extends Node3D
class_name LudoBoard3D

const Rules = preload("res://scripts/ludo_rules.gd")
const COLORS := [
	Color("#ff5268"),
	Color("#23c8ff"),
	Color("#35df91"),
	Color("#ffd34e")
]
const BASE_CENTERS := [
	Vector2(-4.25, -4.25),
	Vector2(4.25, -4.25),
	Vector2(4.25, 4.25),
	Vector2(-4.25, 4.25)
]
const SLOT_OFFSETS := [
	Vector2(-0.72, -0.72),
	Vector2(0.72, -0.72),
	Vector2(-0.72, 0.72),
	Vector2(0.72, 0.72)
]

var state: Dictionary = {}
var path_points: Array[Vector2] = []
var token_root: Node3D
var token_nodes: Array = []
var dice_root: Node3D
var dice_pips: Node3D
var token_skin := "PRISMA"

func _ready() -> void:
	path_points = Rules.track_points()
	_build_board()
	_build_dice()

func show_preview() -> void:
	begin_game(Rules.new_game(4, false, "normal"))

func begin_game(new_state: Dictionary) -> void:
	state = new_state.duplicate(true)
	if token_root != null:
		token_root.queue_free()
	token_root = Node3D.new()
	token_root.name = "Tokens"
	add_child(token_root)
	token_nodes.clear()
	for player in state["players"]:
		var group: Array[Node3D] = []
		var color_id := int(player["color_id"])
		for piece_index in range(4):
			var token := _make_token(color_id)
			token_root.add_child(token)
			group.append(token)
		token_nodes.append(group)
	update_state(state)

func update_state(new_state: Dictionary) -> void:
	state = new_state.duplicate(true)
	if token_nodes.size() != state.get("players", []).size():
		begin_game(new_state)
		return
	for player_index in range(state["players"].size()):
		var player: Dictionary = state["players"][player_index]
		var color_id := int(player["color_id"])
		for piece_index in range(4):
			var progress := int(player["pieces"][piece_index])
			var token: Node3D = token_nodes[player_index][piece_index]
			token.position = _position_for_progress(color_id, progress, piece_index)
			token.visible = true

func set_token_skin(skin: String) -> void:
	token_skin = skin
	if not state.is_empty():
		begin_game(state)

func animate_piece(player_index: int, piece_index: int, old_progress: int, new_progress: int) -> void:
	if player_index >= token_nodes.size():
		return
	var player: Dictionary = state["players"][player_index]
	var color_id := int(player["color_id"])
	var token: Node3D = token_nodes[player_index][piece_index]
	var first_step := 0 if old_progress < 0 else old_progress + 1
	if new_progress >= 57:
		first_step = mini(first_step, 57)
	for step in range(first_step, new_progress + 1):
		var target := _position_for_progress(color_id, step, piece_index)
		var tween := create_tween()
		tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(token, "position", target + Vector3(0, 0.20, 0), 0.11)
		tween.tween_property(token, "position", target, 0.08)
		await tween.finished
	if new_progress >= 57:
		var finish_tween := create_tween()
		finish_tween.tween_property(token, "scale", Vector3.ONE * 1.18, 0.14)
		finish_tween.tween_property(token, "scale", Vector3.ONE, 0.14)
		await finish_tween.finished

func animate_dice(face: int) -> void:
	if dice_root == null:
		return
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(dice_root, "rotation", Vector3(TAU * 2.4, TAU * 2.1, TAU * 1.7), 0.62)
	await tween.finished
	dice_root.rotation = Vector3.ZERO
	_set_dice_face(face)

func _build_board() -> void:
	var slab_material := _material(Color("#0a1830"), 0.72, 0.28)
	_add_box(Vector3(16.2, 0.72, 16.2), Vector3(0, -0.48, 0), slab_material)
	_add_box(Vector3(15.95, 0.12, 15.95), Vector3(0, -0.06, 0), _material(Color("#142b4b"), 0.42, 0.32))
	_add_box(Vector3(15.7, 0.07, 15.7), Vector3(0, 0.025, 0), _material(Color("#d3a957"), 0.72, 0.24))
	_add_box(Vector3(15.42, 0.09, 15.42), Vector3(0, 0.085, 0), _material(Color("#10223e"), 0.38, 0.34))
	_build_track()
	_build_home_zones()
	_build_center()

func _build_track() -> void:
	for i in range(path_points.size()):
		var point := path_points[i]
		var color := Color("#24466f") if i % 2 == 0 else Color("#1a365d")
		if Rules.SAFE_SQUARES.has(i):
			color = Color("#315b84")
		if i in [0, 13, 26, 39]:
			color = COLORS[int(i / 13)]
		_add_box(Vector3(0.91, 0.17, 0.91), Vector3(point.x, 0.20, point.y), _material(color, 0.28, 0.34))
		if Rules.SAFE_SQUARES.has(i):
			var star := Label3D.new()
			star.text = "✦"
			star.font_size = 34
			star.modulate = Color("#ffe2a0")
			star.position = Vector3(point.x, 0.31, point.y)
			star.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			add_child(star)
	for color_id in range(4):
		var start := path_points[color_id * 13]
		var lane_color: Color = COLORS[color_id].darkened(0.08)
		for lane_index in range(5):
			var t := 0.27 + float(lane_index) * 0.115
			var point := start.lerp(Vector2.ZERO, t)
			_add_box(Vector3(0.83, 0.19, 0.83), Vector3(point.x, 0.23, point.y), _material(lane_color, 0.32, 0.29))

func _build_home_zones() -> void:
	for color_id in range(4):
		var center: Vector2 = BASE_CENTERS[color_id]
		var color: Color = COLORS[color_id]
		_add_box(Vector3(4.15, 0.24, 4.15), Vector3(center.x, 0.18, center.y), _material(color.darkened(0.24), 0.26, 0.36))
		_add_box(Vector3(3.82, 0.16, 3.82), Vector3(center.x, 0.34, center.y), _material(color, 0.18, 0.33))
		_add_box(Vector3(3.28, 0.12, 3.28), Vector3(center.x, 0.46, center.y), _material(Color("#f4f7fb"), 0.12, 0.4))
		var plate := Label3D.new()
		plate.text = Rules.COLOR_NAMES[color_id]
		plate.font_size = 22
		plate.modulate = color.darkened(0.35)
		plate.position = Vector3(center.x, 0.56, center.y - 1.40)
		plate.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		add_child(plate)

func _build_center() -> void:
	_add_box(Vector3(2.38, 0.28, 2.38), Vector3(0, 0.30, 0), _material(Color("#d6ad60"), 0.78, 0.22))
	_add_box(Vector3(1.95, 0.22, 1.95), Vector3(0, 0.49, 0), _material(Color("#102746"), 0.42, 0.24))
	var core := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.68
	sphere.height = 1.36
	core.mesh = sphere
	core.position = Vector3(0, 0.95, 0)
	core.material_override = _material(Color("#f5d184"), 0.76, 0.18, Color("#b67c2d"))
	add_child(core)
	var center_label := Label3D.new()
	center_label.text = "NEX"
	center_label.font_size = 30
	center_label.modulate = Color("#102746")
	center_label.position = Vector3(0, 1.62, 0)
	center_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(center_label)

func _build_dice() -> void:
	dice_root = Node3D.new()
	dice_root.name = "AnimatedDice"
	dice_root.position = Vector3(0, 0.82, 8.5)
	add_child(dice_root)
	var cube := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.92, 0.92, 0.92)
	cube.mesh = box
	cube.material_override = _material(Color("#f7f9ff"), 0.12, 0.22)
	dice_root.add_child(cube)
	dice_pips = Node3D.new()
	dice_root.add_child(dice_pips)
	_set_dice_face(1)

func _set_dice_face(face: int) -> void:
	if dice_pips == null:
		return
	for child in dice_pips.get_children():
		child.queue_free()
	var patterns := {
		1: [Vector2.ZERO],
		2: [Vector2(-0.19, -0.19), Vector2(0.19, 0.19)],
		3: [Vector2(-0.19, -0.19), Vector2.ZERO, Vector2(0.19, 0.19)],
		4: [Vector2(-0.19, -0.19), Vector2(0.19, -0.19), Vector2(-0.19, 0.19), Vector2(0.19, 0.19)],
		5: [Vector2(-0.19, -0.19), Vector2(0.19, -0.19), Vector2.ZERO, Vector2(-0.19, 0.19), Vector2(0.19, 0.19)],
		6: [Vector2(-0.19, -0.21), Vector2(0.19, -0.21), Vector2(-0.19, 0.0), Vector2(0.19, 0.0), Vector2(-0.19, 0.21), Vector2(0.19, 0.21)]
	}
	for point in patterns.get(clampi(face, 1, 6), patterns[1]):
		var pip := MeshInstance3D.new()
		var sphere := SphereMesh.new()
		sphere.radius = 0.075
		sphere.height = 0.15
		pip.mesh = sphere
		pip.position = Vector3(point.x, 0.475, point.y)
		pip.material_override = _material(Color("#12243c"), 0.05, 0.3)
		dice_pips.add_child(pip)

func _make_token(color_id: int) -> Node3D:
	var root := Node3D.new()
	root.name = "Token_" + str(color_id)
	var color: Color = COLORS[color_id]
	var accent := Color("#f7df9b")
	if token_skin == "NEON":
		accent = Color("#8cf7ff")
	elif token_skin == "SOLAR":
		accent = Color("#fff0a4")
	elif token_skin == "ROYAL":
		accent = Color("#d9b1ff")
	var base := MeshInstance3D.new()
	var base_mesh := CylinderMesh.new()
	base_mesh.top_radius = 0.31
	base_mesh.bottom_radius = 0.38
	base_mesh.height = 0.18
	base.mesh = base_mesh
	base.position.y = 0.15
	base.material_override = _material(accent, 0.76, 0.22)
	root.add_child(base)
	var body := MeshInstance3D.new()
	var body_mesh := CylinderMesh.new()
	body_mesh.top_radius = 0.23
	body_mesh.bottom_radius = 0.31
	body_mesh.height = 0.45
	body.mesh = body_mesh
	body.position.y = 0.43
	body.material_override = _material(color, 0.48, 0.2, color.lightened(0.12) if token_skin == "NEON" else Color("#000000"))
	root.add_child(body)
	var orb := MeshInstance3D.new()
	var orb_mesh := SphereMesh.new()
	orb_mesh.radius = 0.23
	orb_mesh.height = 0.46
	orb.mesh = orb_mesh
	orb.position.y = 0.76
	orb.material_override = _material(color.lightened(0.22), 0.62, 0.16)
	root.add_child(orb)
	var glint := MeshInstance3D.new()
	var glint_mesh := SphereMesh.new()
	glint_mesh.radius = 0.065
	glint_mesh.height = 0.13
	glint.mesh = glint_mesh
	glint.position = Vector3(-0.08, 0.85, -0.15)
	glint.material_override = _material(Color("#ffffff"), 0.12, 0.1)
	root.add_child(glint)
	return root

func _position_for_progress(color_id: int, progress: int, piece_index: int) -> Vector3:
	if progress < 0:
		var base: Vector2 = BASE_CENTERS[color_id] + SLOT_OFFSETS[piece_index]
		return Vector3(base.x, 0.50, base.y)
	if progress < 52:
		var point := path_points[(color_id * 13 + progress) % 52]
		return Vector3(point.x, 0.50, point.y)
	if progress < 57:
		var start := path_points[color_id * 13]
		var t := 0.27 + float(progress - 52) * 0.115
		var lane := start.lerp(Vector2.ZERO, t)
		return Vector3(lane.x, 0.50, lane.y)
	var finish_offset: Vector2 = SLOT_OFFSETS[piece_index] * 0.34
	return Vector3(finish_offset.x, 0.88, finish_offset.y)

func _add_box(size: Vector3, position_3d: Vector3, material: Material) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	instance.mesh = mesh
	instance.position = position_3d
	instance.material_override = material
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(instance)
	return instance

func _material(color: Color, metallic: float, roughness: float, glow: Color = Color("#000000")) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.metallic = metallic
	mat.roughness = roughness
	if glow != Color("#000000"):
		mat.emission_enabled = true
		mat.emission = glow
	return mat
