import re,sys,urllib.request,json,time,os
ids=sys.argv[1].split(","); ccs=sys.argv[2].split(",")
out={}
for i in ids:
  for cc in ccs:
    f=f"html/{i}-{cc}.html"
    if not os.path.exists(f):
      try:
        t=urllib.request.urlopen(urllib.request.Request(f"https://apps.apple.com/{cc}/app/id{i}",headers={"User-Agent":"Mozilla/5.0"}),timeout=30).read().decode("utf-8","ignore")
        open(f,"w").write(t); time.sleep(0.6)
      except Exception as e:
        print(i,cc,"ERR",e); continue
    t=open(f).read()
    m=re.search(r'"Annotation","title":"[^"]*","summary":"[^"]*","items":\[(.*?)\],"shouldAlwaysPresentExpanded"',t)
    blocks=re.findall(r'"\$kind":"Annotation","title":"([^"]*)","summary":"([^"]*)","items":\[(.*?)\],"shouldAlways',t)
    iap=[]
    for title,summ,items in blocks:
      pairs=re.findall(r'"leadingText":"([^"]*)","trailingText":"([^"]*)"',items)
      if pairs and any(re.search(r'\d',p[1]) for p in pairs): iap=pairs
    sub=re.search(r'"subtitle":"([^"]*)","rating"',t)
    out[f"{i}-{cc}"]={"sub":sub.group(1) if sub else None,"iap":iap}
    print(i,cc,"|",out[f"{i}-{cc}"]["sub"],"|","; ".join(f"{a} {b}" for a,b in iap))
json.dump(out,open("data/iap.json","a"),ensure_ascii=False)
