extends Control

# レシピ帳: 料理を 3列×3段 で並べる（入りきらない分は次のページ）。
# 作ったものは絵と名前、まだのものは「？？？」。妖精さんが書いてくれたヒントは、うすむらさきの字で出す。
# 作った料理には、くまのメモ（隠し味のヒント）。隠し味★を見つけたら金色の星。
# ひみつのレシピを1つでも見つけたら、最後に「ひみつのレシピ」のページが増える。

const COLS := 3
const ROWS := 3
const FAIRY := Color(0.62, 0.42, 0.78)
const MEMO := Color(0.72, 0.42, 0.16)

var recipes: Array = []  # いま見られる料理（開放された材料の分だけ）
var secrets: Array = []  # ひみつのレシピ（全部）
var found := {}  # 作った料理の id → true（ひみつのレシピも）
var hinted := {}  # 妖精さんがヒントを書いてくれた料理の id → true
var starred := {}  # 隠し味★を見つけた料理の id → true
var memos := {}  # 料理の id → くまのメモ（隠し味のヒント）。空なら出さない
var star_names := {}  # 料理の id → 隠し味の材料名
var page := 0


func main_pages() -> int:
	return maxi(1, ceili(recipes.size() / float(COLS * ROWS)))


func has_secret_page() -> bool:
	for r in secrets:
		if found.has(r.id):
			return true
	return false


func pages() -> int:
	return main_pages() + (1 if has_secret_page() else 0)


func on_secret_page() -> bool:
	return page >= main_pages()


func secret_count() -> int:
	var n := 0
	for r in secrets:
		if found.has(r.id):
			n += 1
	return n


func _draw() -> void:
	var font := get_theme_default_font()
	var cw := size.x / COLS
	var ch := 196.0
	var per := COLS * ROWS
	var list: Array = secrets if on_secret_page() else recipes
	var start := 0 if on_secret_page() else page * per
	for i in range(start, mini(list.size(), start + per)):
		var k := i - start
		var r: Dictionary = list[i]
		var c := Vector2((k % COLS + 0.5) * cw, (k / COLS) * ch + 70)
		var got: bool = found.has(r.id)
		var paper := [Color(0.97, 0.94, 1), Color(0.9, 0.86, 0.95)] if on_secret_page() else [Color(1, 0.99, 0.95), Color(0.95, 0.92, 0.86)]
		Art._box(self, Rect2(c + Vector2(-cw / 2 + 6, -64), Vector2(cw - 12, ch - 10)), paper[0] if got else paper[1], 14, 2)
		if got:
			Art.dish(self, r.kind, r.color, c, 0.8)
		else:
			Art.dish(self, "unknown", Color.WHITE, c, 0.8)
			draw_string(font, c + Vector2(-10, 12), "?", HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color(1, 1, 1))
		var name: String = r.name if got else "？？？"
		draw_string(font, c + Vector2(-cw / 2 + 10, 72), name, HORIZONTAL_ALIGNMENT_CENTER, cw - 20, 18, Art.LINE)
		if got and starred.has(r.id):
			Art.star(self, c + Vector2(cw / 2 - 30, -38), 15)
			draw_string(font, c + Vector2(-cw / 2 + 10, 102), "隠し味: %s" % star_names.get(r.id, ""), HORIZONTAL_ALIGNMENT_CENTER, cw - 20, 15, Color(0.75, 0.5, 0.1))
		elif got and memos.has(r.id):
			draw_string(font, c + Vector2(-cw / 2 + 10, 102), memos[r.id], HORIZONTAL_ALIGNMENT_CENTER, cw - 20, 14, MEMO)
		elif not got and (hinted.has(r.id) or on_secret_page()):
			var hl: PackedStringArray = r.hint.split("、", false, 1)  # 長いヒントは「、」で2行に
			if hl.size() == 2:
				draw_string(font, c + Vector2(-cw / 2 + 10, 94), hl[0] + "、", HORIZONTAL_ALIGNMENT_CENTER, cw - 20, 14, FAIRY)
				draw_string(font, c + Vector2(-cw / 2 + 10, 112), hl[1], HORIZONTAL_ALIGNMENT_CENTER, cw - 20, 14, FAIRY)
			else:
				draw_string(font, c + Vector2(-cw / 2 + 10, 102), r.hint, HORIZONTAL_ALIGNMENT_CENTER, cw - 20, 14, FAIRY)
	if on_secret_page():
		draw_string(font, Vector2(0, ROWS * ch + 26), "（このページだけ、紙の色がちがう……）", HORIZONTAL_ALIGNMENT_CENTER, size.x, 16, FAIRY)
	elif not hinted.is_empty():
		draw_string(font, Vector2(0, ROWS * ch + 26), "（ところどころ、自分のじゃない字で書いてある……妖精さん？）", HORIZONTAL_ALIGNMENT_CENTER, size.x, 16, FAIRY)
