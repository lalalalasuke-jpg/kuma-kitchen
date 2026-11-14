class_name Art
extends RefCounted

# 絵を描く部品（材料・料理・くま）。どの CanvasItem の _draw() からでも呼べるように static にしている。
# ci.draw_circle(...) のように、渡された ci に描く。

const LINE := Color(0.33, 0.22, 0.14)  # ふちどり


static func _outlined_circle(ci: CanvasItem, c: Vector2, r: float, fill: Color, w := 3.0) -> void:
	ci.draw_circle(c, r + w, LINE)
	ci.draw_circle(c, r, fill)


static func _box(ci: CanvasItem, r: Rect2, fill: Color, radius := 8, border := 3) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = fill
	sb.set_corner_radius_all(radius)
	sb.border_color = LINE
	sb.set_border_width_all(border)
	ci.draw_style_box(sb, r)


# ---------------------------------------------------------------- 材料

static func ingredient(ci: CanvasItem, id: String, p: Vector2, s := 1.0) -> void:
	match id:
		"turnip":  # カブ: 白い丸に、緑の葉っぱ
			for a in [-0.5, 0.0, 0.5]:
				var tip := p + Vector2(sin(a) * 30, -46).rotated(a * 0.3) * s
				ci.draw_line(p + Vector2(0, -14) * s, tip, LINE, 9 * s)
				ci.draw_line(p + Vector2(0, -14) * s, tip, Color(0.35, 0.7, 0.3), 6 * s)
			_outlined_circle(ci, p, 22 * s, Color(0.97, 0.96, 0.98))
			ci.draw_circle(p + Vector2(0, -12) * s, 9 * s, Color(0.85, 0.6, 0.85))
			ci.draw_line(p + Vector2(0, 22) * s, p + Vector2(2, 32) * s, LINE, 3 * s)
		"tomato":  # トマト: 赤い丸に、緑のへた
			_outlined_circle(ci, p, 24 * s, Color(0.9, 0.22, 0.16))
			ci.draw_circle(p + Vector2(-8, -8) * s, 6 * s, Color(1, 0.55, 0.5))
			for k in 5:
				var a := -PI / 2 + k * TAU / 5
				ci.draw_line(p + Vector2(0, -20) * s, p + (Vector2(0, -20) + Vector2(cos(a), sin(a) * 0.5) * 14) * s, Color(0.3, 0.6, 0.25), 5 * s)
		"strawberry":  # イチゴ: 赤いしずく型に、つぶつぶ
			var pts := PackedVector2Array()
			for k in 24:
				var a := TAU * k / 24.0
				var r := 22.0 * (1.0 - 0.35 * sin(a))  # 下にいくほど細く
				pts.append(p + Vector2(cos(a) * r, sin(a) * r * 1.15 + 4) * s)
			ci.draw_colored_polygon(pts, Color(0.92, 0.2, 0.3))
			pts.append(pts[0])
			ci.draw_polyline(pts, LINE, 3)
			for q in [Vector2(-8, -2), Vector2(6, 0), Vector2(-2, 10), Vector2(9, 12), Vector2(-9, 14), Vector2(2, -8)]:
				ci.draw_circle(p + q * s, 1.8 * s, Color(1, 0.9, 0.5))
			for k in 4:
				var a := PI + k * PI / 3
				ci.draw_line(p + Vector2(0, -18) * s, p + (Vector2(0, -18) + Vector2(cos(a), sin(a) * 0.6) * 13) * s, Color(0.3, 0.6, 0.25), 5 * s)
		"milk":  # ミルク: ビン
			_box(ci, Rect2(p + Vector2(-16, -16) * s, Vector2(32, 44) * s), Color(0.98, 0.98, 1), int(8 * s))
			_box(ci, Rect2(p + Vector2(-9, -30) * s, Vector2(18, 16) * s), Color(0.98, 0.98, 1), int(4 * s))
			_box(ci, Rect2(p + Vector2(-11, -36) * s, Vector2(22, 8) * s), Color(0.3, 0.55, 0.9), int(3 * s))
			ci.draw_rect(Rect2(p + Vector2(-13, 2) * s, Vector2(26, 12) * s), Color(0.3, 0.55, 0.9))
		"egg":  # たまご: たまご型（下がふっくら）
			var pts := PackedVector2Array()
			for k in 28:
				var a := TAU * k / 28.0
				var r := 20.0 * (1.0 + 0.15 * sin(a))
				pts.append(p + Vector2(cos(a) * r * 0.85, sin(a) * r * 1.15) * s)
			ci.draw_colored_polygon(pts, Color(1, 0.97, 0.9))
			pts.append(pts[0])
			ci.draw_polyline(pts, LINE, 3)
			ci.draw_circle(p + Vector2(-6, -8) * s, 4 * s, Color(1, 1, 1))
		"flour":  # 小麦粉: ふくろ
			var bag := PackedVector2Array([p + Vector2(-22, -26) * s, p + Vector2(22, -26) * s, p + Vector2(26, 28) * s, p + Vector2(-26, 28) * s])
			ci.draw_colored_polygon(bag, Color(0.96, 0.92, 0.82))
			bag.append(bag[0])
			ci.draw_polyline(bag, LINE, 3)
			ci.draw_line(p + Vector2(-22, -18) * s, p + Vector2(22, -18) * s, LINE, 2)
			for k in 3:  # 麦の穂
				ci.draw_circle(p + Vector2(0, -2 + k * 9) * s, 3.5 * s, Color(0.85, 0.65, 0.3))
			ci.draw_line(p + Vector2(0, -6) * s, p + Vector2(0, 24) * s, Color(0.6, 0.45, 0.2), 2)
		"butter":  # バター: お皿の上のかたまり
			ci.draw_set_transform(p + Vector2(0, 18) * s, 0, Vector2(1, 0.35))
			ci.draw_circle(Vector2.ZERO, 30 * s + 3, LINE)
			ci.draw_circle(Vector2.ZERO, 30 * s, Color(0.9, 0.95, 1))
			ci.draw_set_transform(Vector2.ZERO)
			_box(ci, Rect2(p + Vector2(-20, -12) * s, Vector2(40, 26) * s), Color(1, 0.9, 0.5), int(5 * s))
			ci.draw_rect(Rect2(p + Vector2(-20, -12) * s, Vector2(40, 7) * s), Color(1, 0.95, 0.7))


# ---------------------------------------------------------------- 料理

static func dish(ci: CanvasItem, kind: String, color: Color, p: Vector2, s := 1.0) -> void:
	match kind:
		"bowl":  # スープ皿
			var pts := PackedVector2Array()
			for k in 17:
				var a := PI * k / 16.0
				pts.append(p + Vector2(cos(a) * 46, sin(a) * 30) * s)
			ci.draw_colored_polygon(pts, Color(1, 1, 1))
			pts.append(pts[0])
			ci.draw_polyline(pts, LINE, 3)
			ci.draw_set_transform(p, 0, Vector2(1, 0.32))
			ci.draw_circle(Vector2.ZERO, 46 * s + 3, LINE)
			ci.draw_circle(Vector2.ZERO, 46 * s, Color(1, 1, 1))
			ci.draw_circle(Vector2.ZERO, 38 * s, color)
			ci.draw_set_transform(Vector2.ZERO)
			for k in 3:  # 湯気
				var x := (k - 1) * 16.0
				ci.draw_arc(p + Vector2(x, -26) * s, 7 * s, PI * 0.5, PI * 1.5, 8, Color(1, 1, 1, 0.8), 3)
				ci.draw_arc(p + Vector2(x, -40) * s, 7 * s, -PI * 0.5, PI * 0.5, 8, Color(1, 1, 1, 0.8), 3)
		"plate":  # 平らなお皿に、まるい煮もの
			ci.draw_set_transform(p + Vector2(0, 10) * s, 0, Vector2(1, 0.35))
			ci.draw_circle(Vector2.ZERO, 52 * s + 3, LINE)
			ci.draw_circle(Vector2.ZERO, 52 * s, Color(1, 1, 1))
			ci.draw_set_transform(Vector2.ZERO)
			for q in [Vector2(-16, 0), Vector2(14, 2), Vector2(0, -10)]:
				_outlined_circle(ci, p + q * s, 13 * s, color, 2)
		"jar":  # ジャムやソースのビン
			_box(ci, Rect2(p + Vector2(-24, -22) * s, Vector2(48, 50) * s), color, int(12 * s))
			ci.draw_rect(Rect2(p + Vector2(-17, -14) * s, Vector2(10, 30) * s), Color(1, 1, 1, 0.35))
			_box(ci, Rect2(p + Vector2(-26, -36) * s, Vector2(52, 16) * s), Color(0.95, 0.85, 0.55), int(4 * s))
			_box(ci, Rect2(p + Vector2(-14, -2) * s, Vector2(28, 18) * s), Color(1, 0.98, 0.92), int(3 * s), 2)
		"glass":  # グラス
			var pts := PackedVector2Array([p + Vector2(-22, -34) * s, p + Vector2(22, -34) * s, p + Vector2(16, 30) * s, p + Vector2(-16, 30) * s])
			ci.draw_colored_polygon(pts, Color(0.9, 0.95, 1, 0.6))
			ci.draw_colored_polygon(PackedVector2Array([p + Vector2(-20, -18) * s, p + Vector2(20, -18) * s, p + Vector2(16, 30) * s, p + Vector2(-16, 30) * s]), color)
			pts.append(pts[0])
			ci.draw_polyline(pts, LINE, 3)
			ci.draw_line(p + Vector2(8, -46) * s, p + Vector2(2, 10) * s, Color(0.95, 0.4, 0.5), 5 * s)  # ストロー
		"cup":  # マグカップ
			_box(ci, Rect2(p + Vector2(-24, -24) * s, Vector2(44, 50) * s), Color(0.55, 0.75, 0.95), int(8 * s))
			ci.draw_arc(p + Vector2(22, 0) * s, 12 * s, -PI / 2, PI / 2, 10, LINE, 9 * s)
			ci.draw_arc(p + Vector2(22, 0) * s, 12 * s, -PI / 2, PI / 2, 10, Color(0.55, 0.75, 0.95), 4 * s)
			ci.draw_set_transform(p + Vector2(-2, -22) * s, 0, Vector2(1, 0.3))
			ci.draw_circle(Vector2.ZERO, 18 * s, color)
			ci.draw_set_transform(Vector2.ZERO)
			for k in 2:
				ci.draw_arc(p + Vector2(-10 + k * 16, -40) * s, 6 * s, PI * 0.5, PI * 1.5, 8, Color(1, 1, 1, 0.8), 3)
		"pancake":  # パンケーキ: 3段重ねにバター
			ci.draw_set_transform(p + Vector2(0, 22) * s, 0, Vector2(1, 0.35))
			ci.draw_circle(Vector2.ZERO, 50 * s + 3, LINE)
			ci.draw_circle(Vector2.ZERO, 50 * s, Color(1, 1, 1))
			ci.draw_set_transform(Vector2.ZERO)
			for k in 3:
				_box(ci, Rect2(p + Vector2(-34, 2 - k * 13) * s, Vector2(68, 15) * s), color, int(7 * s), 2)
			_box(ci, Rect2(p + Vector2(-9, -42) * s, Vector2(18, 10) * s), Color(1, 0.9, 0.5), int(3 * s), 2)
		"cookies":  # クッキー: お皿に3枚
			ci.draw_set_transform(p + Vector2(0, 14) * s, 0, Vector2(1, 0.35))
			ci.draw_circle(Vector2.ZERO, 50 * s + 3, LINE)
			ci.draw_circle(Vector2.ZERO, 50 * s, Color(1, 1, 1))
			ci.draw_set_transform(Vector2.ZERO)
			for q in [Vector2(-20, 2), Vector2(18, 4), Vector2(0, -10)]:
				_outlined_circle(ci, p + q * s, 15 * s, color, 2)
				ci.draw_circle(p + q * s, 5 * s, Color(0.9, 0.2, 0.3))
		"eggs":  # ゆでたまご: エッグスタンドに
			_box(ci, Rect2(p + Vector2(-16, 6) * s, Vector2(32, 22) * s), Color(0.55, 0.75, 0.95), int(6 * s))
			ingredient(ci, "egg", p + Vector2(0, -10) * s, s)
		"pudding":  # プリン: 台形にカラメル
			ci.draw_set_transform(p + Vector2(0, 24) * s, 0, Vector2(1, 0.35))
			ci.draw_circle(Vector2.ZERO, 46 * s + 3, LINE)
			ci.draw_circle(Vector2.ZERO, 46 * s, Color(1, 1, 1))
			ci.draw_set_transform(Vector2.ZERO)
			var pd := PackedVector2Array([p + Vector2(-20, -24) * s, p + Vector2(20, -24) * s, p + Vector2(30, 22) * s, p + Vector2(-30, 22) * s])
			ci.draw_colored_polygon(pd, color)
			ci.draw_colored_polygon(PackedVector2Array([p + Vector2(-20, -24) * s, p + Vector2(20, -24) * s, p + Vector2(22, -14) * s, p + Vector2(-22, -14) * s]), Color(0.6, 0.35, 0.15))
			pd.append(pd[0])
			ci.draw_polyline(pd, LINE, 3)
		"mystery":  # ふしぎな料理: むらさきのもくもく
			ci.draw_set_transform(p + Vector2(0, 14) * s, 0, Vector2(1, 0.32))
			ci.draw_circle(Vector2.ZERO, 50 * s + 3, LINE)
			ci.draw_circle(Vector2.ZERO, 50 * s, Color(1, 1, 1))
			ci.draw_set_transform(Vector2.ZERO)
			for q in [Vector2(-18, 0), Vector2(16, -2), Vector2(0, -16)]:
				_outlined_circle(ci, p + q * s, 18 * s, color, 2)
			ci.draw_string(ThemeDB.fallback_font, p + Vector2(-8, -2) * s, "?", HORIZONTAL_ALIGNMENT_LEFT, -1, int(30 * s), Color(1, 1, 1))
		"unknown":  # まだ作っていない料理（レシピ帳）
			ci.draw_set_transform(p + Vector2(0, 10) * s, 0, Vector2(1, 0.35))
			ci.draw_circle(Vector2.ZERO, 48 * s, Color(0.8, 0.76, 0.7))
			ci.draw_set_transform(Vector2.ZERO)


# ---------------------------------------------------------------- くま紳士ららすけ

# face: 1 = 右向き、-1 = 左向き。t: 動きのタイマー。stir: かき混ぜ中。happy: にっこり度
static func bear(ci: CanvasItem, p: Vector2, face: float, t: float, stir := false, happy := false) -> void:
	var fur := Color(0.7, 0.69, 0.72)
	var fur_dark := Color(0.55, 0.54, 0.58)
	var bob := Vector2(0, -absf(sin(t * 3)) * 3) if stir else Vector2.ZERO
	ci.draw_set_transform(p + Vector2(0, 92), 0, Vector2(1, 0.3))
	ci.draw_circle(Vector2.ZERO, 46, Color(0, 0, 0, 0.18))  # 影
	ci.draw_set_transform(Vector2.ZERO)
	# 足
	for side in [-1, 1]:
		_box(ci, Rect2(p + Vector2(side * 18 - 11, 66), Vector2(22, 26)), fur, 9)
	# からだ（シャツ＋ベスト）
	_box(ci, Rect2(p + Vector2(-34, 4) + bob, Vector2(68, 70)), Color(0.86, 0.85, 0.82), 22)
	_box(ci, Rect2(p + Vector2(-34, 6) + bob, Vector2(68, 66)), Color(0.32, 0.32, 0.35), 22)
	ci.draw_colored_polygon(PackedVector2Array([p + Vector2(-10, 6) + bob, p + Vector2(10, 6) + bob, p + Vector2(0, 30) + bob]), Color(0.92, 0.91, 0.88))
	for k in 2:
		ci.draw_circle(p + Vector2(0, 40 + k * 14) + bob, 3, Color(0.85, 0.75, 0.4))
	# うで（かき混ぜ中は前の手が動く）
	var arm := Vector2(face * 38, 26) + Vector2(cos(t * 8) * 6, sin(t * 8) * 4) * (1.0 if stir else 0.0)
	_outlined_circle(ci, p + arm + bob, 12, fur)
	_outlined_circle(ci, p + Vector2(-face * 36, 30) + bob, 12, fur)
	# 頭
	var h := p + Vector2(0, -30) + bob
	for side in [-1, 1]:  # 耳
		_outlined_circle(ci, h + Vector2(side * 30, -30), 15, fur)
		ci.draw_circle(h + Vector2(side * 30, -30), 8, fur_dark)
	_outlined_circle(ci, h, 42, fur)
	var look := Vector2(face * 5, 0)
	ci.draw_set_transform(h + look + Vector2(0, 14), 0, Vector2(1, 0.75))
	ci.draw_circle(Vector2.ZERO, 18, Color(0.93, 0.92, 0.9))  # 口のまわり
	ci.draw_set_transform(Vector2.ZERO)
	ci.draw_circle(h + look + Vector2(0, 6), 6, LINE)  # 鼻
	if happy:
		ci.draw_arc(h + look + Vector2(0, 16), 7, 0.2, PI - 0.2, 10, LINE, 3)
	else:
		ci.draw_line(h + look + Vector2(0, 10), h + look + Vector2(0, 16), LINE, 2)
		ci.draw_arc(h + look + Vector2(-4, 16), 4, 0, PI, 6, LINE, 2)
		ci.draw_arc(h + look + Vector2(4, 16), 4, 0, PI, 6, LINE, 2)
	var blink := fmod(t, 3.4) < 0.12
	var eyes := [h + look + Vector2(-16, -8), h + look + Vector2(16, -8)]
	for e in eyes:
		if blink or happy:
			ci.draw_arc(e + Vector2(0, 3), 5, PI + 0.3, TAU - 0.3, 8, LINE, 3)
		else:
			ci.draw_circle(e, 4.5, LINE)
			ci.draw_circle(e + Vector2(1.5, -1.5), 1.5, Color(1, 1, 1))
	# モノクル: くま自身の左目（正面から見て向かって右の目）。鎖はお腹のほうへ
	var mono: Vector2 = eyes[1]
	ci.draw_arc(mono, 11, 0, TAU, 24, LINE, 5)
	ci.draw_arc(mono, 11, 0, TAU, 24, Color(0.87, 0.7, 0.34), 3)
	ci.draw_polyline(PackedVector2Array([mono + Vector2(10, 6), mono + Vector2(14, 30), p + Vector2(18, 22) + bob, p + Vector2(10, 40) + bob]), Color(0.87, 0.7, 0.34), 2)
	ci.draw_circle(h + look + Vector2(-26, 8), 6, Color(1, 0.6, 0.62, 0.5))  # ほっぺ
	ci.draw_circle(h + look + Vector2(26, 8), 6, Color(1, 0.6, 0.62, 0.5))
	# カンカン帽（ベージュに黒いリボン）
	_box(ci, Rect2(h + Vector2(-44, -42), Vector2(88, 12)), Color(0.9, 0.8, 0.6), 6)
	_box(ci, Rect2(h + Vector2(-26, -66), Vector2(52, 28)), Color(0.9, 0.8, 0.6), 6)
	ci.draw_rect(Rect2(h + Vector2(-25, -48), Vector2(50, 8)), Color(0.15, 0.13, 0.13))
