extends Node

const SAVE_PATH = "user://leaderboard.save"
const MAX_SCORES = 10

var scores = []


func _ready() -> void:
	load_scores()


func add_score(player_name: String, score: int) -> void:
	scores.append({
		"name": player_name,
		"score": score
	})

	scores.sort_custom(func(a, b): return a["score"] > b["score"])

	if scores.size() > MAX_SCORES:
		scores = scores.slice(0, MAX_SCORES)

	save_scores()


func save_scores() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Could not open leaderboard save file.")
		return

	file.store_string(JSON.stringify(scores))
	file.close()


func load_scores() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		scores = []
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("Could not open leaderboard file for reading.")
		scores = []
		return

	var text = file.get_as_text()
	file.close()

	var json = JSON.new()
	var result = json.parse(text)

	if result != OK:
		push_error("Could not parse leaderboard save data.")
		scores = []
		return

	if typeof(json.data) == TYPE_ARRAY:
		scores = json.data
	else:
		scores = []


func get_scores() -> Array:
	return scores
	
func clear_scores() -> void:
	scores = []
	save_scores()
