extends Node2D

# キッチンの絵: 壁・棚（材料と残りの数）・コンロと鍋・くま・できた料理。
# 状態（stock / pot など）は main.gd が持っていて、ここは描くだけ＋タップした場所の判定。

const FONT := preload("res://fonts/NotoSansJP-Subset.ttf")
const SHELF_Y := 300  # 棚の材料の中心の高さ
const POT := Vector2(300, 700)  # 鍋の中心
const BEAR := Vector2(560, 700)
const DISH := Vector2(560, 470)  # できた料理を置く台の上

var order: Array = []  # 材料の並び順（main から）
var stock := {}  # 材料ごとの残り
var pot: Array = []  # 鍋に入れた材料
var capacity := 2  # 鍋に入れられる数（上級編で3）
var cooking := false
var last_dish := {}  # 最後にできた料理（kind, color）
var happy := false
var _t := 0.0


# 材料が増えるほど、1つぶんの幅をせまくする
func slot_w() -> float:
	return minf(160.0, 672.0 / maxi(order.size(), 1))


func slot_center(k: int) -> Vector2:
	return Vector2(360 + (k - (order.size() - 1) / 2.0) * slot_w(), SHELF_Y)


func slot_at(pos: Vector2) -> String:
	var w := slot_w()
	for k in order.size():
		if Rect2(slot_center(k) - Vector2(w / 2.0 - 4, 90), Vector2(w - 8, 170)).has_point(pos):
			return order[k]
	return ""


func pot_hit(pos: Vector2) -> bool:
	return Rect2(POT - Vector2(130, 150), Vector2(260, 260)).has_point(pos)


# 鍋の上に材料を浮かせて見せる位置（2個なら左右、3個なら3つ並び）
func _slot_pos(k: int) -> Vector2:
	var gap := 100.0 if capacity < 3 else 80.0
	return POT + Vector2((k - (capacity - 1) / 2.0) * gap, -90)


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	# 壁と床
	draw_rect(Rect2(0, 130, 720, 860), Color(0.99, 0.93, 0.8))
	for x in range(0, 720, 48):  # 壁のたてじま
		draw_rect(Rect2(x, 130, 24, 470), Color(1, 0.96, 0.86))
	draw_rect(Rect2(0, 600, 720, 390), Color(0.82, 0.62, 0.42))
	for y in range(600, 990, 40):
		draw_line(Vector2(0, y), Vector2(720, y), Color(0.72, 0.52, 0.34), 2)
	# 窓
	Art._box(self, Rect2(470, 160, 200, 120), Color(0.7, 0.86, 0.98), 10, 5)
	draw_line(Vector2(570, 162), Vector2(570, 278), Art.LINE, 4)
	draw_circle(Vector2(520, 200), 18, Color(1, 0.95, 0.6))
	# 棚の板
	Art._box(self, Rect2(30, SHELF_Y + 52, 660, 22), Color(0.72, 0.5, 0.3), 6)
	for k in order.size():
		var id: String = order[k]
		var c := slot_center(k)
		var n: int = stock.get(id, 0)
		if n > 0:
			Art.ingredient(self, id, c + Vector2(0, -4), minf(1.25, slot_w() / 105.0))
		else:
			draw_circle(c, 26, Color(0.85, 0.78, 0.68, 0.6))
		Art._box(self, Rect2(c + Vector2(-34, 82), Vector2(68, 36)), Color(1, 0.99, 0.95), 10)
		draw_string(FONT, c + Vector2(-30, 110), "×%d" % n, HORIZONTAL_ALIGNMENT_CENTER, 60, 26, Art.LINE)
	# 料理を置く台
	Art._box(self, Rect2(DISH + Vector2(-90, 50), Vector2(180, 22)), Color(0.72, 0.5, 0.3), 6)
	if not last_dish.is_empty():
		Art.dish(self, last_dish.kind, last_dish.color, DISH, 1.2)
	# コンロ
	Art._box(self, Rect2(POT + Vector2(-150, 70), Vector2(300, 220)), Color(0.85, 0.85, 0.88), 16, 4)
	for k in 2:
		draw_circle(POT + Vector2(-60 + k * 120, 230), 18, Color(0.4, 0.4, 0.45))
	if cooking:  # 火
		for k in 5:
			var x := -60.0 + k * 30
			var hgt := 22 + sin(_t * 20 + k) * 8
			draw_colored_polygon(PackedVector2Array([POT + Vector2(x - 12, 74), POT + Vector2(x + 12, 74), POT + Vector2(x, 74 - hgt)]), Color(1, 0.55, 0.15))
	# 鍋
	var pot_color := Color(0.55, 0.6, 0.68) if capacity < 3 else Color(0.85, 0.5, 0.3)  # 上級編は新しい銅の鍋
	Art._box(self, Rect2(POT + Vector2(-110, -20), Vector2(220, 100)), pot_color, 30, 4)
	Art._box(self, Rect2(POT + Vector2(-150, -6), Vector2(40, 18)), Color(0.4, 0.4, 0.45), 8)
	Art._box(self, Rect2(POT + Vector2(110, -6), Vector2(40, 18)), Color(0.4, 0.4, 0.45), 8)
	draw_set_transform(POT + Vector2(0, -20), 0, Vector2(1, 0.28))
	draw_circle(Vector2.ZERO, 113, Art.LINE)
	draw_circle(Vector2.ZERO, 110, pot_color.darkened(0.15))
	draw_circle(Vector2.ZERO, 96, Color(0.98, 0.85, 0.6) if cooking else Color(0.3, 0.32, 0.38))
	draw_set_transform(Vector2.ZERO)
	# 鍋に入れた材料（鍋の上にふわっと浮かせて見せる）
	for k in pot.size():
		var q := _slot_pos(k) + Vector2(0, sin(_t * 3 + k) * 6)
		if cooking:
			q = POT + Vector2((k - (pot.size() - 1) / 2.0) * 60, -36 + sin(_t * 12 + k) * 4)
		Art.ingredient(self, pot[k], q, 1.0 if not cooking else 0.6)
	if not cooking:
		for k in range(pot.size(), capacity):  # 空いているところ
			var q := _slot_pos(k)
			draw_arc(q, 30, 0, TAU, 24, Color(0.6, 0.5, 0.4, 0.6), 3)
			draw_string(FONT, q + Vector2(-8, 10), "?", HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color(0.6, 0.5, 0.4, 0.8))
	else:  # 湯気とあわ
		for k in 4:
			var ph := fmod(_t * 1.5 + k * 0.25, 1.0)
			draw_circle(POT + Vector2(-60 + k * 40, -40 - ph * 120), 10 + ph * 8, Color(1, 1, 1, 0.6 * (1 - ph)))
	# くま（鍋のほうを向く）
	Art.bear(self, BEAR, -1.0, _t, cooking, happy)
