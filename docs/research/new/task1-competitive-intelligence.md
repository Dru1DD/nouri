# Nuori — Task 1: Product & Competitive Intelligence

**Дата доступа ко всем источникам:** 2026-10-10, если не указано иное.
**Основа:** NUORI Shared Research Brief + Task 1.
**Статус:** desk research. Документ формирует гипотезы для проверки с пользователями и **не доказывает product-market fit**.

> Предыдущие версии (`docs/research_old/`, 2026-10-09) использовались только как список кандидатов. Все цифры в этом документе собраны заново 2026-10-10.

---

## 0. Методология, легенда и ограничения

**Легенда.**

- **[FACT]** — подтверждено первичным источником.
- **[ESTIMATE]** — оценка стороннего сервиса.
- **[INFERENCE]** — вывод из нескольких источников.
- **[UNKNOWN]** — надёжных публичных данных нет.
- **[HYPOTHESIS]** — требует проверки.

| Что | Как получено | Ограничения |
|---|---|---|
| Рейтинг, число оценок, продавец, даты релиза и обновления, наличие Watch-приложения | Публичный iTunes Lookup/Search API (`itunes.apple.com/lookup?id=…&country=…`), storefront `us, gb, de, pl, fr, nl`. Watch-приложение определяется по наличию `Watch*` в `supportedDevices` | Число оценок относится **к одному storefront** и **не равно** числу пользователей или загрузок. `supportedDevices` показывает наличие Watch-приложения, а не его качество. Уведомления iPhone с action-кнопками зеркалируются на Watch и без нативного приложения |
| Цены In-App Purchases | Блок «In-App Purchases» на странице `apps.apple.com/<cc>/app/id<ID>` (US, GB, DE, PL) | Apple показывает до 10 SKU без указания, какой из них актуален, и без условий trial. Видимые SKU могут быть старыми, промо или региональными. Это **не** экран paywall |
| Отзывы | Публичный RSS `itunes.apple.com/<cc>/rss/customerreviews/…/sortby=mostrecent/json`: до 150 свежих отзывов на приложение, US и GB, 15 приложений | Только свежие отзывы, только US/GB. Счётчики тем — это **доля внутри выборки**, а не доля аудитории. Темы считались по ключевым словам: возможны ложные срабатывания |
| Оценки загрузок, MAU и revenue | AppGoblin (бесплатный) | Методология не раскрыта; revenue указан диапазоном «$10K+». Цифры противоречат данным самих компаний (см. раздел 6) |
| Функции Apple | support.apple.com, developer.apple.com (WWDC25), заметки к релизу watchOS 27 (iClarified, 2026-09-09) | — |
| Сравнимость выборок отзывов | У популярных приложений 150 US-отзывов покрывают несколько дней. Пример — WaterMinder US: 2026-10-03…10-08, все 4–5★, вероятно всплеск после запроса оценки в v8.0.5. У менее популярных и GB-выборок окно — месяцы или годы | Доли негатива **нельзя сравнивать между приложениями** с разными окнами. Период выборки указан в 4.15 |
| Платформы iPad, web, Mac | Флаг iPad в `supportedDevices` есть у всех 14 приложений shortlist, но для iPhone-приложений он означает и режим совместимости. Нативный iPad-UI и web-версии не проверялись | iPad/web — [UNKNOWN] |
| Цены FR/NL | SKU собраны только для US, GB, DE, PL | FR/NL цены — [UNKNOWN]; рейтинги FR/NL собраны |
| Reddit | Прямой доступ заблокирован (HTTP 403). `site:reddit.com` в поиске не вернул тредов | Всё, что касается Reddit, — [UNKNOWN]. Проверять вручную |
| Sensor Tower, AppMagic, Similarweb (детально) | Не использовались — платные | См. раздел 10 |
| Onboarding и paywall | **Вживую не проходились**: нет устройства и аккаунта в среде исследования | Везде, где нет внешнего источника, — [UNKNOWN] |

**Ссылки на App Store** строятся по шаблону `https://apps.apple.com/<storefront>/app/id<ID>`. Например, WaterMinder в US: https://apps.apple.com/us/app/id653031147. ID указан в каждой строке таблиц, так что любую строку можно проверить. Ссылка на отзывы: `https://itunes.apple.com/us/rss/customerreviews/id=<ID>/sortby=mostrecent/json`.

**Что такое Nuori на момент сравнения** (по `README.md` репозитория):

- iPhone: dashboard с quick-add и calorie presets.
- Apple Watch: одна метрика на экран (вода, калории, лекарства), quick-add +100/+250/+500.
- Напоминания о лекарствах: локальные уведомления с действиями **Taken / Snooze 10 min / Skip**.
- Widgets и complications: Hydration % и Medications «2/3 + next dose» — на iPhone, циферблате Watch и в Smart Stack.
- HealthKit на iPhone; SwiftData локально; без сторонних зависимостей.

---

## 1. Executive summary

**Главный вывод.** Связка «вода + лекарства на Apple Watch» сама по себе — слабое позиционирование. Два инди-продукта с ровно этой связкой (Dosia, WatchRipple) и один Watch-first medication-трекер (Cadence) не набрали заметного числа оценок [FACT, API]. Apple Health Medications бесплатно закрывает «напомни и отметь таблетку на часах» [FACT]. Сильные сигналы спроса и оплаты есть там, где лекарство, вода и питание **связаны одной медицинской ситуацией** — прежде всего GLP-1 [INFERENCE, средняя уверенность].

**Семь находок** (детали — в разделах 2–4):

1. **Hydration насыщен; Watch там — норма.** У Waterllama (162 713 US-оценок), Plant Nanny, VGFIT и WaterMinder есть Watch-приложения; WaterMinder — Editors' Choice, его Watch хвалят в отзывах [FACT].
2. **Apple закрывает лекарства, но не воду на часах.** Medications на Watch: Taken/Skipped, follow-up через 30 минут, Critical Alerts. В watchOS 27 ни Medications, ни воды не добавили [FACT].
3. **HealthKit Medications API (iOS 26) позволяет читать лекарства и дозы из Apple Health** [FACT, WWDC25]. Запись — [UNKNOWN]. Отсюда главная гипотеза: Nuori как **companion** к Apple Medications, а не конкурент [HYPOTHESIS].
4. **Medisafe платный вне США с 2026-01-01** ($4.99/мес, $39.99/год). GB-отзывы массово негативны по цене, люди уходят к бесплатному Apple [FACT]. Готовность платить у этого сегмента низкая [INFERENCE].
5. **GLP-1 — платящая категория без сильного Watch-игрока.** Shotsy и MeAgain — более 33k US-оценок каждое, подписки $40–120 в год, в отзывах просят Watch-приложение [FACT]. Риски: бесплатный GLP-1 в MyFitnessPal, быстрое заполнение категории.
6. **В напоминаниях ценится настойчивость** (phone call у Pill Buddy и Max), но её надо делать настраиваемой [FACT, RSS].
7. **Монетизация:** для простых reminders и hydration — one-time или lifetime ($3–10); подписка принимается только в condition-specific категориях вроде GLP-1 [FACT, IAP + RSS].

**Проверяемое преимущество Nuori** [HYPOTHESIS]: «Одна complication и Smart Stack-виджет, где видно и следующую дозу, и воду. Отметить можно одним тапом с запястья. Лекарства можно взять из Apple Health, без аккаунта.» Это не воспроизводится зеркальными уведомлениями и не делается ни одним крупным игроком из выборки.

**ICP для проверки (не выбор):**

| Код | Сегмент | Рынок |
|---|---|---|
| A | GLP-1 users с Apple Watch | US/UK |
| B | Пользователи Apple Medications, которые хотят видеть воду и дозы вместе (в том числе беженцы от Medisafe) | UK/EU |
| C | Забывчивые / ADHD с ежедневными препаратами | US/UK |
| D | Состояния, где вода — часть лечения (камни в почках, POTS, литий, post-op) | — |
| E | Hydration-only | Низкий приоритет |

**Калории** — не убирать из кода, но убрать из позиционирования. Quick-add механику переиспользовать для белка в тесте ICP A (раздел 9).

**Что делать сейчас.** Не расширять функциональность. Сделать технический spike HealthKit Medications API: работает ли чтение на iPhone и как синхронизировать на Watch. Параллельно провести 2–3 дешёвых теста сегментов A/B/C: лендинг + интервью + TestFlight-когорта (раздел 10).

---

## 2. Market map

**Как читать таблицы.**

- Рейтинг указан в формате `средняя/число оценок` для storefront на 2026-10-10 [FACT, API]. «0» означает 0 оценок, «—» — приложения нет в storefront.
- «Watch-app» — наличие нативного Watch-приложения по `supportedDevices` [FACT, API].
- «Функции» — упоминания в описании App Store или release notes [FACT, текст]. Расшифровка: W — widgets, C — complications, HK — Apple Health, S — Siri/Shortcuts. Отсутствие упоминания не означает отсутствия функции.
- Цены — SKU из блока In-App Purchases US, если не указано иное [FACT, со всеми ограничениями из раздела 0].

### 2.1 Hydration / water tracking (14)

| # | Продукт (App Store ID) | Продавец | Promise / аудитория | Watch-app | Функции (по описанию) | US | GB | DE | PL | FR | NL | Монетизация |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Water Tracker by WaterMinder (653031147) | Funn Media, LLC | Вода + кофе/чай, «Standalone Apple Watch app»; App Store Editors' Choice | ✅ | W, HK, S | 4.75/35 117 | 4.61/2 823 | 4.55/5 555 | 4.71/917 | 4.50/1 457 | 4.52/1 166 | Freemium (реклама в free — по отзывам GB); $2.99/мес, $14.99–29.99/год; tips |
| 2 | Waterllama (1454778585) | Llama Luna Apps Inc | Геймификация (персонажи, челленджи), 22 языка | ✅ | W (Home/Lock/Control Center), HK, S | 4.87/162 713 | 4.86/5 976 | 4.79/25 778 | 4.86/1 669 | 4.82/7 823 | 4.80/3 114 | Freemium; $0.99/мес; разовые/lifetime $8.99–19.99 |
| 3 | Water Reminder – Daily Tracker (VGFIT) (1221965482) | VGFIT LLC | Массовый reminder-трекер | ✅ | W, HK | 4.73/78 802 | 4.66/16 058 | 4.50/5 601 | 4.70/2 347 | 4.58/9 336 | 4.51/8 267 | Freemium; «Premium» $0.99–79.99 (периоды не раскрыты) |
| 4 | Plant Nanny (1424178757) | SPARKFUL INC. | Пьёшь — растёт растение | ✅ | W, HK | 4.72/106 490 | 4.70/10 378 | 4.62/8 091 | 4.80/1 867 | 4.67/2 193 | 4.58/3 078 | $7.99/мес, $44.99/6 мес, $69.99/год + расходники |
| 5 | My Water: Daily Drink Tracker (964748094) | My Water Drink Tracker Oy | Трекер напитков | ✅ | HK | 4.65/24 211 | 4.47/2 566 | 4.39/3 039 | 4.66/1 759 | 4.39/1 076 | 4.36/1 251 | [UNKNOWN] — IAP не извлекались |
| 6 | Drink Water Reminder N Tracker (870372885) | Phoenix Games LLP | Reminder-трекер, старый игрок | ✅ | HK | 4.50/152 197 | 4.41/10 977 | 4.39/1 126 | 4.49/863 | 4.43/438 | 4.23/785 | [UNKNOWN] |
| 7 | HidrateSpark (1056269374) | Hidrate Inc. | Компаньон умной бутылки | ✅ | W, HK | 4.55/19 803 | 4.35/1 099 | 3.91/856 | 4.19/226 | 3.78/409 | 4.11/311 | Hardware + app |
| 8 | waterdrop Hydration App (1535002336) | Waterdrop Microdrink GmbH | Бренд-компаньон напитков (DE) | ✅ | HK | 4.82/781 | 4.75/546 | 4.70/2 447 | 5.00/18 | 4.76/807 | 4.67/646 | Free (маркетинг бренда) |
| 9 | Waterful (1515530685) | Listonic sp. z o.o. | Польский трекер (Listonic); последнее обновление 2023-08-07 | ✅ | W, HK, S | 4.81/619 | 4.67/174 | 4.61/470 | 4.82/1 843 | 4.74/134 | 4.65/92 | $0.99/мес, $2.99–7.49/год, lifetime $7.99–9.99 (PL 4,99 zł/мес, 39,99–49,99 zł lifetime) |
| 10 | Watercat (1579056677) | Orange dog d.o.o. | Милый кот-трекер; лидер PL по числу оценок среди hydration | ❌ | — | 4.89/1 362 | 4.96/83 | 4.86/565 | 4.94/2 586 | 4.86/497 | 4.86/79 | [UNKNOWN] |
| 11 | Water Time – My Drink Reminder (1208916325) | Roman Nikolaev | Reminder; заметен в PL; обновление 2024-09 | ✅ | — | 4.71/2 354 | 4.53/257 | 4.41/1 652 | 4.72/3 867 | 4.53/1 354 | 4.32/91 | [UNKNOWN] |
| 12 | Water reminder & drink tracker (Wachanga) (1417038587) | Wachanga LTD | Reminder; заметен в PL | ❌ | — | — | 4.64/53 | 4.43/30 | 4.73/6 022 | 4.58/161 | 4.44/27 | [UNKNOWN] |
| 13 | Drink Water Aquarium (1315396498) | Andreas Budde | Аквариум-геймификация (DE-инди) | ✅ | — | 4.75/3 596 | 4.73/77 | 4.64/5 493 | 4.76/251 | — | 4.46/190 | [UNKNOWN] |
| 14 | Trink Wasser – Gesund Trinken (913969576) | murbit GmbH | Немецкий локальный трекер | ✅ | — | 4.61/103 | 4.68/34 | 4.41/3 520 | 5.00/7 | 4.19/42 | 3.50/4 | [UNKNOWN] |

**Качество доказательств:**
- высокое — рейтинги и флаг Watch (первичные данные App Store);
- среднее — функции (текст описаний) и цены (SKU без контекста);
- нет данных — onboarding и paywall.

**Наблюдения по hydration.**

- Watch-приложение есть у всех крупных игроков с >20k US-оценок, кроме нескольких reminder-клонов [FACT].
- В Польше картина другая: лидеры по числу PL-оценок — Wachanga (6 022), Water Time (3 867) и Watercat (2 586). Все три **без Watch-приложения** [FACT, API].
- Польский Waterful (Listonic) с хорошими отзывами о complication не обновлялся с 2023-08-07 [FACT].
- В DE сильны бренды-компаньоны: Gerolsteiner TrinkCheck (4 095 DE-оценок, вне таблицы) и waterdrop (2 447) [FACT].

### 2.2 Medication and pill reminders (15)

| # | Продукт (App Store ID) | Продавец | Promise / аудитория | Watch-app | Функции (по описанию) | US | GB | DE | PL | FR | NL | Монетизация |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 15 | Medisafe (573916946) | MediSafe Inc. | Chronic patients, семьи, Medfriends | ✅ | HK | 4.71/101 447 | 4.64/13 460 | 4.47/3 675 | 4.60/386 | 4.51/4 904 | 4.43/3 210 | Вне США полностью платно с 2026-01-01: $4.99/мес, $39.99/год; статус free-tier в США — [UNKNOWN] |
| 16 | MyTherapy (662170995) | smartpatient GmbH | Пациенты, дневник симптомов (DE, smartpatient) | ❌ | HK | 4.77/8 556 | 4.76/3 205 | 4.65/15 381 | 4.80/1 871 | 4.76/4 039 | 4.65/2 364 | Free + реклама; ad-free $0.99/мес, $9.99/год; Plus lifetime $49.99 (DE 59,99 €, PL 199,99 zł) |
| 17 | Pill Reminder – All in One (816347839) | Sergio Licea | Гибкие расписания, PRN, refill | ❌ | Critical alerts | 4.72/27 927 | 4.74/2 102 | 4.56/518 | 4.52/29 | 4.42/379 | 4.49/1 151 | Free (2 напоминания) + Full Version $2.99 one-time (PL 14,99 zł) |
| 18 | Max – Pill reminder (1502063556) | Artify Inc. | Простой reminder, «звонок» при пропуске (по отзывам) | ❌ | — | 4.77/9 803 | 4.74/780 | 4.65/803 | 5.00/19 | 4.76/17 | 4.48/27 | Free + реклама; IAP на странице нет |
| 19 | Pill Buddy (6742357512) | Kai Loh | Маскот, эскалация, phone-call напоминание | ❌ | W | 4.88/1 788 | 4.86/93 | 4.25/4 | 5.00/8 | 4.75/4 | 4.67/3 | Free + Supporter $4.99/мес, $35.90/год |
| 20 | EveryDose (1188929364) | Groove Health, Inc. | US, сложные режимы | ❌ | HK | 4.76/5 130 | — | — | — | — | — | $9.99/мес, $59.99/год; только US storefront |
| 21 | Hero: Medication Manager (1352848484) | Hero Health, Inc. | Компаньон диспенсера, пожилые, caregivers | ✅ | — | 4.70/10 640 | — | — | — | — | — | Hardware-членство (цены не проверялись); только US storefront |
| 22 | Medication Reminder: Cadence (6758649306) | Alex Stewart | «No account, no ads, no renewal date»; Watch tap-to-confirm; импорт лекарств из Health на iOS 26 | ✅ | HK (Pro), critical alerts | 4.58/12 | 4.67/3 | 5.00/3 | 0 | 5.00/2 | 0 | Free (unlimited meds) + Pro $9.99 one-time, 7-дн. trial |
| 23 | mediteo (1063257864) | Mediteo GmbH | Немецкий рынок, «Tabletten Erinnerung» | ❌ | HK | — | — | 4.67/20 294 | — | 4.72/592 | 4.65/51 | DE: premium 8,99 €/мес, 23,49 €/3 мес; supporter 0,99–5,99 € |
| 24 | Pill Reminder+ DE (Bayer) (1444392024) | Bayer Aktiengesellschaft | Pharma-бренд, DE | ❌ | — | — | — | 4.65/3 214 | — | — | — | Free [INFERENCE: инструмент бренда] |
| 25 | Peach : rappel de médicaments (1512969375) | Mathys Sicaud | FR-инди | ❌ | — | — | — | — | — | 4.69/1 325 | — | [UNKNOWN] |
| 26 | Medico (1462935634) | Pierre Boudoin | FR, справочник + напоминания | ❌ | — | — | — | — | — | 4.56/2 390 | — | [UNKNOWN] |
| 27 | MedApp (1527313551) | MedApp Nederland B.V. | NL, связь с аптеками | ❌ | — | — | — | — | — | — | 4.15/1 296 | [UNKNOWN] |
| 28 | myPill (425632209) | Bouqt.com Ltd | Контрацепция; заметен в DE/FR | ❌ | — | 4.80/6 561 | 4.77/5 724 | 4.62/9 224 | 4.86/412 | 4.71/9 595 | 4.73/1 768 | [UNKNOWN] |
| 29 | Theraview (1541078407) | Theraview LLC | ADHD-стимуляторы, «wearing off»; обновление 2023-08 | ❌ | — | 4.90/329 | 4.87/47 | 5.00/17 | 5.00/7 | 4.88/8 | 4.92/12 | [UNKNOWN] |

**Качество доказательств:**
- высокое — рейтинги и флаг Watch;
- среднее — цены (9 из 15 позиций);
- низкое — локальные игроки FR/NL/DE (только рейтинги).

**Наблюдения по medication-категории.**

- Большинство крупных игроков **не имеют нативного Watch-приложения**: MyTherapy, Pill Reminder All in One, Max, Pill Buddy, EveryDose, mediteo. Watch-приложение есть у Medisafe, Hero и Cadence, а также у Apple Medications [FACT, API].
- Рынки сильно локальны:

  | Страна | Лидеры по числу оценок в storefront |
  |---|---|
  | DE | mediteo (20 294), MyTherapy (15 381), Bayer Pill Reminder+ DE (3 214) |
  | FR | Medico (2 390), Peach (1 325) |
  | NL | MedApp (1 296) |
  | PL | Местный лидер не найден; у MyTherapy 1 871 PL-оценка, у Medisafe — всего 386 |

  [FACT, API]

### 2.3 Объединённые daily health routines, включая GLP-1 companions и прямые аналоги Nuori (11)

| # | Продукт (App Store ID) | Продавец | Promise / аудитория | Watch-app | Функции (по описанию) | US | GB | DE | PL | FR | NL | Монетизация |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 30 | Dosia: Water & Medication (6762511328) | Panagiotis Athanasiou | Прямой аналог Nuori: вода + лекарства, SwiftData, «Nothing ever leaves your iPhone»; только iPhone | ❌ | виджеты (по release notes) | 0 | 0 | 0 | 0 | 0 | 0 | Paid upfront $0.99 |
| 31 | WatchRipple (6747939802) | Yi Fang | Прямой аналог: water + medicine на Watch, Digital Crown | ✅ | C, HK, CloudKit | 0 | 0 | 0 | 0 | 0 | 0 | Paid upfront $1.99 |
| 32 | Shotsy GLP-1 Tracker (6499510249) | Shotsy Co. | Дозы, побочки, вес, калории, белок, вода; импорт из Health | ❌ | HK | 4.83/33 276 | 4.82/4 211 | 4.79/1 613 | 4.85/169 | 4.80/608 | 4.70/273 | $9.99–19.99/мес, $39.99–59.99/год |
| 33 | MeAgain: GLP-1 Tracker (6744178534) | DOTS FUTURE TECHNOLOGIES INC | «dose, site, food, protein, fiber, water, side effects…» | ❌ | W, HK | 4.79/36 543 | 4.67/185 | 4.76/29 | 4.56/9 | 5.00/20 | 4.65/23 | «Unlimited» $14.99–119.99 (периоды не раскрыты) |
| 34 | Glapp (6756984097) | Glapp, Inc. | Shots, side effects, medication level; widget на Watch (по отзыву) | ✅ | W | 4.74/988 | 4.65/95 | 4.86/14 | 3.67/6 | 5.00/1 | 4.76/17 | $4.99/нед, $9.99/мес, $39.99/год |
| 35 | Zepbound & Mounjaro Tracker (6670317407) | The Manhattan App Studio LLC | Shot tracker; заметен в GB | ❌ | — | 4.81/3 188 | 4.83/2 067 | 5.00/14 | 5.00/5 | 4.78/37 | 3.67/3 | [UNKNOWN] |
| 36 | Glowise (6730116702) | VOCALBEATS.AI PTE. LTD. | GLP-1 дневник + калории | ❌ | HK | 4.77/6 619 | 4.73/212 | 4.74/58 | 0 | 4.78/68 | 4.33/6 | $5.99–6.99/нед, $19.99/мес, $59.99–69.99/год |
| 37 | DreamMe: GLP-1 Tracker Pet (6755569693) | Everr AI LLC | GLP-1 + питомец-маскот (релиз 12.2025) | ❌ | HK | 4.69/3 045 | 4.70/188 | 5.00/5 | 0 | 5.00/4 | 4.91/11 | $14.99/мес, $24.99/квартал, $39.99–69.99/год + валюта |
| 38 | Bearable (1482581097) | Bearable Ltd | Симптомы + лекарства + настроение, chronic illness (UK) | ❌ | HK | 4.77/6 456 | 4.66/875 | 4.65/201 | 4.72/40 | 4.68/65 | 4.61/64 | Premium $4.49–49.99 (разные периоды) |
| 39 | MyFitnessPal (341232718) | MyFitnessPal, Inc. | Калории + вода + бесплатный GLP-1 Support (04.2026) | ✅ | C, HK | 4.71/2 375 258 | 4.70/473 246 | 4.52/80 001 | 4.68/10 589 | 4.62/51 965 | 4.55/41 325 | $9.99–19.99/мес, $49.99–79.99/год |
| 40 | POTSie (6474701900) | Madeline LeClair | POTS-симптомы (состояние, где соль/вода — часть лечения) | ❌ | — | 4.79/53 | 4.88/8 | 0 | 0 | 0 | 0 | [UNKNOWN] |

**Качество доказательств:**
- высокое — рейтинги, цены GLP-1 приложений, описания;
- категория молодая и быстро меняется: многие релизы 2025–2026 гг.

**Наблюдения.**

1. **Прямые аналоги Nuori.**
   - Dosia: iPhone, вода + лекарства, локальные данные, $0.99, релиз 2026-04-20, версия 1.3.4 от 2026-10-03.
   - WatchRipple: Watch water + medicine, $1.99, релиз 2025-10-24, после этого не обновлялся.
   - У обоих **0 оценок во всех 6 storefront** [FACT, API].
   - [INFERENCE] Комбинация «вода + лекарства + приватность» не создаёт органического притока. Ограничение вывода: маркетинговые усилия авторов неизвестны, а платная модель снижает число установок.
2. **GLP-1.**
   - Есть минимум 7 специализированных приложений; Shotsy и MeAgain — десятки тысяч US-оценок за 1,5–2,5 года [FACT].
   - Среди **специализированных** GLP-1 приложений Watch-приложение есть только у Glapp; Revio, вне таблицы, тоже его указывает. У MyFitnessPal Watch-приложение есть, но работает ли на нём GLP-1 функциональность — [UNKNOWN] [FACT, API].
   - В Европе спрос неравномерен. Shotsy по storefront: GB 4 211 ≫ DE 1 613 > FR 608 > NL 273 > PL 169. Zepbound & Mounjaro Tracker: GB 2 067 при US 3 188 [FACT].
3. **MyFitnessPal.**
   - В описании App Store: «Stick to your schedule with custom reminders for your GLP-1 medication» и «Stay hydrated with the built-in water tracker» [FACT, описание 341232718].
   - По пресс-релизу (GlobeNewswire, 2026-04-28, через поисковый пересказ) GLP-1 Support бесплатен для всех [FACT, но текст релиза напрямую не открыт].
   - Работают ли дозы GLP-1 на Watch — [UNKNOWN].

### 2.4 Habit tracking и wellness — только релевантные (5)

| # | Продукт (App Store ID) | Продавец | Promise / аудитория | Watch-app | Функции (по описанию) | US | GB | DE | PL | FR | NL | Монетизация |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 41 | Streaks (963034692) | Crunchy Bagel Pty Ltd | До 24 привычек; авто-выполнение из Health (вода) | ✅ | W, C, S, HK | 4.81/27 350 | 4.75/4 236 | 4.69/3 613 | 4.80/619 | 4.72/819 | 4.64/752 | Paid upfront $5.99 |
| 42 | Habit Tracker (Inner Grow) (1438388363) | Inner Grow Limited | Высоко в выдаче по water-запросам | ✅ | — | 4.79/147 776 | 4.73/23 051 | 4.66/12 934 | 4.79/4 557 | 4.69/7 874 | 4.69/4 155 | Freemium |
| 43 | Tiimo (1480220328) | tiimo ApS | ADHD-планировщик с Watch | ✅ | — | 4.59/20 735 | 4.46/4 078 | 4.30/2 063 | 4.46/592 | 4.47/1 431 | 4.26/634 | Freemium |
| 44 | Lifesum (286906691) | Lifesum AB | Калории + вода; силён в EU | ✅ | HK | 4.65/150 839 | 4.60/28 130 | 4.55/81 712 | 4.63/1 607 | 4.55/34 074 | 4.55/23 779 | Freemium |
| 45 | YAZIO (946099227) | YAZIO GmbH | Калории + вода; DE-компания | ✅ | HK | 4.70/51 137 | 4.68/12 301 | 4.62/445 354 | 4.74/32 463 | 4.67/144 650 | 4.59/28 052 | Freemium |

**Качество доказательств:**
- высокое — рейтинги;
- Watch-функции habit-приложений глубоко не проверялись.

Streaks важен как бенчмарк Watch-UX и paid-upfront модели. В свежих отзывах есть прямой запрос на то, что делает Nuori:

> «Some watch faces I just want to see a single habit (like drinking water), but now I can't do that?»
> — 1★, 2026-09-26, US

Lifesum и YAZIO показывают, что в EU вода чаще живёт **внутри** калорийного трекера: YAZIO — 445 354 DE-оценки, 32 463 PL [FACT].

### 2.5 Встроенные функции Apple и поведенческие заменители (5)

| # | Решение | Что делает | Подтверждение |
|---|---|---|---|
| 46 | **Apple Health → Medications** (iPhone + приложение Medications на Watch) | На Watch: «Log All as Taken» или отметка отдельных лекарств (Taken → Done), изменение на Taken/Skipped. Follow-up reminders, если доза не отмечена через 30 минут. Critical Alerts для отдельных лекарств («play a sound even if a Focus is on or your iPhone is muted»). As-needed лекарства. Export PDF. Проверка взаимодействий — только в США. Cyclical и specific-day расписания — с iOS 18 / watchOS 11. Недоступно для Apple Watch For Your Kids | [FACT] https://support.apple.com/guide/watch/medications-apd3dd24d78b/watchos ; https://support.apple.com/en-us/105064 |
| 47 | **HealthKit Medications API** (iOS 26, WWDC25) | Сторонние приложения **читают** лекарства (`HKUserAnnotatedMedication`) и dose events (`HKMedicationDoseEvent`, статусы taken/skipped и др.). Per-object authorization: пользователь выбирает лекарства. Запись лекарств в сессии не описана | [FACT] https://developer.apple.com/videos/play/wwdc2025/321/ ; https://developer.apple.com/documentation/healthkit/hkuserannotatedmedication ; вопрос о записи без ответа — https://developer.apple.com/forums/thread/803954 |
| 48 | **Вода в Apple Health** | Тип данных Dietary Water, ручной ввод на iPhone. Нативного Watch-интерфейса для воды нет. В заметках к watchOS 27 (2026-09-09) нет ни Medications, ни hydration | [FACT] https://www.iclarified.com/102069/watchos-27-release-notes ; отсутствие функции — [INFERENCE] (нет официальной страницы, подтверждающей «нет») |
| 49 | **Shortcuts → Log Health Sample; Reminders; Clock** | Бесплатный «один тап = стакан» (через Shortcuts — [INFERENCE], официальной инструкции Apple не открывалось) или повторяющееся напоминание. У Reminders 1 029 913 US-оценок [FACT, API 1108187841]. Свежий отзыв о Pill Reminder All in One: «I have decided to use Apple's reminder/alarm app…» (2★, 2026-10-07) | [FACT, RSS] |
| 50 | **Таблетница, бутылка с метками, бумага, отсутствие трекинга** | Физические заменители | [UNKNOWN] — Reddit недоступен, частоту подтвердить нечем |

**Вывод по market map**

- **Подтверждено:**
  - Hydration насыщен, Watch там стандарт.
  - Medication-категория в основном iPhone-only, но базу закрывает Apple.
  - GLP-1 — единственная из найденных категорий, где за 2024–2026 гг. появились десятки тысяч оценок и подписки от $40 в год.
  - Прямые аналоги «вода + лекарства» не набрали оценок.
  - С iOS 26 есть официальный способ читать лекарства из Apple Health.
- **Неизвестно:**
  - активная аудитория любых приложений;
  - нужен ли пользователям нативный Watch или хватает зеркальных уведомлений;
  - Reddit-дискуссии.
- **Уверенность:**
  - **высокая** в структуре рынка — первичные данные App Store;
  - **низкая** в выводах о спросе на Watch.
- **Что делать:** использовать карту как список для ручного прохождения onboarding и paywall 6 приложений: Apple Medications, WaterMinder, Shotsy, MeAgain, Pill Buddy, Cadence (раздел 10, U6).

---

## 3. Shortlist: критерии, веса, оценки

**Веса.** Стартовые веса из брифа сохранены без изменений. Важная оговорка: B («качество Watch») оценивается по наличию Watch-приложения, описанию и отзывам. Watch-UX вживую не тестировался [UNKNOWN].

| Критерий | Вес |
|---|---|
| A. Пересечение аудитории и сценария | 25% |
| B. Качество Apple Watch и скорость действий | 20% |
| C. Пересечение hydration + medications / daily routines | 15% |
| D. Сила потребительских сигналов и отзывов | 15% |
| E. Интересность модели монетизации | 10% |
| F. Подтверждённые каналы роста | 10% |
| G. Релевантность для early-stage основателя | 5% |

Итог = Σ(оценка × вес). Это инструмент приоритизации исследования, а **не** оценка качества бизнеса.

| Продукт | A | B | C | D | E | F | G | Итог | Shortlist | Ключевое обоснование |
|---|---|---|---|---|---|---|---|---|---|---|
| WaterMinder | 4 | 5 | 2 | 4 | 4 | 3 | 4 | **3.80** | ✅ | Лучший Watch-UX в hydration по отзывам; Editors' Choice [FACT] |
| Shotsy | 4 | 1 | 4 | 5 | 5 | 4 | 4 | **3.65** | ✅ | Платящая GLP-1 аудитория; каналы роста подтверждены основателем |
| MeAgain | 4 | 1 | 4 | 5 | 5 | 3 | 3 | **3.50** | ✅ | Protein + water + dose; прямой запрос на Watch-приложение |
| Apple Health Medications | 5 | 4 | 2 | 4 | 1 | 1 | 5 | **3.40** | ✅ baseline | Бесплатный конкурент по умолчанию |
| Streaks | 3 | 4 | 3 | 4 | 4 | 2 | 4 | **3.40** | ✅ | Watch-бенчмарк, paid upfront, жалобы на complications |
| Dosia + WatchRipple (прямые аналоги) | 5 | 3 | 5 | 1 | 3 | 1 | 5 | **3.40** | ✅ | Ровно гипотеза Nuori — и 0 оценок |
| Medisafe | 5 | 2 | 2 | 4 | 4 | 2 | 3 | **3.30** | ✅ | Источник недовольных пользователей; поломка Watch-приложения |
| Waterllama | 3 | 4 | 1 | 5 | 4 | 2 | 4 | **3.25** | ✅ | Эталон геймификации и lifetime-продаж |
| Pill Buddy | 4 | 1 | 2 | 4 | 4 | 4 | 5 | **3.15** | ✅ | Инди-эталон: эскалация и пресса |
| Glapp | 3 | 3 | 3 | 3 | 4 | 1 | 4 | **2.95** | ✅ | Единственный заметный GLP-1 трекер с Watch |
| Cadence | 4 | 4 | 1 | 1 | 4 | 1 | 5 | **2.85** | ✅ | Соло-инди, Watch, импорт из Health, one-time $9.99 |
| Waterful (PL) | 3 | 4 | 1 | 3 | 4 | 1 | 4 | **2.85** | ✅ | Польский рынок; дешёвый lifetime; заброшен |
| MyTherapy | 4 | 1 | 2 | 4 | 3 | 2 | 3 | **2.75** | ✅ | Сильнейший в EU; модель «free + ad-free + lifetime» |
| Pill Reminder – All in One | 4 | 1 | 1 | 4 | 4 | 1 | 5 | **2.70** | ✅ | Инди, $2.99 one-time, жалобы на звук в iOS 27 |
| MyFitnessPal (GLP-1) | 3 | 3 | 3 | 5 | 3 | 3 | 1 | 3.20 | ⚠️ как риск | Бесплатный GLP-1 Support; гигант — не модель для копирования |
| VGFIT Water Reminder | 3 | 4 | 1 | 3 | 2 | 1 | 2 | 2.55 | ❌ | Пример анти-паттерна монетизации (GB-отзывы) |
| Max – Pill reminder | 3 | 1 | 1 | 3 | 2 | 1 | 3 | 2.00 | ❌ | Сигнал о ценности «звонка»; учтён в разделе про Pill Buddy |
| mediteo (DE) | 3 | 1 | 1 | 4 | 2 | 1 | 2 | 2.10 | ❌ | Важен только для DE |

Пример расчёта для WaterMinder: 4×0.25 + 5×0.20 + 2×0.15 + 4×0.15 + 4×0.10 + 3×0.10 + 4×0.05 = 3.80.

**Вывод по shortlist**

- **Подтверждено:** 14 позиций, которые покрывают пять кластеров:
  - hydration с Watch;
  - medication;
  - GLP-1;
  - прямые аналоги Nuori;
  - Watch-бенчмарк (Streaks).
- **Неизвестно:** реальное число тапов до действия на Watch. Оценки B экспертные.
- **Уверенность:** **средняя**. Ранжирование чувствительно к A и B; MyFitnessPal не попал в shortlist по критерию G, но остаётся главным риском для ICP A.
- **Что делать:** после ручного Watch-теста (U6) пересчитать B.

---

## 4. Deep dive по shortlist

**Общие ограничения раздела.**

- Onboarding и paywall **не проходились вживую** и помечены [UNKNOWN], если нет внешнего источника.
- Цитаты взяты из RSS App Store, дата отзыва указана.
- Счётчики тем отражают долю в выборке до 150 последних отзывов, а не долю всех пользователей.

### 4.1 Apple Health → Medications (baseline)

- **ICP и JTBD:** любой владелец iPhone/Watch, которому нужно «напомнить и отметить» приём. Product promise — встроенность и бесплатность.
- **Функции и Watch-UX** [FACT, Apple Support]:
  - Log All as Taken; отдельные дозы — Taken → Done;
  - follow-up через 30 минут; Critical Alerts для выбранных лекарств;
  - As Needed; Export PDF; interaction checks — только в US.
- **Число тапов:** Apple его не публикует. По описанию — уведомление → Taken или открыть приложение → Log All as Taken [INFERENCE].
- **Ограничения:**
  - нет воды и любых других рутин рядом с дозами;
  - complications для Medications в гайде не упомянуты [UNKNOWN — проверить на устройстве];
  - нет эскалации сильнее одного follow-up и Critical Alert;
  - Snooze в официальном гайде не описан.
- **Monetization:** бесплатно. Это главный фактор, ограничивающий готовность платить за «простые напоминания».
- **Customer evidence:** сравнение идёт через отзывы конкурентов: «Fortunately, the stock Apple app seems to work fine» (Medisafe US, 2★, 2026-08-31); «use you health app that's already on ur phone by default» (Medisafe GB, 1★, 2026-04-03).
- **Market evidence:** [UNKNOWN] — Apple не публикует статистику Medications.

**Вывод.**
- **Подтверждено:** Apple закрывает базовый сценарий лекарств на Watch бесплатно; HealthKit даёт к нему read-доступ.
- **Неизвестно:** есть ли у Medications complication; насколько надёжны follow-ups.
- **Уверенность:** высокая — первичные источники.
- **Что делать:** не позиционировать Nuori как «лучшее напоминание о таблетках». Исследовать позицию «companion к Apple Medications» (O1).

### 4.2 WaterMinder (Funn Media, LLC; с 2013)

- **ICP и JTBD:** люди, которые забывают пить, включая нейроотличных («as a neurodivergent person, who can often forget to take care of myself, this app is a life changer», 5★, 2026-10-08, US). Promise: «Drink More, Hydration Reminder».
- **Функции** [FACT, описание]:
  - «Standalone Apple Watch app»;
  - «Multiple Home Screen and Lock Screen Widgets»;
  - Health, Siri/Shortcuts, кофеин и другие напитки.
- **Watch-UX** [FACT, RSS]. В US-выборке (5 дней, 2026-10-03…08, вероятно, всплеск после запроса оценки) Watch упоминают 18 из 150 отзывов, все позитивно. В GB (2022–2026) — 36 из 150, из них 7 негативных. Примеры:
  - «the most effective way to remind me» (5★, 2026-10-07);
  - «Apple watch app too, which is the reason I'm using it» (5★, GB, 2026-09-29).
- **Monetization** [FACT, IAP]:
  - US: $2.99/мес; годовые $14.99–29.99; «Yearly Offer» $7.49; tips.
  - GB: £15.49–29.99/год; есть «Remove Ads» £1.59.
  - DE: 17,99–44,99 €/год.
  - PL: 36,99–149,99 zł/год.
  - Trial: [UNKNOWN].
- **Негатив** (GB-выборка, 24 из 150 — 1★): реклама и paywall. «WHY HAVE I GOT TO WATCH A 40 SECOND ADD TO LOG 300ml OF COFFEE?… If you want a circle chart they make you pay» (1★, 2026-08-27).
- **Market evidence:**
  - App Store: US 35 117, DE 5 555, GB 2 823 оценки [FACT]; Editors' Choice — флаг `isEditorsChoice` на странице [FACT].
  - AppGoblin: 4M installs, ~199K MAU, revenue «$10K+», «IAP 33% · Ad 67%» [ESTIMATE, низкое качество].
- **Гипотеза о готовности платить** [HYPOTHESIS]: «worth its price» говорят ядро пользователей Watch. Free-пользователи в GB раздражены рекламой.

**Вывод.**
- **Подтверждено:** у hydration-сегмента сильный Watch-UX уже есть, и его ценят.
- **Неизвестно:** конверсия в подписку и доля пользователей Watch.
- **Уверенность:** высокая в качестве продукта, низкая в экономике.
- **Что делать:** не конкурировать за hydration-only. Использовать WaterMinder как планку скорости Watch-логирования в тесте U6.

### 4.3 Waterllama (Llama Luna Apps Inc)

- **ICP и JTBD:** массовый пользователь, мотивация через «cute» и челленджи. Promise: «Hydration drink reminder».
- **Функции** [FACT]: Apple Watch app, виджеты Home/Lock/Control Center, Shortcuts & Siri, 22 языка.
- **Monetization** [FACT, IAP]:
  - US: «Monthly – Full Access» $0.99 и разовые $8.99–19.99;
  - отзыв: «offered the 75% off for a $10 lifetime subscription, I literally did not hesitate» (5★, 2026-10-04).
- **Негатив** [FACT, RSS]: «Almost everything is paywalled, including setting shortcuts for different water amounts — free only lets you click 8, 12, or 16 oz… constant popups begging you for money» (1★, 2026-09-29).
- **Market evidence:**
  - US 162 713 оценок, DE 25 778 [FACT].
  - AppGoblin: 18.5M installs, 907K MAU [ESTIMATE].
- **Урок для Nuori** [INFERENCE]: lifetime со скидкой — рабочий триггер. Агрессивный paywall на quick-add злит.

**Вывод.**
- **Подтверждено:** lifetime-предложение работает как триггер покупки; навязчивые попапы бьют по оценкам.
- **Неизвестно:** доля lifetime в выручке.
- **Уверенность:** средняя.
- **Что делать:** не закрывать quick-add за paywall. Тестировать lifetime.

### 4.4 Medisafe (MediSafe Inc.)

- **ICP и JTBD:** хронические пациенты и семьи (Medfriends, dependents). Вероятна и B2B-фарм дистрибуция [INFERENCE по прошлым публичным материалам компании; в этом исследовании не перепроверялось].
- **Monetization:**
  - help center, 2026-01-07: «Medisafe is now a fully paid app for users outside of the United States», $4.99/мес и $39.99/год [FACT];
  - SKU в US: $2.99–9.99/мес, $27.99–39.99/год; в GB: £2.99–4.99/мес, £29.95–39.99/год [FACT, IAP];
  - статус free-tier в US — [UNKNOWN]: блог конкурента Pillo пишет о лимите 2 лекарства, но это заинтересованный источник.
- **Watch-UX** [FACT, RSS, US]: в версиях 9.52.0–9.52.1 (2026-08-31…09-06) — «crashes when I try to launch it on Apple Watch», «Not working on Apple Watches». 2026-09-11: «Watch complication… Fixed as of 9/11/26».
- **CX** [FACT, RSS]:
  - US: 59 из 150 — 1★;
  - GB: 102 из 150 — 1★, тема цены в 95 из 150.
  - Типичные цитаты (GB):
    - «£60 a year for a daily push notification?» (1★, 2026-05-26);
    - «I'd have paid a more reasonable subscription of £10 a year but £40 just not in my budget» (3★, 2026-01-21);
    - «the Apple Watch app… still functioning pretty much as an original 2015 Apple Watch app» (1★, 2026-01-20).
- **Market evidence:**
  - US 101 447, GB 13 460 оценок [FACT].
  - AppGoblin: 11.5M installs, тренд «Declining», ~547K MAU [ESTIMATE].
- **Гипотеза о готовности платить** [HYPOTHESIS]: часть ушедших пользователей заплатит около £10 в год или разово, но большинство уходит к бесплатному Apple.

**Вывод.**
- **Подтверждено:** сильное недовольство ценой вне US; нестабильное Watch-приложение.
- **Неизвестно:** куда реально уходят пользователи; доля тех, кто заплатил бы разово.
- **Уверенность:** высокая в недовольстве, низкая в готовности платить.
- **Что делать:** тестировать в UK сообщение «one-time, no account, works with Apple Health Medications». Не строить бизнес-план на этих пользователях.

### 4.5 MyTherapy (smartpatient GmbH, DE)

- **ICP и JTBD:** пациенты с несколькими препаратами и дневником симптомов; рекомендуют специалисты («I'm a social worker in mental health… I recommend to them!», 5★, 2026-09-11, US).
- **Monetization** [FACT, IAP]:
  - free + реклама;
  - ad-free $0.99/мес или $9.99/год;
  - Plus Lifetime $49.99 (DE 59,99 €, PL 199,99 zł);
  - в DE и PL — «Support the Team».
- **Watch:** нет нативного приложения [FACT, API].
- **CX** [FACT, RSS]: реклама — 9 из 150 упоминаний в US (5 негативных); «Too many intrusive ads» (2★, 2026-06-07). 106 из 150 — 5★.
- **Market evidence:** DE 15 381, GB 3 205, PL 1 871 оценка [FACT]. Самый «европейский» игрок.

**Вывод.**
- **Подтверждено:** модель «бесплатно + дешёвое ad-free + lifetime» принимается в EU.
- **Неизвестно:** выручка.
- **Уверенность:** средняя.
- **Что делать:** для EU сравнить цены Nuori с этой «ценовой нормой»: около 10 € в год или около 50 € lifetime.

### 4.6 Pill Reminder – All in One (Sergio Licea, инди)

- **ICP и JTBD:** сложные и гибкие расписания (интервальные, PRN). Promise: гибкость без лишнего.
- **Monetization** [FACT]: бесплатно 2 напоминания; Full Version $2.99 one-time (PL 14,99 zł).
- **CX** [FACT, RSS]:
  - «Spend the purchase price of $2.99 to support the developer, it's well worth it» (5★, 2026-09-29);
  - против: «"Free" version is 100% useless… only add 2 reminders» (1★, 2026-05-23);
  - свежая регрессия: «No sound since update to iOS 27… decided to use Apple's reminder/alarm app» (2★, 2026-10-07);
  - запрос: «It would be amazing to have Apple Watch support for notifications!!» (4★, 2026-01-24).
- **Market evidence:** US 27 927 оценок [FACT].

**Вывод.**
- **Подтверждено:** разовая низкая цена воспринимается как справедливая. Надёжность звука — критичная ценность.
- **Неизвестно:** продажи.
- **Уверенность:** средняя.
- **Что делать:** надёжность уведомлений и Critical Alerts — must-have для Nuori до любых новых функций.

### 4.7 Pill Buddy (Kai Loh, инди, бывший PM Duolingo)

- **ICP и JTBD:** забывчивые взрослые, в том числе с витаминами. Promise: милый маскот, который «gets increasingly annoying if you miss a dose!» [FACT, описание].
- **Функции:** «Choose from push notifications, phone calls, and widgets» [FACT]. Нативного Watch-приложения нет [FACT, API].
- **Monetization:** Supporter $4.99/мес или $35.90/год (DE 39,90 €, PL 149,99 zł) [FACT, IAP].
- **CX** [FACT, RSS, US]:
  - «I actually take my meds now… The phone call is the best feature… happy and willing to pay $5 a month… (even though there's a free version that works just fine)» (5★, 2026-10-07);
  - против: «Way too aggressive… downright irritating» (2★, 2026-10-07);
  - 128 из 150 — 5★.
- **Growth:**
  - 9to5Mac Indie App Spotlight (https://9to5mac.com/?p=1004129);
  - TuttoTech, IT, 2025-06-09;
  - пост на Indie Hackers «Just launched a cute medicine tracking app» (страница вернула 403, факт публикации — по поисковой выдаче).
  - Это подтверждённые упоминания в прессе. Их вклад в установки — [UNKNOWN].
- **Market evidence:**
  - US 1 788 оценок за ~16 месяцев [FACT].
  - AppGoblin: ~107K installs, ~12K MAU, revenue <$10K в месяц [ESTIMATE].

**Вывод.**
- **Подтверждено:** эскалация (звонок, «злой» маскот) — реальная ценность для забывчивых. Инди-продукт может получить прессу.
- **Неизвестно:** конверсия в Supporter.
- **Уверенность:** средняя.
- **Что делать:** проверить, работает ли эскалация через Watch-хаптику (повтор, усиление) как аналог «звонка» (O4).

### 4.8 Streaks (Crunchy Bagel)

- **ICP и JTBD:** люди с несколькими ежедневными привычками и часами. Paid upfront $5.99 [FACT].
- **Watch-UX** [FACT, RSS]:
  - позитив: «It is absolutely critical that they have a watch app too… I love that this is NOT A SUBSCRIPTION» (5★, 2026-03-13);
  - против:
    - «The screenshots of the Apple Watch appear to show complications… these don't actually exist» (1★, 2026-03-17);
    - «what happened to watch complications?… I just want to see a single habit (like drinking water)» (1★, 2026-09-26);
    - «blank widget bug on apple watch» (2★, 2026-07-24).
- **Market evidence:** US 27 350 оценок [FACT].

**Вывод.**
- **Подтверждено:** есть пользователи, которым нужна **одна полезная complication** с конкретной метрикой, и они замечают её отсутствие.
- **Неизвестно:** масштаб этой потребности.
- **Уверенность:** средняя.
- **Что делать:** complication и Smart Stack должны быть лучшей частью Nuori. Тестировать их в первую очередь.

### 4.9 Shotsy (Shotsy Co.)

- **ICP и JTBD:** пользователи GLP-1 (Zepbound, Wegovy, в том числе oral). Promise: «Track your full medication history, side effects, weight, calories, protein, and water intake»; импорт веса, калорий, белка и воды из Apple Health [FACT, описание].
- **Watch:** нет [FACT, API].
- **Monetization:**
  - US: $9.99–19.99/мес, $39.99–59.99/год; GB от £29.99/год; PL 129,99–199,99 zł/год [FACT, IAP];
  - февраль 2025: «$19.99 annual subscription» [FACT, Silicon Florist, 2025-02-20].
- **CX** [FACT, RSS]:
  - против: «I've been paying $19.99 yearly… Now… I need to pay an additional $59.99/yr?… Bait and switch» (1★, 2026-10-04); «$15/month?! That's how much Netflix is» (1★, 2026-10-08);
  - за: «Worth the price. Highly recommend» (5★, 2026-10-03).
- **Growth** [FACT, company-stated] по RevenueCat, 2025-12-03:
  - «She hasn't spent a dollar on ads»;
  - ранний спрос — из «spreadsheet threads, subreddit buzz»;
  - word of mouth через скриншоты графиков; ASO;
  - «All the important stuff is free».
- **Market evidence:**
  - Silicon Florist (2025-02-20): «over 100,00 times» (опечатка в источнике; по контексту >100 000), $1M run-rate, прибыльность, seed $2.25M [FACT, пресса со слов основателя].
  - App Store US 33 276 оценок [FACT].
  - AppGoblin: 2.4M installs, ~200K MAU, revenue «$10K+» в месяц [ESTIMATE]. Это противоречит run-rate $1M в год ещё в 2025 году — пример ненадёжности бесплатных оценок.

**Вывод.**
- **Подтверждено:** GLP-1 пользователи платят $20–60 в год; рост шёл через сообщества и ASO без рекламы; повышение цены вызывает протест.
- **Неизвестно:** текущая выручка; нужен ли этим пользователям Watch.
- **Уверенность:** средняя–высокая в готовности платить, низкая в потребности в Watch.
- **Что делать:** тест ICP A (раздел 8).

### 4.10 MeAgain (DOTS Future Technologies)

- **ICP и JTBD:** GLP-1. Promise: «MeAgain is built for the GLP-1 routine itself: dose, site, food, protein, fiber, water, side effects, weight, photos and consistency together». Противопоставление: «Medication reminder apps focus on alarms» [FACT, описание].
- **Функции:** shot и pill reminders, protein/fiber/water, виджеты с маскотом Capy [FACT].
- **Monetization:** «Unlimited» $14.99–119.99 в US, периоды не раскрыты [FACT, IAP]. Paywall и trial — [UNKNOWN].
- **CX** [FACT, RSS, US]:
  - 129 из 150 — 5★;
  - в 23 из 150 упоминаются protein/fiber, в 29 — вода;
  - «Love the app but needs an Apple Watch app!» (5★, 2026-09-29);
  - «Found this app from an ad on FB» (4★, 2026-09-17) — подтверждает показ рекламы в Facebook хотя бы одному пользователю; объём кампаний — [UNKNOWN];
  - «My dietitian is now referring this app to other patients» (5★, 2026-10-08).
- **Market evidence:**
  - US 36 543 оценки; GB только 185 [FACT] — продукт US-центричен.
  - AppGoblin: 1.9M installs, «+204K» в месяц, тренд «Declining», ~208K MAU [ESTIMATE].

**Вывод.**
- **Подтверждено:** GLP-1 пользователи ежедневно логируют воду и белок; есть явный запрос на Watch.
- **Неизвестно:** масштаб запроса на Watch (1 отзыв из 150 в выборке).
- **Уверенность:** средняя.
- **Что делать:** проверить, нужна ли этому сегменту **часовая** быстрая отметка воды и белка (тест U2).

### 4.11 Glapp (Glapp, Inc.; релиз 2026-03-22)

- **ICP и JTBD:** GLP-1. Shots, side effects, «phase tracker», supply.
- **Watch:** Watch-приложение есть [FACT, API]. Отзыв: «I can add a widget to my home screen and Apple Watch» (5★, 2026-09-25).
- **Monetization:** $4.99/нед, $9.99/мес, $39.99/год [FACT, IAP].
- **CX:** «They need a much, much lower price and/or a lifetime subscription option. It stopped me from subscribing… I'm not the only one per the online groups» (4★, 2026-09-21); «Got Because Free… And then they Changed it» (1★, 2026-07-22).
- **Market evidence:** US 988 оценок за ~6,5 месяцев [FACT].

**Вывод.**
- **Подтверждено:** Watch у GLP-1 трекера сам по себе не создал взрывного роста. Сегмент чувствителен к переходу от free к paid.
- **Неизвестно:** доля использования Watch.
- **Уверенность:** низкая–средняя.
- **Что делать:** если идти в GLP-1, дифференцироваться не просто «наличием Watch», а скоростью ежедневной отметки воды и белка.

### 4.12 Cadence (Alex Stewart, соло-инди; релиз 2026-02-19)

- **ICP и JTBD:** люди с несколькими лекарствами, которым важны приватность и аналитика. Promise: «No account, no ads, no renewal date» [FACT, описание].
- **Функции** [FACT, описание и release notes]:
  - Watch tap-to-confirm;
  - follow-ups; confirm/skip/snooze с lock screen;
  - critical alerts (v1.9.2);
  - импорт лекарств из Health на iOS 26 (Pro);
  - корреляции с HR/sleep/HRV; PDF для врача.
- **Monetization:** free с unlimited meds; Pro $9.99 one-time с 7-дневным trial [FACT].
- **Market evidence:** US 12 оценок за ~8 месяцев [FACT]. Отзыв: «Wish it could read/write the medications I take in Apple Health» (5★, 2026-09-05).

**Вывод.**
- **Подтверждено:** соло-разработчик уже занял позицию «private, one-time, Watch, Apple Health import» для лекарств — без заметного органического роста.
- **Неизвестно:** продажи и маркетинговые усилия.
- **Уверенность:** средняя.
- **Что делать:** Nuori нужно отличаться не приватностью и не одноразовой ценой (это гигиена), а **сценарием**: вода + дозы на запястье и конкретный сегмент.

### 4.13 Прямые аналоги: Dosia и WatchRipple

- **Dosia** [FACT, описание]: «help users build two daily habits… staying hydrated and taking medications on time»; SwiftData, «Nothing ever leaves your iPhone»; $0.99; iOS 26.4+; только английский; без Watch.
- **WatchRipple** [FACT, описание]: water + medicine на Watch, Digital Crown, complications, CloudKit; $1.99; не обновлялся с 2025-10-24.
- **Market evidence:** 0 оценок во всех 6 storefront у обоих [FACT].

**Вывод.**
- **Подтверждено:** продуктовая формула Nuori уже существует в двух исполнениях, и ни одно не получило видимого отклика.
- **Неизвестно:** продвигались ли они вообще.
- **Уверенность:** средняя. Ноль оценок у платного приложения без маркетинга ожидаем.
- **Что делать:** считать это аргументом против generic-позиционирования, а не против продукта.

### 4.14 Waterful (Listonic sp. z o.o., PL)

- **ICP и JTBD:** массовый hydration; сильный Watch complication по отзывам: «I had two requirements — Track my intake to Apple Health and have a GOOD Apple Watch complication. This app knocks it out of the park!!» (5★, 2025-01-20, US).
- **Monetization:** lifetime $7.99–9.99, годовая $2.99–7.49; PL — 39,99–49,99 zł lifetime [FACT]. «$8 for a lifetime subscription! Yes please» (5★, 2025-01-30).
- **Минусы:** последнее обновление 2023-08-07 [FACT]; жалобы на падения Watch-приложения на Ultra.
- **Market evidence:** PL 1 843 оценки — больше, чем US 619 [FACT].

**Вывод.**
- **Подтверждено:** в PL есть спрос на hydration с Watch и дешёвым lifetime; лидер не развивается.
- **Неизвестно:** реальная активность пользователей.
- **Уверенность:** средняя.
- **Что делать:** PL можно использовать как дешёвый ASO-полигон (локализация уже есть), но не как основной рынок.

### 4.15 Сводка повторяющихся паттернов CX

| Паттерн | Где наблюдается (выборки RSS) | Период выборок | Значение для Nuori |
|---|---|---|---|
| Watch — причина выбора hydration-приложения | WaterMinder US 18/150 (0 негативных), GB 36/150 (7 негативных) | US 2026-10-03…10-08; GB 2022-03…2026-10 | Watch — входной билет в hydration, а не отличие |
| Подписка за «простой reminder» вызывает гнев | Medisafe GB 95/150 (87 негативных); VGFIT GB 49/150 (32 негативных) | Medisafe GB 2025-03…2026-09; VGFIT GB 2021-01…2026-09 | One-time или дешёвый lifetime для generic-сегментов |
| Изменение цены или условий для старых пользователей = 1★ | Shotsy, Glapp, Medisafe | Shotsy US 2026-09…10; Glapp US 2026-03…10 | Grandfathering ранних пользователей |
| Ненадёжность уведомлений — критичный провал | Pill Reminder AIO (звук в iOS 27), Medisafe (уведомления отключились) | 2026-08…10 | Надёжность > функций |
| Эскалация ценится, но может раздражать | Pill Buddy («phone call is the best feature» vs «Way too aggressive»), Max | Pill Buddy US 2025-06…2026-10 | Настраиваемая эскалация |
| Complication обещана, но бесполезна или отсутствует | Streaks, Waterful, Medisafe | Streaks US 2025-01…2026-10 | Конкретная, информативная complication — шанс выделиться |
| GLP-1: вода, белок и доза — единая рутина | MeAgain (water 29/150, protein/fiber 23/150), Shotsy | MeAgain US 2026-09-17…10-09 | Связка Nuori уместна в этом контексте |

Доли внутри разных окон не сравнимы между собой (см. раздел 0).

---

## 5. Pricing и monetization matrix

**Как читать таблицу.**

- Источник — SKU из блока In-App Purchases на страницах App Store, доступ 2026-10-10 [FACT].
- Это **не** экраны paywall. Какие SKU показываются новому пользователю сейчас, неизвестно. Trial указан, только если он есть в описании.
- Локальные цены приведены как есть — это не конвертация.

| Продукт | Модель | US | GB | DE | PL | Что бесплатно / что платно | Trial | Сигнал по цене в отзывах |
|---|---|---|---|---|---|---|---|---|
| Apple Medications | Бесплатно, встроено | — | — | — | — | Всё | — | Пользователи конкурентов называют его бесплатной заменой |
| WaterMinder | Freemium, подписка + реклама в free | $2.99/мес; $14.99–29.99/год; offer $7.49/год | £2.99/мес; £9.79–29.99/год; Remove Ads £1.59 | 2,99 €/мес; 10,49–44,99 €/год | 14,99 zł/мес; 36,99–149,99 zł/год | Free — базовый лог с рекламой; графики и челленджи — платные (по отзыву GB) | [UNKNOWN] | Ядро: «worth its price»; free в GB: реклама 40 с |
| Waterllama | Freemium; monthly + разовые | $0.99/мес; разовые $8.99–19.99 | £0.79/мес; £6.99–14.99 | 0,99 €/мес; 6,99–19,99 € | 4,99 zł/мес; 29,99–69,99 zł | Free — только 8/12/16 oz, только вода (по отзыву) | [UNKNOWN] | Lifetime за $10 со скидкой 75% — триггер покупки; попапы злят |
| VGFIT Water Reminder | Freemium, «Premium» разных периодов | $0.99–35.99 | £0.99–79.99 | 0,99–89,99 € | 4,99–399,99 zł | Только вода бесплатно; другие напитки платно (GB) | [UNKNOWN] | «Subscription for water reminders — make it one time purchase» |
| Plant Nanny | Подписка + расходники | $7.99/мес; $44.99/6 мес; $69.99/год | £7.99/мес; £69.99/год | 8,99 €/мес; 79,99 €/год | 39,99 zł/мес; 399,99 zł/год | [UNKNOWN] | [UNKNOWN] | Не анализировалось |
| Waterful | Freemium + дешёвый lifetime | $0.99/мес; $2.99–7.49/год; lifetime $7.99–9.99 | lifetime £7.99–9.99 | lifetime 8,99–9,99 € | lifetime 39,99–49,99 zł | «didn't ask for money as soon as I installed it» | [UNKNOWN] | «$8 for a lifetime subscription! Yes please» |
| Medisafe | Подписка (вне US — обязательна с 2026-01-01) | $2.99–9.99/мес; $27.99–39.99/год | £2.99–4.99/мес; £29.95–39.99/год | 2,99–5,99 €/мес; 29,99–44,99 €/год | 14,99–29,99 zł/мес; 129,99–199,99 zł/год | Вне US бесплатного уровня нет [FACT, help center]; в US — [UNKNOWN] | [UNKNOWN] | GB: «£60 a year for a daily push notification?»; «I'd have paid… £10 a year» |
| MyTherapy | Free + реклама; ad-free; lifetime | $0.99/мес; $9.99/год; lifetime $49.99 | £0.99; £9.99; £49.99 | 0,99 €; 9,99 €; 59,99 € | 4,99; 49,99; 199,99 zł | Функции бесплатно; платно — убрать рекламу и Plus | — | Жалобы на рекламу, не на цену |
| Pill Reminder – All in One | Free (2 напоминания) + one-time | $2.99 | £2.99 | 2,99 € | 14,99 zł | 2 напоминания бесплатно | — | «well worth it» vs «Free version is 100% useless» |
| Pill Buddy | Free + Supporter-подписка | $4.99/мес; $35.90/год | £4.99; £34.90 | 5,99 €; 39,90 € | 24,99; 149,99 zł | «mostly free» | [UNKNOWN] | «willing to pay $5 a month… even though there's a free version» |
| Cadence | Free + Pro one-time | $9.99 | £9.99 | 9,99 € | 49,99 zł | Unlimited meds бесплатно; Pro — инсайты, Health, PDF | 7 дней Pro | Мало данных (7 US-отзывов) |
| Streaks | Paid upfront | $5.99 | [UNKNOWN] | [UNKNOWN] | [UNKNOWN] | — | — | «NOT A SUBSCRIPTION. Absolutely worth the one time cost» |
| Dosia / WatchRipple | Paid upfront | $0.99 / $1.99 | — | — | — | — | — | 0 оценок |
| Shotsy | Freemium + подписка | $9.99–19.99/мес; $39.99–59.99/год | £7.09–19.99/мес; £29.99–39.99/год | 7,59–22,99 €/мес; 34,99–49,99 €/год | 26,49–99,99 zł/мес; 129,99–199,99 zł/год | «All the important stuff is free» (основатель); medication level graph — платно (по отзыву) | [UNKNOWN]; жалоба «Tricked me into purchase when I thought I was getting a free trial» | Рост с $19.99 до $59.99 в год → «Bait and switch» |
| MeAgain | Подписка «Unlimited» | $14.99–119.99 | £14.99–119.99 | 17,99–129,99 € | 69,99–499,99 zł | [UNKNOWN] | [UNKNOWN] | «worth every penny» (US), но GB 5/11 негатив по цене |
| Glapp | Freemium + подписка | $4.99/нед; $9.99/мес; $39.99/год | £4.99; £9.99; £39.99 | 5,99; 9,99; 44,99 € | 24,99; 49,99; 199,99 zł | Отчёты и insights — платно | [UNKNOWN] | «They need… a lifetime subscription option» |
| MyFitnessPal | Freemium + Premium | $9.99–19.99/мес; $49.99–79.99/год | £7.99–15.99; £39.99–64.99 | 9,99–21,99 €; 49,99–87,99 € | 34,99–97,99; 184,99–399,99 zł | GLP-1 Support бесплатно (пресс-релиз 2026-04-28) | [UNKNOWN] | Не анализировалось |

**Вывод по монетизации.**

- **Подтверждено.** Есть две разные «ценовые нормы» [FACT, IAP + RSS]:
  - **Generic reminder или hydration:** one-time $2.99–9.99, lifetime $8–50 или ad-free около $10 в год. Подписки выше $30 в год вызывают массовый негатив.
  - **Condition-specific (GLP-1):** подписка $40–60 в год принимается частью пользователей. Любое повышение цены для старых пользователей приводит к волне 1★.
- **Неизвестно:**
  - конверсии;
  - доля lifetime;
  - реальные экраны paywall и trial;
  - US free-tier Medisafe.
- **Уверенность:** средняя. SKU — первичные данные, но без контекста показа.
- **Что делать** [HYPOTHESIS]:
  - для generic-сегментов (B, C, E) тестировать один разовый unlock в диапазоне $4.99–9.99;
  - для GLP-1 (A) — годовую подписку около $19.99–29.99 против lifetime около $39.99;
  - ранних тестировщиков grandfather-ить.

---

## 6. Публичные метрики и ограничения данных

| Продукт | Метрика | Значение | Период | География | Источник | Тип данных | Уверенность |
|---|---|---|---|---|---|---|---|
| Shotsy | Загрузки | «over 100,00» (опечатка; по контексту >100 000) | на 2025-02-20 | Глобально | [Silicon Florist](https://siliconflorist.com/2025/02/20/shotsy-lands-2-million-for-weight-loss-shot-tracking-app/) | [FACT, со слов основателя] | Средняя |
| Shotsy | Revenue run-rate | $1M в год; прибыльна; seed $2.25M | на 2025-02-20 | Глобально | Там же | [FACT, со слов основателя, не аудировано] | Средняя |
| Shotsy | Платная реклама | «hasn't spent a dollar on ads» | на 2025-12-03 | — | [RevenueCat](https://www.revenuecat.com/blog/growth/aja-beckett-shotsy-launched-podcast-2025) | [FACT, company-stated] | Средняя |
| Shotsy | «Close to one million downloads» | — | 03.2026 | — | Пресс-релиз (EZ Newswire), виден только в поисковой выдаче; страница вернула 429 | [UNKNOWN — не открыт напрямую] | Низкая |
| Shotsy | Installs / MAU / revenue | 2.4M / ~200K / «$10K+» в месяц | crawl 2026-10-08 | Не указано | [AppGoblin](https://appgoblin.info/apps/6499510249) | [ESTIMATE] | Низкая (противоречит run-rate) |
| MeAgain | Installs / прирост / MAU | 1.9M / +204K в месяц («Declining») / 208K | crawl 2026-10-08 | Не указано | [AppGoblin](https://appgoblin.info/apps/6744178534) | [ESTIMATE] | Низкая |
| WaterMinder | Installs / MAU / ads-IAP | 4M / 199K / Ad 67%, IAP 33% | crawl 2026-10-08 | Не указано | [AppGoblin](https://appgoblin.info/apps/653031147) | [ESTIMATE] | Низкая |
| Waterllama | Installs / MAU | 18.5M / 907K | crawl 2026-10-08 | Не указано | [AppGoblin](https://appgoblin.info/apps/1454778585) | [ESTIMATE] | Низкая |
| Medisafe | Installs / прирост / MAU | 11.5M / +14K в месяц («Declining») / 547K | crawl 2026-10-08 | Не указано | [AppGoblin](https://appgoblin.info/apps/573916946) | [ESTIMATE] | Низкая |
| Pill Buddy | Installs / MAU / revenue | 107K / ~12K / <$10K в месяц | crawl 2026-10-10 | Не указано | [AppGoblin](https://appgoblin.info/apps/6742357512) | [ESTIMATE] | Низкая |
| Все из market map | Рейтинг и число оценок | Таблицы раздела 2 | 2026-10-10 | По storefront | iTunes Lookup API | [FACT] — косвенный индикатор масштаба, **не пользователи** | Высокая (как факт), низкая (как proxy аудитории) |
| Medisafe | Доля 1★ в свежих отзывах | US 59/150; GB 102/150 | US 2025-11…2026-10; GB 2025-03…2026-09 | US, GB | RSS App Store | [FACT, выборка] | Средняя |
| WaterMinder | Editors' Choice | Да | 2026-10-10 | US | Страница App Store (`isEditorsChoice`) | [FACT] | Высокая |
| Dosia, WatchRipple | Число оценок | 0 во всех 6 storefront | 2026-10-10 | US, GB, DE, PL, FR, NL | iTunes Lookup API | [FACT] | Высокая |
| Apple Medications | Использование | — | — | — | — | [UNKNOWN] | — |
| Все | DAU, retention, CAC, конверсии | — | — | — | Не публикуются | [UNKNOWN] | — |

**Что можно проверить бесплатно:**
- рейтинги и их динамику: повторять скрипт Lookup еженедельно;
- SKU;
- отзывы через RSS;
- AppGoblin как грубый тренд;
- Meta Ad Library вручную — требует браузера;
- Apple Search Ads keyword popularity — нужен бесплатный аккаунт Apple Search Ads.

**Что требует платного инструмента:**
- загрузки и revenue по странам (Sensor Tower, AppMagic, Appfigures);
- историю рейтингов ключевых слов (AppTweak, Appfigures).

**Вывод.**
- **Подтверждено:** надёжных метрик активной аудитории нет ни у одного конкурента. Единственные «твёрдые» бизнес-цифры — Shotsy со слов основателя на 2025-02.
- **Неизвестно:** почти всё про MAU, retention и revenue.
- **Уверенность:** низкая в любых абсолютных цифрах.
- **Что делать:** не строить решения на AppGoblin. Использовать собственные метрики TestFlight: D1/D7 retention, число логов в день, долю логов с Watch.

---

## 7. Пять продуктовых возможностей

Ответы на 8 вопросов этапа E — в 7.6.

### O1. «Companion to Apple Medications»: вода + дозы из Apple Health в одной complication

- **Evidence:**
  - HealthKit Medications API (iOS 26) даёт чтение лекарств и dose events [FACT, WWDC25];
  - у Apple нет воды на Watch, а watchOS 27 этого не добавил [FACT];
  - пользователи уходят от платных reminders к Apple [FACT, Medisafe GB];
  - Cadence получил запрос «read/write the medications I take in Apple Health» [FACT].
- **Сегмент:** пользователи Apple Medications с Watch, которые следят за водой (ICP B, частично C и D).
- **Ценность** [HYPOTHESIS]:
  - не переносить лекарства в ещё одно приложение;
  - видеть «следующая доза + вода %» на циферблате;
  - пить воду, когда принимаешь таблетку.
- **Альтернативы:** Apple Medications + WaterMinder (два приложения и две complications); Cadence (только лекарства).
- **Риски:**
  - API только на чтение: отметить дозу из Nuori в Apple Health, судя по сессии WWDC, нельзя, и тогда Taken в Nuori не синхронизируется с Apple;
  - сессия WWDC называет платформы «iOS, iPadOS, and visionOS» — watchOS не упоминается. Естественный путь — читать на iPhone и передавать на Watch через существующий у Nuori sync (WatchConnectivity);
  - Apple может добавить воду сама.
- **Самый дешёвый способ проверки:**
  1. 1–2 дня технического spike: прочитать лекарства и дозы на iPhone, показать их в complication.
  2. Спросить 12 тестировщиков: «Вы используете Apple Medications? Хотели бы видеть его дозы рядом с водой?»
  3. Лендинг-вариант «Works with Apple Health Medications».

### O2. Лучшая в категории «daily essentials» complication и Smart Stack

- **Evidence:**
  - Streaks: «I just want to see a single habit (like drinking water)» и «complications… don't actually exist» [FACT];
  - Waterful: «have a GOOD Apple Watch complication» [FACT];
  - Medisafe: complication ломалась [FACT];
  - в watchOS 27 появился Siri Modular face с прямоугольной complication, которая зеркалирует верхний виджет Smart Stack [FACT, iClarified].
- **Сегмент:** все Watch-пользователи A–E.
- **Ценность:** ноль тапов, чтобы увидеть статус, и один тап, чтобы отметить [HYPOTHESIS].
- **Альтернативы:** WaterMinder (вода), Apple (лекарства — наличие complication [UNKNOWN]).
- **Риски:** complication — функция, а не продукт: её легко скопировать.
- **Проверка:** в TestFlight измерить долю пользователей, которые поставили complication и виджет, и долю логов из Watch и виджетов от всех логов.

### O3. GLP-1 wrist companion: shot day + вода + белок одним тапом

- **Evidence:**
  - Shotsy и MeAgain: десятки тысяч оценок, платные подписки [FACT];
  - MeAgain: «needs an Apple Watch app!» [FACT];
  - в отзывах вода и белок — ежедневная рутина [FACT].
- **Сегмент:** ICP A (US/UK).
- **Ценность** [HYPOTHESIS]: отмечать воду и белок с часов в течение дня. Сам укол — раз в неделю, поэтому основная ежедневная ценность — в воде и белке, а не в напоминании.
- **Альтернативы:**
  - MeAgain и Shotsy (полнота на iPhone);
  - MyFitnessPal (бесплатный GLP-1 + вода + Watch-приложение);
  - Glapp (Watch).
- **Риски:**
  - конкуренты добавят Watch быстрее;
  - медицинская ответственность;
  - сегмент US-центричен, а Nuori сейчас без белка;
  - MyFitnessPal бесплатен.
- **Проверка:** лендинг «Log water and protein from your wrist on GLP-1» + 10 интервью из GLP-1 сообществ. Готовность платить — через pre-order или waitlist с ценой.

### O4. Настраиваемая эскалация напоминаний через Watch-хаптику

- **Evidence:**
  - Pill Buddy: «phone call is the best feature» и «Way too aggressive» [FACT];
  - Max: «reminder calls when I forget a dose» [FACT];
  - Apple: один follow-up через 30 минут и Critical Alerts [FACT].
- **Сегмент:** ICP C (ADHD / забывчивые).
- **Ценность:** «не дать забыть», а не «напомнить» [HYPOTHESIS].
- **Альтернативы:** Pill Buddy, Max, Apple Critical Alerts.
- **Риски:**
  - ограничения iOS на повторяющиеся уведомления;
  - раздражение пользователей;
  - звонки — отдельная инфраструктура (Nuori без сервера).
- **Проверка:** в TestFlight A/B-эксперимент «стандартный» против «эскалации» (повтор через 5/10/20 минут), метрика — доля доз, отмеченных в течение часа.

### O5. Честная монетизация и приватность как гигиена (не дифференциатор)

- **Evidence:**
  - one-time хвалят (Pill Reminder AIO, Streaks, Waterful);
  - подписки на reminders ругают (Medisafe, VGFIT);
  - Cadence и Dosia уже позиционируются как «no account» [FACT].
- **Сегмент:** B, C, E — особенно UK/EU.
- **Ценность:** снятие барьера покупки.
- **Риски:** низкий LTV; не отличает от Cadence и Dosia.
- **Проверка:** fake-door на лендинге с тремя ценовыми якорями ($4.99 one-time / $9.99 lifetime / $1.99 в месяц).

### 7.6 Ответы на вопросы этапа E

**1. Сегменты с наибольшей потенциальной пользой.** A — GLP-1 + Watch; B — пользователи Apple Medications, следящие за водой; C — ADHD/забывчивые; D — состояния, где вода медицинская; E — hydration-only. Подробности в разделе 8.

**2. Плохо обслуживаемый сценарий.** «С запястья за 2 секунды увидеть и отметить и воду, и дозу». У Apple нет воды. У hydration-приложений нет лекарств. У medication-приложений чаще всего нет Watch-приложения. У GLP-1 приложений почти нет Watch [FACT по отдельности; INFERENCE в совокупности]. Нужен ли этот сценарий массово — [UNKNOWN]: оба прямых аналога не набрали оценок.

**3. Проблема, за решение которой уже платят.**
- Да — GLP-1 трекинг (подписки $40–60 в год).
- Да, но мало — hydration (lifetime около $10, WaterMinder около $15–30 в год).
- Слабо — простые напоминания о лекарствах: Apple бесплатен, Medisafe теряет пользователей на цене [FACT].

**4. Объединять ли hydration и medications.**
[INFERENCE] В общем случае это две задачи с разной аудиторией:
- hydration — массовая привычка, ценность в мотивации;
- лекарства — обязательство, ценность в надёжности.

Объединение имеет смысл только там, где они **связаны медицински или ритуально**:
- GLP-1;
- камни в почках, литий, POTS;
- «запиваю таблетку».

Рекомендация: оставить обе функции, но позиционировать через ситуацию, а не через список функций.

**5. Калории** — на второй план, см. раздел 9.

**6. Что в Apple Health усложняет конкуренцию:**
- бесплатные Medications на Watch с follow-up и Critical Alerts;
- проверка взаимодействий (US);
- PDF-экспорт;
- доверие к Apple как к хранилищу медицинских данных;
- запись лекарств сторонними приложениями, по всей видимости, недоступна — Nuori не может «стать» источником правды для Apple Health Medications [INFERENCE].

**7. Проверяемое преимущество Nuori** [HYPOTHESIS]:

> «For people who already use Apple Health Medications and want to drink enough water: one complication shows your next dose and your water. Log either one with one tap from the wrist. No account.»

Метрика проверки — доля логов с Watch и complication и retention D7/D30 по сравнению с контрольной группой без Watch.

**8. Что не разрабатывать до подтверждения спроса:**
- AI-распознавание еды и фото-логирование калорий;
- облачный аккаунт и sync между пользователями (caregivers);
- interaction checks;
- поддержку Android и Wear OS;
- phone-call напоминания (нужен сервер);
- полноценный GLP-1 модуль (уровни препарата, побочки) — до результатов теста O3;
- новые языки сверх существующих четырёх.

**Вывод по разделу 7.**
- **Подтверждено:** отдельные элементы каждой возможности имеют первичные доказательства.
- **Неизвестно:** спрос на их комбинацию.
- **Уверенность:** средняя для O1, O2 и O5; низкая–средняя для O3 и O4.
- **Что делать:** O1 и O2 проверить внутри TestFlight (дёшево). O3 — внешним лендингом и интервью.

---

## 8. ICP-гипотезы

| ICP | Описание | Боль | Evidence | Готовность платить | Доступность для соло-основателя | Риски | Оценка доказательств |
|---|---|---|---|---|---|---|---|
| **A. GLP-1 + Apple Watch** (US/UK) | Люди на Ozempic, Wegovy, Mounjaro, Zepbound, которые носят Watch | Ежедневно добирать воду и белок при низком аппетите; помнить shot day | Shotsy и MeAgain: >33k US-оценок каждое [FACT]; «needs an Apple Watch app» [FACT, 1 отзыв]; подписки $40–60 в год [FACT] | **Высокая для категории** [FACT]; для Nuori — [UNKNOWN] | Средняя: сообщества GLP-1 [UNKNOWN — Reddit не проверен]; Shotsy вырос через них [FACT] | MyFitnessPal бесплатен; конкуренты добавят Watch; медицинский контекст; GB-доля мала | **Средняя** |
| **B. Пользователи Apple Medications + вода** (UK/EU, US) | Уже ведут лекарства в Apple Health и хотят видеть воду рядом | Два приложения и две complications; платные reminders не нужны | Отток Medisafe к Apple [FACT, GB]; HealthKit API [FACT]; нет воды у Apple на Watch [FACT] | **Низкая–средняя**: one-time около $5–10 [HYPOTHESIS] | Высокая: тестировщики, ASO «Apple Health medications water» | Только чтение из HealthKit; Apple может закрыть пробел | **Средняя** |
| **C. ADHD / забывчивые с ежедневными препаратами** (US/UK) | Стимуляторы, SSRI, контрацепция, витамины | «Сделаю через минуту» → забыл | Pill Buddy и Max: эскалация ценится [FACT]; WaterMinder: «neurodivergent… life changer» [FACT]; Theraview (ниша, не обновлялся с 2023) [FACT] | Средняя: «willing to pay $5 a month» (1 отзыв) [FACT] | Высокая: личные соцсети, сообщества | Без звонков эскалация слабее; раздражение | **Средняя–низкая** |
| **D. Вода как часть лечения** (камни в почках, POTS, литий, post-op, беременность) | Врач сказал пить X литров и принимать Y | Медицински обязательный объём воды + лекарства | POTSie (53 US-оценки) [FACT]; Pill Buddy: «medication, water and pain levels after a multiple teeth extraction» [FACT, 1 отзыв] | [UNKNOWN] | Средняя: нишевые сообщества | Ниши маленькие и разрозненные | **Низкая** |
| **E. Hydration-only** | Хотят пить больше воды | Забывают пить | Огромный рынок [FACT] | Низкая–средняя (lifetime около $10) | Низкая: насыщенный ASO | Waterllama и WaterMinder сильнее | **Высокая — но против входа** |

**Вывод.**
- **Подтверждено:** A — сильнейшие сигналы оплаты в категории; B — сильнейшая техническая и позиционная логика для текущего продукта; E — не стоит.
- **Неизвестно:** нужен ли Watch сегменту A; есть ли у B желание платить.
- **Уверенность:** средняя.
- **Что делать:** параллельно тестировать A и B (раздел 10). C добавить как третий вариант лендинга. D проверить в интервью с текущими тестировщиками.

---

## 9. Роль calorie tracking

**Факты:**
- Рынок калорий занят гигантами: MyFitnessPal (2 375 258 US-оценок), YAZIO (445 354 DE), Lifesum (81 712 DE) [FACT].
- MyFitnessPal бесплатно добавил GLP-1 и воду [FACT].
- В GLP-1 рутине пользователи говорят о **белке и клетчатке** чаще, чем о калориях: в выборке MeAgain US protein/fiber упоминаются в 23 из 150 отзывов [FACT, ключевые слова].

**Стратегическая ценность** [INFERENCE]:
1. Механика quick-add, presets и ring уже работает и переносится на любую «счётную» метрику: белок, клетчатку, кофеин.
2. Для ICP A счётчик белка ценнее счётчика калорий.
3. Калории дают Nuori ощущение «полного» трекера, но позиционно делают его слабым MyFitnessPal.

**Альтернативная стоимость:** поддержка калорий — это отдельные экраны на iPhone и Watch, presets, локализация, HealthKit-маппинг, а также ожидания пользователей по базе продуктов и сканеру штрихкодов, которых у Nuori нет и которые дорого делать.

**Рекомендация:**
- Убрать калории из позиционирования, App Store-описания и первого экрана onboarding.
- Оставить в коде как опциональный модуль (выключен по умолчанию).
- В тесте ICP A превратить тот же модуль в «Protein» (граммы, quick-add 10/20/30 g).
- Новой работы по калориям не делать, пока не появятся ≥3 независимых запроса от релевантных пользователей.

**Вывод.**
- **Подтверждено:** калории — переполненная категория; белок — активная часть GLP-1 рутины.
- **Неизвестно:** используют ли текущие 12 тестировщиков калории (проверить в данных или опросе).
- **Уверенность:** средняя–высокая.
- **Что делать:** скрыть калории по умолчанию. Через 2 недели посмотреть, кто включит их сам.

---

## 10. Десять ключевых неизвестных и как их проверить

| # | Неизвестное | Почему важно | Самый дешёвый способ проверки | Срок / стоимость |
|---|---|---|---|---|
| U1 | Работает ли HealthKit Medications API для Nuori: чтение на iPhone, передача на Watch, отображение в complication; возможна ли запись | Определяет жизнеспособность O1 и ICP B | Технический spike: Apple docs + прототип на своём устройстве | 1–2 дня, $0 |
| U2 | Нужна ли GLP-1 пользователям Watch-отметка воды и белка | Ядро ICP A | 10 интервью + лендинг «GLP-1 wrist companion» с waitlist; рекрутинг в GLP-1 сообществах (вручную, с соблюдением правил сообществ) | 1–2 недели; $0–100 |
| U3 | Какая доля текущих тестировщиков пользуется Apple Medications, Watch и complication | Базовая линия для O1 и O2 | Опрос из 5 вопросов + локальная статистика в TestFlight | 3 дня, $0 |
| U4 | Готовность платить и формат оплаты (one-time vs подписка) по сегментам | Модель монетизации | Fake-door цены на лендингах A/B/C. Покупки в TestFlight идут в sandbox и не показательны, поэтому следующий шаг — pre-order в App Store | 2–4 недели; $0–100 |
| U5 | Есть ли у Apple Medications complication и как быстро отметить дозу на Watch (тапы) | Насколько Nuori быстрее Apple | Ручной хронометраж на своём Watch: Apple vs WaterMinder vs Nuori; запись экрана | 1 день, $0 |
| U6 | Реальные onboarding и paywall Shotsy, MeAgain, WaterMinder, Pill Buddy, Cadence | Пробел этого исследования | Установить, записать экраны, посчитать шаги до первого лога, зафиксировать момент показа paywall и trial | 1–2 дня, $0 (возможна отмена trial) |
| U7 | Насколько сильна эскалация через Watch-хаптику по сравнению со «звонком» | O4 и ICP C | A/B в TestFlight на 10–20 пользователях: доля доз, отмеченных в течение 60 минут | 2 недели, $0 |
| U8 | Что говорят Reddit-сообщества (r/Ozempic, r/Mounjaro, r/ADHD, r/AppleWatch) о Watch-логировании и Apple Medications | Каналы и язык боли | Ручной поиск в браузере, 2 часа; таблица цитат с датами | 2 часа, $0 |
| U9 | Ключевые слова и спрос в App Store (US/UK/PL): «medication reminder apple watch», «glp-1 water tracker», «water and pill reminder» | ASO и выбор рынка | Apple Search Ads: бесплатный аккаунт, keyword popularity; при бюджете $100 — тестовая кампания | 1 день; $0–100 |
| U10 | Использует ли MyFitnessPal GLP-1 и воду на Watch и насколько хорошо | Главный конкурентный риск для ICP A | Установить MyFitnessPal на iPhone и Watch и проверить | 1 час, $0 |

**Итог по уверенности**

| Вывод | Уверенность | Почему |
|---|---|---|
| Hydration насыщен, Watch там стандарт | Высокая | Первичные данные App Store, много игроков |
| Apple закрывает базовые напоминания о лекарствах | Высокая | Apple Support |
| Связка «вода + лекарства» сама по себе не продаёт | Средняя | 2 аналога с 0 оценок, но их маркетинг неизвестен |
| GLP-1 — сегмент с подтверждённой готовностью платить | Средняя–высокая | Company-stated цифры Shotsy + IAP + отзывы |
| GLP-1 нужен Watch | Низкая | 1 прямой отзыв; у Glapp с Watch-приложением 988 US-оценок за 6,5 месяцев, без заметного отрыва |
| «Companion к Apple Medications» технически возможен | Средняя | WWDC25 подтверждает чтение; детали на Watch не проверены |
| Калории — не позиционирование | Средняя–высокая | Структура рынка |

---

## Приложение A. Ключевые источники (доступ 2026-10-10)

**Apple**
- Medications на Watch: https://support.apple.com/guide/watch/medications-apd3dd24d78b/watchos
- Medications в Health: https://support.apple.com/en-us/105064
- WWDC25 «Meet the HealthKit Medications API»: https://developer.apple.com/videos/play/wwdc2025/321/
- `HKUserAnnotatedMedication`: https://developer.apple.com/documentation/healthkit/hkuserannotatedmedication
- Developer Forums, вопрос о записи лекарств: https://developer.apple.com/forums/thread/803954
- Заметки к релизу watchOS 27 (2026-09-09): https://www.iclarified.com/102069/watchos-27-release-notes

**Компании и пресса**
- Medisafe help center (2026-01-07): https://help-center.medisafe.com/en/articles/13052285-medisafe-is-moving-to-a-fully-paid-app-for-users-outside-the-u-s-on-january-1-2026
- Shotsy: RevenueCat (2025-12-03) — https://www.revenuecat.com/blog/growth/aja-beckett-shotsy-launched-podcast-2025 ; Silicon Florist (2025-02-20) — https://siliconflorist.com/2025/02/20/shotsy-lands-2-million-for-weight-loss-shot-tracking-app/
- Pill Buddy: 9to5Mac Indie App Spotlight — https://9to5mac.com/?p=1004129 ; TuttoTech (2025-06-09) — https://www.tuttotech.net/news/2025/06/09/pill-buddy-app-ios-promemoria-medicine.html/amp
- MyFitnessPal GLP-1 (2026): пресс-релиз через AP/Bakersfield — https://www.bakersfield.com/ap/news/myfitnesspal-launches-comprehensive-glp-1-support-helping-users-stay-consistent-and-build/article_594b029e-ed9b-5c1a-ac3b-a4ea46e70908.html (страница вернула 429, содержание — по поисковой выдаче)

**Данные App Store и оценки**
- AppGoblin (оценки): https://appgoblin.info/apps/<ID> — для 6499510249, 6744178534, 653031147, 1454778585, 573916946, 6742357512
- App Store: `https://apps.apple.com/<cc>/app/id<ID>`; Lookup: `https://itunes.apple.com/lookup?id=<ID>&country=<cc>`; отзывы: `https://itunes.apple.com/<cc>/rss/customerreviews/page=<n>/id=<ID>/sortby=mostrecent/json`

## Приложение B. Воспроизводимость

Скрипты сбора и снимки данных лежат в `docs/research/data/`:

- `pull.py` — Lookup по 6 storefront;
- `search.py` — поиск по локальным запросам;
- `iap2.py` — извлечение SKU;
- `rev.py` — RSS-отзывы;
- `themes.py` — счётчик тем;
- `appstore-lookup-2026-10-10.json`, `iap-skus-2026-10-10.txt` — снимки на дату исследования.

Запуск: `python3 -I pull.py ids.txt out.json`. Скрипты пишут в относительные папки `html/`, `rev/`, `data/`. Перезапускать ежемесячно, чтобы отслеживать динамику оценок.

Использованные локальные поисковые запросы:

| Storefront | Запросы |
|---|---|
| DE | «tabletten erinnerung», «trinken erinnerung», «medikamente erinnerung apple watch» |
| PL | «przypomnienie o lekach», «picie wody», «przypominacz leki» |
| FR | «rappel médicament», «boire de l'eau rappel» |
| NL | «medicijn herinnering», «water drinken herinnering» |
