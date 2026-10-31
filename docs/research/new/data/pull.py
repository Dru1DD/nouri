import json,sys,urllib.request,time
ids=open(sys.argv[1]).read().split()
out={}
for cc in ["us","gb","de","pl","fr","nl"]:
    for i in range(0,len(ids),40):
        chunk=",".join(ids[i:i+40])
        u=f"https://itunes.apple.com/lookup?id={chunk}&country={cc}&entity=software"
        d=json.load(urllib.request.urlopen(u,timeout=30))
        for r in d["results"]:
            out.setdefault(str(r["trackId"]),{})[cc]={k:r.get(k) for k in ["trackName","sellerName","averageUserRating","userRatingCount","formattedPrice","releaseDate","currentVersionReleaseDate","version","primaryGenreName"]}
            out[str(r["trackId"])][cc]["watch"]=any("Watch" in x for x in r.get("supportedDevices",[]))
        time.sleep(1)
json.dump(out,open(sys.argv[2],"w"),indent=1,ensure_ascii=False)
