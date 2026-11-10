extends Node3D

const Rules = preload("res://scripts/ludo_rules.gd")
const BoardScript = preload("res://scripts/ludo_board_3d.gd")

const NAVY := Color("#07152a")
const PANEL := Color("#102744")
const PANEL_LIGHT := Color("#18395f")
const GOLD := Color("#f0c66e")
const MUTED := Color("#a9bfd8")
const WHITE := Color("#f4f7ff")

var ui_layer: CanvasLayer
var ui_root: Control
var board
var camera: Camera3D
var current_screen := "home"
var state: Dictionary = {}
var setup_mode := "cpu"
var selected_players := 4
var selected_difficulty := "normal"
var busy := false
var top_label: Label
var bottom_content: VBoxContainer
var profile_name := "JOGADOR"
var selected_skin := "PRISMA"
var wins := 0

func _ready() -> void:
	randomize()
	_load_profile()
	_build_world()
	_build_board()
	_build_home()

func _build_world() -> void:
	var world := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = NAVY
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#a8c9ee")
	environment.ambient_light_energy = 0.72
	world.environment = environment
	add_child(world)

	var key_light := DirectionalLight3D.new()
	key_light.rotation_degrees = Vector3(-54, -28, 0)
	key_light.light_color = Color("#fff0d2")
	key_light.light_energy = 1.35
	key_light.shadow_enabled = true
	add_child(key_light)

	var fill_light := OmniLight3D.new()
	fill_light.position = Vector3(-7, 8, 5)
	fill_light.light_color = Color("#3f9fff")
	fill_light.light_energy = 1.0
	fill_light.omni_range = 23.0
	add_child(fill_light)

	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 27.5
	camera.position = Vector3(0, 21.5, 23.5)
	add_child(camera)
	camera.look_at(Vector3.ZERO, Vector3.UP)
	camera.current = true

	ui_layer = CanvasLayer.new()
	ui_layer.layer = 10
	add_child(ui_layer)

func _build_board() -> void:
	board = BoardScript.new()
	board.name = "Procedural3DBoard"
	board.scale = Vector3(0.82, 0.82, 0.82)
	add_child(board)
	board.show_preview()
	board.set_token_skin(selected_skin)

func _new_screen(dim_background: bool = true) -> Control:
	if ui_root != null:
		ui_root.queue_free()
	ui_root = Control.new()
	ui_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui_layer.add_child(ui_root)
	if dim_background:
		var shade := ColorRect.new()
		shade.color = Color(0.015, 0.035, 0.075, 0.56)
		shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		ui_root.add_child(shade)
	return ui_root

func _make_column(parent: Control, top: float = 0.035, bottom: float = 0.965) -> VBoxContainer:
	var column := VBoxContainer.new()
	column.anchor_left = 0.055
	column.anchor_right = 0.945
	column.anchor_top = top
	column.anchor_bottom = bottom
	column.add_theme_constant_override("separation", 16)
	parent.add_child(column)
	return column

func _make_label(parent: Node, text: String, size: int = 22, color: Color = WHITE, centered: bool = false) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if centered else HORIZONTAL_ALIGNMENT_LEFT
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(label)
	return label

func _make_button(parent: Node, text: String, primary: bool, callback: Callable, compact: bool = false) -> Button:
	var button := Button.new()
	button.text = text
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(0, 54 if compact else 70)
	button.add_theme_font_size_override("font_size", 18 if compact else 21)
	button.add_theme_color_override("font_color", NAVY if primary else WHITE)
	button.add_theme_color_override("font_hover_color", NAVY if primary else GOLD)
	button.add_theme_color_override("font_pressed_color", NAVY)
	var normal := StyleBoxFlat.new()
	normal.bg_color = GOLD if primary else PANEL_LIGHT
	normal.border_color = Color("#ffe5a7") if primary else Color("#3c6289")
	normal.set_border_width_all(2)
	normal.corner_radius_top_left = 17
	normal.corner_radius_top_right = 17
	normal.corner_radius_bottom_left = 17
	normal.corner_radius_bottom_right = 17
	normal.shadow_color = Color(0, 0, 0, 0.28)
	normal.shadow_size = 6
	normal.shadow_offset = Vector2(0, 4)
	button.add_theme_stylebox_override("normal", normal)
	var hover := normal.duplicate()
	hover.bg_color = Color("#ffdb91") if primary else Color("#214a75")
	button.add_theme_stylebox_override("hover", hover)
	var pressed := normal.duplicate()
	pressed.bg_color = Color("#d9ad5e") if primary else Color("#102744")
	button.add_theme_stylebox_override("pressed", pressed)
	button.pressed.connect(callback)
	parent.add_child(button)
	return button

func _make_panel(parent: Control, left: float, top: float, right: float, bottom: float, color: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.anchor_left = left
	panel.anchor_top = top
	panel.anchor_right = right
	panel.anchor_bottom = bottom
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color("#b98b45")
	style.set_border_width_all(2)
	style.corner_radius_top_left = 22
	style.corner_radius_top_right = 22
	style.corner_radius_bottom_left = 22
	style.corner_radius_bottom_right = 22
	style.shadow_color = Color(0, 0, 0, 0.45)
	style.shadow_size = 12
	style.shadow_offset = Vector2(0, 6)
	panel.add_theme_stylebox_override("panel", style)
	parent.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	panel.add_child(margin)
	return panel

func _build_home() -> void:
	current_screen = "home"
	busy = false
	board.visible = true
	var root := _new_screen(true)
	var column := _make_column(root, 0.035, 0.97)

	var header := HBoxContainer.new()
	column.add_child(header)
	var brand := VBoxContainer.new()
	brand.add_theme_constant_override("separation", 0)
	header.add_child(brand)
	_make_label(brand, "NEXAUREN  /  GAME STUDIO", 12, MUTED)
	_make_label(brand, "LUDO NEX", 27, GOLD)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)
	_make_label(header, "●  1 250     ◆  80", 17, WHITE, true)

	var upper_space := Control.new()
	upper_space.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(upper_space)

	_make_label(column, "UM TABULEIRO. QUATRO REINOS.", 15, GOLD, true)
	_make_label(column, "A próxima jogada é tua.", 35, WHITE, true)
	_make_label(column, "Estratégia, sorte e movimento em 3D.", 17, MUTED, true)

	var hero_space := Control.new()
	hero_space.custom_minimum_size.y = 28
	column.add_child(hero_space)

	_make_button(column, "COMEÇAR PARTIDA", true, Callable(self, "_open_setup").bind("cpu"))
	var mode_row := HBoxContainer.new()
	mode_row.add_theme_constant_override("separation", 12)
	column.add_child(mode_row)
	_make_button(mode_row, "JOGO LOCAL", false, Callable(self, "_open_setup").bind("local"), true)
	_make_button(mode_row, "VER COLEÇÃO", false, Callable(self, "_open_collection"), true)

	var lower_space := Control.new()
	lower_space.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(lower_space)

	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 12)
	column.add_child(footer)
	_make_button(footer, "PERFIL", false, Callable(self, "_open_profile"), true)
	_make_button(footer, "REGRAS", false, Callable(self, "_show_rules"), true)
	_make_label(column, "OFFLINE  •  2 A 4 JOGADORES  •  PRIMEIRA VERSÃO", 12, MUTED, true)

func _open_setup(mode: String) -> void:
	setup_mode = mode
	selected_players = 4
	_build_setup()

func _build_setup() -> void:
	current_screen = "setup"
	var root := _new_screen(true)
	var column := _make_column(root, 0.07, 0.93)
	_make_button(column, "‹  VOLTAR", false, Callable(self, "_build_home"), true)
	_make_label(column, "CONFIGURAR PARTIDA", 30, WHITE, true)
	_make_label(column, "Escolhe como queres jogar.", 16, MUTED, true)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(spacer)

	_make_label(column, "MODO DE JOGO", 16, GOLD, true)
	var mode_row := HBoxContainer.new()
	mode_row.add_theme_constant_override("separation", 12)
	column.add_child(mode_row)
	_make_button(mode_row, "VS COMPUTADOR" + ("  ✓" if setup_mode == "cpu" else ""), setup_mode == "cpu", Callable(self, "_select_mode").bind("cpu"), true)
	_make_button(mode_row, "LOCAL" + ("  ✓" if setup_mode == "local" else ""), setup_mode == "local", Callable(self, "_select_mode").bind("local"), true)

	_make_label(column, "NÚMERO DE JOGADORES", 16, GOLD, true)
	var count_row := HBoxContainer.new()
	count_row.add_theme_constant_override("separation", 12)
	column.add_child(count_row)
	for amount in [2, 3, 4]:
		_make_button(count_row, str(amount) + ("  ✓" if selected_players == amount else ""), selected_players == amount, Callable(self, "_select_player_count").bind(amount), true)

	if setup_mode == "cpu":
		_make_label(column, "DIFICULDADE DO COMPUTADOR", 16, GOLD, true)
		var difficulty_row := HBoxContainer.new()
		difficulty_row.add_theme_constant_override("separation", 10)
		column.add_child(difficulty_row)
		_make_button(difficulty_row, "FÁCIL", selected_difficulty == "easy", Callable(self, "_select_difficulty").bind("easy"), true)
		_make_button(difficulty_row, "NORMAL", selected_difficulty == "normal", Callable(self, "_select_difficulty").bind("normal"), true)
		_make_button(difficulty_row, "DIFÍCIL", selected_difficulty == "hard", Callable(self, "_select_difficulty").bind("hard"), true)

	_make_label(column, "Cada jogador tem quatro peças. No modo local, todos jogam no mesmo dispositivo.", 14, MUTED, true)

	var lower_space := Control.new()
	lower_space.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(lower_space)
	_make_button(column, "CRIAR PARTIDA  →", true, Callable(self, "_start_game"))
	_make_label(column, "REGRAS CLÁSSICAS  •  TABULEIRO 3D", 12, MUTED, true)

func _select_mode(mode: String) -> void:
	setup_mode = mode
	_build_setup()

func _select_player_count(amount: int) -> void:
	selected_players = amount
	_build_setup()

func _select_difficulty(difficulty: String) -> void:
	selected_difficulty = difficulty
	_build_setup()

func _start_game() -> void:
	state = Rules.new_game(selected_players, setup_mode == "cpu", selected_difficulty)
	state["players"][0]["name"] = profile_name
	board.begin_game(state)
	board.visible = true
	_build_game_ui()
	_maybe_run_cpu()

func _build_game_ui() -> void:
	current_screen = "game"
	var root := _new_screen(false)
	var top_panel := _make_panel(root, 0.035, 0.025, 0.965, 0.145, Color("#0b1d35"))
	var top_box := VBoxContainer.new()
	top_box.add_theme_constant_override("separation", 4)
	top_panel.get_child(0).add_child(top_box)
	var top_row := HBoxContainer.new()
	top_box.add_child(top_row)
	_make_button(top_row, "SAIR", false, Callable(self, "_go_home"), true)
	top_label = _make_label(top_row, "VEZ DE " + profile_name, 18, GOLD, true)
	_make_label(top_box, "LUDO NEX  •  PARTIDA OFFLINE", 12, MUTED, true)

	var bottom_panel := _make_panel(root, 0.035, 0.785, 0.965, 0.985, Color("#0b1d35"))
	bottom_content = VBoxContainer.new()
	bottom_content.add_theme_constant_override("separation", 10)
	bottom_panel.get_child(0).add_child(bottom_content)
	_refresh_game_ui()

func _refresh_game_ui() -> void:
	if current_screen != "game" or bottom_content == null or state.is_empty():
		return
	var player: Dictionary = state["players"][int(state["current_player"])]
	if top_label != null:
		top_label.text = "VEZ DE " + str(player["name"]) + ("  •  CPU" if player["is_cpu"] else "")
	for child in bottom_content.get_children():
		bottom_content.remove_child(child)
		child.queue_free()

	var info := Label.new()
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info.add_theme_font_size_override("font_size", 16)
	info.add_theme_color_override("font_color", GOLD)
	bottom_content.add_child(info)

	if busy:
		info.text = "A PREPARAR A JOGADA..."
		return
	if int(state["last_roll"]) == 0:
		info.text = "É A TUA VEZ DE LANÇAR O DADO"
		_make_button(bottom_content, "🎲  LANÇAR DADO", true, Callable(self, "_perform_roll"))
		return

	var roll := int(state["last_roll"])
	info.text = "O DADO MOSTROU  " + str(roll) + "  •  ESCOLHE UMA PEÇA"
	var moves := Rules.legal_moves(state)
	var move_grid := GridContainer.new()
	move_grid.columns = 2
	move_grid.add_theme_constant_override("h_separation", 10)
	move_grid.add_theme_constant_override("v_separation", 8)
	bottom_content.add_child(move_grid)
	for piece_index in moves:
		var progress := int(player["pieces"][piece_index])
		var caption := "PEÇA " + str(piece_index + 1)
		if progress == -1:
			caption += "  •  ENTRAR"
		elif progress + roll == 57:
			caption += "  •  FINALIZAR"
		_make_button(move_grid, caption, true, Callable(self, "_move_piece").bind(piece_index), true)

func _perform_roll() -> void:
	if busy or state.is_empty() or int(state["winner"]) >= 0:
		return
	busy = true
	_refresh_game_ui()
	var value := randi_range(1, 6)
	await board.animate_dice(value)
	state["last_roll"] = value
	busy = false
	var moves := Rules.legal_moves(state)
	if moves.is_empty():
		busy = true
		_refresh_game_ui()
		await get_tree().create_timer(0.75).timeout
		Rules.pass_turn(state)
		busy = false
		_refresh_game_ui()
		_maybe_run_cpu()
		return

	var current: Dictionary = state["players"][int(state["current_player"])]
	if bool(current["is_cpu"]):
		busy = true
		_refresh_game_ui()
		await get_tree().create_timer(0.65 if selected_difficulty == "easy" else 0.9).timeout
		var chosen := Rules.choose_ai_move(state)
		busy = false
		await _move_piece(chosen)
	else:
		_refresh_game_ui()

func _move_piece(piece_index: int) -> void:
	if busy or state.is_empty() or int(state["last_roll"]) <= 0:
		return
	var player_index := int(state["current_player"])
	var old_progress := int(state["players"][player_index]["pieces"][piece_index])
	var outcome: Dictionary = Rules.apply_move(state, piece_index)
	busy = true
	_refresh_game_ui()
	await board.animate_piece(player_index, piece_index, old_progress, int(outcome["new_progress"]))
	board.update_state(state)
	busy = false
	if bool(outcome["finished"]):
		wins += 1
		_save_profile()
		_build_results()
	else:
		_refresh_game_ui()
		_maybe_run_cpu()

func _maybe_run_cpu() -> void:
	if current_screen != "game" or state.is_empty() or busy:
		return
	if int(state["winner"]) >= 0:
		return
	var player: Dictionary = state["players"][int(state["current_player"])]
	if bool(player["is_cpu"]):
		await get_tree().create_timer(0.6).timeout
		if current_screen == "game" and not busy:
			await _perform_roll()

func _build_results() -> void:
	current_screen = "results"
	var winner_index := int(state["winner"])
	var winner: Dictionary = state["players"][winner_index]
	var root := _new_screen(true)
	var column := _make_column(root, 0.18, 0.82)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(spacer)
	_make_label(column, "PARTIDA CONCLUÍDA", 18, GOLD, true)
	_make_label(column, "VITÓRIA!", 48, WHITE, true)
	_make_label(column, str(winner["name"]), 30, GOLD, true)
	_make_label(column, "Todas as quatro peças chegaram ao centro.", 17, MUTED, true)
	var gap := Control.new()
	gap.custom_minimum_size.y = 28
	column.add_child(gap)
	_make_button(column, "JOGAR NOVAMENTE", true, Callable(self, "_restart_game"))
	_make_button(column, "VOLTAR AO MENU", false, Callable(self, "_go_home"))
	var lower := Control.new()
	lower.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(lower)

func _restart_game() -> void:
	_start_game()

func _go_home() -> void:
	state = {}
	busy = false
	board.show_preview()
	_build_home()

func _open_collection() -> void:
	current_screen = "collection"
	var root := _new_screen(true)
	var column := _make_column(root, 0.07, 0.93)
	_make_button(column, "‹  VOLTAR", false, Callable(self, "_build_home"), true)
	_make_label(column, "COLEÇÃO", 32, WHITE, true)
	_make_label(column, "Escolhe o acabamento das tuas peças.", 16, MUTED, true)
	var options := [
		["PRISMA", "Metal polido e brilho suave."],
		["NEON", "Energia azul e reflexos luminosos."],
		["SOLAR", "Dourado quente e acabamento premium."],
		["ROYAL", "Detalhes violeta e aparência real."]
	]
	for option in options:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		column.add_child(row)
		var text_box := VBoxContainer.new()
		text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(text_box)
		_make_label(text_box, option[0] + ("  ✓" if selected_skin == option[0] else ""), 18, GOLD)
		_make_label(text_box, option[1], 13, MUTED)
		_make_button(row, "EQUIPAR", selected_skin == option[0], Callable(self, "_select_skin").bind(option[0]), true)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(spacer)
	_make_label(column, "OS ACABAMENTOS SÃO COSMÉTICOS. AS REGRAS SÃO IGUAIS PARA TODOS.", 12, MUTED, true)

func _select_skin(skin: String) -> void:
	selected_skin = skin
	board.set_token_skin(skin)
	_open_collection()

func _open_profile() -> void:
	current_screen = "profile"
	var root := _new_screen(true)
	var column := _make_column(root, 0.10, 0.90)
	_make_button(column, "‹  VOLTAR", false, Callable(self, "_build_home"), true)
	_make_label(column, "PERFIL DE JOGADOR", 30, WHITE, true)
	_make_label(column, "O teu progresso fica guardado neste dispositivo.", 16, MUTED, true)
	var name_input := LineEdit.new()
	name_input.text = profile_name
	name_input.placeholder_text = "Nome do jogador"
	name_input.custom_minimum_size.y = 58
	name_input.add_theme_font_size_override("font_size", 19)
	column.add_child(name_input)
	_make_label(column, "VITÓRIAS REGISTADAS:  " + str(wins), 20, GOLD, true)
	_make_button(column, "GUARDAR PERFIL", true, Callable(self, "_save_profile_from_input").bind(name_input))
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(spacer)
	_make_label(column, "LUDO NEX  •  PERFIL LOCAL", 12, MUTED, true)

func _save_profile_from_input(name_input: LineEdit) -> void:
	var clean_name := name_input.text.strip_edges()
	if clean_name.is_empty():
		clean_name = "JOGADOR"
	profile_name = clean_name.substr(0, 18)
	_save_profile()
	_build_profile_saved()

func _build_profile_saved() -> void:
	_open_profile()

func _show_rules() -> void:
	var dialog := AcceptDialog.new()
	dialog.title = "REGRAS DO LUDO NEX"
	dialog.dialog_text = "Lança um seis para tirar uma peça da base. Percorre o caminho, captura peças adversárias fora das casas seguras e chega ao centro com o número exato. Cada jogador tem quatro peças. Quem levar todas ao centro vence."
	add_child(dialog)
	dialog.confirmed.connect(dialog.queue_free)
	dialog.canceled.connect(dialog.queue_free)
	dialog.popup_centered(Vector2i(620, 420))

func _load_profile() -> void:
	var config := ConfigFile.new()
	if config.load("user://ludo_nex.cfg") == OK:
		profile_name = str(config.get_value("profile", "name", "JOGADOR"))
		wins = int(config.get_value("profile", "wins", 0))
		selected_skin = str(config.get_value("profile", "skin", "PRISMA"))

func _save_profile() -> void:
	var config := ConfigFile.new()
	config.set_value("profile", "name", profile_name)
	config.set_value("profile", "wins", wins)
	config.set_value("profile", "skin", selected_skin)
	config.save("user://ludo_nex.cfg")
