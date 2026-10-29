import json,glob,re,os
T={"watch":r"\bwatch\b","subscr/price":r"subscri|paywall|pay |price|expensive|premium|free version|money|lifetime|one.time","notif fail":r"(notification|reminder|alert)s?\s+(stopp|don.t|didn.t|not|never|no longer)|stopped (working|remind)|not (getting|receiving)","apple health/native":r"apple health|health app|apple.s (med|own)|stock app|built.in|native app","widget/complication":r"widget|complication","water":r"\bwater|hydrat","protein":r"protein|fiber|fibre","ads":r"\bads\b|advert","bug/crash":r"crash|bug|glitch|freez","sync/data loss":r"lost (all|my) data|data (loss|lost|gone)|sync","adhd/forget":r"adhd|forget|forgetful","caregiver":r"\bmom\b|\bdad\b|mother|father|parent|husband|wife|caregiver"}
names={"653031147":"WaterMinder","1454778585":"Waterllama","1221965482":"VGFIT","573916946":"Medisafe","662170995":"MyTherapy","816347839":"PillReminderAIO","6742357512":"PillBuddy","963034692":"Streaks","6499510249":"Shotsy","6744178534":"MeAgain","6756984097":"Glapp","1515530685":"Waterful","1502063556":"Max","6758649306":"Cadence","6755569693":"DreamMe"}
print("app cc n",*T.keys(),sep="|")
for f in sorted(glob.glob("rev/*.json")):
  i,cc=os.path.basename(f)[:-5].split("-")
  R=json.load(open(f))
  if not R: continue
  row=[names[i],cc,str(len(R))]
  for k,p in T.items():
    hits=[r for r in R if re.search(p,(r["t"]+" "+r["c"]).lower())]
    row.append(f"{len(hits)}({sum(1 for r in hits if r['r']<=2)}neg)")
  print(*row,sep="|")
