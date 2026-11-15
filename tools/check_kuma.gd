extends SceneTree
# ことばのチェック:
#  1) くまのセリフを全部 kuma() に通して、改行の位置を見る
#  2) 英語の辞書（scenes/tr.gd）に、訳がぬけている日本語がないか
# 使い方: godot --headless --path . --script res://tools/check_kuma.gd
func _initialize() -> void:
	var m = load("res://scenes/main.gd").new()
	for r in m.RECIPES + m.SECRETS:
		print(m.kuma(r.say).replace("\n", " / "))
	var keys := []
	for r in m.RECIPES + m.SECRETS:
		keys += [r.name, r.hint, r.say]
	keys += m.NAMES.values() + m.MEMO.values() + m.STAR_SAY.values() + m.SFX_NAMES.values() + [m.HOWTO, m.CREDITS]
	var re := RegEx.new()
	re.compile("(?:T|Tr\\.t)\\(\"((?:[^\"\\\\]|\\\\.)*)\"\\)")
	for path in ["res://scenes/main.gd", "res://scenes/book.gd"]:
		for mt in re.search_all(FileAccess.get_file_as_string(path)):
			keys.append(mt.get_string(1).c_unescape())
	var missing := 0
	for k in keys:
		if not Tr.EN.has(String(k).replace("\r", "")):
			print("訳がない: ", String(k).replace("\n", "\\n"))
			missing += 1
	print("チェックした数: ", keys.size(), "  訳がない: ", missing)
	m.free()
	quit()
