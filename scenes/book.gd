extends Control

# レシピ帳: 料理を 3列×3段 で並べる（入りきらない分は次のページ）。
# 作ったものは絵と名前、まだのものは「？？？」。妖精さんが書いてくれたヒントは、うすむらさきの字で出す。

const COLS := 3
const ROWS := 3
const FAIRY := Color(0.62, 0.42, 0.78)

var recipes: Array = []  # いま見られる料理（開放された材料の分だけ）
var found := {}  # 作った料理の id → true
var hinted := {}  # 妖精さんがヒントを書いてくれた料理の id → true
var page := 0


func pages() -> int:
	return maxi(1, ceili(recipes.size() / float(COLS * ROWS)))


func _draw() -> void:
	var font := get_theme_default_font()
	var cw := size.x / COLS
	var ch := 196.0
	var per := COLS * ROWS
	for i in range(page * per, mini(recipes.size(), (page + 1) * per)):
		var k := i - page * per
		var r: Dictionary = recipes[i]
		var c := Vector2((k % COLS + 0.5) * cw, (k / COLS) * ch + 70)
		var got: bool = found.has(r.id)
		Art._box(self, Rect2(c + Vector2(-cw / 2 + 6, -64), Vector2(cw - 12, ch - 10)), Color(1, 0.99, 0.95) if got else Color(0.95, 0.92, 0.86), 14, 2)
		if got:
			Art.dish(self, r.kind, r.color, c, 0.8)
		else:
			Art.dish(self, "unknown", Color.WHITE, c, 0.8)
			draw_string(font, c + Vector2(-10, 12), "?", HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color(1, 1, 1))
		var name: String = r.name if got else "？？？"
		draw_string(font, c + Vector2(-cw / 2 + 10, 72), name, HORIZONTAL_ALIGNMENT_CENTER, cw - 20, 18, Art.LINE)
		if not got and hinted.has(r.id):
			draw_string(font, c + Vector2(-cw / 2 + 10, 102), r.hint, HORIZONTAL_ALIGNMENT_CENTER, cw - 20, 15, FAIRY)
	if not hinted.is_empty():
		draw_string(font, Vector2(0, ROWS * ch + 26), "（ところどころ、自分のじゃない字で書いてある……妖精さん？）", HORIZONTAL_ALIGNMENT_CENTER, size.x, 16, FAIRY)
