extends CanvasLayer

@onready var score_label = $ScoreLabel
@onready var game_over_rect = $GameOverRect
@onready var next_piece_display = $NextPieceDisplay

func update_score(score: int):
	score_label.text = "SCORE: " + str(score)

func show_game_over(show: bool):
	game_over_rect.visible = show

func update_next_piece(shape: Array, color: Color):
	# 기존 미리보기 삭제
	for child in next_piece_display.get_children():
		child.queue_free()
	
	# 간단한 미리보기용 Node2D 생성 (또는 직접 그리기 위해 PieceDisplay 같은 것을 쓸 수도 있음)
	# 여기서는 간단히 Piece 노드와 유사한 그리기 로직을 위해 별도 그리기 수행
	next_piece_display.queue_redraw()

func _ready():
	next_piece_display.draw.connect(_on_next_piece_draw)

func _on_next_piece_draw():
	# Main이나 HUD 변수를 통해 공유된 데이터로 그림
	# 이 부분은 Main에서 HUD에 데이터를 전달하고 그리기를 트리거하는 방식으로 처리
	pass

# 대안적으로 HUD 내부에서 next_shape/color를 직접 가지고 그리기
var next_shape: Array = []
var next_color: Color = Color.WHITE

func set_next_piece(shape: Array, color: Color):
	next_shape = shape
	next_color = color
	next_piece_display.queue_redraw()

func _on_next_piece_draw_custom():
	for cell in next_shape:
		Constants.draw_block(next_piece_display, Vector2(cell), next_color)

# 연결
func _init():
	pass

func _on_ready_late():
	next_piece_display.draw.disconnect(_on_next_piece_draw)
	next_piece_display.draw.connect(_on_next_piece_draw_custom)

func _ready_ext():
	_on_ready_late()
