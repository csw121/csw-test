extends Node2D

@export var piece_scene: PackedScene

@onready var board = $Board
@onready var hud = $HUD
@onready var clear_particles = $ClearParticles

var current_piece: Node2D = null
var next_type: String = ""
var score: int = 0
var is_game_over: bool = false

var drop_timer: float = 0.0
var drop_interval: float = 0.5

func _ready():
	randomize()
	board.lines_cleared.connect(_on_lines_cleared)
	select_next_type()
	start_new_game()

func start_new_game():
	score = 0
	is_game_over = false
	drop_interval = 0.5
	board.init_grid()
	hud.update_score(score)
	hud.show_game_over(false)
	spawn_piece()

func select_next_type():
	var keys = Constants.TETROMINOES.keys()
	next_type = keys[randi() % keys.size()]
	var data = Constants.TETROMINOES[next_type]
	hud.set_next_piece(data.shape, data.color)

func spawn_piece():
	if current_piece:
		current_piece.queue_free()
	
	var data = Constants.TETROMINOES[next_type]
	current_piece = piece_scene.instantiate()
	# Board의 자식으로 추가하거나 Main의 자식으로 추가 후 위치 동기화
	# 여기선 Board 자식으로 넣어 좌표계를 일치시킴
	board.add_child(current_piece)
	
	var start_pos = Vector2i(Constants.COLS / 2 - 2, 0)
	current_piece.setup(data.shape, data.color, start_pos, board)
	current_piece.locked.connect(_on_piece_locked)
	
	select_next_type()
	
	if not current_piece.is_valid_move(start_pos, data.shape):
		game_over()

func _unhandled_input(event):
	if is_game_over:
		if event.is_action_pressed("ui_accept"):
			start_new_game()
		return

	if current_piece == null: return

	if event.is_action_pressed("ui_left"):
		current_piece.move(Vector2i(-1, 0))
	elif event.is_action_pressed("ui_right"):
		current_piece.move(Vector2i(1, 0))
	elif event.is_action_pressed("ui_down"):
		current_piece.move(Vector2i(0, 1))
	elif event.is_action_pressed("ui_up"):
		current_piece.rotate_piece()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_CTRL:
		current_piece.flip_piece()
	elif event.is_action_pressed("ui_select"): # Space Bar
		current_piece.hard_drop()

func _process(delta):
	if is_game_over or current_piece == null:
		return

	drop_timer += delta
	if drop_timer >= drop_interval:
		if not current_piece.move(Vector2i(0, 1)):
			_on_piece_locked(current_piece.grid_pos, current_piece.shape, current_piece.color)
		drop_timer = 0.0

func _on_piece_locked(pos, shape, color):
	board.lock_piece(pos, shape, color)
	spawn_piece()

func _on_lines_cleared(count):
	# 파티클 효과
	clear_particles.position = board.position + Vector2(Constants.COLS * Constants.CELL_SIZE / 2, 300) # 대략 중앙
	clear_particles.restart()
	
	score += count * 100 * count
	hud.update_score(score)
	# 속도 점진적 증가
	drop_interval = max(0.1, 0.5 - (score / 5000.0))

func game_over():
	is_game_over = true
	hud.show_game_over(true)
	if current_piece:
		current_piece.queue_free()
		current_piece = null
