import json,urllib.request,urllib.parse,time
Q={"us":["water tracker apple watch","medication reminder apple watch","pill reminder","water and medication","glp-1 tracker","supplement reminder","hydration medication reminder","adhd medication tracker"],
"gb":["pill reminder","water tracker"],
"de":["tabletten erinnerung","trinken erinnerung","medikamente erinnerung apple watch"],
"pl":["przypomnienie o lekach","picie wody","przypominacz leki"],
"fr":["rappel médicament","boire de l'eau rappel"],
"nl":["medicijn herinnering","water drinken herinnering"]}
known=set(open("ids.txt").read().split())
seen={}
for cc,qs in Q.items():
  for q in qs:
    u="https://itunes.apple.com/search?"+urllib.parse.urlencode({"term":q,"country":cc,"entity":"software","limit":25})
    for rank,r in enumerate(json.load(urllib.request.urlopen(u,timeout=30))["results"],1):
      i=str(r["trackId"])
      if i in known or (r.get("userRatingCount") or 0)<300: continue
      k=(i,cc)
      if k not in seen:
        seen[k]=1
        print(f"{cc}|{q}|#{rank}|{i}|{r['trackName'][:45]}|{r['sellerName'][:25]}|{r.get('averageUserRating',0):.2f}/{r.get('userRatingCount')}|{'W' if any('Watch' in x for x in r.get('supportedDevices',[])) else '-'}|{r.get('releaseDate','')[:10]}")
    time.sleep(0.5)
