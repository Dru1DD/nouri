# Nuori — Task 1: Product & Competitive Intelligence

**Дата доступа ко всем источникам: 2026-10-09**, если не указано иное.
**Метод:** desk research. Приложения не устанавливались, paywall и onboarding вживую не проверялись.
**Обозначения:** [FACT], [ESTIMATE], [INFERENCE], [UNKNOWN], [HYPOTHESIS] — по стандарту Shared Brief.

**Как собирались данные App Store** (воспроизводимо, бесплатно):
- Рейтинги, количество оценок, даты релизов, описания: iTunes Lookup/Search API (`itunes.apple.com/lookup?id=…&country=XX`) по storefront US, GB, DE, FR, NL, PL.
- Цены in-app покупок и требование watchOS: публичные страницы `apps.apple.com/<cc>/app/id…`. App Store показывает **не более 10 IAP-позиций**, поэтому список может быть неполным. Позиции с одним названием и разной ценой обычно означают A/B-тесты цен или intro offers — какая цена видна конкретному пользователю, по странице определить нельзя.
- Отзывы: публичный RSS `itunes.apple.com/us/rss/customerreviews/…/sortby=mostrecent/json`, до 500 последних отзывов на приложение, **только US storefront**. RSS отдаёт самые свежие отзывы, а не репрезентативную выборку. Средняя оценка в RSS систематически ниже витринной, потому что недовольные пользователи пишут текстовые отзывы чаще.
- Напоминание: **количество оценок ≠ количество пользователей**. Это косвенный индикатор масштаба.

---

## 1. Executive summary

_Уверенность по ключевым выводам — в таблице «Итог по уверенности» в конце документа._

**Главный вывод:** гипотеза «Apple Watch-first medication + hydration companion для всех» в текущем виде слабо защищена. Сама связка «вода + лекарства» уже есть на рынке, и в одиночку она пользователей не притягивает. Сильные сигналы спроса и готовности платить в 2024–2026 гг. появились там, где лекарство, вода и питание объединены **вокруг конкретного состояния или препарата**. Самый яркий пример — GLP-1 трекеры.

Ключевые находки:

1. **Прямой аналог Nuori уже существует и не набрал оценок.** [FACT] *Dosia: Water & Medication* (indie, релиз 2026-04-20) — вода + лекарства, локальное хранение, без аккаунта, $0.99 upfront, виджеты. На 2026-10-09 у него **0 оценок во всех 6 проверенных storefront**, хотя версия 1.3.4 вышла 2026-10-03. [INFERENCE] Комбинация «вода + лекарства + приватность» сама по себе не даёт органического притока. Слабость вывода: мы не знаем маркетинговых усилий автора Dosia.
2. **Apple Health Medications — сильный бесплатный baseline для лекарств.** [FACT] Логирование на Watch (Taken / Skipped / Remind Me in 10 Minutes), follow-up reminder через 30 минут, Critical Alerts для отдельных лекарств, Log All as Taken, экспорт PDF; в США также сканирование этикетки и проверка взаимодействий. В watchOS/iOS 27 (сентябрь 2026) по Medications и воде ничего нового не анонсировано. Конкурировать с Apple на «простых напоминаниях о таблетках» бессмысленно.
3. **Встроенного hydration-логирования на Apple Watch у Apple нет.** [INFERENCE] Ни Apple Support, ни анонсы watchOS 27 не упоминают его. Вода существует только как тип данных HealthKit (Dietary Water). Hydration-приложения с хорошим Watch UX (WaterMinder) в отзывах прямо называют часы «the most effective way to remind me». Это реальная ниша, но она плотно занята: Waterllama (162k оценок US), WaterMinder (35k), Plant Nanny (106k).
4. **Самая сильная обнаруженная готовность платить — GLP-1.** [FACT] Shotsy (релиз 05.2024) — 33 219 оценок в US. MeAgain (релиз 04.2025) — 36 257 оценок в US. Подписки $9.99–19.99 в месяц / $39.99–119.99 в год. [FACT, company-stated] Shotsy в феврале 2025 сообщала о run-rate $1M и 100k+ загрузок без платной рекламы. Эти приложения объединяют **уколы + воду + белок/калории + побочные эффекты**, то есть ровно модули Nuori. При этом ни у Shotsy, ни у MeAgain на странице App Store нет требования watchOS — вероятно, Watch-приложения нет [INFERENCE].
5. **Повторяющийся паттерн в отзывах о лекарствах:** ценность — в **настойчивости и надёжности напоминаний** (эскалация, «phone call» в Pill Buddy и Max, «Remind again»). Самые частые жалобы — уведомления перестают приходить. Вторая частая жалоба — paywall на базовые функции (Medisafe, Waterllama после v1.93, WaterMinder).
6. **Монетизация.** Пользователи открыто злятся на подписку за «простой трекер». Lifetime / one-time опции присутствуют у WaterMinder ($49.99), MyTherapy (lifetime 199,99 zł в PL), Pill Reminder All in One (Full Version $2.99), HiWater ($9.99). [HYPOTHESIS] Для generic-сегмента one-time/lifetime может конвертировать лучше подписки. Для GLP-1 и chronic-сегментов подписка принимается.
7. **Калории** — самая переполненная категория (MyFitnessPal 2.37M оценок, Cal AI 369k, Lose It! 780k). Как самостоятельное позиционирование для соло-основателя — нет. Как модуль «белок + калории при GLP-1» — потенциально да.

**Рекомендация на 30 дней:** не расширять функциональность. Проверить 2–3 конкретных сегмента через лендинги и интервью: (а) GLP-1 users с Apple Watch; (б) люди со строгим режимом приёма + воды (POTS, литий, камни в почках, post-op); (в) «supplement/creatine stackers» с Apple Watch. Параллельно сделать Watch-UX бенчмарк против Apple Medications и WaterMinder: тапы до действия, complications, надёжность напоминаний.

---

## 2. Market map

Колонки:
- **US ★/N** — средний рейтинг и число оценок в US storefront на 2026-10-09 [FACT].
- **Watch** — по странице App Store:
  - ✓p — на странице указано «Requires watchOS X».
  - ✓d — Watch упомянут только в описании.
  - ✗p — требование watchOS на странице не найдено.
  - ? — не проверено.
- **Флаги** — из описания [FACT: заявление разработчика]: W = widget, C = complication, HK = Apple Health/HealthKit, S = Siri/Shortcuts, F = family/sharing.
- **Монетизация** — по списку IAP на странице US (до 10 позиций).

### 2.1 Hydration / water tracking

| # | Продукт | Целевая аудитория / проблема | US ★/N | Watch | Флаги | Монетизация (US) | Отличие | Качество данных |
|---|---|---|---|---|---|---|---|---|
| 1 | [Waterllama](https://apps.apple.com/us/app/id1454778585) (Llama Luna Apps) | Массовый, геймификация привычки пить | 4.9 / 162 644 | ✓p (10.0) | W, HK, S | Freemium; подписки, видны $0.99/мес … $19.99; позиции $8.99–19.99 | Персонажи, челленджи, App Store Award 2022 | Высокое |
| 2 | [WaterMinder](https://apps.apple.com/us/app/id653031147) (Funn Media) | Взрослые, Apple-экосистема | 4.7 / 35 063 | ✓p (10.0) | W, HK, S, F | $2.99/мес, $14.99/год (offer $7.49), lifetime $49.99, tip jar | Лучший Watch UX по отзывам, complications, с 2013 г. | Высокое |
| 3 | [Plant Nanny](https://apps.apple.com/us/app/id1424178757) (Sparkful) | Массовый, «вырасти растение» | 4.7 / 106 483 | ✓p (9.0) | W, HK, F | $3.99–7.99/мес, $44.99/6 мес, $69.99/год, consumables | Тамагочи-механика | Высокое |
| 4 | [Drink Water Reminder N Tracker](https://apps.apple.com/us/app/id870372885) (Phoenix Games) | Массовый | 4.5 / 152 195 | ✓d? | HK | ? | Ранний игрок; последнее обновление 2025-09 | Среднее |
| 5 | [Water Reminder – Daily Tracker](https://apps.apple.com/us/app/id1221965482) (VGFIT) | Массовый, 33 языка | 4.7 / 78 784 | ✓p (9.0) | W, HK | Premium $0.99 … $79.99 (много вариантов) | Сильная локализация; GB 16k, FR 9.3k, NL 8.3k оценок | Высокое |
| 6 | [My Water](https://apps.apple.com/us/app/id964748094) (My Water Drink Tracker Oy, FI) | Массовый | 4.6 / 24 209 | ✓p (10.0) | HK | Неделя $1.99–4.99, месяц $4.99–9.99, год $39.99–49.99, full $59.99 | Агрессивная weekly-модель | Высокое |
| 7 | [HidrateSpark](https://apps.apple.com/us/app/id1056269374) | Владельцы умной бутылки | 4.5 / 19 804 | ✓p (7.0) | W, HK | Premium $1.99 / $14.99 + hardware | Привязка к железу; 54% из 500 последних отзывов ≤2★ (bugs/sync) | Высокое |
| 8 | [waterdrop Hydration](https://apps.apple.com/us/app/id1535002336) (DE бренд напитков) | Покупатели бренда | 4.8 / 780 (DE 2 447) | ? | HK | Free | Brand-app, DE-фокус | Среднее |
| 9 | [Drink water: Drinking reminder](https://apps.apple.com/us/app/id1478980974) (TMEDILAB) | Массовый, 33 языка | 4.6 / 22 559 | ? | HK, F | ? | Локализации, DE 2.9k | Среднее |
| 10 | [Water Time](https://apps.apple.com/us/app/id1208916325) (Roman Nikolaev) | Массовый | 4.7 / 2 354 (**PL 3 867**) | ✓p (4.3) | HK | $3.99–4.99/мес, $19.99/год, PRO $19.99, ads removal | Indie; в PL оценок больше, чем в US; обновлялось последний раз 2024-09 | Высокое |
| 11 | [Drink Water Aquarium](https://apps.apple.com/us/app/id1315396498) (Andreas Budde, DE) | Массовый, геймификация | 4.7 / 3 596 (DE 5 492) | ✓d | — | Подписка | Indie, сильнее в DE | Среднее |
| 12 | [HiWater](https://apps.apple.com/us/app/id1561732866) | Power users, Watch | 4.7 / 131 | ✓p (10.0) | W, C, S | $0.99/мес, $5.99/год, **permanent $9.99** | Watch-first indie, дешёвый lifetime | Высокое |
| 13 | [Watercat](https://apps.apple.com/pl/app/id1579056677) (Orange dog, SI) | Массовый, «кот» | US 1 361 / **PL 2 586** | ✗p | — | Удаление рекламы 4,99 zł | Сильнее в PL | Высокое |
| 14 | [Waterful](https://apps.apple.com/pl/app/id1515530685) (**Listonic sp. z o.o., PL**) | Массовый | US 619 / **PL 1 843** | ✓p (8.0) | W, HK | 4,99 zł/мес; 14,99–37,99 zł/год; lifetime 39,99–49,99 zł | Польский разработчик; последнее обновление 2023-08 | Высокое |
| 15 | [Water reminder & drink tracker](https://apps.apple.com/pl/app/id1417038587) (Wachanga) | Массовый | **PL 6 022** | ? | — | ? | Лидер PL-выдачи; обновлялось последний раз 2022-05 | Среднее |
| 16 | [Gerolsteiner TrinkCheck](https://apps.apple.com/de/app/id370892661) | DE, бренд воды | DE 4 094 | ✓d | W, HK | Free | Бренд-приложение (DE) | Среднее |
| 17 | [Hydra Fuel – Water & Creatine](https://apps.apple.com/us/app/id6761676503) | Gym, креатин + вода | 4.6 / 14 | ✗p | — | Weekly $3.99–9.99, yearly $9.99–39.99 | Новая микро-ниша (релиз 2026-05) | Высокое (факт), ниша — низкое |

### 2.2 Medication & pill reminders

| # | Продукт | Целевая аудитория / проблема | US ★/N | Watch | Флаги | Монетизация (US) | Отличие | Качество данных |
|---|---|---|---|---|---|---|---|---|
| 18 | [Medisafe](https://apps.apple.com/us/app/id573916946) | Хронические пациенты, многокомпонентная терапия, семьи | 4.7 / 101 444 | ✓p (10.0) | HK, F | $2.99–9.99/мес, $27.99–39.99/год (PL: 14,99–29,99 zł/мес, 129,99–199,99 zł/год) | Лидер категории, pharma-партнёрства, «Medfriend»; 50% из 500 последних отзывов ≤2★ | Высокое |
| 19 | [MyTherapy](https://apps.apple.com/us/app/id662170995) (smartpatient GmbH, DE) | Хронические пациенты, EU | 4.8 / 8 554 (**DE 15 378**) | ✗p | HK, F | Ad-free подписка $0.99 / $9.99; **lifetime $49.99** (PL 199,99 zł) | Бесплатное ядро; 32 языка, включая PL/UK; лидер DE/FR | Высокое |
| 20 | [mediteo](https://apps.apple.com/de/app/id1063257864) (DE) | DE-пациенты | DE 20 292 | ✗p | HK | DE: premium 8,99 €/мес, 23,49 €/3 мес (с trial); «Unterstützer» 0,99–5,99 € | Крупнейший в DE по оценкам | Высокое |
| 21 | [Pill Reminder – All in One](https://apps.apple.com/us/app/id816347839) (Sergio Licea, indie) | Сложные схемы, PRN, опекуны | 4.7 / 27 923 | ✗p | F, **Critical Alerts** (описание) | **Full Version $2.99 (one-time)** | Локальные данные, без аккаунта; Watch-приложения нет (отзыв 2021 подтверждает) | Высокое |
| 22 | [Max – Pill reminder](https://apps.apple.com/us/app/id1502063556) (Artify, KR) | Забывчивые, семьи (Share & Care) | 4.8 / 9 803 | ✗p | F | IAP на странице не видны | Персонаж-собака, «фейковый звонок» как эскалация | Высокое |
| 23 | [Pill Buddy](https://apps.apple.com/us/app/id6742357512) (Kai Loh, ex-Duolingo PM) | Молодые, забывчивые, витамины | 4.9 / 1 775 (релиз 2025-05) | ✗p | W | Supporter $4.99/мес, $35.90/год (GB £4.99 / £34.90) | Маскот, который «злится», телефонные звонки, streaks | Высокое |
| 24 | [EveryDose](https://apps.apple.com/us/app/id1188929364) | US-пациенты | 4.8 / 5 129 (только US) | ✗p | HK, F | $9.99/мес, $59.99/год | US-only | Высокое |
| 25 | [Pill Reminder Medication Alarm](https://apps.apple.com/us/app/id863327251) | Массовый | 4.6 / 4 424 | ✓d | — | ? | Будильник-стиль | Среднее |
| 26 | [Doseful](https://apps.apple.com/us/app/id6739787051) | Массовый | 4.7 / 446 | ✗p | — | Weekly $4.99–8.99, $14.99/мес, $39.99–59.99/год | Агрессивный weekly paywall | Высокое |
| 27 | [Hero Health](https://apps.apple.com/us/app/id1352848484) | Пожилые, US, диспенсер | 4.7 / 10 631 | ✓d | F | Hardware + подписка | Железо; не прямой конкурент | Среднее |
| 28 | [TOM](https://apps.apple.com/de/app/id1469898237) (Innovation 6, DE) | DE/FR пациенты | DE 418 / FR 391 | ? | — | Free | Локальный DE | Среднее |
| 29 | [Peach](https://apps.apple.com/fr/app/id1512969375) / [Medico](https://apps.apple.com/fr/app/id1462935634) (FR indie) | FR | FR 1 325 / 2 390 | ? | — | Free | Локальные FR-игроки | Среднее |
| 30 | [MedApp](https://apps.apple.com/nl/app/id1527313551) (NL) | NL, связь с аптеками | NL 1 294 | ? | — | Free | Локальный NL | Среднее |
| 31 | [Tablets App](https://apps.apple.com/gb/app/id1322116003) (Sleepy Boy, UK) | UK/EU | GB 422 | ✓d | W | ? | Watch + widget | Среднее |
| 32 | Round Health | Ранее популярный iOS pill reminder | — | — | — | — | [UNKNOWN] Lookup API по ID 1059591124 на 2026-10-09 не вернул данных ни в одном из 6 storefront. Возможно, приложение снято с продажи — не подтверждено | Низкое |

### 2.3 Приложения, объединяющие несколько health-рутин

| # | Продукт | Что объединяет | US ★/N | Watch | Монетизация | Комментарий |
|---|---|---|---|---|---|---|
| 33 | [**Dosia: Water & Medication**](https://apps.apple.com/us/app/id6762511328) | Вода + лекарства, local-only | **0 / 0** во всех 6 storefront | ✗p | $0.99 paid upfront | Ближайший аналог Nuori, только на английском |
| 34 | [**Shotsy**](https://apps.apple.com/us/app/id6499510249) | GLP-1 уколы/таблетки + вода + белок/калории + побочные эффекты + вес | 4.8 / 33 219 (GB 4 210, DE 1 604) | ✗p | $9.99–19.99/мес, $39.99–59.99/год | Самый сильный кейс WTP |
| 35 | [**MeAgain**](https://apps.apple.com/us/app/id6744178534) | GLP-1 + еда/белок/клетчатка/вода + побочные эффекты | 4.8 / 36 257 (релиз 2025-04) | ✗p | «Unlimited» $14.99 … $119.99 | Быстрый рост |
| 36 | [Glowise](https://apps.apple.com/us/app/id6730116702) и ещё 10+ GLP-1 трекеров (Zepbound & Mounjaro Tracker 3 179; Dose AI 1 009; Glapp 985; Pep 931) | GLP-1 | 4.8 / 6 612 | ? | Подписки | Ниша быстро переполняется |
| 37 | [Bearable](https://apps.apple.com/us/app/id1482581097) | Симптомы + лекарства + настроение, корреляции | 4.8 / 6 447 | ✗p | Premium $4.49 … $49.99 | Chronic illness, нет Watch |
| 38 | [CareClinic](https://apps.apple.com/us/app/id1455648231) | Лекарства + симптомы + дневник | 4.2 / 2 309 | ✓p (9.0) | Pass $5.99 … $79.99 | Перегружен, 72 языка |
| 39 | [POTSie](https://apps.apple.com/us/app/id6474701900) / [SaltStack](https://apps.apple.com/us/app/id6759544311) | POTS: жидкость + соль + лекарства + симптомы | 4.8 / 53; 0 / 0 | ✗p / ✓d | Free / IAP | Сигнал ниши «вода + лекарства по медицинской причине» |
| 40 | [SuppCo](https://apps.apple.com/us/app/id6504838951) | Supplement stack: сканер + трекер | 4.8 / 30 753 (только US) | ? | ? | Сегмент «стекеров» добавок |

### 2.4 Habit tracking / wellness (только релевантные)

| # | Продукт | US ★/N | Watch | Монетизация | Релевантность |
|---|---|---|---|---|---|
| 41 | [Streaks](https://apps.apple.com/us/app/id963034692) (Crunchy Bagel) | 4.8 / 27 349 | ✓p (10.0), C | **$5.99 paid upfront**, без IAP | Watch-first habit tracker, умеет автоматически засчитывать задачи по данным Health (описание). Пользователи делают в нём «pills» и «water» |
| 42 | [Finch](https://apps.apple.com/us/app/id1528595748) | 4.9 / 761 397 | ✗ | Freemium | Self-care-рутины с питомцем — эталон эмоционального удержания |
| 43 | [Me+](https://apps.apple.com/us/app/id1596403446), [Habit Tracker (Inner Grow)](https://apps.apple.com/us/app/id1438388363), [Fabulous](https://apps.apple.com/us/app/id1203637303) | 248k / 148k / 89k | частично | Подписки | Рутины «выпей воду / прими витамины» внутри общих трекеров |
| 44 | [Tally](https://apps.apple.com/us/app/id1090990601), [HabitMinder](https://apps.apple.com/us/app/id1253577148) (Kodeon) | 4.4 / 4 106; 4.6 / 5 882 | ✓d | Подписка | «Anything tracker» с Watch и Siri |

### 2.5 Встроенные инструменты Apple

| # | Решение | Что умеет (подтверждено) | Источник |
|---|---|---|---|
| 45 | **Health → Medications** (iOS 16+, watchOS 9+; расписания по дням недели и циклические — iOS 18 / watchOS 11+) | [FACT] Добавление лекарств (в США — сканирование камерой); расписания; dose reminders; follow-up через 30 минут; Critical Alerts для отдельных лекарств (звук даже в Focus/mute); на Watch: Log as Taken / Skipped / Remind Me in 10 Minutes, Log All as Taken; экспорт PDF; sharing через Health Sharing; проверка взаимодействий (только США); Siri «Log my 6AM medications» (Ultra 2, не во всех регионах) | [Apple Support 105064](https://support.apple.com/en-us/105064); [Watch Ultra guide](https://support.apple.com/en-ae/guide/watch-ultra/apd3dd24d78b/watchos); [Macworld](https://www.macworld.com/article/2521302/how-to-adjust-medications-reminders-on-your-iphone-ipad-and-apple-watch.html) |
| | Ограничения Medications | [FACT, Macworld] Dose reminder не повторяется; follow-up — одна дополнительная попытка; нет разных доз в разные дни. [ANECDOTAL] В Apple Community жалуются на тихий звук и пропадающие напоминания | [Apple Community 255955677](https://discussions.apple.com/thread/255955677), [254457209](https://discussions.apple.com/thread/254457209) |
| 46 | **Health → Water (HealthKit Dietary Water)** | [INFERENCE] Тип данных существует; ручной ввод — в Health на iPhone. Нативного Watch-интерфейса для логирования воды Apple не документирует. В анонсах watchOS 27 / iOS 27 (09.09.2026) нет ни воды, ни Medications | [Apple Newsroom 2026-09](https://www.apple.com/newsroom/2026/09/apple-advances-health-and-fitness-capabilities-using-apple-intelligence/) |
| 47 | **Reminders / Alarms / Shortcuts** | [FACT] Бесплатно, есть Watch. [ANECDOTAL] Пользователи используют Reminders как обходной путь из-за громкости, но «you still have to go to the Health app to check off your medicine» | [Apple Community 254457209](https://discussions.apple.com/thread/254457209) |

### 2.6 Поведенческие заменители

| # | Заменитель | Комментарий |
|---|---|---|
| 48 | Таблетница по дням недели, бутылка с разметкой по часам | [INFERENCE] Нулевое трение; основной конкурент для «простых» пользователей. Данных о доле не найдено [UNKNOWN] |
| 49 | Умные бутылки (HidrateSpark, LARQ) | Железо + приложение + подписка; много жалоб на sync |
| 50 | Отсутствие трекинга | [UNKNOWN] Доля и причины не изучены — проверять интервью |

### 2.7 Наблюдения по географии

| Рынок | Лидеры по оценкам (hydration) | Лидеры (medication) | Наблюдение |
|---|---|---|---|
| US | Waterllama 163k, Drink Water Reminder N 152k, Plant Nanny 106k | Medisafe 101k, Pill Reminder All in One 28k | Самая глубокая выручка и конкуренция; GLP-1 почти полностью US-история |
| GB | VGFIT 16k, Drink Water Reminder N 11k, Plant Nanny 10k | Medisafe 13k, MyTherapy 3.2k | Близок к US, GLP-1 присутствует (Shotsy 4.2k) |
| DE | Waterllama 26k, Plant Nanny 8k, VGFIT 5.6k, Drink Water Aquarium 5.5k | **mediteo 20k**, **MyTherapy 15k**, Medisafe 3.7k | Локальные игроки сильнее глобальных в лекарствах; бренды воды (Gerolsteiner, waterdrop) |
| FR | VGFIT 9.3k, Waterllama 7.8k | Medisafe 4.9k, MyTherapy 4.0k, Medico 2.4k, Peach 1.3k | Локальные indie-приложения для лекарств |
| NL | VGFIT 8.3k, Plant Nanny 3.1k, Waterllama 3.1k | Medisafe 3.2k, MyTherapy 2.4k, MedApp 1.3k | Небольшой рынок, локальный MedApp |
| PL | **Wachanga 6.0k**, Water Time 3.9k, Watercat 2.6k, VGFIT 2.3k, Waterful 1.8k | MyTherapy 1.9k, Medisafe 0.4k | Абсолютные числа малы; польский разработчик (Listonic) есть, но Waterful не обновлялся с 2023 |

[INFERENCE] Польша — удобный тестовый рынок: родной для основателя, PL-локализация уже есть, а лидеры hydration-категории неактивны или слабы (Wachanga не обновлялся с 2022, Waterful — с 2023).

Цены: PLN-тарифы **сопоставимы с долларовыми или выше** при пересчёте. Примеры: WaterMinder 87,99 zł/год против $14.99; Medisafe 149,99–199,99 zł/год против $39.99; MyTherapy lifetime 199,99 zł против $49.99. Курс для точного сравнения брать по NBP на дату. При этом цены в PL включают 23% VAT, а US-цены — без sales tax. Слабость PL — в покупательной способности и маленьком абсолютном объёме рынка. [HYPOTHESIS] Конверсия в оплату в PL ниже, чем в US/UK; поэтому PL подходит для проверки использования, но хуже — для проверки WTP.

**Что подтверждено:** состав лидеров по странам (по оценкам); в DE/FR/NL сильны локальные medication-приложения; в PL hydration-лидеры не обновляются.
**Что неизвестно:** реальные доли загрузок по странам (Sensor Tower/AppMagic недоступны).
**Уверенность: средняя** — оценки отражают накопленную историю, а не текущий спрос.
**Действие:** использовать PL для ранних usage-тестов; WTP проверять на англоязычной аудитории (US/UK).

**Итог по разделу 2 (market map).**
- **Что подтверждено:** рейтинги, цены IAP, требования watchOS на 2026-10-09 для ~50 решений.
- **Что неизвестно:** onboarding/paywall, retention, загрузки.
- **Уверенность: высокая** в составе рынка; **низкая** в масштабе отдельных игроков.
- **Действие:** использовать shortlist ниже как список для установки и UX-бенчмарка.
---

## 3. Shortlist и обоснование выбора

### 3.1 Веса

Стартовые веса из брифа оставлены с одной корректировкой: Apple Health Medications не скорится, а используется как **baseline**. Это бесплатная системная функция, и её «монетизация» и «каналы роста» не сравнимы с коммерческими приложениями.

| Критерий | Вес |
|---|---|
| A. Пересечение аудитории и сценария | 25% |
| B. Apple Watch UX и скорость действий | 20% |
| C. Пересечение hydration + meds / рутин | 15% |
| D. Сила потребительских сигналов | 15% |
| E. Интересность монетизации | 10% |
| F. Подтверждённые каналы роста | 10% |
| G. Релевантность для early-stage основателя | 5% |

### 3.2 Оценки (1–5)

Это инструмент приоритизации исследования, а не оценка качества бизнеса.

| Продукт | A | B | C | D | E | F | G | **Итог** | Почему в shortlist |
|---|---|---|---|---|---|---|---|---|---|
| WaterMinder | 4 | 5 | 2 | 4 | 5 | 3 | 4 | **3.90** | Эталон Watch-hydration, lifetime + подписка |
| Streaks | 3 | 5 | 4 | 4 | 5 | 2 | 5 | **3.90** | Watch-first, paid upfront, маленькая команда |
| Waterllama | 3 | 4 | 2 | 5 | 4 | 3 | 5 | **3.55** | Indie → студия, лидер hydration, свежий переход к paywall |
| Shotsy | 3 | 1 | 4 | 5 | 5 | 4 | 5 | **3.45** | Сильнейший кейс WTP и роста без рекламы |
| Medisafe | 4 | 4 | 2 | 4 | 4 | 2 | 2 | **3.40** | Лидер meds с Watch; источник жалоб |
| MeAgain | 3 | 1 | 4 | 5 | 4 | 2 | 3 | **3.05** | Быстрорастущий GLP-1 combo |
| Dosia | 5 | 1 | 5 | 1 | 2 | 1 | 5 | **2.90** | Прямой аналог концепции |
| MyTherapy | 4 | 1 | 2 | 4 | 3 | 2 | 2 | **2.70** | EU-лидер, бесплатное ядро, lifetime |
| Pill Reminder – All in One | 4 | 1 | 1 | 4 | 4 | 1 | 5 | **2.70** | Соло-разработчик, one-time $2.99, local-only |
| Pill Buddy | 3 | 1 | 2 | 3 | 4 | 3 | 5 | **2.65** | Indie 2025, эмоциональный UX, эскалация |
| Plant Nanny | 2 | 3 | 1 | 5 | 3 | 2 | 2 | **2.60** | Масштаб геймификации |
| Max | 3 | 1 | 1 | 4 | 2 | 1 | 3 | **2.15** | «Фейковый звонок», Share & Care |
| *Apple Health Medications* | baseline | | | | | | | — | Главный бесплатный заменитель |

Пояснения к оценкам B:
- B = 1 означает, что на странице App Store нет требования watchOS (✗p). Для Shotsy, MeAgain, Dosia, MyTherapy, Max, Pill Buddy и Pill Reminder All in One отсутствие Watch-приложения подтверждено **двумя независимыми сигналами**: (1) нет «Requires watchOS» на странице; (2) в поле `supportedDevices` Lookup API нет Watch-устройств. Для сравнения, у Medisafe и WaterMinder там есть `Watch4-Watch4`. [INFERENCE, средне-высокая уверенность] — окончательно проверить установкой.
- Оценки F основаны только на подтверждённых источниках, перечисленных в разделе 4.

Не вошли в shortlist, но важны как фон: VGFIT (локализации), HiWater (Watch-first indie, дешёвый lifetime), Hydra Fuel (creatine-ниша), POTSie/SaltStack (chronic-ниша), mediteo (DE).

**Итог по разделу 3.**
- **Что подтверждено:** входные данные для оценок (рейтинги, цены, Watch-флаги).
- **Что неизвестно:** качество Watch UX у тех, у кого он есть (без установки).
- **Уверенность: средняя** — веса субъективны, оценки A и G экспертные.
- **Действие:** установить топ-6 (WaterMinder, Streaks, Waterllama, Shotsy, Medisafe, Pill Buddy) + Apple Medications и сделать UX-бенчмарк.

---

## 4. Deep dive по конкурентам

> Общее ограничение: onboarding, paywall timing и число тапов на Watch вживую **не проверялись** [UNKNOWN]. Ниже — то, что видно из страниц App Store, описаний, release notes, отзывов (US RSS, до 500 последних) и публичных статей. Число «n отзывов с упоминанием X» — подсчёт по ключевым словам в выборке RSS; это грубая метрика.

### 4.1 Apple Health Medications (baseline)

- **ICP / JTBD:** любой пользователь iPhone, принимающий лекарства или добавки. «Напомни и зафиксируй, что я принял».
- **Сильные стороны [FACT]:** бесплатно, встроено и не требует установки. Работает на Watch. Есть Critical Alerts — сторонним приложениям для этого нужен отдельный entitlement от Apple ([Apple Developer: criticalAlert](https://developer.apple.com/documentation/usernotifications/unauthorizationoptions/criticalalert)). PDF-экспорт для врача.
- **Слабые стороны [FACT / ANECDOTAL]:** одно напоминание плюс один follow-up, без нарастающей эскалации; нет разных доз по дням (Macworld). Жалобы на тихий звук и пропадающие напоминания (Apple Community, анекдотично). Отзывы прямо говорят: «The Apple medications app was great for simple medication reminders, but … I would sleep through my medication reminders» (Max, 5★, 2025-08-17, US). А пользователь Medisafe, наоборот, уходит к Apple из-за paywall: «I am transitioning Apple's native Health app to record meds» (Medisafe, 3★, 2025-01-01).
- **Вывод [INFERENCE]:** Apple закрывает «простые» сценарии. Пространство для сторонних приложений остаётся: (1) настойчивость и эскалация; (2) сложные схемы (PRN, интервалы «каждые 8 часов», курсы); (3) связка с другими действиями (вода, еда, симптомы); (4) эмоциональная мотивация; (5) уход за другим человеком.

### 4.2 WaterMinder (Funn Media, LLC)

- **ICP:** взрослые пользователи iPhone + Apple Watch, привычка к здоровью. Основатель — Kriss Smolka, приложение существует с 2013 г.
- **Позиционирование:** «Water Tracker by WaterMinder®». Простота, кастомизация напитков, Watch.
- **Watch UX [FACT по отзывам/прессе]:** complications, интерактивные виджеты на Watch (2024), логирование «with just a tap». Watch-приложение переписано на SwiftUI в версии 5.1 ([MacStories](https://macstories.net/?p=69231)). Цитаты: «I love that it works on my Apple Watch, too, as that is the most effective way to remind me» (5★, 2026-10-07). «I use it mostly on my Apple Watch which makes it super easy to log» (5★, 2026-10-05). В выборке 43 из 500 отзывов упоминают watch, только 3 из них негативные.
- **Монетизация [FACT, US-страница]:** $2.99/мес, $14.99/год, Yearly Offer $7.49, **Premium One time $49.99**, tip jar $0.99–49.99. PL: 14,99 zł/мес, 87,99 zł/год, offer 44,99 zł, lifetime 229,99 zł.
- **Негатив:** 34 из 69 негативных отзывов (≤2★) касаются цены или подписки. Пример: «it forces you to pay a subscription to use it at all» (2★, 2026-06-25); «Free trial is not free that is a nice way of saying bait and switch» (1★, 2026-06-24). Также жалобы на то, что напоминания перестают приходить (1★, 2026-07-01).
- **Рост [FACT, Apple spotlight 2021]:** в первый день — «a couple hundred downloads». Затем бесплатная промо-акция и внимание медиа дали сотни тысяч загрузок ([iPhoneinCanada](https://www.iphoneincanada.ca/2021/02/12/apple-spotlights-waterminder-app-developer/)). Есть пресса о featuring/обновлениях (9to5Mac, appgefahren.de).
- **WTP-гипотеза:** пользователи платят за быстрый Watch-ввод и кастомизацию, но жёсткий paywall на старте вызывает отторжение.

### 4.3 Waterllama (Llama Luna Apps Inc.)

- **ICP:** широкая аудитория, в т.ч. молодая; мотивация через персонажей и челленджи.
- **Происхождение [FACT, пресса TW]:** украинский indie-разработчик Vitalii Mogylevets и жена-иллюстратор; App Store Award 2022 ([inside.com.tw](https://www.inside.com.tw/article/29894-2022-App-Store-Awards-Waterllama)). Сейчас — команда около 10 человек, «8M+ combined downloads» по всем приложениям студии; студия нанимает growth/acquisition lead ([djinni](https://djinni.co/jobs/835286-mobile-growth-marketing-lead-ios-apps/)) [FACT, company-stated, не аудировано].
- **Watch:** требует watchOS 10. Отзывы хвалят наличие часов, есть и баг-репорты по Watch-отображению (4★, 2026-07-31).
- **Монетизация:** freemium + подписки; на US-странице видны позиции $0.99 (Monthly Full Access) … $19.99. PL: 4,99 zł/мес … 69,99 zł.
- **Важный сдвиг [FACT по отзывам]:** после обновления v1.93 (июль 2026) часть ранее бесплатных функций ушла за paywall: «custom amount of water, challenges, tips, drink choice, missed days … locked behind a $8.99 or $39.99 subscription» (1★, 2026-07-25); «I Would Rather Not Track Water Than Buy Premium» (1★, 2026-07-27). В выборке 31 из 47 негативных отзывов касаются цены или подписки.
- **Вывод [INFERENCE]:** даже лидер с 160k оценок ужесточает монетизацию. Это сигнал, что freemium hydration плохо монетизируется на мягком paywall. Одновременно это окно для «честной» альтернативы.

### 4.4 Plant Nanny (Sparkful)

- **ICP:** казуальные пользователи, геймификация «поливай растение».
- **Монетизация [FACT]:** $3.99–7.99/мес, $44.99/6 мес, $69.99/год, consumables (clovers, packs).
- **CX:** самая высокая доля позитива в выборке (17 негативных из 500). Free-версия ценится: «Free version reminds me … via notifications to my phone and Apple Watch» (5★, 2026-03-27).
- **Метрики:** «Downloads 3M+» [ESTIMATE, mwm.ai]; «9.5M users» [FACT, маркетинговое заявление компании, не аудировано]; 30M+ downloads по всем приложениям Sparkful (сайт) ([sparkful.app](https://sparkful.app/)).
- **Вывод:** эмоциональная механика удерживает, но это B2C-игра с большой арт-командой; для соло-основателя трудно повторить.

### 4.5 Medisafe

- **ICP:** люди с несколькими хроническими препаратами, их семьи (Medfriend), pharma-программы.
- **Watch:** требует watchOS 10, есть complication. Ценность Watch подтверждена: «I frequently use my Apple Watch to mark my meds as taken with Medsafe because my phone is not always nearby» (отзыв о Pill Reminder All in One, 4★, 2021-09-10). Но есть жалобы на sync с Watch (1★, 2026-09-02; 3★, 2026-06-21).
- **Монетизация [FACT]:** US $2.99–9.99/мес, $27.99–39.99/год. **По отзывам (не проверено):** примерно с ноября 2024 бесплатная версия ограничена двумя лекарствами: «charging people to manage more than 2 medicines is absolutely unacceptable» (1★, 2024-11-15); «$10/month for reminders??» (1★, 2024-08-30).
- **CX:** в RSS-выборке 250 из 500 отзывов — ≤2★. Темы: подписка (81 негативный), уведомления (82), sync/bugs (50), навязчивая лента контента (1★, 2025-05-30), проблемы с PRN («as needed») и интервалами «3x a day ≠ every 8 hours» (1★, 2025-06-13).
- **Метрики:** «7M+ registered users» [FACT, company-stated, старые]; 13M+ [непроверенный профиль]; ~345K iOS MAU [ESTIMATE, AppGoblin]; revenue $10–15M [ESTIMATE, Similarweb, company-level]. Данные противоречат друг другу.
- **Вывод [INFERENCE]:** лидер «размывается» — бизнес B2B2C/pharma, consumer UX деградирует. Недовольные пользователи уходят к Apple или к indie-приложениям.

### 4.6 MyTherapy (smartpatient GmbH → Shop Apotheke Europe / Redcare)

- **ICP:** хронические пациенты, EU-фокус; дневник здоровья (симптомы, измерения).
- **Позиционирование:** бесплатное ядро; бесплатная версия показывает рекламу (есть IAP «Ad-free Subscription», 13 упоминаний рекламы в выборке отзывов); основной доход, вероятно, — pharma-партнёрства [INFERENCE] ([smartpatient.eu](https://smartpatient.eu/)); куплено Shop Apotheke Europe ([Munich Startup](https://www.munich-startup.de/news/shop-apotheke-europe-uebernimmt-smartpatient)).
- **Watch:** на странице нет требования watchOS → вероятно, нет Watch-приложения [INFERENCE].
- **Монетизация [FACT]:** ad-free подписка $0.99 / $9.99; lifetime $49.99 (PL 4,99 zł, 49,99 zł, lifetime 199,99 zł). Жалоб на цену почти нет (2 негативных из 38).
- **CX:** 294 из 500 отзывов про напоминания; негатив — напоминания перестают приходить (1★, 2026-07-07; 2★, 2026-04-25). Нравится refill reminder (5★, 2026-02-09). «it's ugly» (4★, 2026-06-01).
- **Метрики:** «12M+ users» и «9M+ (Feb 2024)» [FACT, company-stated, противоречивы]. DE 15 378 оценок [FACT].
- **Вывод:** в EU бесплатное и широко локализованное решение ставит планку «лекарства — бесплатно». Платить за базовые напоминания европейцы, вероятно, не будут [HYPOTHESIS].

### 4.7 Pill Reminder – All in One (Sergio Licea)

- **ICP:** сложные схемы (послеоперационные, PRN), опекуны супругов, животные (эпилепсия у собаки, 5★, 2024-11-12).
- **Монетизация [FACT]:** Full Version **$2.99 one-time**. Тот же разработчик делает Birth Control Pill Reminder (9 735 оценок) — портфельная стратегия по нишевым keywords [INFERENCE].
- **CX:** «It doesn't require an account … All the data is stored locally» (5★, 2025-12-10) — приватность и local-only ценятся. Минус — нет Watch: пользователь вернулся к Medisafe из-за Watch (4★, 2021-09-10). Просят CSV-экспорт (5★, 2026-07-27).
- **Вывод [INFERENCE]:** соло-модель «дешёвый one-time + много узких приложений под keywords» жизнеспособна. Подтверждённый пробел конкурента — Watch.

### 4.8 Max – Pill reminder (Artify Inc.)

- **ICP:** забывчивые, семьи (Share & Care — «look after your parents' meds from afar»).
- **UX:** «фейковый звонок»/лай собаки как эскалация. Цитата: «I would sleep through my medication reminders … This app is amazing because it actually…» (5★, 2025-08-17, сравнение с Apple Medications).
- **CX-риски:** «It stops working after about a month» (1★, 2022); потеря данных после перезагрузки (4★, 2025-11-19). 31 упоминание рекламы в выборке.
- **Монетизация:** IAP на странице не видны [UNKNOWN]; вероятно, реклама.

### 4.9 Pill Buddy (Kai Loh)

- **ICP:** молодые забывчивые взрослые, витамины, «I notoriously forget my morning meds».
- **Promise:** маскот, который «gets increasingly annoying if you miss a dose»; push + **phone calls** + widgets; streaks и звёзды.
- **Рост [FACT]:** 9to5Mac Indie App Spotlight — экс-Duolingo PM, ушёл в indie ([9to5Mac](https://9to5mac.com/?p=1004129)); TuttoTech (IT). Reddit/TikTok-кампании **не подтверждены** [UNKNOWN].
- **Монетизация [FACT]:** Supporter $4.99/мес, $35.90/год (GB £4.99 / £34.90); ядро бесплатно. «Most apps like this will make u pay … This app works without having to spend a dime» (5★, 2026-10-06).
- **CX:** 7 негативных из 157. «The phone call is the best feature. It's hard to ignore» (5★, 2026-10-07).
- **Watch:** нет [INFERENCE по странице] — **пробел**.
- **Вывод [INFERENCE]:** «Duolingo-подход к лекарствам» (персонаж + эскалация) — проверенная формула удержания; Watch-тактильность могла бы её усилить.

### 4.10 Streaks (Crunchy Bagel)

- **ICP:** Apple-энтузиасты, habit tracking до 24 задач, Watch-first.
- **Монетизация [FACT]:** $5.99 paid upfront, без IAP.
- **Watch:** требует watchOS 10, complications. Отзывы: «The Apple Watch integration is seamless» (5★, 2023-03-21). Негатив: разные контролы на Watch и iPhone (5★, 2023-04-06); 16 негативных отзывов с упоминанием Watch и 30 — про sync/bugs.
- **Вывод [INFERENCE]:** generic habit tracker уже покрывает «выпить воду + принять таблетку» для Apple-аудитории за $5.99. Nuori должен быть лучше именно в специфике (дозы, объёмы, эскалация).

### 4.11 Dosia: Water & Medication (Panagiotis Athanasiou)

- **Promise:** «two of the most important daily health habits: staying hydrated and taking your medications on time». Local-only, SwiftData, без аккаунта, без аналитики; умные напоминания («Already logged your water? No reminder»).
- **Монетизация:** $0.99 paid upfront.
- **Сигналы:** 0 оценок в US/GB/DE/FR/NL/PL за ~6 месяцев; версия 1.3.4 от 2026-10-03; только английский.
- **Watch:** не указан.
- **Вывод [INFERENCE, средняя уверенность]:** концепция почти идентична Nuori без Watch. Отсутствие оценок — сигнал, что generic-позиционирование плохо находит аудиторию через ASO. Альтернативное объяснение — автор не занимался маркетингом, а paid upfront режет установки.

### 4.12 Shotsy (Shotsy Co., основатель Aja Beckett)

- **ICP:** пользователи GLP-1 (Ozempic, Wegovy, Mounjaro, Zepbound, оральные формы).
- **JTBD:** «отслеживать еженедельные уколы, уровни препарата, побочные эффекты, белок, воду, вес».
- **Рост [FACT, founder-stated]:** «hasn't spent a dollar on ads»; word of mouth через скриншоты графиков в сообществах; ранний спрос из spreadsheet-тредов и subreddit-обсуждений; ASO ([RevenueCat](https://www.revenuecat.com/blog/growth/aja-beckett-shotsy-launched-podcast-2025.md)). Февраль 2025: 100k+ загрузок, **$1M run-rate**, прибыльность, seed $2.25M ([Silicon Florist](https://siliconflorist.com/2025/02/20/shotsy-lands-2-million-for-weight-loss-shot-tracking-app/)). Март 2026: «close to one million downloads» (пресс-релиз) [FACT, company-stated, не аудировано].
- **Монетизация [FACT, US]:** $9.99–19.99/мес, $39.99–59.99/год; ранее $19.99/год. «All the important stuff is free».
- **CX:** 27 из 49 негативных отзывов — цена; sync/bugs 83 упоминания.
- **Watch:** нет [INFERENCE] — в выборке 1 упоминание watch.
- **Вывод:** этот кейс — самый близкий к соло-пути из найденных: личная боль, сообщество, ASO, без рекламы.

### 4.13 MeAgain (DOTS Future Technologies)

- **ICP / promise:** «GLP-1 tracking should not feel like another job» — уколы, таблетки, белок, клетчатка, **вода**, побочные эффекты, фото еды.
- **Сигналы:** 36 257 оценок US за 18 месяцев [FACT]. Отзыв: «It automatically connects to my scale app & my Apple Watch. I only have to log my water and injections» (5★, 2026-06-19) — **именно вода и уколы остаются ручными действиями**.
- **Монетизация:** «Unlimited» $14.99 … $119.99. Жалобы на отсутствие trial и списания (1★, 2026-07-14, 2026-07-30).
- **Вывод [INFERENCE]:** в GLP-1-сценарии ручной ввод сводится к воде и уколам — ровно то, что Watch-first UX Nuori может сделать быстрее всех. Это главная продуктовая зацепка исследования.

**Итог по разделу 4 (deep dive).**
- **Что подтверждено:** позиционирование, цены, Watch-наличие (два сигнала); повторяющиеся паттерны отзывов: (1) настойчивость напоминаний ценится; (2) недоставленные уведомления — главный негатив; (3) paywall на базовые функции раздражает; (4) Watch ценится в hydration и meds.
- **Что неизвестно:** onboarding и paywall вживую, число тапов на Watch, retention, причины отмены подписок (кроме отзывов).
- **Уверенность: средняя.** RSS-выборка — только US и последние 500 отзывов, смещена к недовольным.
- **Действие:** установить приложения из shortlist и закрыть unknowns #1–#3 из раздела 10.

---

## 5. Pricing & monetization matrix

Цены — со страниц App Store на 2026-10-09; список IAP ограничен 10 позициями и может включать A/B-варианты.

| Продукт | Модель | US | PL / GB (если проверено) | Lifetime / one-time | Free-ядро | Жалобы на цену в RSS (негатив/всего негатива) |
|---|---|---|---|---|---|---|
| Apple Medications | Бесплатно (системное) | — | — | — | Всё | — |
| WaterMinder | Freemium + подписка + lifetime + tips | $2.99/мес; $14.99/год; offer $7.49 | PL 14,99 zł/мес; 87,99 zł/год | $49.99 (PL 229,99 zł) | Ограничено, есть trial | 34/69 |
| Waterllama | Freemium + подписка | $0.99–19.99 (много вариантов) | PL 4,99–69,99 zł | Вероятно есть [UNKNOWN] | Урезано после v1.93 | 31/47 |
| Plant Nanny | Freemium + подписка + consumables | $3.99–7.99/мес; $69.99/год | — | — | Да | 10/17 |
| My Water | Weekly/monthly/yearly | $1.99–4.99/нед; $39.99–49.99/год | — | $59.99 | ? | — |
| HiWater | Подписка + permanent | $0.99/мес; $5.99/год | — | **$9.99** | ? | — |
| Waterful (PL) | Подписка + lifetime | — | 4,99 zł/мес; 14,99–37,99 zł/год | 39,99–49,99 zł | ? | — |
| Medisafe | Freemium (≤2 лекарств бесплатно — по отзывам, не проверено) | $2.99–9.99/мес; $27.99–39.99/год | PL 14,99–29,99 zł/мес; 129,99–199,99 zł/год | — | Ограничено | 81/250 |
| MyTherapy | Бесплатно + ad-free/support | $0.99 / $9.99 | PL 4,99 / 49,99 zł | $49.99 (PL 199,99 zł) | Почти всё | 2/38 |
| Pill Reminder – All in One | One-time | **$2.99** | — | $2.99 | Базовое | 16/93 |
| Pill Buddy | Supporter-подписка | $4.99/мес; $35.90/год | GB £4.99 / £34.90 | — | Почти всё | 0/7 |
| EveryDose | Подписка | $9.99/мес; $59.99/год | — | — | ? | — |
| Doseful | Weekly-first | $4.99–8.99/нед; $59.99/год | — | — | ? | — |
| Streaks | Paid upfront | **$5.99** | — | — | — | 11/125 |
| Dosia | Paid upfront | **$0.99** | — | — | — | нет отзывов |
| Shotsy | Freemium + подписка | $9.99–19.99/мес; $39.99–59.99/год | — | — | «Important stuff free» | 27/49 |
| MeAgain | Подписка | $14.99–119.99 | — | — | Частично | 29/60 |
| Hydra Fuel | Weekly-first | $3.99–9.99/нед; $9.99–39.99/год | — | — | ? | — |

Паттерны [INFERENCE]:
1. **Generic hydration / meds:** потолок около $15–40 в год, сильное сопротивление подпискам, высокая ценность «бесплатного ядра». Lifetime $10–50 — частая опция у indie.
2. **Condition-specific (GLP-1):** подписка $40–120 в год принимается, несмотря на жалобы. Ценность связана с дорогим препаратом и высокими ставками.
3. **Weekly-подписки** (Doseful, My Water, Hydra Fuel) — признак paid-acquisition / агрессивной воронки; для соло-основателя без бюджета и в health-категории это риск по доверию.
4. Paywall timing и trial-условия ни для одного продукта вживую не проверены [UNKNOWN].

**Итог по разделу 5.**
- **Что подтверждено:** видимые IAP-цены и модели; частота жалоб на цену.
- **Что неизвестно:** какую цену видит конкретный пользователь (A/B), trial-условия, конверсия.
- **Уверенность: средняя.**
- **Действие:** для generic-позиционирования тестировать «free core + lifetime»; для condition-specific (GLP-1) — годовую подписку $30–60 с trial. Обе гипотезы проверять fake-door до реализации платежей.

---

## 6. Публичные метрики и ограничения данных

| Продукт | Метрика | Значение | Период | География | Источник | Тип данных | Уверенность |
|---|---|---|---|---|---|---|---|
| Все shortlist | Рейтинг / число оценок | см. разделы 2–3 | на 2026-10-09 | US/GB/DE/FR/NL/PL | iTunes Lookup API | FACT (индикатор, не пользователи) | Высокая |
| Shotsy | Загрузки | 100k+ | на 02.2025 | глобально | [Silicon Florist](https://siliconflorist.com/2025/02/20/shotsy-lands-2-million-for-weight-loss-shot-tracking-app/) | FACT, company-stated | Средняя |
| Shotsy | Revenue run-rate | $1M | 02.2025 | глобально | там же | FACT, company-stated, метод не раскрыт | Средняя |
| Shotsy | Funding | $2.25M seed | 02.2025 | — | там же | FACT | Высокая |
| Shotsy | Загрузки | «close to one million» | 03.2026 | глобально | пресс-релиз ([Rutland Herald / EZ Newswire](https://www.rutlandherald.com/features/health/shotsy-now-supports-oral-glp-1-tracking-first-of-its-kind-maintenance-mode-and-multi/article_b641db90-e971-5ec6-ad56-16a4197f845e.html)) | FACT, company-stated, PR | Низкая–средняя |
| Shotsy | Paid ads | $0 | до 2025 | — | [RevenueCat](https://www.revenuecat.com/blog/growth/aja-beckett-shotsy-launched-podcast-2025.md) | FACT, founder-stated | Средняя |
| Medisafe | Registered users | 7M+ (старое), 13M+ (профиль) | разные | глобально | обзор выдачи (hitconsultant, yespress) | company-stated / непроверено | Низкая |
| Medisafe | iOS MAU | ~345K | ? | ? | AppGoblin | ESTIMATE | Низкая |
| Medisafe | Revenue | $10–15M | ? | company | Similarweb | ESTIMATE | Низкая |
| Medisafe | Funding | $30M round | — | — | [Mercom](https://mercomcapital.com/medisafe-raises-30-million-for-medication-management-app/) | FACT | Высокая |
| MyTherapy | Users | 12M+ / 9M+ (02.2024) | — | глобально | [smartpatient.eu](https://smartpatient.eu/) | company-stated, противоречиво | Низкая |
| MyTherapy | Active users | ~1.4M | 01.2021 | ? | [Munich Startup](https://www.munich-startup.de/news/shop-apotheke-europe-uebernimmt-smartpatient) | company-stated, устарело | Низкая |
| Waterllama (студия) | Downloads | 8M+ combined | ~2026 | глобально | [djinni вакансия](https://djinni.co/jobs/835286-mobile-growth-marketing-lead-ios-apps/) | company-stated | Средняя |
| Waterllama | Revenue | — | — | — | Starter Story (одна auto-generated точка) | Непригодно | — |
| Plant Nanny | Downloads | 3M+ | ? | ? | mwm.ai | ESTIMATE | Низкая |
| Plant Nanny | Users | 9.5M | ? | глобально | промо-графика | company-stated | Низкая |
| WaterMinder | Downloads | «hundreds of thousands» после промо | ~2013–2021 | глобально | [Apple spotlight via iPhoneinCanada](https://www.iphoneincanada.ca/2021/02/12/apple-spotlights-waterminder-app-developer/) | founder-stated | Средняя |
| Dosia | Ratings | 0 | 2026-04 → 2026-10 | 6 storefront | Lookup API | FACT | Высокая |
| Все | Downloads / revenue / retention / CAC | — | — | — | Sensor Tower, AppMagic, data.ai | **[UNKNOWN] — платный доступ, не использовался** | — |

**Что можно проверить бесплатно:**
- рейтинги и их динамику — повторный снимок Lookup API раз в 2–4 недели даёт прирост оценок как proxy роста;
- категорийные ранги — Apple RSS top charts, бесплатные слои AppFigures/Sensor Tower;
- keyword-подсказки App Store Search;
- Apple Search Ads popularity — требует аккаунта Search Ads, бесплатно;
- Reddit-треды вручную.

**Что требует платных инструментов:** загрузки и revenue по приложениям, retention-кривые, keyword volume по странам (Sensor Tower, AppMagic, AppTweak).

**Итог по разделу 6.**
- **Что подтверждено:** рейтинги по storefront; отдельные company-stated цифры (Shotsy run-rate, funding).
- **Что неизвестно:** загрузки, revenue, MAU, retention почти всех игроков.
- **Уверенность: низкая** для любых абсолютных метрик, кроме рейтингов.
- **Действие:** раз в 2–4 недели делать снимок Lookup API по shortlist (прирост оценок как proxy роста); платные инструменты не покупать до выбора сегмента.

---

## 7. Пять продуктовых возможностей и ответы на вопросы этапа E

### O1. «Fastest wrist logging» для GLP-1: укол + вода + белок с часов
- **Evidence:**
  - [FACT] Shotsy и MeAgain — 33k и 36k оценок, подписки $40–120 в год.
  - [INFERENCE] Watch-приложений у них нет (по страницам).
  - [FACT] Отзыв MeAgain: «I only have to log my water and injections» — это те действия, которые остаются ручными.
- **Сегмент:** пользователи GLP-1 с Apple Watch; прежде всего US/UK, в EU растёт.
- **Ценность:** быстрый ввод воды и белка в дни низкого аппетита; напоминание об уколе с complication-обратным отсчётом.
- **Альтернативы:** Shotsy/MeAgain + Apple Medications (уколы — да; вода на Watch — нет).
- **Риски:**
  - переполненная ниша (10+ приложений);
  - медицинские claims и App Store Review (разделы Guidelines о health/medical apps и данных здоровья — сверить перед релизом);
  - trademarks препаратов;
  - Nuori пришлось бы добавить уровни препарата и побочные эффекты;
  - сегмент US-центричен.
- **Самая дешёвая проверка:**
  - лендинг «Log your GLP-1 shot, water & protein from your wrist»;
  - 10 сообщений-вопросов в r/Mounjaro, r/Zepbound, r/Semaglutide (с соблюдением правил сабреддитов);
  - 5 интервью;
  - метрика: доля посетителей, оставивших email.

**O1 — итог.** Подтверждено: WTP в GLP-1; отсутствие Watch у лидеров (два сигнала). Неизвестно: доля пользователей с Apple Watch; нужна ли им быстрая запись с часов. Уверенность: средняя. Действие: лендинг + 5 интервью до любой разработки GLP-1-функций.

### O2. Настойчивые, эскалирующие напоминания с Watch-тактильностью для «забывчивых»
- **Evidence:**
  - [FACT] Pill Buddy (phone calls, 4.9★, 7 негативных из 157) и Max (фейковый звонок) хвалят именно за настойчивость.
  - [FACT, Macworld] Apple Medications даёт максимум одно напоминание плюс один follow-up.
  - [FACT] Главная жалоба в категории — напоминания перестают приходить (MyTherapy, Max, WaterMinder).
- **Сегмент:** взрослые 20–40 лет с ежедневными препаратами (ADHD-стимуляторы, антидепрессанты, контрацепция, витамины), которые «спят через напоминания».
- **Ценность:** «you won't miss a dose»; нарастающие тактильные напоминания на запястье; надёжность.
- **Альтернативы:** Apple Medications + Critical Alerts, Pill Buddy, Max.
- **Риски:**
  - Critical Alerts требуют entitlement от Apple. Но соло-разработчик Pill Reminder – All in One заявляет в описании «Critical Alerts Support» [FACT: заявление разработчика] — значит, entitlement для indie-приложения напоминаний о лекарствах получить реально;
  - лимиты local notifications iOS (64 pending);
  - низкий WTP — Pill Buddy монетизирует через «supporter».
- **Проверка:** A/B двух лендингов — «Persistent reminders that escalate on your wrist» против «Water + meds in one app». Тест надёжности: 7 дней, 3 расписания, сравнить с Apple Medications по пропущенным уведомлениям.

**O2 — итог.** Подтверждено: эскалация ценится (отзывы Pill Buddy и Max); у Apple одна follow-up попытка. Неизвестно: WTP за настойчивость; техническая надёжность Nuori. Уверенность: средняя. Действие: 7-дневный тест доставки уведомлений + запрос Critical Alerts entitlement.

### O3. «Regimen days»: вода, связанная с лекарствами по медицинской причине
- **Evidence:**
  - [FACT] Появление POTSie и SaltStack (жидкость + соль + лекарства).
  - [FACT] Hydra Fuel (креатин + вода, 2026).
  - [INFERENCE] Существуют режимы, где вода — часть терапии: POTS, литий, камни в почках, некоторые антибиотики, химиотерапия, post-op. Медицинская сторона требует проверки у специалистов; конкретные цели жидкости приложение не должно назначать.
- **Сегмент:** люди, которым врач предписал объём жидкости вместе с лекарством.
- **Ценность:** один экран «сегодня: 3 таблетки, 2.5 л, 5 г соли»; экспорт отчёта врачу (как PDF у Apple).
- **Альтернативы:** Bearable, POTSie, Apple Health + бумага.
- **Риски:** маленькие сегменты; медицинская ответственность; сложно достучаться без комьюнити.
- **Проверка:** 5–8 интервью в r/POTS, r/dysautonomia, r/KidneyStones (с соблюдением правил); вопрос — «как вы сейчас ведёте учёт и что показываете врачу?».

**O3 — итог.** Подтверждено: появление нишевых POTS-приложений. Неизвестно: размер сегментов и WTP. Уверенность: низкая. Действие: 3–5 интервью параллельно, без разработки.

### O4. Честная монетизация как дифференциатор в hydration
- **Evidence:**
  - [FACT] Waterllama урезал бесплатную часть в v1.93 (июль 2026); в выборке 31 из 47 негативных отзывов — про цену.
  - [FACT] У WaterMinder 34 из 69 негативных — про подписку.
  - [FACT] У Medisafe 81 из 250 негативных — про подписку.
  - [FACT] Lifetime-опции у WaterMinder, HiWater, MyTherapy, Pill Reminder All in One.
- **Сегмент:** пользователи, ушедшие из Waterllama/Medisafe из-за paywall.
- **Ценность:** «Free core forever, one-time Pro» + приватность (local-only).
- **Альтернативы:** HiWater ($9.99 permanent), Pill Reminder All in One ($2.99), Streaks ($5.99).
- **Риски:** низкий LTV, конкуренция по цене, сложно финансировать развитие. Сама по себе честная монетизация не является каналом привлечения: Dosia — $0.99 и 0 оценок.
- **Проверка:** fake-door paywall в TestFlight/лендинге с тремя вариантами — $2.99/мес, $14.99/год, $24.99 lifetime; считать клики.

**O4 — итог.** Подтверждено: массовое недовольство подписками у лидеров. Неизвестно: станет ли «честная цена» причиной установки. Уверенность: средняя в проблеме, низкая в том, что это канал. Действие: fake-door с тремя ценами.

### O5. Watch-first «daily essentials» complication: одна complication — несколько быстрых действий
- **Evidence:**
  - [FACT] Пользователи WaterMinder ценят complication и Watch как «most effective way to remind».
  - [FACT] Пользователи Medisafe отмечают Watch, «phone is not always nearby».
  - [INFERENCE] У большинства конкурентов в meds Watch-приложения нет: MyTherapy, Pill Buddy, Max, Pill Reminder All in One, Shotsy, MeAgain, Dosia.
- **Сегмент:** владельцы Apple Watch с 2–3 ежедневными рутинами (вода + витамины / лекарства).
- **Ценность:** один тап с циферблата — вода или «принял»; без открытия приложения.
- **Альтернативы:** Streaks ($5.99, generic), Apple Medications + WaterMinder (два приложения, две complications).
- **Риски:**
  - Apple может добавить нативный Water на Watch;
  - generic-ценность слабо отличается от Streaks;
  - Dosia показывает слабый ASO-спрос на generic-комбо.
- **Проверка:** Watch-UX бенчмарк — число тапов до лога, сравнить с Apple Medications, WaterMinder, Streaks. 10 TestFlight-пользователей с Watch: доля логов, сделанных с часов, против iPhone (нужна локальная аналитика, без отправки данных или с согласия).

**O5 — итог.** Подтверждено: Watch ценится; у большинства meds-конкурентов Watch нет. Неизвестно: заметит ли пользователь разницу с Apple Medications + WaterMinder; планы Apple (редизайн Health «later this year»). Уверенность: средняя–низкая. Действие: бенчмарк тапов и доля Watch-логов у тестировщиков.

### 7.6 Ответы на вопросы этапа E

**Q1. Какие сегменты получат наибольшую пользу?** GLP-1 users с Apple Watch; забывчивые взрослые с ежедневными препаратами; Apple Watch «wellness stackers»; пациенты с режимом «жидкость + препарат». Подробно — раздел 8.

**Q2. Какой сценарий плохо обслуживается?** Быстрая запись **воды + дозы с запястья** в рамках одного режима. Apple не даёт воду на Watch; hydration-приложения не знают о лекарствах; meds- и GLP-1 приложения в основном без Watch. [INFERENCE, средняя уверенность]

**Q3. Есть ли проблема, за которую уже платят?** Да:
- GLP-1 трекинг — подписки $40–120 в год, company-stated $1M run-rate у Shotsy;
- hydration с хорошим Watch UX — WaterMinder: подписка и lifetime $49.99;
- сложные схемы лекарств — Medisafe premium, Pill Reminder All in One $2.99 one-time.
За простые напоминания о таблетках платят мало — Apple и MyTherapy бесплатны.

**Q4. Объединять hydration и medications?** **Только вокруг режима или состояния, а не как generic-комбо.**
- Generic-комбо уже существует (Dosia) и не набрало ни одной оценки за 6 месяцев.
- Где объединение работает, оно привязано к причине: GLP-1 (вода при низком аппетите), POTS (жидкость + соль + препараты), креатин (Hydra Fuel).
- Для массовой аудитории это две разные задачи с разными триггерами: вода — частые лёгкие действия, лекарства — редкие критичные. Такие задачи лучше решают специализированные приложения.
- [INFERENCE, средняя уверенность — один контрпример]

**Q5. Калории?** Убрать из позиционирования; исследовать только как protein quick-add для GLP-1. Раздел 9.

**Q6. Что в Apple Health усложняет конкуренцию?**
- Medications бесплатен и встроен.
- Есть Watch-логирование и Critical Alerts.
- Есть PDF-экспорт, а в США — сканирование этикеток и проверка взаимодействий.
- Система сама предлагает функцию пользователю.
Конкурировать на «просто напоминать о таблетках» нельзя. Плюс риск, что Apple добавит воду на Watch.

**Q7. Проверяемое преимущество Nuori.** Сформулировать как измеримое утверждение, а не функцию:
- *«Запись воды или дозы с циферблата Apple Watch за 1 тап, против N тапов в Apple Medications / WaterMinder»*. N определить в бенчмарке (unknown #3).
- *«0 пропущенных напоминаний за 7 дней при эскалации до подтверждения»* — против Apple Medications в том же тесте (unknown #4).
Если оба утверждения не подтвердятся измерением, Watch-first-позиционирование не имеет защитимого ядра.

**Q8. Что не разрабатывать до подтверждения спроса (H1–H3):**
- синхронизацию для опекунов и серверную часть;
- AI-распознавание еды по фото и базу штрихкодов;
- базу взаимодействий лекарств;
- графики уровня GLP-1 препарата;
- Android-версию;
- новые локализации сверх EN/PL/UK/RU;
- геймификацию с персонажами (дорого в арте);
- расширение калорийного модуля.

---

## 8. ICP-гипотезы

| # | ICP | Боль / JTBD | Доказательства | WTP-сигнал | Доступность канала для соло | Оценка доказательств |
|---|---|---|---|---|---|---|
| H1 | **GLP-1 users с Apple Watch** (US/UK, 30–55 лет) | Не пропустить еженедельный укол; добирать воду и белок при низком аппетите; видеть связь с побочными эффектами | Shotsy 33k, MeAgain 36k, Glowise 6.6k оценок; $1M run-rate Shotsy (02.2025); отзыв «only have to log my water and injections» | **Высокий** (подписки $40–120 в год) | Средняя: сабреддиты и FB-группы большие; ASO конкурентен | **Средняя–высокая** для сегмента, **низкая** для Nuori-специфичной ценности (Watch) |
| H2 | **Забывчивые взрослые с ежедневными препаратами** (ADHD, SSRIs, контрацепция) | «Я сплю через напоминания»; нужна эскалация | Pill Buddy 4.9★ (phone call), Max; жалобы на Apple Medications | Низкий–средний (supporter $35.90 в год; Pill Buddy «mostly free») | Высокая: TikTok/Reddit-контент «cute nagging» | **Средняя** |
| H3 | **Apple Watch «wellness stackers»** (вода + витамины / креатин / добавки) | Быстро отметить рутины с запястья | WaterMinder Watch-отзывы; SuppCo 30k (US); creatine-трекеры (8+ новых в 2025–26, все с 1–14 оценками) | Низкий–средний ($15–40 в год, lifetime) | Высокая: личный контент, r/AppleWatch, r/Creatine | **Средняя** (спрос на hydration подтверждён; на «стек» — слабый) |
| H4 | **Пациенты с режимом «жидкость + препарат»** (POTS, камни в почках, литий, post-op) | Соблюдать объём жидкости и схему; отчёт врачу | POTSie, SaltStack, Bearable; медицинская логика | Неизвестен [UNKNOWN] | Средняя: узкие, но активные сообщества | **Низкая** (мало публичных данных) |
| H5 | **Опекуны пожилых родителей** | Проверять приём лекарств удалённо | Max Share & Care, Medisafe Medfriend, отзывы опекунов | Средний (Medisafe family) | Низкая для Nuori: нужна синхронизация/сервер (противоречит local-only), Watch не центральный | **Средняя** для рынка, **низкая** для fit с Nuori |

Рекомендованный порядок проверки: **H1 → H2 → H3**, H4 — через 3–5 интервью параллельно. H5 отложить: требует серверной архитектуры.

**Что подтверждено:** спрос на hydration- и pill-приложения массовый; GLP-1 — самая сильная обнаруженная зона WTP; Watch ценится в hydration и meds; подписки на базовые функции вызывают отторжение.
**Что неизвестно:** WTP конкретно за Watch-first; доля GLP-1 пользователей с Apple Watch; retention любых конкурентов; конверсия в оплату.
**Уверенность: средняя.** Данные App Store и отзывы надёжны как индикаторы, но не как метрики использования. GLP-1 цифры частично company-stated.
**Что делать основателю:** проверять H1–H3 лендингами и интервью до разработки новых функций.

---

## 9. Рекомендация по роли calorie tracking

**Рекомендация:** убрать калории из позиционирования и первого экрана. Код не удалять, перевести в «скрытый / второстепенный» модуль. Исследовать **только** как гипотезу «protein + calories for GLP-1 users», если H1 подтвердится.

Обоснование:
1. **[FACT]** Категория переполнена гигантами и AI-новичками: MyFitnessPal 2 374 672 оценки (US), Lose It! 780 324, Cal AI 369 194 (релиз 2024-04), Cronometer 99 171. Стандарт ввода сместился к фото/AI и штрихкодам. Quick-add preset в Nuori здесь не конкурентен.
2. **[INFERENCE]** Альтернативная стоимость высока: база продуктов, точность и AI-распознавание — бесконечный backlog для соло-разработчика. Это размывает Watch-first-сообщение.
3. **[FACT]** Но в GLP-1 трекерах белок, калории и вода — ядро (MeAgain: «protein, fiber and water when appetite is low»; Shotsy: «weight, calories, protein, and water intake»). Здесь грубый quick-add («+20 г белка») с часов может быть ценнее точного подсчёта калорий [HYPOTHESIS].
4. **Проверка:** в интервью с GLP-1 пользователями спросить, что они считают — калории, белок или ничего — и где сейчас логируют. Если более 50% логируют белок и это раздражает — переделать модуль в «protein quick-add».

**Что подтверждено:** переполненность калорийной категории; присутствие белка и воды в GLP-1 продуктах.
**Неизвестно:** используют ли текущие тестировщики калории (нужна статистика TestFlight).
**Уверенность: высокая** в том, что калории не должны быть лидирующим позиционированием; **низкая** в том, что protein-модуль для GLP-1 нужен.
**Действие:** спрятать калории в настройки / вторичный таб; не развивать до результатов интервью H1.

---

## 10. Десять ключевых неизвестных и как их проверить

| # | Неизвестное | Почему важно | Как проверить (дёшево) | Срок |
|---|---|---|---|---|
| 1 | Есть ли Watch-приложения у Shotsy, MeAgain, MyTherapy, Pill Buddy, Dosia (вывод сделан по странице App Store) | Основа дифференциации O1/O5 | Установить на iPhone + Watch, проверить раздел Watch app | 1 день |
| 2 | Onboarding и paywall timing у WaterMinder, Waterllama, Medisafe, Shotsy, Pill Buddy | Бенчмарк воронки | Установить, записать экран: число шагов до первого лога, когда появляется paywall, trial | 2 дня |
| 3 | Число тапов на Watch: лог воды / «принял» (Apple Medications, WaterMinder, Streaks, Nuori) | Проверяемое преимущество «fastest» | Таблица тапов и секунд, по 3 замера | 1 день |
| 4 | Надёжность напоминаний (iOS local notifications) Nuori против Apple Medications | Главная жалоба категории | 7-дневный тест, 3 расписания, лог доставок | 1 неделя |
| 5 | Доля пользователей GLP-1 с Apple Watch и их боль при логировании | H1 | 5–8 интервью + опрос в сообществах (с разрешения модераторов) | 2 недели |
| 6 | WTP и предпочтительная модель (подписка / lifetime) | Выбор монетизации | Fake-door paywall в TestFlight + лендинг с тремя ценами | 2–3 недели |
| 7 | Что делают 12 текущих тестировщиков: какие модули используют, с какого устройства | Реальное поведение | Короткий опрос + локальные счётчики (с согласия) | 1 неделя |
| 8 | Почему у Dosia 0 оценок: спрос или дистрибуция | Валидность generic-комбо | Написать автору (indie-сообщество), проверить App Store ранги по keywords | 1 неделя |
| 9 | Можно ли получить entitlement Critical Alerts для Nuori | Ключ для O2. Прецедент есть: indie Pill Reminder – All in One заявляет «Critical Alerts Support» | Подать запрос через Apple Developer (форма entitlement) | 2–4 недели |
| 10 | Keyword-спрос по странам (water tracker, pill reminder, GLP-1 tracker; PL/DE-эквиваленты) | ASO-стратегия и выбор рынка | Apple Search Ads popularity (бесплатный аккаунт), подсказки App Store Search, бесплатный trial AppTweak/AppFigures | 1 неделя |

Дополнительные [UNKNOWN], которые не вошли в топ-10: retention и конверсия любых конкурентов (только платные базы или интервью основателей); точная история монетизации Waterllama и Medisafe; статус Round Health.

---

### Итог по уверенности

| Вывод | Уверенность | Почему |
|---|---|---|
| Apple закрывает простые medication-сценарии бесплатно | Высокая | Первичные Apple Support документы |
| Нативного Watch-логирования воды у Apple нет | Средняя | Отсутствие в документации и анонсах — не прямое подтверждение. Редизайн Health app (iOS 27) выходит «later this year» с неизвестным содержанием — риск |
| Generic «вода + лекарства» плохо привлекает органику | Низкая–средняя | Один кейс (Dosia), много альтернативных объяснений |
| GLP-1 — зона высокой WTP | Средняя–высокая | Рейтинги (FACT) + company-stated revenue |
| Watch-пробел у GLP-1 и pill-приложений | Средняя–высокая | Два независимых сигнала (страница + `supportedDevices`); финально — установкой |
| Подписки на базовые функции вызывают отторжение | Высокая | Многочисленные отзывы у нескольких лидеров |

> Это desk research. Он формирует гипотезы, но не доказывает product-market fit и готовность платить за Nuori. Их нужно проверять интервью, лендингами и fake-door экспериментами.
