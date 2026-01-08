extends Node2D

signal lines_cleared(count)

var grid: Array = []

func _ready():
	init_grid()

func init_grid():
	grid.clear()
	for y in range(Constants.ROWS):
		var row = []
		for x in range(Constants.COLS):
			row.append(null)
		grid.append(row)
	queue_redraw()

func is_cell_occupied(x: int, y: int) -> bool:
	if x < 0 or x >= Constants.COLS or y >= Constants.ROWS:
		return true
	if y >= 0 and grid[y][x] != null:
		return true
	return false

func lock_piece(pos: Vector2i, shape: Array, color: Color):
	for cell in shape:
		var grid_pos = pos + cell
		if grid_pos.y >= 0:
			grid[grid_pos.y][grid_pos.x] = color
	check_line_clear()
	queue_redraw()

func check_line_clear():
	var lines_to_clear = []
	for y in range(Constants.ROWS):
		var is_full = true
		for x in range(Constants.COLS):
			if grid[y][x] == null:
				is_full = false
				break
		if is_full:
			lines_to_clear.append(y)
			
	if lines_to_clear.size() > 0:
		for line_y in lines_to_clear:
			grid.remove_at(line_y)
			var new_row = []
			for x in range(Constants.COLS):
				new_row.append(null)
			grid.insert(0, new_row)
		
		lines_cleared.emit(lines_to_clear.size())
		queue_redraw()

func _draw():
	# 1. 배경 격자 및 테두리 (Constants의 유틸리티 사용 불가능하므로 직접 그리기)
	var board_rect = Rect2(-2, -2, Constants.COLS * Constants.CELL_SIZE + 4, Constants.ROWS * Constants.CELL_SIZE + 4)
	draw_rect(board_rect, Constants.COLOR_BOARD_BORDER, false, 3.0)
	
	for i in range(Constants.COLS + 1):
		draw_line(Vector2(i * Constants.CELL_SIZE, 0), Vector2(i * Constants.CELL_SIZE, Constants.ROWS * Constants.CELL_SIZE), Constants.COLOR_GRID_LINE)
	for j in range(Constants.ROWS + 1):
		draw_line(Vector2(0, j * Constants.CELL_SIZE), Vector2(Constants.COLS * Constants.CELL_SIZE, j * Constants.CELL_SIZE), Constants.COLOR_GRID_LINE)
		
	# 2. 고정된 블록 그리기
	for y in range(Constants.ROWS):
		for x in range(Constants.COLS):
			if grid[y][x] != null:
				Constants.draw_block(self, Vector2(x, y), grid[y][x])
