extends Node2D

signal locked(pos, shape, color)

var shape: Array = []
var color: Color = Color.WHITE
var grid_pos: Vector2i = Vector2i(0, 0)
var board: Node2D = null # Board 참조

func setup(p_shape: Array, p_color: Color, p_pos: Vector2i, p_board: Node2D):
	shape = p_shape
	color = p_color
	grid_pos = p_pos
	board = p_board
	queue_redraw()

func move(dir: Vector2i) -> bool:
	var new_pos = grid_pos + dir
	if is_valid_move(new_pos, shape):
		grid_pos = new_pos
		queue_redraw()
		return true
	return false

func rotate_piece():
	var new_shape = []
	for cell in shape:
		new_shape.append(Vector2i(-cell.y, cell.x))
	apply_shape_change(new_shape)

func flip_piece():
	var new_shape = []
	for cell in shape:
		new_shape.append(Vector2i(-cell.x, cell.y))
	apply_shape_change(new_shape)

func apply_shape_change(new_shape: Array):
	var kicks = [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(-2, 0), Vector2i(2, 0)]
	for kick in kicks:
		if is_valid_move(grid_pos + kick, new_shape):
			grid_pos += kick
			shape = new_shape
			queue_redraw()
			return

func is_valid_move(pos: Vector2i, p_shape: Array) -> bool:
	if board == null: return false
	for cell in p_shape:
		var target_pos = pos + cell
		if board.is_cell_occupied(target_pos.x, target_pos.y):
			return false
	return true

func hard_drop():
	while move(Vector2i(0, 1)):
		pass
	emit_signal("locked", grid_pos, shape, color)

func get_ghost_position() -> Vector2i:
	var temp_pos = grid_pos
	while is_valid_move(temp_pos + Vector2i(0, 1), shape):
		temp_pos += Vector2i(0, 1)
	return temp_pos

func _draw():
	# 1. 고스트 블록 그리기
	var ghost_pos = get_ghost_position()
	# 보드 상대 좌표를 캔버스 좌표로 변환하기 위해 board 위치는 무시 (Piece 자체가 Board 하위에 있거나 위치 맞춰야 함)
	# 여기서는 Piece의 position이 Board와 동기화된다고 가정하거나 직접 계산
	for cell in shape:
		var draw_pos = (ghost_pos - grid_pos + cell)
		Constants.draw_block(self, Vector2(draw_pos), color, true)
	
	# 2. 현재 블록 그리기
	for cell in shape:
		Constants.draw_block(self, Vector2(cell), color)

func _process(_delta):
	# 개별 Piece에서 position 업데이트 (격자 좌표 -> 화면 좌표)
	position = Vector2(grid_pos) * float(Constants.CELL_SIZE)
