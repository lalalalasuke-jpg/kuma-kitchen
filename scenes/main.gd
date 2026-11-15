extends Node2D

# くま紳士のキッチン（仮）: 材料を2つえらんで鍋で煮ると料理ができる。レシピ帳を全部うめたらクリア。
# 棚の材料をタップ → 鍋に入る（2つまで。鍋をタップすると1つ戻す）→「煮る」→ 料理ができてレシピ帳へ。
# 材料は使うと減る。「次の日」で少し補充される。何日でレシピ帳をうめられるか。

const BEST_PATH := "user://best.cfg"
const SFX_SETS := ["code", "off"]
const SFX_NAMES := {"code": "音: あり", "off": "音: なし"}
const BASE := ["turnip", "tomato", "strawberry", "milk"]  # はじめから使える材料
const NAMES := {"turnip": "カブ", "tomato": "トマト", "strawberry": "イチゴ", "milk": "ミルク",
	"egg": "たまご", "flour": "小麦粉", "butter": "バター"}
const START_STOCK := 3  # はじめの材料の数（それぞれ）。新しく入荷した材料も同じ数から
const DAILY := 2  # 次の日に増える数（それぞれ）
const STOCK_MAX := 6
const COOK_TIME := 1.4
# 開放のしくみ（遊んでみて調整する数字はここ）
const EGG_RECIPES := 4  # この数のレシピを見つけたら、次の朝たまごが入荷（にわとりさんから）
const EGG_DAY := 3  # 見つけられなくても、この日になったら入荷（救済）
const FB_RECIPES := 10  # この数で、次の朝に小麦粉とバターを買ってくる（鍋は2つのまま）
const FB_DAY := 5
const POT_DAY := 8  # 2つの料理を全部見つけたら「上級編」: 次の朝、新しい鍋（3つ入る）。見つけきれなくてもこの日に
const HINT_FAILS := 2  # ふしぎな料理をこの回数作ったら、次の朝に妖精さんのヒント
const HINTS_PER := 2  # 1回で書いてくれるヒントの数
# 料理。pair は使う材料（2つか3つ、順番は関係なし）。どれにも当てはまらない組み合わせは「ふしぎな料理」
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
	{"id": "yudetamago", "name": "ゆでたまご", "pair": ["egg", "egg"], "kind": "eggs", "color": Color(1, 0.97, 0.9),
		"hint": "たまごをたっぷり", "say": "にわとりさんに感謝を"},
	{"id": "tomatama", "name": "トマトたまごスープ", "pair": ["tomato", "egg"], "kind": "bowl", "color": Color(0.98, 0.6, 0.3),
		"hint": "赤い野菜とたまご", "say": "ふわふわのたまごが、たまりませんな"},
	{"id": "pudding", "name": "プリン", "pair": ["egg", "milk"], "kind": "pudding", "color": Color(1, 0.88, 0.5),
		"hint": "たまごと白い飲みもの", "say": "ぷるぷる……紳士も笑顔になります"},
	{"id": "tamagotoji", "name": "カブのたまごとじ", "pair": ["turnip", "egg"], "kind": "toji", "color": Color(1, 0.86, 0.45),
		"hint": "白い野菜とたまご", "say": "やさしい黄色ですな"},
	{"id": "pasta", "name": "パスタ", "pair": ["flour", "egg"], "kind": "noodles", "color": Color(0.98, 0.85, 0.5),
		"hint": "粉とたまご", "say": "生地から作るとは、本格的ですな"},
	{"id": "butterni", "name": "カブのバター煮", "pair": ["turnip", "butter"], "kind": "butterni", "color": Color(0.99, 0.97, 0.9),
		"hint": "白い野菜とバター", "say": "バターの香りが、紳士的でございます"},
	{"id": "scrambled", "name": "スクランブルエッグ", "pair": ["egg", "butter"], "kind": "scramble", "color": Color(1, 0.88, 0.35),
		"hint": "たまごとバター", "say": "とろとろ……朝の幸せでございます"},
	{"id": "crepe", "name": "クレープ", "pair": ["flour", "milk"], "kind": "crepe", "color": Color(1, 0.98, 0.92),
		"hint": "粉と白い飲みもの", "say": "うすく、うすく……紳士の腕の見せどころ"},
	{"id": "shortbread", "name": "ショートブレッド", "pair": ["flour", "butter"], "kind": "bars", "color": Color(0.96, 0.82, 0.55),
		"hint": "粉とバター", "say": "紅茶のお供に、これ以上はございません"},
	{"id": "yakitomato", "name": "焼きトマト", "pair": ["tomato", "butter"], "kind": "halves", "color": Color(0.9, 0.28, 0.18),
		"hint": "赤い野菜とバター", "say": "焼くと、甘みがぐっと増しますな"},
	{"id": "pancake", "name": "パンケーキ", "pair": ["flour", "egg", "milk"], "kind": "pancake", "color": Color(0.9, 0.68, 0.38),
		"hint": "粉とたまごと白い飲みもの", "say": "ふわっふわ……！"},
	{"id": "whitesauce", "name": "ホワイトソース", "pair": ["flour", "butter", "milk"], "kind": "jar", "color": Color(0.99, 0.97, 0.9),
		"hint": "粉とバターと白い飲みもの", "say": "料理の腕が、また一段上がりましたな"},
	{"id": "cookie", "name": "イチゴクッキー", "pair": ["flour", "butter", "strawberry"], "kind": "cookies", "color": Color(0.9, 0.7, 0.42),
		"hint": "粉とバターとあまい実", "say": "おやつの時間にいたしましょう"},
	{"id": "stew", "name": "クリームシチュー", "pair": ["turnip", "milk", "butter"], "kind": "bowl", "color": Color(1, 0.96, 0.88),
		"hint": "白い野菜と白い飲みものとバター", "say": "寒い日には、これに限りますな"},
	{"id": "minestrone", "name": "ミネストローネ", "pair": ["turnip", "tomato", "butter"], "kind": "bowl", "color": Color(0.9, 0.36, 0.22),
		"hint": "畑の野菜ふたつとバター", "say": "具だくさんで、ごちそうですな"},
	{"id": "ichigopudding", "name": "イチゴプリン", "pair": ["egg", "milk", "strawberry"], "kind": "pudding", "color": Color(1, 0.72, 0.78),
		"hint": "たまごと白い飲みものとあまい実", "say": "これは……かわいらしさの極み"},
	{"id": "gratin", "name": "カブのグラタン", "pair": ["turnip", "milk", "flour"], "kind": "bowl", "color": Color(0.98, 0.82, 0.5),
		"hint": "白い野菜と白い飲みものと粉", "say": "こんがり、香ばしい……"},
	{"id": "omelet", "name": "オムレツ", "pair": ["egg", "egg", "milk"], "kind": "omelet", "color": Color(1, 0.86, 0.3),
		"hint": "たまごふたつと白い飲みもの", "say": "ふわふわの黄色……ため息が出ますな"},
	{"id": "napolitan", "name": "ナポリタン", "pair": ["flour", "egg", "tomato"], "kind": "noodles", "color": Color(0.95, 0.42, 0.22),
		"hint": "粉とたまごと赤い野菜", "say": "どこか懐かしいお味でございます"},
	{"id": "ichigocrepe", "name": "イチゴクレープ", "pair": ["flour", "milk", "strawberry"], "kind": "crepe", "color": Color(1, 0.7, 0.75),
		"hint": "粉と白い飲みものとあまい実", "say": "くるっと巻いて……完璧ですな"},
	{"id": "madeleine", "name": "マドレーヌ", "pair": ["flour", "butter", "egg"], "kind": "shells", "color": Color(0.96, 0.76, 0.4),
		"hint": "粉とバターとたまご", "say": "貝の形が、なんとも上品で"},
	{"id": "tomatogratin", "name": "トマトのグラタン", "pair": ["tomato", "milk", "flour"], "kind": "bowl", "color": Color(0.95, 0.55, 0.32),
		"hint": "赤い野菜と白い飲みものと粉", "say": "こんがりと、真っ赤な誘惑"},
	{"id": "shake", "name": "イチゴシェイク", "pair": ["strawberry", "strawberry", "milk"], "kind": "glass", "color": Color(1, 0.6, 0.7),
		"hint": "あまい実ふたつと白い飲みもの", "say": "ストローが止まりませんな"},
	{"id": "mystery", "name": "ふしぎな料理", "pair": [], "kind": "mystery", "color": Color(0.58, 0.46, 0.7),
		"hint": "合わない組み合わせ…？", "say": "……これは、なんでございましょう"},
]
# 隠し味: 2つの料理に、この材料をもう1つ足すと「★」になる（その料理を見つけたあとだけ。クリアには関係なし）
const STARS := {"potage": "milk", "vegsoup": "egg", "nimono": "tomato", "sauce": "strawberry", "cream": "butter",
	"jam": "butter", "smilk": "milk", "hotmilk": "butter", "yudetamago": "butter", "tomatama": "milk", "pudding": "milk",
	"tamagotoji": "egg", "pasta": "egg", "butterni": "egg", "scrambled": "milk", "crepe": "milk", "shortbread": "butter",
	"yakitomato": "egg"}
# くまのメモ（隠し味のヒント）。鍋に3つ入るようになったら、作った料理のカードに出る
const MEMO := {"milk": "もっとまろやかにできそう", "butter": "コクと香りがほしいかも", "egg": "もっとふわっとさせたい",
	"strawberry": "ほんのり甘みがほしいかも", "tomato": "さっぱり酸味がほしいかも"}
const STAR_SAY := {"milk": "まろやかさが、ぐっと増しましたな", "butter": "コクと香りが、格別でございます",
	"egg": "ふわっと、やさしい口当たりに", "strawberry": "ほんのり甘くて、上品ですな", "tomato": "さっぱりして、いくらでもいけますな"}
# ひみつのレシピ（クリアには関係なし。見つけるとレシピ帳に「ひみつのレシピ」のページが増える）
const SECRETS := [
	{"id": "chick", "name": "ひよこ", "pair": ["egg", "egg", "egg"], "kind": "chick", "color": Color(1, 0.9, 0.35),
		"hint": "たまごを、たくさん温めると……", "say": "……おや？ 料理のはずが、ぴよっと"},
	{"id": "milkbath", "name": "ミルクのおふろ", "pair": ["milk", "milk", "milk"], "kind": "bath", "color": Color(1, 0.99, 0.95),
		"hint": "白い飲みものを、あふれるほど", "say": "これは……料理ではなく、おふろですな"},
	{"id": "udon", "name": "手作りうどん", "pair": ["flour", "flour", "flour"], "kind": "udon", "color": Color(1, 0.99, 0.94),
		"hint": "粉だけで、こねてこねて……", "say": "紳士も、たまにはすすりとうございます"},
	{"id": "scone", "name": "イチゴのスコーン", "pair": ["strawberry", "flour", "flour"], "kind": "scone", "color": Color(0.92, 0.72, 0.42),
		"hint": "粉をたっぷりと、あまい実", "say": "紅茶の時間でございます"},
	{"id": "clotted", "name": "クロテッドクリーム", "pair": ["milk", "butter", "butter"], "kind": "jar", "color": Color(1, 0.95, 0.75),
		"hint": "白い飲みものと、バターをたっぷり", "say": "スコーンには、これがなくては"},
	{"id": "pizza", "name": "マルゲリータ風ピザ", "pair": ["tomato", "tomato", "flour"], "kind": "pizza", "color": Color(0.88, 0.22, 0.14),
		"hint": "赤い野菜をたっぷりと粉", "say": "イタリアの風が吹いてきましたな"},
	{"id": "okonomi", "name": "カブのお好み焼き", "pair": ["turnip", "egg", "flour"], "kind": "okonomi", "color": Color(0.9, 0.68, 0.38),
		"hint": "白い野菜とたまごと粉", "say": "カブでも、ちゃんとお好み焼きでございます"},
	{"id": "castella", "name": "カステラ", "pair": ["egg", "flour", "flour"], "kind": "castella", "color": Color(1, 0.84, 0.35),
		"hint": "たまごと、粉をたっぷり", "say": "しっとり、ふんわり……"},
	{"id": "tart", "name": "イチゴのタルト", "pair": ["strawberry", "strawberry", "flour"], "kind": "tart", "color": Color(0.88, 0.66, 0.36),
		"hint": "あまい実をたっぷりと粉", "say": "宝石箱のようでございます"},
]
const HOWTO := """あそびかた

くま紳士ららすけは、お料理上手をめざして
今日もお料理修行。
目標は、レシピ帳をいっぱいにすること！

棚の材料をタップすると、鍋に入るよ
鍋をタップすると、1つ棚にもどすよ
2つ入ったら「煮る」で料理ができる！

材料は使うと減るよ。「次の日」で少し増えるよ
料理が上手になると、新しい材料や
大きな鍋が手に入るかも……？"""
const CREDITS := """クレジット

企画・ゲームデザイン: ららすけ（lalasuke）
プログラム・絵・効果音: Claude（Anthropic の AI）
ららすけと AI がいっしょに作ったゲームです

フォント: Noto Sans JP（SIL Open Font License 1.1）
ゲームエンジン: Godot Engine（MIT License）
(c) Juan Linietsky, Ariel Manzur and contributors
godotengine.org/license"""

signal popup_closed

static var skip_title := false  # 「もう一回」でシーンを読み直した時はタイトルを出さない

var best_path := BEST_PATH  # テストでは別のファイルに差し替える
var day := 1
var stock := {}
var pot: Array = []
var found := {}
var cooked := 0  # 作った回数
var unlocked: Array = BASE.duplicate()  # 使える材料
var capacity := 2  # 鍋に入れられる数
var egg_ready := false  # たまごの入荷（次の朝）
var fb_ready := false  # 小麦粉・バターの入荷（次の朝）
var pot_ready := false  # 上級編（次の朝、新しい鍋）
var fails := 0  # 前のヒントからあとに、ふしぎな料理を作った回数
var hinted := {}
var starred := {}  # 隠し味★を見つけた料理
var completed := false  # レシピ帳（ひみつ以外）がいっぱいになった
var continuing := false  # クリアのあと「つづけて探す」中
var end_text := ""  # クリア画面の文（一度決めたら、レシピ帳を閉じたあとも同じものを出す）
var end_buttons: Array = []
var book_title: Label
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
var page_label: Label


func _ready() -> void:
	for id in unlocked:
		stock[id] = START_STOCK
	kitchen.order = unlocked
	# ことば: 保存してあればそれ、なければブラウザ/OSの言語（日本語なら日本語、それ以外は英語）
	var cfg := ConfigFile.new()
	var has_cfg := cfg.load(best_path) == OK
	Tr.lang = "ja" if OS.get_locale_language() == "ja" else "en"
	if has_cfg:
		sfx_set = cfg.get_value("settings", "sfx", sfx_set)
		Tr.lang = cfg.get_value("settings", "lang", Tr.lang)
	_build_ui()
	sfx_button.text = T(SFX_NAMES[sfx_set])
	_refresh()
	if skip_title:
		_start()
	else:
		busy = true
		fade.color.a = 0.6
		_show_title()


func _show_title() -> void:
	var best := _load_best()
	var text := T("くま紳士のキッチン\n\nお料理上手をめざして\n今日もお料理修行\n\n目標は\nレシピ帳をいっぱいにすること！")
	if best > 0:
		text += T("\n\nベスト: %d日でコンプリート") % best
	var perfect := _load_best("perfect")
	if perfect > 0:
		text += T("\nひみつも全部: %d日") % perfect
	_show_popup(text, [[T("はじめる"), _start], [T("あそびかた"), _show_howto], [T("クレジット"), _show_credits],
		["English" if Tr.lang == "ja" else "日本語", _toggle_lang]])


# ことばを切り替えて、画面を作り直す（タイトルから）
func _toggle_lang() -> void:
	Tr.lang = "en" if Tr.lang == "ja" else "ja"
	var cfg := ConfigFile.new()
	cfg.load(best_path)
	cfg.set_value("settings", "lang", Tr.lang)
	cfg.save(best_path)
	sfx("click")
	_to_title()


func T(s: String) -> String:
	return Tr.t(s)


func _show_howto() -> void:
	_show_popup(T(HOWTO), [[T("もどる"), _show_title]], 24)


func _show_credits() -> void:
	_show_popup(T(CREDITS), [[T("もどる"), _show_title]], 22)


func _start() -> void:
	popup.visible = false
	say(T("棚の材料をタップして、鍋に2つ入れてみよう"))
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
	sfx_button.text = T(SFX_NAMES[sfx_set])
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
	if pot.size() >= capacity:
		sfx("error")
		say(T("鍋はいっぱい。鍋をタップすると材料をもどせるよ"))
		return
	if stock[id] <= 0:
		sfx("error")
		say(T("%sがもうないよ。「次の日」にすると増えるよ") % T(NAMES[id]))
		return
	stock[id] -= 1
	pot.append(id)
	sfx("sow")
	var names := []
	for x in pot:
		names.append(T(NAMES[x]))
	if pot.size() == capacity:
		say(T("%s。「煮る」で料理しよう！") % T("と").join(names))
	elif pot.size() >= 2:
		say(T("%s。「煮る」で料理できるよ。もう1つ入れてもいいよ") % T("と").join(names))
	else:
		say(T("%sを鍋に入れたよ。あと1つえらんでね") % T(NAMES[id]))
	_refresh()


func take_back() -> void:
	if pot.is_empty():
		return
	var id: String = pot.pop_back()
	stock[id] += 1
	sfx("click")
	say(T("%sを棚にもどしたよ") % T(NAMES[id]))
	_refresh()


func _sorted(a: Array) -> Array:
	var b := a.duplicate()
	b.sort()
	return b


# 鍋の中身からできる料理。ふつうの料理・ひみつのレシピ → 隠し味★（元の料理を見つけていたら）→ ふしぎな料理
# 隠し味★は {"star": 元の料理の id} がついた、元の料理のコピーを返す
func recipe_for(items: Array) -> Dictionary:
	var a := _sorted(items)
	for r in RECIPES + SECRETS:
		if not r.pair.is_empty() and _sorted(r.pair) == a:
			return r
	if a.size() == 3:
		for r in RECIPES:
			if STARS.has(r.id) and found.has(r.id) and _sorted(r.pair + [STARS[r.id]]) == a:
				var s: Dictionary = r.duplicate()
				s["star"] = r.id
				s["name"] = r.name + "★"
				s["say"] = STAR_SAY[STARS[r.id]]
				return s
	return RECIPES[RECIPES.size() - 1]  # ふしぎな料理


# くまのセリフ。1行に入りきらない時は「、」「……」などのあとで改行して、閉じかっこだけが次の行に残らないように
func kuma(say: String, width := 19) -> String:
	if Tr.lang == "en":  # 英語はスペースで自動で折り返すので、そのまま
		return "Sir Bear: \"%s\"" % say
	var line := "くま「%s」" % say
	if line.length() <= width:
		return line
	var best := -1
	for mark in ["、", "……", "！", "？", "。"]:
		var i := say.find(mark)
		while i != -1:
			var cut: int = i + mark.length()
			if cut < say.length() and (best == -1 or absi(cut - say.length() / 2) < absi(best - say.length() / 2)):
				best = cut
			i = say.find(mark, i + 1)
	if best == -1:
		return "くま\n「%s」" % say
	return "くま「%s\n%s」" % [say.substr(0, best), say.substr(best).strip_edges()]


func is_secret(id: String) -> bool:
	return SECRETS.any(func(r: Dictionary) -> bool: return r.id == id)


# 見つけた料理の数（ひみつのレシピは数えない。ふしぎな料理は数える）
func main_found() -> int:
	var n := 0
	for r in RECIPES:
		if found.has(r.id):
			n += 1
	return n


func secret_found() -> int:
	var n := 0
	for r in SECRETS:
		if found.has(r.id):
			n += 1
	return n


func two_all_found() -> bool:
	for r in RECIPES:
		if r.pair.size() == 2 and not found.has(r.id):
			return false
	return true


# いま作れる可能性のある料理（材料が開放されていて、鍋に入る数）。レシピ帳にはこれだけ出す
func visible_recipes() -> Array:
	var out := []
	for r in RECIPES:
		if r.pair.is_empty():
			continue
		var ok: bool = r.pair.size() <= capacity
		for x in r.pair:
			if not unlocked.has(x):
				ok = false
		if ok:
			out.append(r)
	out.append(RECIPES[RECIPES.size() - 1])
	return out


func cook() -> void:
	if busy or pot.size() < 2:
		return
	busy = true
	kitchen.cooking = true
	kitchen.happy = false
	sfx("water")
	say(T("ぐつぐつ……"))
	_refresh()
	await get_tree().create_timer(COOK_TIME).timeout
	var r := recipe_for(pot)
	pot.clear()
	kitchen.cooking = false
	kitchen.happy = true
	var star_id: String = r.get("star", "")
	var secret := is_secret(r.id)
	kitchen.last_dish = {"kind": r.kind, "color": r.color, "shine": star_id != "" or secret}
	cooked += 1
	var is_new: bool
	if star_id != "":
		is_new = not starred.has(star_id)
		starred[star_id] = true
	else:
		is_new = not found.has(r.id)
		found[r.id] = true
	_refresh()
	if r.id == "mystery":
		fails += 1
	sfx("good" if r.id != "mystery" else "error")
	var text: String = T("%sができた！") % T(r.name)
	if is_new and star_id != "":
		text += T("\n\n隠し味を見つけた！\nレシピ帳に★をつけたよ")
	elif is_new and secret:
		text += T("\n\n★ ひみつのレシピを見つけた！\n（%d / %d）") % [secret_found(), SECRETS.size()]
	elif is_new:
		text += T("\n\nNEW! レシピ帳に登録したよ（%d / %d）") % [main_found(), RECIPES.size()]
	text += "\n\n" + kuma(T(r.say))
	if main_found() >= EGG_RECIPES and not unlocked.has("egg"):
		egg_ready = true
	if main_found() >= FB_RECIPES and not unlocked.has("flour") and not fb_ready:
		fb_ready = true
		text += "\n\n" + kuma(T("そろそろ、小麦粉とバターも使ってみたいですな")) + T("\n明日、買いものにいこう")
	if capacity < 3 and not pot_ready and unlocked.has("flour") and two_all_found():
		pot_ready = true
		text += T("\n\n上級編！\n") + kuma(T("2つで作る料理は、すべて覚えましたな")) + T("\n明日、新しい鍋を買いにいこう")
	var next: Callable = _close_popup
	if not completed and main_found() == RECIPES.size():
		completed = true
		next = _complete
	elif continuing and is_new and secret and secret_found() == SECRETS.size():
		continuing = false
		end_buttons = []
		end_text =T("ひみつのレシピも、ぜんぶ見つけた！\n\n今度は、ひみつのレシピも全部見つけて\nクリアしてみよう！\n\n") + kuma(T("紳士の秘伝の書、ここに完成ですな"))
		next = _complete
	_show_popup(text, [[T("つづける"), next]], 26)


func _close_popup() -> void:
	popup.visible = false
	kitchen.happy = false
	busy = false
	if _stuck():
		say(T("材料がたりないね。「次の日」にしよう"))
	else:
		say(T("次はどれとどれにしようかな"))


# 材料が足りなくて、もう何も作れない
func _stuck() -> bool:
	var total := pot.size()
	for id in unlocked:
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
	for id in unlocked:
		stock[id] = mini(stock[id] + DAILY, STOCK_MAX)
	kitchen.last_dish = {}
	# 朝のできごと（入荷・上級編・妖精さん）。同じ朝に重なったら、1枚のお知らせにまとめる
	# 開放は たまご → 小麦粉・バター → 新しい鍋 の順。日にちの救済で後ろが先に来たら、前のも一緒に
	var lines := []
	var news := []
	var want_pot := capacity < 3 and (pot_ready or day >= POT_DAY)
	var want_fb := not unlocked.has("flour") and (fb_ready or day >= FB_DAY or want_pot)
	if not unlocked.has("egg") and (egg_ready or day >= EGG_DAY or want_fb):
		_unlock(["egg"])
		lines.append(T("にわとりさんが、たまごを産んでくれた！"))
		news.append(T("たまごが使えるようになったよ"))
	if want_fb:
		_unlock(["flour", "butter"])
		lines.append((T("それに、") if not lines.is_empty() else "") + T("お料理用に\n小麦粉とバターを買ってきた！"))
		news.append(T("小麦粉とバターが使えるようになったよ"))
	if want_pot:
		capacity = 3
		lines.append((T("それに、") if not lines.is_empty() else "") + T("本格的にお料理するために\n新しい鍋を買ってきた！"))
		news.append(T("鍋に3つまで入れられるようになったよ"))
		news.append(T("（レシピ帳に、くまのメモが書いてある……？）"))
	var fairy := fails >= HINT_FAILS and not _hint_candidates().is_empty()
	if fairy:
		fails = 0
		var picks := _hint_candidates()
		picks.shuffle()
		for r in picks.slice(0, HINTS_PER):
			hinted[r.id] = true
		lines.append((T("それから、") if not lines.is_empty() else "") + T("夜のうちに\nレシピ帳が枕元に置いてあった……"))
		news.append(T("レシピ帳の中身を見てみよう"))
	if not lines.is_empty():  # 最後に、なにが使えるようになったかをまとめる
		lines.append("\n".join(news))
	_refresh()
	sfx("morning")
	say(T("%d日目の朝。材料が届いたよ") % day)
	await _fade_to(0.0)
	if not lines.is_empty():
		sfx("good")
		_show_popup("\n\n".join(lines), [[T("レシピ帳を見る") if fairy else T("わーい"), _next_event]], 26)
		await popup_closed
		if fairy:
			busy = false
			_show_book()
			return
	busy = false


func _next_event() -> void:
	popup.visible = false
	popup_closed.emit()


func _unlock(ids: Array) -> void:
	for id in ids:
		if not unlocked.has(id):
			unlocked.append(id)
			stock[id] = START_STOCK
	kitchen.order = unlocked


# 妖精さんがヒントを書ける料理（まだ作っていなくて、ヒントもまだのもの）
func _hint_candidates() -> Array:
	var out := []
	for r in visible_recipes():
		if r.id != "mystery" and not found.has(r.id) and not hinted.has(r.id):
			out.append(r)
	return out


# クリア画面。はじめて呼ばれた時に文を決めて記録を保存。レシピ帳を閉じたあとは同じものを出す
# ひみつのレシピ: 0個 → 次のプレイで探してね／とちゅう → あと◯つ（つづけて探せる）／全部 → パーフェクト
func _complete() -> void:
	sfx("clear")
	kitchen.happy = true
	busy = true
	say(T("レシピ帳がいっぱいになった！"))
	var basic: Array = [[T("レシピ帳を見る"), _show_book_from_clear], [T("もう一回"), _restart], [T("タイトルへ"), _to_title]]
	if end_text == "":
		var s := secret_found()
		var text := T("レシピ帳がぜんぶうまった！\n\n%d日目でコンプリート\n（料理した回数 %d回）") % [day, cooked]
		var best := _load_best()
		if best == 0 or day < best:
			_save_best(day)
			text += T("\n\nベスト記録！")
		else:
			text += T("\n\nベスト: %d日") % best
		end_buttons = basic
		if s == SECRETS.size():
			text = T("ひみつのレシピも全部見つけて\nクリア！ おめでとう！！\n\n") + text
			var perfect := _load_best("perfect")
			if perfect == 0 or day < perfect:
				_save_best(day, "perfect")
		elif s > 0:
			text += T("\n\nひみつのレシピは、あと%dつ！") % (SECRETS.size() - s)
			end_buttons = [[T("つづけて探す"), _continue]] + basic
		else:
			text += T("\n\nじつは、ひみつのレシピがあるよ！\n次のプレイで探してみてね")
		text += "\n\n" + kuma(T("紳士の食卓が、完成いたしました"))
		end_text = text
	if end_buttons.is_empty():  # つづけて探して、ひみつのレシピを見つけきった時
		end_buttons = basic
	_show_popup(end_text, end_buttons, 26)


func _continue() -> void:
	continuing = true
	popup.visible = false
	kitchen.happy = false
	busy = false
	say(T("ひみつのレシピを探そう！ あと%dつ") % (SECRETS.size() - secret_found()))


func _show_book_from_clear() -> void:
	popup.visible = false
	busy = false
	_show_book()


func _restart() -> void:
	skip_title = true
	get_tree().reload_current_scene()


func _to_title() -> void:
	skip_title = false
	get_tree().reload_current_scene()


# key: "days"（ふつうのクリア）/ "perfect"（ひみつのレシピも全部）
func _load_best(key := "days") -> int:
	var cfg := ConfigFile.new()
	if cfg.load(best_path) != OK:
		return 0
	return cfg.get_value("best", key, 0)


func _save_best(d: int, key := "days") -> void:
	var cfg := ConfigFile.new()
	cfg.load(best_path)
	cfg.set_value("best", key, d)
	cfg.save(best_path)


func _show_book() -> void:
	if busy:
		return
	sfx("click")
	book.recipes = visible_recipes()
	book.secrets = SECRETS
	book.found = found
	book.hinted = hinted
	book.starred = starred
	book.memos = {}
	book.star_names = {}
	for id in STARS:
		book.star_names[id] = T(NAMES[STARS[id]])
		if capacity >= 3:
			book.memos[id] = T(MEMO[STARS[id]])
	book.page = 0
	_update_page()
	book_panel.visible = true
	busy = true


func _hide_book() -> void:
	sfx("click")
	book_panel.visible = false
	busy = false
	if completed and not continuing:
		_complete()


func _turn_page(d: int) -> void:
	sfx("click")
	book.page = clampi(book.page + d, 0, book.pages() - 1)
	_update_page()


func _update_page() -> void:
	page_label.text = "%d / %d" % [book.page + 1, book.pages()]
	if book.on_secret_page():
		book_title.text = T("ひみつのレシピ %d / %d") % [book.secret_count(), SECRETS.size()]
		book_title.add_theme_color_override("font_color", Color(0.62, 0.42, 0.78))
	else:
		book_title.text = T("レシピ帳")
		book_title.remove_theme_color_override("font_color")
	book.queue_redraw()


# ---------------------------------------------------------------- 画面

func say(text: String) -> void:
	message_label.text = text


func _refresh() -> void:
	day_label.text = T("%d日目") % day
	book_button.text = T("レシピ帳 %d / %d") % [main_found(), RECIPES.size()]
	cook_button.disabled = pot.size() < 2 or kitchen.cooking
	kitchen.capacity = capacity
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
	cook_button.text = T("煮る")
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
	next_button.text = T("次の日（材料が増える）")
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
	book_title = Label.new()
	book_title.text = T("レシピ帳")
	book_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	book_title.add_theme_font_size_override("font_size", 32)
	bbox.add_child(book_title)
	book = Control.new()
	book.set_script(load("res://scenes/book.gd"))
	book.custom_minimum_size = Vector2(624, 630)
	bbox.add_child(book)
	var nav := HBoxContainer.new()
	nav.add_theme_constant_override("separation", 16)
	bbox.add_child(nav)
	for spec in [[T("← まえ"), -1], ["", 0], [T("つぎ →"), 1]]:
		if spec[1] == 0:
			page_label = Label.new()
			page_label.custom_minimum_size = Vector2(200, 0)
			page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			page_label.add_theme_font_size_override("font_size", 24)
			nav.add_child(page_label)
			continue
		var b := Button.new()
		b.text = spec[0]
		b.custom_minimum_size = Vector2(196, 52)
		b.add_theme_font_size_override("font_size", 22)
		b.pressed.connect(_turn_page.bind(spec[1]))
		nav.add_child(b)
	var close := Button.new()
	close.text = T("とじる")
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
