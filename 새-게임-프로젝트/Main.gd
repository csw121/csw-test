extends Node2D

# 테트리스 격자 설정
const COLS = 10
const ROWS = 20
const CELL_SIZE = 30

# 색상 설정
const COLOR_GRID_LINE = Color(0.2, 0.2, 0.4, 0.3) # 연한 청회색 격자
const COLOR_GHOST = Color(1, 1, 1, 0.2) # 고스트 블록 (반투명)

# 테트로미노 데이터 (모양 및 색상)
const TETROMINOES = {
	"I": {"color": Color.CYAN, "shape": [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)]},
	"J": {"color": Color.BLUE, "shape": [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]},
	"L": {"color": Color.ORANGE, "shape": [Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]},
	"O": {"color": Color.YELLOW, "shape": [Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1)]},
	"S": {"color": Color.GREEN, "shape": [Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)]},
	"T": {"color": Color.PURPLE, "shape": [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]},
	"Z": {"color": Color.RED, "shape": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1)]}
}

# 게임 상태 변수
var grid: Array = []
var current_shape: Array = []
var current_color: Color = Color.WHITE
var current_pos: Vector2i = Vector2i(0, 0)

var next_shape: Array = []
var next_color: Color = Color.WHITE

var drop_timer: float = 0.0
var drop_interval: float = 0.5
var score: int = 0
var is_game_over: bool = false

# 노드 참조
@onready var score_label = $UI/ScoreLabel
@onready var game_over_rect = $UI/GameOverRect
@onready var clear_particles = $ClearParticles

func _ready():
	position = Vector2(100, 50)
	# 초기 무작위 시드
	randomize()
	# 첫 번째 블록 미리 생성
	select_next_piece()
	init_game()

func init_game():
	grid.clear()
	for y in range(ROWS):
		var row = []
		for x in range(COLS):
			row.append(null)
		grid.append(row)
	score = 0
	update_score_ui()
	is_game_over = false
	game_over_rect.hide()
	spawn_piece()

func select_next_piece():
	var keys = TETROMINOES.keys()
	var key = keys[randi() % keys.size()]
	next_shape = TETROMINOES[key]["shape"]
	next_color = TETROMINOES[key]["color"]

func _unhandled_input(event):
	if is_game_over:
		if event.is_action_pressed("ui_accept"):
			init_game()
		return

	if event.is_action_pressed("ui_left"):
		move_piece(Vector2i(-1, 0))
	elif event.is_action_pressed("ui_right"):
		move_piece(Vector2i(1, 0))
	elif event.is_action_pressed("ui_down"):
		move_piece(Vector2i(0, 1))
	elif event.is_action_pressed("ui_up"):
		rotate_piece()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_CTRL:
		flip_piece()
	elif event.is_action_pressed("ui_select"): # Space Bar
		hard_drop()

func _process(delta):
	if is_game_over:
		return

	drop_timer += delta
	if drop_timer >= drop_interval:
		if not move_piece(Vector2i(0, 1)):
			lock_piece()
		drop_timer = 0.0

func spawn_piece():
	current_shape = next_shape
	current_color = next_color
	current_pos = Vector2i(COLS / 2 - 2, 0)
	
	select_next_piece()
	
	if not is_valid_move(current_pos, current_shape):
		is_game_over = true
		game_over_rect.show()
	
	queue_redraw()

func move_piece(dir: Vector2i) -> bool:
	var new_pos = current_pos + dir
	if is_valid_move(new_pos, current_shape):
		current_pos = new_pos
		queue_redraw()
		return true
	return false

func hard_drop():
	while move_piece(Vector2i(0, 1)):
		pass
	lock_piece()

func rotate_piece():
	var new_shape = []
	for cell in current_shape:
		new_shape.append(Vector2i(-cell.y, cell.x))
	apply_shape_change(new_shape)

func flip_piece():
	var new_shape = []
	for cell in current_shape:
		# x좌표를 반전시켜 수평 반전 구현
		new_shape.append(Vector2i(-cell.x, cell.y))
	apply_shape_change(new_shape)

func apply_shape_change(new_shape: Array):
	# 회전이나 반전 시 충돌하면 좌우로 보정 시도 (±1, ±2)
	var kicks = [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(-2, 0), Vector2i(2, 0)]
	for kick in kicks:
		if is_valid_move(current_pos + kick, new_shape):
			current_pos += kick
			current_shape = new_shape
			queue_redraw()
			return

func is_valid_move(pos: Vector2i, shape: Array) -> bool:
	for cell in shape:
		var grid_pos = pos + cell
		if grid_pos.x < 0 or grid_pos.x >= COLS or grid_pos.y >= ROWS:
			return false
		if grid_pos.y >= 0 and grid[grid_pos.y][grid_pos.x] != null:
			return false
	return true

func lock_piece():
	for cell in current_shape:
		var grid_pos = current_pos + cell
		if grid_pos.y >= 0:
			grid[grid_pos.y][grid_pos.x] = current_color
	check_line_clear()
	spawn_piece()

func check_line_clear():
	var lines_to_clear = []
	for y in range(ROWS):
		var is_full = true
		for x in range(COLS):
			if grid[y][x] == null:
				is_full = false
				break
		if is_full:
			lines_to_clear.append(y)
			
	if lines_to_clear.size() > 0:
		# 파티클 위치 설정 (마지막 줄 기준 중앙)
		clear_particles.position = Vector2((COLS * CELL_SIZE) / 2, lines_to_clear[0] * CELL_SIZE)
		clear_particles.restart()
		
		for line_y in lines_to_clear:
			grid.remove_at(line_y)
			var new_row = []
			for x in range(COLS):
				new_row.append(null)
			grid.insert(0, new_row)
		
		score += lines_to_clear.size() * 100 * lines_to_clear.size() # 연속 보너스
		update_score_ui()
		queue_redraw()

func update_score_ui():
	score_label.text = "SCORE: " + str(score)

func get_ghost_position() -> Vector2i:
	var temp_pos = current_pos
	while is_valid_move(temp_pos + Vector2i(0, 1), current_shape):
		temp_pos += Vector2i(0, 1)
	return temp_pos

func draw_block(cell_pos: Vector2, color: Color, is_ghost: bool = false):
	var rect = Rect2(cell_pos.x * CELL_SIZE, cell_pos.y * CELL_SIZE, CELL_SIZE, CELL_SIZE)
	
	if is_ghost:
		draw_rect(rect, COLOR_GHOST, false, 1.0)
		return

	# 입체감 있는 블록 그리기
	# 1. 메인 배경
	draw_rect(rect, color)
	
	# 2. 테두리 및 하이라이트 (Bevel 효과)
	var light = color.lightened(0.3)
	var dark = color.darkened(0.3)
	
	# 상/좌 밝은 선
	draw_line(rect.position, rect.position + Vector2(rect.size.x, 0), light, 2.0)
	draw_line(rect.position, rect.position + Vector2(0, rect.size.y), light, 2.0)
	# 하/우 어두운 선
	draw_line(rect.position + Vector2(0, rect.size.y), rect.end, dark, 2.0)
	draw_line(rect.position + Vector2(rect.size.x, 0), rect.end, dark, 2.0)
	# 검정 외곽 테두리
	draw_rect(rect, Color.BLACK, false, 1.0)

func _draw():
	# 1. 배경 격자 (은은하게)
	for i in range(COLS + 1):
		draw_line(Vector2(i * CELL_SIZE, 0), Vector2(i * CELL_SIZE, ROWS * CELL_SIZE), COLOR_GRID_LINE)
	for j in range(ROWS + 1):
		draw_line(Vector2(0, j * CELL_SIZE), Vector2(COLS * CELL_SIZE, j * CELL_SIZE), COLOR_GRID_LINE)
		
	# 2. 고정된 블록 그리기
	for y in range(ROWS):
		for x in range(COLS):
			if grid[y][x] != null:
				draw_block(Vector2(x, y), grid[y][x])
	
	# 3. 고스트 블록 그리기
	if not is_game_over:
		var ghost_pos = get_ghost_position()
		for cell in current_shape:
			draw_block(Vector2(ghost_pos + cell), current_color, true)
		
		# 4. 현재 움직이는 블록 그리기
		for cell in current_shape:
			draw_block(Vector2(current_pos + cell), current_color)
			
	# 5. 다음 블록 미리보기 그리기 (UI 좌표 기준 소폭 이동)
	var next_preview_pos = Vector2(COLS + 5, 6) # 그리드 밖 오른쪽
	for cell in next_shape:
		draw_block(next_preview_pos + Vector2(cell), next_color)
