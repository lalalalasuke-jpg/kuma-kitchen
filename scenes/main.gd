extends Node2D

# くま紳士のキッチン（仮）: 材料を2つえらんで鍋で煮ると料理ができる。レシピ帳を全部うめたらクリア。
# 棚の材料をタップ → 鍋に入る（2つまで。鍋をタップすると1つ戻す）→「煮る」→ 料理ができてレシピ帳へ。
# 材料は使うと減る。「次の日」で少し補充される。何日でレシピ帳をうめられるか。

const BEST_PATH := "user://best.cfg"
const SFX_SETS := ["code", "off"]
const SFX_NAMES := {"code": "音: あり", "off": "音: なし"}
const ORDER := ["turnip", "tomato", "strawberry", "milk"]
const NAMES := {"turnip": "カブ", "tomato": "トマト", "strawberry": "イチゴ", "milk": "ミルク"}
const START_STOCK := 3  # はじめの材料の数（それぞれ）
const DAILY := 2  # 次の日に増える数（それぞれ）
const STOCK_MAX := 6
const COOK_TIME := 1.4
# 料理。pair は使う材料2つ（順番は関係なし）。どれにも当てはまらない組み合わせは「ふしぎな料理」
const RECIPES := [
	{"id": "potage", "name": "カブのポタージュ", "pair": ["turnip", "milk"], "kind": "bowl", "color": Color(0.98, 0.95, 0.84),
		"hint": "白い野菜と白い飲みもの", "say": "まろやかで、紳士的なお味でございます"},
	{"id": "vegsoup", "name": "やさいスープ", "pair": ["turnip", "tomato"], "kind": "bowl", "color": Color(0.95, 0.5, 0.32),
		"hint": "畑の野菜どうし", "say": "畑の恵みが、ひと皿に"},
	{"id": "nimono", "name": "カブの煮もの", "pair": ["turnip", "turnip"], "kind": "plate", "color": Color(0.95, 0.88, 0.62),
		"hint": "白い野菜をたっぷり", "say": "ほっとする、やさしいお味ですな"},
	{"id": "sauce", "name": "トマトソース", "pair": ["tomato", "tomato"], "kind": "jar", "color": Color(0.86, 0.2, 0.14),
		"hint": "赤い野菜をたっぷり", "say": "これは何にでも合いそうですな"},
	{"id": "cream", "name": "トマトクリームスープ", "pair": ["tomato", "milk"], "kind": "bowl", "color": Color(0.98, 0.62, 0.5),
		"hint": "赤い野菜と白い飲みもの", "say": "酸味とまろやかさの、見事な調和"},
	{"id": "jam", "name": "イチゴジャム", "pair": ["strawberry", "strawberry"], "kind": "jar", "color": Color(0.88, 0.14, 0.3),
		"hint": "あまい実をたっぷり", "say": "朝のパンが待ち遠しいですな"},
	{"id": "smilk", "name": "イチゴミルク", "pair": ["strawberry", "milk"], "kind": "glass", "color": Color(1, 0.74, 0.8),
		"hint": "あまい実と白い飲みもの", "say": "なんと、かわいらしい……"},
	{"id": "hotmilk", "name": "ホットミルク", "pair": ["milk", "milk"], "kind": "cup", "color": Color(0.99, 0.98, 0.94),
		"hint": "白い飲みものをたっぷり", "say": "夜ふかしのお供に"},
	{"id": "mystery", "name": "ふしぎな料理", "pair": [], "kind": "mystery", "color": Color(0.58, 0.46, 0.7),
		"hint": "合わない組み合わせ…？", "say": "……これは、なんでございましょう"},
]
const HOWTO := """あそびかた

棚の材料をタップすると、鍋に入るよ（2つまで）
鍋をタップすると、1つ棚にもどすよ
2つ入ったら「煮る」で料理ができる！

できた料理はレシピ帳に登録されるよ
レシピ帳をぜんぶうめたらクリア

材料は使うと減るよ
「次の日」にすると少し増えるよ
何日でうめられるかな？"""
const CREDITS := """クレジット

企画・ゲームデザイン: ららすけ（lalasuke）
プログラム・絵・効果音: Claude（Anthropic の AI）
ららすけと AI がいっしょに作ったゲームです

フォント: Noto Sans JP（SIL Open Font License 1.1）
ゲームエンジン: Godot Engine（MIT License）
© Juan Linietsky, Ariel Manzur and contributors
godotengine.org/license"""

static var skip_title := false  # 「もう一回」でシーンを読み直した時はタイトルを出さない

var best_path := BEST_PATH  # テストでは別のファイルに差し替える
var day := 1
var stock := {}
var pot: Array = []
var found := {}
var cooked := 0  # 作った回数
var sfx_set := "code"
var _sfx_cache := {}
var _sfx_players: Array = []
var _sfx_next := 0
var busy := false

@onready var kitchen: Node2D = $Kitchen

var day_label: Label
var book_button: Button
var sfx_button: Button
var message_label: Label
var cook_button: Button
var next_button: Button
var fade: ColorRect
var popup: PanelContainer
var popup_label: Label
var popup_buttons: VBoxContainer
var book_panel: PanelContainer
var book: Control


func _ready() -> void:
	for id in ORDER:
		stock[id] = START_STOCK
	kitchen.order = ORDER
	_build_ui()
	var cfg := ConfigFile.new()
	if cfg.load(best_path) == OK:
		sfx_set = cfg.get_value("settings", "sfx", sfx_set)
	sfx_button.text = SFX_NAMES[sfx_set]
	_refresh()
	if skip_title:
		_start()
	else:
		busy = true
		fade.color.a = 0.6
		_show_title()


func _show_title() -> void:
	var best := _load_best()
	var text := "くま紳士のキッチン\n\n材料をくみあわせて\nレシピ帳をうめよう"
	if best > 0:
		text += "\n\nベスト: %d日でコンプリート" % best
	_show_popup(text, [["はじめる", _start], ["あそびかた", _show_howto], ["クレジット", _show_credits]])


func _show_howto() -> void:
	_show_popup(HOWTO, [["もどる", _show_title]], 24)


func _show_credits() -> void:
	_show_popup(CREDITS, [["もどる", _show_title]], 22)


func _start() -> void:
	popup.visible = false
	say("棚の材料をタップして、鍋に2つ入れてみよう")
	await _fade_to(0.0)
	busy = false


# ---------------------------------------------------------------- 効果音

func sfx(name: String) -> void:
	if sfx_set == "off":
		return
	var path := "res://sfx/code/%s.wav" % name
	if not _sfx_cache.has(path):
		_sfx_cache[path] = load(path)
	if _sfx_players.is_empty():
		for k in 4:
			var p := AudioStreamPlayer.new()
			add_child(p)
			_sfx_players.append(p)
	var pl: AudioStreamPlayer = _sfx_players[_sfx_next]
	_sfx_next = (_sfx_next + 1) % _sfx_players.size()
	pl.stream = _sfx_cache[path]
	pl.play()


func _on_sfx_pressed() -> void:
	sfx_set = SFX_SETS[(SFX_SETS.find(sfx_set) + 1) % SFX_SETS.size()]
	sfx_button.text = SFX_NAMES[sfx_set]
	var cfg := ConfigFile.new()
	cfg.load(best_path)
	cfg.set_value("settings", "sfx", sfx_set)
	cfg.save(best_path)
	sfx("click")


# ---------------------------------------------------------------- 操作

func _unhandled_input(event: InputEvent) -> void:
	if busy:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_tap(make_input_local(event).position)


func _on_tap(pos: Vector2) -> void:
	var id: String = kitchen.slot_at(pos)
	if id != "":
		add_to_pot(id)
	elif kitchen.pot_hit(pos):
		take_back()


func add_to_pot(id: String) -> void:
	if pot.size() >= 2:
		sfx("error")
		say("鍋はいっぱい。鍋をタップすると材料をもどせるよ")
		return
	if stock[id] <= 0:
		sfx("error")
		say("%sがもうないよ。「次の日」にすると増えるよ" % NAMES[id])
		return
	stock[id] -= 1
	pot.append(id)
	sfx("sow")
	if pot.size() == 2:
		say("%sと%s。「煮る」で料理しよう！" % [NAMES[pot[0]], NAMES[pot[1]]])
	else:
		say("%sを鍋に入れたよ。あと1つえらんでね" % NAMES[id])
	_refresh()


func take_back() -> void:
	if pot.is_empty():
		return
	var id: String = pot.pop_back()
	stock[id] += 1
	sfx("click")
	say("%sを棚にもどしたよ" % NAMES[id])
	_refresh()


func recipe_for(a: String, b: String) -> Dictionary:
	for r in RECIPES:
		var p: Array = r.pair
		if p.size() == 2 and ((p[0] == a and p[1] == b) or (p[0] == b and p[1] == a)):
			return r
	return RECIPES[RECIPES.size() - 1]  # ふしぎな料理


func cook() -> void:
	if busy or pot.size() < 2:
		return
	busy = true
	kitchen.cooking = true
	kitchen.happy = false
	sfx("water")
	say("ぐつぐつ……")
	_refresh()
	await get_tree().create_timer(COOK_TIME).timeout
	var r := recipe_for(pot[0], pot[1])
	pot.clear()
	kitchen.cooking = false
	kitchen.happy = true
	kitchen.last_dish = {"kind": r.kind, "color": r.color}
	cooked += 1
	var is_new := not found.has(r.id)
	found[r.id] = true
	_refresh()
	if found.size() == RECIPES.size():
		sfx("clear")
		_complete()
		return
	sfx("good" if r.id != "mystery" else "error")
	var text: String = "%sができた！" % r.name
	if is_new:
		text += "\n\nNEW! レシピ帳に登録したよ（%d / %d）" % [found.size(), RECIPES.size()]
	text += "\n\nくま「%s」" % r.say
	_show_popup(text, [["つづける", _close_popup]], 28)


func _close_popup() -> void:
	popup.visible = false
	kitchen.happy = false
	busy = false
	if _stuck():
		say("材料がたりないね。「次の日」にしよう")
	else:
		say("次はどれとどれにしようかな")


# 材料が足りなくて、もう何も作れない
func _stuck() -> bool:
	var total := pot.size()
	for id in ORDER:
		total += stock[id]
	return total < 2


func next_day() -> void:
	if busy:
		return
	busy = true
	for id in pot:  # 鍋の中身は棚にもどす
		stock[id] += 1
	pot.clear()
	await _fade_to(0.8)
	day += 1
	for id in ORDER:
		stock[id] = mini(stock[id] + DAILY, STOCK_MAX)
	kitchen.last_dish = {}
	_refresh()
	sfx("morning")
	say("%d日目の朝。材料が届いたよ" % day)
	await _fade_to(0.0)
	busy = false


func _complete() -> void:
	var best := _load_best()
	var text := "レシピ帳がぜんぶうまった！\n\n%d日目でコンプリート\n（料理した回数 %d回）" % [day, cooked]
	if best == 0 or day < best:
		_save_best(day)
		text += "\n\nベスト記録！"
	else:
		text += "\n\nベスト: %d日" % best
	text += "\n\nくま「紳士の食卓が、完成いたしました」"
	_show_popup(text, [["もう一回", _restart], ["タイトルへ", _to_title]], 28)


func _restart() -> void:
	skip_title = true
	get_tree().reload_current_scene()


func _to_title() -> void:
	skip_title = false
	get_tree().reload_current_scene()


func _load_best() -> int:
	var cfg := ConfigFile.new()
	if cfg.load(best_path) != OK:
		return 0
	return cfg.get_value("best", "days", 0)


func _save_best(d: int) -> void:
	var cfg := ConfigFile.new()
	cfg.load(best_path)
	cfg.set_value("best", "days", d)
	cfg.save(best_path)


func _show_book() -> void:
	if busy:
		return
	sfx("click")
	book.found = found
	book.queue_redraw()
	book_panel.visible = true
	busy = true


func _hide_book() -> void:
	sfx("click")
	book_panel.visible = false
	busy = false


# ---------------------------------------------------------------- 画面

func say(text: String) -> void:
	message_label.text = text


func _refresh() -> void:
	day_label.text = "%d日目" % day
	book_button.text = "レシピ帳 %d / %d" % [found.size(), RECIPES.size()]
	cook_button.disabled = pot.size() < 2 or kitchen.cooking
	kitchen.stock = stock
	kitchen.pot = pot
	kitchen.queue_redraw()


func _fade_to(alpha: float) -> void:
	var tw := create_tween()
	tw.tween_property(fade, "color:a", alpha, 0.4)
	await tw.finished


func _build_ui() -> void:
	var hud := CanvasLayer.new()
	add_child(hud)
	var theme := _make_theme()

	var top := _rect(hud, Rect2(0, 0, 720, 130), Color(0.98, 0.94, 0.84))
	top.theme = theme
	_rect(top, Rect2(0, 126, 720, 4), Color(0.86, 0.74, 0.54))
	day_label = _label(top, Rect2(24, 30, 260, 60), 40, Color(0.35, 0.25, 0.15))
	book_button = Button.new()
	book_button.position = Vector2(270, 16)
	book_button.size = Vector2(426, 52)
	book_button.add_theme_font_size_override("font_size", 26)
	book_button.pressed.connect(_show_book)
	top.add_child(book_button)
	sfx_button = Button.new()
	sfx_button.position = Vector2(556, 76)
	sfx_button.size = Vector2(140, 44)
	sfx_button.add_theme_font_size_override("font_size", 20)
	sfx_button.pressed.connect(_on_sfx_pressed)
	top.add_child(sfx_button)

	var bottom := _rect(hud, Rect2(0, 990, 720, 290), Color(0.98, 0.94, 0.84))
	bottom.theme = theme
	_rect(bottom, Rect2(0, 0, 720, 4), Color(0.86, 0.74, 0.54))
	message_label = _label(bottom, Rect2(24, 8, 672, 90), 26, Color(0.35, 0.25, 0.15))
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cook_button = Button.new()
	cook_button.text = "煮る"
	cook_button.position = Vector2(24, 106)
	cook_button.size = Vector2(672, 80)
	cook_button.add_theme_font_size_override("font_size", 36)
	cook_button.pressed.connect(cook)
	for st in ["normal", "hover", "pressed"]:  # 煮るボタンはオレンジ
		var sb: StyleBoxFlat = theme.get_stylebox(st, "Button").duplicate()
		sb.bg_color = Color(1, 0.72, 0.4) if st != "pressed" else Color(0.95, 0.6, 0.3)
		sb.border_color = Color(0.75, 0.42, 0.15)
		cook_button.add_theme_stylebox_override(st, sb)
	bottom.add_child(cook_button)
	next_button = Button.new()
	next_button.text = "次の日（材料が増える）"
	next_button.position = Vector2(24, 198)
	next_button.size = Vector2(672, 64)
	next_button.add_theme_font_size_override("font_size", 28)
	next_button.pressed.connect(next_day)
	for st in ["normal", "hover", "pressed"]:  # 次の日ボタンは夜の色
		var sb: StyleBoxFlat = theme.get_stylebox(st, "Button").duplicate()
		sb.bg_color = Color(0.36, 0.4, 0.68) if st != "pressed" else Color(0.28, 0.32, 0.56)
		sb.border_color = Color(0.22, 0.25, 0.45)
		next_button.add_theme_stylebox_override(st, sb)
	for st in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color", "font_focus_color"]:
		next_button.add_theme_color_override(st, Color(1, 0.97, 0.88))
	bottom.add_child(next_button)

	# レシピ帳
	book_panel = PanelContainer.new()
	book_panel.position = Vector2(20, 150)
	book_panel.theme = theme
	book_panel.visible = false
	hud.add_child(book_panel)
	var bbox := VBoxContainer.new()
	book_panel.add_child(bbox)
	var title := Label.new()
	title.text = "レシピ帳"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	bbox.add_child(title)
	book = Control.new()
	book.set_script(load("res://scenes/book.gd"))
	book.custom_minimum_size = Vector2(624, 660)
	book.recipes = RECIPES
	bbox.add_child(book)
	var close := Button.new()
	close.text = "とじる"
	close.custom_minimum_size = Vector2(0, 60)
	close.add_theme_font_size_override("font_size", 26)
	close.pressed.connect(_hide_book)
	bbox.add_child(close)

	fade = _rect(hud, Rect2(0, 0, 720, 1280), Color(0.05, 0.05, 0.15, 0.0))

	popup = PanelContainer.new()
	popup.position = Vector2(60, 360)
	popup.custom_minimum_size = Vector2(600, 0)
	popup.visible = false
	popup.theme = theme
	hud.add_child(popup)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 24)
	popup.add_child(box)
	popup_label = Label.new()
	popup_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	popup_label.custom_minimum_size = Vector2(544, 0)
	box.add_child(popup_label)
	popup_buttons = VBoxContainer.new()
	popup_buttons.add_theme_constant_override("separation", 16)
	box.add_child(popup_buttons)


# ボタンとポップアップの見た目（Tiny Lala Farm と同じ、クリーム色に茶色のふち）
func _make_theme() -> Theme:
	var th := Theme.new()
	var brown := Color(0.35, 0.25, 0.15)
	var styles := {
		"normal": [Color(1, 0.99, 0.95), Color(0.76, 0.6, 0.42), 3],
		"hover": [Color(1, 0.97, 0.88), Color(0.76, 0.6, 0.42), 3],
		"pressed": [Color(1, 0.9, 0.58), Color(0.86, 0.55, 0.15), 5],
		"disabled": [Color(0.92, 0.9, 0.86), Color(0.8, 0.76, 0.7), 3],
	}
	for st in styles:
		var sb := StyleBoxFlat.new()
		sb.bg_color = styles[st][0]
		sb.border_color = styles[st][1]
		sb.set_border_width_all(styles[st][2])
		sb.set_corner_radius_all(14)
		sb.shadow_color = Color(0, 0, 0, 0.12)
		sb.shadow_size = 2
		sb.shadow_offset = Vector2(0, 3)
		th.set_stylebox(st, "Button", sb)
	th.set_stylebox("hover_pressed", "Button", th.get_stylebox("pressed", "Button"))
	th.set_stylebox("focus", "Button", StyleBoxEmpty.new())
	for st in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color", "font_focus_color"]:
		th.set_color(st, "Button", brown)
	th.set_color("font_disabled_color", "Button", Color(0.65, 0.6, 0.55))
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color(1, 0.98, 0.92)
	panel.border_color = Color(0.6, 0.45, 0.28)
	panel.set_border_width_all(4)
	panel.set_corner_radius_all(22)
	panel.set_content_margin_all(28)
	panel.shadow_color = Color(0, 0, 0, 0.25)
	panel.shadow_size = 10
	th.set_stylebox("panel", "PanelContainer", panel)
	th.set_color("font_color", "Label", brown)
	return th


func _show_popup(text: String, buttons: Array, font_size := 30) -> void:
	popup_label.text = text.replace("\r", "")
	popup_label.add_theme_font_size_override("font_size", font_size)
	for b in popup_buttons.get_children():
		popup_buttons.remove_child(b)
		b.queue_free()
	for spec in buttons:
		var b := Button.new()
		b.text = spec[0]
		b.custom_minimum_size = Vector2(0, 72)
		b.add_theme_font_size_override("font_size", 28)
		b.pressed.connect(spec[1])
		popup_buttons.add_child(b)
	popup.visible = true
	popup.reset_size()
	popup.position.y = (1280 - popup.size.y) / 2


func _rect(parent: Node, r: Rect2, color: Color) -> ColorRect:
	var cr := ColorRect.new()
	cr.position = r.position
	cr.size = r.size
	cr.color = color
	cr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(cr)
	return cr


func _label(parent: Node, r: Rect2, font_size: int, color: Color) -> Label:
	var l := Label.new()
	l.position = r.position
	l.size = r.size
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	parent.add_child(l)
	return l
