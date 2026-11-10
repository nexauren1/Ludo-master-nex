extends RefCounted
class_name LudoRules

const PLAYER_COLORS := [
	Color("#ff5268"),
	Color("#23c8ff"),
	Color("#35df91"),
	Color("#ffd34e")
]
const COLOR_NAMES := ["RUBI", "AZUL", "ESMERALDA", "DOURADO"]
const SAFE_SQUARES := [0, 8, 13, 21, 26, 34, 39, 47]

static func track_points() -> Array[Vector2]:
	var points: Array[Vector2] = []
	for i in range(14):
		points.append(Vector2(-6.5 + i, -6.5))
	for i in range(1, 14):
		points.append(Vector2(6.5, -6.5 + i))
	for i in range(1, 14):
		points.append(Vector2(6.5 - i, 6.5))
	for i in range(1, 13):
		points.append(Vector2(-6.5, 6.5 - i))
	return points

static func new_game(player_count: int, vs_cpu: bool, difficulty: String) -> Dictionary:
	var color_ids: Array[int] = []
	if player_count == 2:
		color_ids.append(0)
		color_ids.append(2)
	elif player_count == 3:
		color_ids.append(0)
		color_ids.append(1)
		color_ids.append(2)
	else:
		color_ids.append(0)
		color_ids.append(1)
		color_ids.append(2)
		color_ids.append(3)
	var players: Array[Dictionary] = []
	for i in range(color_ids.size()):
		var is_cpu := vs_cpu and i > 0
		var player_name := "VOCÊ" if i == 0 else ("CPU " + str(i) if is_cpu else "JOGADOR " + str(i + 1))
		players.append({
			"id": i,
			"color_id": color_ids[i],
			"name": player_name,
			"is_cpu": is_cpu,
			"pieces": [-1, -1, -1, -1],
			"finished": 0
		})
	return {
		"players": players,
		"current_player": 0,
		"last_roll": 0,
		"winner": -1,
		"difficulty": difficulty,
		"turn_number": 1
	}

static func start_index(color_id: int) -> int:
	return color_id * 13

static func global_track_index(color_id: int, progress: int) -> int:
	return (start_index(color_id) + progress) % 52

static func is_safe_square(track_index: int) -> bool:
	return SAFE_SQUARES.has(track_index)

static func legal_moves(state: Dictionary) -> Array[int]:
	var moves: Array[int] = []
	if state.is_empty() or int(state.get("last_roll", 0)) <= 0:
		return moves
	var player: Dictionary = state["players"][int(state["current_player"])]
	var roll := int(state["last_roll"])
	var pieces: Array = player["pieces"]
	for i in range(pieces.size()):
		var progress := int(pieces[i])
		if progress == -1:
			if roll == 6:
				moves.append(i)
		elif progress < 57 and progress + roll <= 57:
			moves.append(i)
	return moves

static func apply_move(state: Dictionary, piece_index: int) -> Dictionary:
	var player_index := int(state["current_player"])
	var roll := int(state["last_roll"])
	var player: Dictionary = state["players"][player_index]
	var color_id := int(player["color_id"])
	var pieces: Array = player["pieces"]
	var old_progress := int(pieces[piece_index])
	var new_progress := 0 if old_progress == -1 else old_progress + roll
	pieces[piece_index] = new_progress
	var captured: Array[Dictionary] = []
	if new_progress >= 0 and new_progress < 52:
		var landing_index := global_track_index(color_id, new_progress)
		if not is_safe_square(landing_index):
			for other_index in range(state["players"].size()):
				if other_index == player_index:
					continue
				var other: Dictionary = state["players"][other_index]
				var other_pieces: Array = other["pieces"]
				for other_piece_index in range(other_pieces.size()):
					var other_progress := int(other_pieces[other_piece_index])
					if other_progress >= 0 and other_progress < 52:
						var other_global := global_track_index(int(other["color_id"]), other_progress)
						if other_global == landing_index:
							other_pieces[other_piece_index] = -1
							captured.append({"player": other_index, "piece": other_piece_index})
	var finished := 0
	for progress in pieces:
		if int(progress) == 57:
			finished += 1
	player["finished"] = finished
	var winner := finished == 4
	state["last_roll"] = 0
	if winner:
		state["winner"] = player_index
	elif roll != 6:
		advance_turn(state)
	return {
		"player": player_index,
		"piece": piece_index,
		"old_progress": old_progress,
		"new_progress": new_progress,
		"captured": captured,
		"finished": winner
	}

static func advance_turn(state: Dictionary) -> void:
	state["current_player"] = (int(state["current_player"]) + 1) % state["players"].size()
	state["turn_number"] = int(state.get("turn_number", 1)) + 1
	state["last_roll"] = 0

static func pass_turn(state: Dictionary) -> void:
	var was_six := int(state.get("last_roll", 0)) == 6
	state["last_roll"] = 0
	if not was_six:
		advance_turn(state)

static func choose_ai_move(state: Dictionary) -> int:
	var options := legal_moves(state)
	if options.is_empty():
		return -1
	var player_index := int(state["current_player"])
	var player: Dictionary = state["players"][player_index]
	var color_id := int(player["color_id"])
	var roll := int(state["last_roll"])
	var best_piece := options[0]
	var best_score := -INF
	for piece_index in options:
		var current := int(player["pieces"][piece_index])
		var next_progress := 0 if current == -1 else current + roll
		var score := float(next_progress)
		if current == -1:
			score += 48.0
		if next_progress == 57:
			score += 1000.0
		elif next_progress >= 0 and next_progress < 52:
			var landing := global_track_index(color_id, next_progress)
			if is_safe_square(landing):
				score += 35.0
			else:
				for other_index in range(state["players"].size()):
					if other_index == player_index:
						continue
					var other: Dictionary = state["players"][other_index]
					for other_progress in other["pieces"]:
						if int(other_progress) >= 0 and int(other_progress) < 52:
							if global_track_index(int(other["color_id"]), int(other_progress)) == landing:
								score += 120.0
		if score > best_score:
			best_score = score
			best_piece = piece_index
	return best_piece

static func count_finished(state: Dictionary, player_index: int) -> int:
	var count := 0
	for progress in state["players"][player_index]["pieces"]:
		if int(progress) == 57:
			count += 1
	return count
