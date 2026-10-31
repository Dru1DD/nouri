import json,sys,urllib.request,time
ids=sys.argv[1].split(","); ccs=sys.argv[2].split(",")
for i in ids:
  for cc in ccs:
    allr=[]
    for p in range(1,4):
      u=f"https://itunes.apple.com/{cc}/rss/customerreviews/page={p}/id={i}/sortby=mostrecent/json"
      try: d=json.load(urllib.request.urlopen(u,timeout=30))
      except Exception as e: break
      es=d.get("feed",{}).get("entry",[])
      if isinstance(es,dict): es=[es]
      es=[e for e in es if "im:rating" in e]
      if not es: break
      for e in es:
        allr.append({"r":int(e["im:rating"]["label"]),"t":e["title"]["label"],"c":e["content"]["label"],"d":e["updated"]["label"][:10],"v":e.get("im:version",{}).get("label")})
      time.sleep(0.4)
    json.dump(allr,open(f"rev/{i}-{cc}.json","w"),ensure_ascii=False)
    if allr:
      import collections
      c=collections.Counter(x["r"] for x in allr)
      print(i,cc,len(allr),allr[-1]["d"],"..",allr[0]["d"],dict(sorted(c.items())))
    else: print(i,cc,0)
