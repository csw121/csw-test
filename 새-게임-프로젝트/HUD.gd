extends CanvasLayer

@onready var score_label = $ScoreLabel
@onready var game_over_rect = $GameOverRect
@onready var next_piece_display = $NextPieceDisplay

func update_score(score: int):
	score_label.text = "SCORE: " + str(score)

func show_game_over(show: bool):
	game_over_rect.visible = show

var next_shape: Array = []
var next_color: Color = Color.WHITE

func set_next_piece(shape: Array, color: Color):
	next_shape = shape
	next_color = color
	next_piece_display.queue_redraw()

func _ready():
	next_piece_display.draw.connect(_on_next_piece_draw)

func _on_next_piece_draw():
	for cell in next_shape:
		# 미리보기 위치 조정을 위해 오프셋을 줄 수 있습니다.
		# 여기서는 0,0을 기준으로 그립니다.
		Constants.draw_block(next_piece_display, Vector2(cell), next_color)

