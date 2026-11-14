extends SceneTree
# 見た目確認用: 少し遊んだ状態にしてスクショを保存する
# 使い方: godot --path . --resolution 720x1280 --script res://tools/screenshot.gd -- <出力.png> [title|play|cooking|result|book|complete]
func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var mode: String = args[1] if args.size() > 1 else "title"
	var main = load("res://scenes/main.tscn").instantiate()
	main.best_path = "user://test_best.cfg"
	root.add_child(main)
	await create_timer(0.2).timeout
	if mode != "title":
		main._start()
		await create_timer(0.6).timeout
	if mode == "play" or mode == "cooking" or mode == "result":
		main._on_tap(main.kitchen.slot_center(0))  # カブ
		main._on_tap(main.kitchen.slot_center(3))  # ミルク
		if mode != "play":
			main.cook()
			await create_timer(0.7 if mode == "cooking" else 1.8).timeout
	elif mode == "book" or mode == "complete":
		var pairs := [["turnip", "milk"], ["tomato", "tomato"], ["strawberry", "milk"], ["turnip", "strawberry"]]
		if mode == "complete":
			pairs = [["turnip", "milk"], ["turnip", "tomato"], ["turnip", "turnip"], ["tomato", "tomato"], ["tomato", "milk"],
				["strawberry", "strawberry"], ["strawberry", "milk"], ["milk", "milk"], ["turnip", "strawberry"]]
		for pr in pairs:
			while main.stock[pr[0]] < 1 or main.stock[pr[1]] < (2 if pr[0] == pr[1] else 1):
				main.next_day()
				await create_timer(1.0).timeout
			main.add_to_pot(pr[0])
			main.add_to_pot(pr[1])
			main.cook()
			await create_timer(1.6).timeout
			if main.found.size() < main.RECIPES.size():
				main._close_popup()
		if mode == "book":
			main._show_book()
		print("day=", main.day, " found=", main.found.size(), " cooked=", main.cooked)
	await create_timer(0.3).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(args[0])
	quit()
