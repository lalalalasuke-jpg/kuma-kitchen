extends Control

# レシピ帳: 料理を3×3で並べる。作ったものは絵と名前、まだのものは「？？？」とヒント

var recipes: Array = []
var found := {}  # 作った料理の id → true


func _draw() -> void:
	var font := get_theme_default_font()
	var cw := size.x / 3.0
	var ch := 220.0
	for k in recipes.size():
		var r: Dictionary = recipes[k]
		var c := Vector2((k % 3 + 0.5) * cw, (k / 3) * ch + 80)
		var got: bool = found.has(r.id)
		Art._box(self, Rect2(c + Vector2(-cw / 2 + 8, -70), Vector2(cw - 16, ch - 14)), Color(1, 0.99, 0.95) if got else Color(0.95, 0.92, 0.86), 14, 2)
		if got:
			Art.dish(self, r.kind, r.color, c, 0.9)
		else:
			Art.dish(self, "unknown", Color.WHITE, c, 0.9)
			draw_string(font, c + Vector2(-12, 14), "?", HORIZONTAL_ALIGNMENT_LEFT, -1, 34, Color(1, 1, 1))
		var name: String = r.name if got else "？？？"
		draw_string(font, c + Vector2(-cw / 2 + 12, 84), name, HORIZONTAL_ALIGNMENT_CENTER, cw - 24, 20, Art.LINE)
		if not got:
			draw_string(font, c + Vector2(-cw / 2 + 12, 116), r.hint, HORIZONTAL_ALIGNMENT_CENTER, cw - 24, 16, Color(0.5, 0.42, 0.34))
