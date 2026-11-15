# 全部のレシピを知っている人が最短で回したら何日でクリアできるか（ランダムな作り順を何千回も試して最小を取る）
import random, sys
from collections import Counter
BASE=['turnip','tomato','strawberry','milk']
TWO=[('turnip','milk'),('turnip','tomato'),('turnip','turnip'),('tomato','tomato'),('tomato','milk'),('strawberry','strawberry'),('strawberry','milk'),('milk','milk'),('egg','egg'),('tomato','egg'),('egg','milk'),('turnip','egg'),('flour','egg'),('turnip','butter'),('egg','butter'),('flour','milk'),('flour','butter'),('tomato','butter')]
THREE=[('flour','egg','milk'),('flour','butter','milk'),('flour','butter','strawberry'),('turnip','milk','butter'),('turnip','tomato','butter'),('egg','milk','strawberry'),('turnip','milk','flour'),('egg','egg','milk'),('flour','egg','tomato'),('flour','milk','strawberry'),('flour','butter','egg'),('tomato','milk','flour'),('strawberry','strawberry','milk')]
MYST=('turnip','strawberry')
ALL=TWO+THREE+[MYST]
def run(START,DAILY,MAX,EGG_R=4,EGG_D=3,FB_R=10,FB_D=5,POT_D=8,rng=random):
    day=1; unl=list(BASE); cap=2; stock={i:START for i in unl}; found=set()
    egg_r=fb_r=pot_r=False
    while True:
        # その日にできるだけ新しい料理を作る（ランダムな順番で）
        while True:
            cand=[r for r in ALL if r not in found and len(r)<=cap and all(x in unl for x in r)
                  and all(stock[x]>=c for x,c in Counter(r).items())]
            if not cand: break
            r=rng.choice(cand)
            for x in r: stock[x]-=1
            found.add(r)
            n=len(found)
            if n>=EGG_R: egg_r=True
            if n>=FB_R and 'flour' not in unl: fb_r=True
            if 'flour' in unl and all(t in found for t in TWO): pot_r=True
        if len(found)==len(ALL): return day
        day+=1
        for i in unl: stock[i]=min(stock[i]+DAILY,MAX)
        want_pot=cap<3 and (pot_r or day>=POT_D)
        want_fb='flour' not in unl and (fb_r or day>=FB_D or want_pot)
        if 'egg' not in unl and (egg_r or day>=EGG_D or want_fb): unl.append('egg'); stock['egg']=START
        if want_fb:
            for i in ('flour','butter'): unl.append(i); stock[i]=START
        if want_pot: cap=3
        if day>60: return 99
for START,DAILY,MAX in [(3,1,6),(3,2,6),(3,3,6),(3,2,8),(3,3,9),(4,2,6),(4,3,8)]:
    res=[run(START,DAILY,MAX) for _ in range(3000)]
    c=Counter(res)
    print(f'はじめ{START} 毎日+{DAILY} 上限{MAX}: 最短{min(res)}日  ふつう(中央){sorted(res)[len(res)//2]}日  分布{sorted(c.items())[:6]}')
print('--- いまの設定(3,+2,6)の流れ ---')
import builtins
SECRETS=[('egg','egg','egg'),('milk','milk','milk'),('flour','flour','flour'),('strawberry','flour','flour'),('milk','butter','butter'),('tomato','tomato','flour'),('turnip','egg','flour'),('egg','flour','flour'),('strawberry','strawberry','flour')]
def trace(START,DAILY,MAX,extra=()):
    global ALL
    old=ALL; ALL=old+list(extra)
    day=1; unl=list(BASE); cap=2; stock={i:START for i in unl}; found=set(); log=[]
    egg_r=fb_r=pot_r=False
    rng=random.Random(1)
    while True:
        made=0
        while True:
            cand=[r for r in ALL if r not in found and len(r)<=cap and all(x in unl for x in r) and all(stock[x]>=c for x,c in Counter(r).items())]
            if not cand: break
            r=rng.choice(cand)
            for x in r: stock[x]-=1
            found.add(r); made+=1
            n=len([f for f in found if f not in extra])
            if n>=4: egg_r=True
            if n>=10 and 'flour' not in unl: fb_r=True
            if 'flour' in unl and all(t in found for t in TWO): pot_r=True
        log.append(f'{day}日目: {made}品作った（合計{len(found)}）鍋{cap} 材料{len(unl)}')
        if len(found)==len(ALL) or day>30: break
        day+=1
        for i in unl: stock[i]=min(stock[i]+DAILY,MAX)
        want_pot=cap<3 and (pot_r or day>=8)
        want_fb='flour' not in unl and (fb_r or day>=5 or want_pot)
        if 'egg' not in unl and (egg_r or day>=3 or want_fb): unl.append('egg'); stock['egg']=START
        if want_fb:
            for i in ('flour','butter'): unl.append(i); stock[i]=START
        if want_pot: cap=3
    ALL=old
    print('\n'.join(log))
trace(3,2,6)
print('--- ひみつも全部(3,+2,6) ---')
trace(3,2,6,SECRETS)
