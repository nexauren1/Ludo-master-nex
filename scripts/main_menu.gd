extends Control

const BG := Color("#071426")
const PANEL := Color("#10243d")
const GOLD := Color("#e8bd68")
const MUTED := Color("#a8b8ca")

func _ready() -> void:
	_build_screen()

func _build_screen() -> void:
	var background := ColorRect.new()
	background.color = BG
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var glow := ColorRect.new()
	glow.color = Color(0.12, 0.28, 0.48, 0.20)
	glow.position = Vector2(-180, 180)
	glow.size = Vector2(700, 700)
	glow.rotation = deg_to_rad(35)
	background.add_child(glow)

	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 24)
	root.add_theme_constant_override("margin_left", 52)
	root.add_theme_constant_override("margin_right", 52)
	root.add_theme_constant_override("margin_top", 70)
	root.add_theme_constant_override("margin_bottom", 70)
	add_child(root)

	var top := HBoxContainer.new()
	top.alignment = BoxContainer.ALIGNMENT_END
	root.add_child(top)
	var version := Label.new()
	version.text = "NEXAUREN  •  GAME STUDIO"
	version.add_theme_color_override("font_color", MUTED)
	version.add_theme_font_size_override("font_size", 15)
	top.add_child(version)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(spacer)

	var brand := VBoxContainer.new()
	brand.alignment = BoxContainer.ALIGNMENT_CENTER
	brand.add_theme_constant_override("separation", 8)
	root.add_child(brand)

	var emblem := Label.new()
	emblem.text = "✦"
	emblem.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	emblem.add_theme_color_override("font_color", GOLD)
	emblem.add_theme_font_size_override("font_size", 64)
	brand.add_child(emblem)

	var title := Label.new()
	title.text = "LUDO NEX"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color("#f4f7fb"))
	title.add_theme_font_size_override("font_size", 54)
	brand.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "A NEW WAY TO PLAY"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_color_override("font_color", GOLD)
	subtitle.add_theme_font_size_override("font_size", 16)
	brand.add_child(subtitle)

	var description := Label.new()
	description.text = "Strategy, luck and friends.\nYour next match starts here."
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description.add_theme_color_override("font_color", MUTED)
	description.add_theme_font_size_override("font_size", 19)
	brand.add_child(description)

	var middle_space := Control.new()
	middle_space.custom_minimum_size.y = 90
	root.add_child(middle_space)

	var play := _make_button("PLAY NOW", true)
	play.pressed.connect(_on_play_pressed)
	root.add_child(play)

	var secondary := HBoxContainer.new()
	secondary.add_theme_constant_override("separation", 14)
	root.add_child(secondary)
	var settings := _make_button("SETTINGS", false)
	settings.pressed.connect(_on_settings_pressed)
	secondary.add_child(settings)
	var stats := _make_button("STATISTICS", false)
	stats.pressed.connect(_on_stats_pressed)
	secondary.add_child(stats)

	var bottom_space := Control.new()
	bottom_space.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(bottom_space)

	var footer := Label.new()
	footer.text = "OFFLINE PLAY  •  2–4 PLAYERS"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_color_override("font_color", MUTED)
	footer.add_theme_font_size_override("font_size", 14)
	root.add_child(footer)

func _make_button(caption: String, primary: bool) -> Button:
	var button := Button.new()
	button.text = caption
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(0, 72)
	button.add_theme_font_size_override("font_size", 19)
	button.add_theme_color_override("font_color", BG if primary else Color("#f4f7fb"))
	button.add_theme_color_override("font_hover_color", BG if primary else GOLD)
	var style := StyleBoxFlat.new()
	style.bg_color = GOLD if primary else PANEL
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_left = 18
	style.corner_radius_bottom_right = 18
	style.border_width_bottom = 2
	style.border_color = Color("#b88e45") if primary else Color("#29415e")
	button.add_theme_stylebox_override("normal", style)
	var hover := style.duplicate()
	hover.bg_color = Color("#f3d18d") if primary else Color("#183451")
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
	return button

func _on_play_pressed() -> void:
	_show_notice("PLAYER MODE SELECTION", "The local and computer modes are coming in the next development step.")

func _on_settings_pressed() -> void:
	_show_notice("SETTINGS", "Sound, language and gameplay settings will be added here.")

func _on_stats_pressed() -> void:
	_show_notice("STATISTICS", "Your match history and records will appear here.")

func _show_notice(heading: String, message: String) -> void:
	var dialog := AcceptDialog.new()
	dialog.title = heading
	dialog.dialog_text = message
	add_child(dialog)
	dialog.confirmed.connect(dialog.queue_free)
	dialog.canceled.connect(dialog.queue_free)
	dialog.popup_centered()
