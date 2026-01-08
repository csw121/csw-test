extends Node

# 테트리스 격자 설정
const COLS = 10
const ROWS = 20
const CELL_SIZE = 30

# 색상 설정
const COLOR_GRID_LINE = Color(0.3, 0.3, 0.5, 0.6)
const COLOR_BOARD_BORDER = Color.GRAY
const COLOR_GHOST = Color(1, 1, 1, 0.2)

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

# 유틸리티 함수: 블록 그리기 (공공용)
static func draw_block(canvas: CanvasItem, cell_pos: Vector2, color: Color, is_ghost: bool = false):
	var rect = Rect2(cell_pos.x * CELL_SIZE, cell_pos.y * CELL_SIZE, CELL_SIZE, CELL_SIZE)
	
	if is_ghost:
		canvas.draw_rect(rect, COLOR_GHOST, false, 1.0)
		return

	# 입체감 있는 블록 그리기
	canvas.draw_rect(rect, color)
	
	var light = color.lightened(0.3)
	var dark = color.darkened(0.3)
	
	canvas.draw_line(rect.position, rect.position + Vector2(rect.size.x, 0), light, 2.0)
	canvas.draw_line(rect.position, rect.position + Vector2(0, rect.size.y), light, 2.0)
	canvas.draw_line(rect.position + Vector2(0, rect.size.y), rect.end, dark, 2.0)
	canvas.draw_line(rect.position + Vector2(rect.size.x, 0), rect.end, dark, 2.0)
	canvas.draw_rect(rect, Color.BLACK, false, 1.0)
