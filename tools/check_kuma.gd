extends SceneTree
# くまのセリフの改行チェック: 全部のセリフを kuma() に通して表示する
func _initialize() -> void:
	var m = load("res://scenes/main.gd").new()
	for r in m.RECIPES + m.SECRETS:
		print(m.kuma(r.say).replace("\n", " / "))
	for v in m.STAR_SAY.values():
		print(m.kuma(v).replace("\n", " / "))
	quit()
