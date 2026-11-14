extends SceneTree
# 見た目確認用: 少し遊んだ状態にしてスクショを保存する
# 使い方: godot --path . --resolution 720x1280 --script res://tools/screenshot.gd -- <出力.png> [mode]
#   mode: title / play / cooking / result / egg（たまご入荷の朝）/ fairy（妖精さんのヒント）/ adv（上級編の鍋）/ complete（全部作ってクリア）/ book2（クリア後のレシピ帳2ページ目）
var main


func _initialize() -> void:
	_run.call_deferred()


# 材料を（足りなければ足して）鍋に入れて煮る。できた料理のポップアップは閉じる
func make(items: Array, close := true) -> void:
	for x in items:
		main.stock[x] = maxi(main.stock[x], 3)
	for x in items:
		main.add_to_pot(x)
	main.cook()
	await create_timer(1.6).timeout
	if close and not main.completed:
		main._close_popup()


# 次の日へ。朝のできごとのポップアップは全部「わーい」で閉じる（妖精さんのレシピ帳はそのまま）
func next_day(keep_last := false) -> void:
	main.next_day()
	await create_timer(1.1).timeout
	for k in 4:
		if not main.popup.visible:
			break
		if keep_last and k >= 0:
			return
		main._next_event()
		await create_timer(0.3).timeout


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var mode: String = args[1] if args.size() > 1 else "title"
	main = load("res://scenes/main.tscn").instantiate()
	main.best_path = "user://test_best.cfg"
	root.add_child(main)
	await create_timer(0.2).timeout
	if mode != "title":
		main._start()
		await create_timer(0.6).timeout
	match mode:
		"play":
			main._on_tap(main.kitchen.slot_center(0))
			main._on_tap(main.kitchen.slot_center(3))
		"cooking", "result":
			main._on_tap(main.kitchen.slot_center(0))
			main._on_tap(main.kitchen.slot_center(3))
			main.cook()
			await create_timer(0.7 if mode == "cooking" else 1.8).timeout
		"egg":
			for pr in [["turnip", "milk"], ["tomato", "tomato"], ["strawberry", "milk"], ["turnip", "tomato"]]:
				await make(pr)
			await next_day(true)
		"all3":  # 1日目にたまご・上級編・妖精さんの条件を全部満たして、次の朝のお知らせ（1枚にまとまる）
			for pr in [["turnip", "milk"], ["tomato", "tomato"], ["strawberry", "milk"], ["turnip", "tomato"],
					["tomato", "milk"], ["strawberry", "strawberry"], ["milk", "milk"], ["turnip", "turnip"],
					["turnip", "strawberry"], ["tomato", "strawberry"]]:
				await make(pr)
			await next_day(true)
		"fairy":
			await make(["turnip", "strawberry"])
			await make(["tomato", "strawberry"])
			await next_day()
		"adv":
			for pr in [["turnip", "milk"], ["tomato", "tomato"], ["strawberry", "milk"], ["turnip", "tomato"],
					["tomato", "milk"], ["strawberry", "strawberry"], ["milk", "milk"], ["turnip", "turnip"]]:
				await make(pr)
			await next_day()
			main.add_to_pot("flour")
			main.add_to_pot("egg")
			main.add_to_pot("milk")
		"complete", "book2":
			for r in main.RECIPES:
				if r.pair.is_empty():
					continue
				if r.pair.size() == 3 and main.capacity < 3:
					await next_day()
				for x in r.pair:
					if not main.unlocked.has(x):
						await next_day()
				await make(r.pair)
			await make(["turnip", "strawberry"])
			main._complete()
			await create_timer(0.3).timeout
			if mode == "book2":
				main._show_book_from_clear()
				main._turn_page(1)
	print("mode=", mode, " day=", main.day, " found=", main.found.size(), " cap=", main.capacity, " unlocked=", main.unlocked, " hinted=", main.hinted.keys())
	await create_timer(0.4).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(args[0])
	quit()
