# Nuori — Task 1: Product & Competitive Intelligence

Дата исследования и доступа ко всем источникам: **2026-10-09** (если не указано иное).
Автор: desk research (Claude) по брифу NUORI Shared Research Brief.

> Это не доказательство product-market fit. Документ формирует гипотезы для проверки с реальными пользователями.

---

## 0. Методология, легенда и ограничения

**Источники и способ сбора**

| Что | Как получено | Ограничения |
|---|---|---|
| Рейтинги, количество оценок, продавец, даты релиза, описание | Публичный iTunes Search/Lookup API (`itunes.apple.com/search`, `/lookup`) по storefront `us`, `gb`, `de`, `pl`, `fr`, `nl` | Количество оценок относится **только к конкретному storefront**. Это не пользователи и не загрузки |
| Наличие нативного Watch-приложения | Поле `supportedDevices` в API (наличие `Watch*`) + проверка на известных приложениях | Измеряет **наличие Watch-приложения**, а не удобство на запястье. Уведомления iPhone с кнопками действий зеркалируются на Watch и без нативного приложения |
| Цены In-App Purchases | HTML-страница App Store (`apps.apple.com/<cc>/app/id<ID>`), блок «In-App Purchases» | Apple показывает **до 10 позиций**, без указания, какая из них текущая, и без trial-условий. Немецкая страница имеет другую разметку — цены DE не извлечены |
| Отзывы | Публичный RSS App Store (`itunes.apple.com/us/rss/customerreviews/...`), по 150 самых свежих US-отзывов на приложение (11 приложений + 2 GLP-1) | Только US, только свежие. Счётчики ключевых слов — **темы внутри выборки из 150 отзывов**, а не доля всей аудитории |
| Оценки загрузок / MAU / revenue | AppGoblin (бесплатный), ScreensDesign | Методология не раскрыта, цифры противоречат друг другу. Только для относительного масштаба и направления тренда |
| Функции Apple | apple.com/watchos/watchos-preview, support.apple.com, 9to5Mac | Официальной документации по ручному вводу воды в Health на support.apple.com не найдено |
| Reddit | **Недоступен** для инструментов исследования (блокировка) | Все выводы о Reddit — [UNKNOWN], проверка вручную |
| Sensor Tower, AppMagic, Similarweb (детально) | Не использовались — платные | См. раздел 10 |

**Легенда:** [FACT] — первичный источник; [ESTIMATE] — оценка стороннего сервиса; [INFERENCE] — вывод из нескольких источников; [UNKNOWN] — данных нет; [HYPOTHESIS] — требует проверки.

**Шаблоны ссылок.** App Store: `https://apps.apple.com/<storefront>/app/id<ID>`. Например, WaterMinder в US — https://apps.apple.com/us/app/id653031147. ID приведены в таблицах, чтобы каждую строку можно было проверить.

**Факты о Nuori, относительно которых делаются сравнения** (из `README.md` репозитория): одна метрика на экран Watch (вода, калории, лекарства); quick-add 💧 +100/+250/+500 и 🔥 +100/+250/+500 и presets; уведомления о лекарствах с действиями **Taken / Snooze 10 min / Skip**; widgets и complications «Hydration %» и «Medications 2/3 + next dose»; HealthKit; данные локально (SwiftData), без сторонних зависимостей, без аналитики и рекламы.

---

## 1. Executive summary

**Главный вывод.** Гипотеза «Apple Watch-first medication + hydration companion» в общем виде слаба. Её сильная версия — **конкретная ситуация лечения, при которой лекарство и вода (и белок) логируются вместе**. Лучший найденный кандидат — **пользователи GLP-1 (Ozempic, Mounjaro, Zepbound)** [INFERENCE, средняя уверенность].

**Что показали данные:**
1. **Hydration насыщен.** Waterllama (US 162 644 оценки), WaterMinder (35 063), VGFIT, Plant Nanny почти все имеют Watch, виджеты и Health. WaterMinder уже продаёт «quick Watch logging» [FACT]. Nuori не выиграет здесь на качестве Watch.
2. **Medication на Watch слабо обслужен частными игроками, но закрыт бесплатным Apple Health Medications.** У Apple есть Taken/Skipped на Watch, follow-up через 30 минут и Critical Alerts [FACT]. Крупные pill-приложения (MyTherapy, Pill Reminder All in One, Max, Pill Buddy) нативного Watch-приложения не имеют. Их уведомления всё равно зеркалируются на Watch, поэтому «есть Watch-приложение» само по себе не преимущество [INFERENCE].
3. **Medisafe — источник недовольных платящих пользователей.** Переход на подписку в январе 2026 (free — 2 лекарства по данным конкурента) и регрессия Watch в августе–сентябре 2026: 59 из 150 свежих US-отзывов — 1★. Пользователи пишут, что уходят к «stock Apple app» [FACT, отзывы].
4. **GLP-1 companions — быстрорастущая платящая категория без Watch.**
   - Shotsy (с 2024-05) — 33 246 US-оценок, MeAgain (с 2025-04) — 36 185 [FACT];
   - цены $40–120/год, пользователи называют их «worth the price» [FACT];
   - отзывы связывают **уколы + воду + белок + клетчатку** и прямо просят Apple Watch app «for checking protein/fiber/water goals, and quick logging» [FACT];
   - среди **специализированных** GLP-1 приложений Watch есть только у малых Glapp и Revio [FACT, API]. Но MyFitnessPal (Watch-приложение есть) добавил GLP-1 дозы, напоминания и воду. Работает ли это на часах — [UNKNOWN]; это главный риск.
5. **Монетизация.** В hydration и простых reminders подписка вызывает сопротивление; работают lifetime и разовая цена (Waterllama lifetime, Pill Reminder $2.99, Streaks $5.99). В GLP-1 подписка $40+/год принимается, но повышение цены вызывает протест [FACT, отзывы].
6. **Калории** проигрывают как позиционирование (MyFitnessPal, YAZIO, Cal AI). Quick-add механику стоит переиспользовать для **белка** в GLP-1 гипотезе [INFERENCE].
7. **Apple в watchOS 27** не добавил ни воду, ни изменения Medications, по официальной странице [FACT, 2026-10-09].

**Проверяемое преимущество Nuori** [HYPOTHESIS]: complication «доза / следующая доза + вода» и лог незапланированного действия (вода, белок, укол) одним тапом с запястья — офлайн, без аккаунта. Зеркальные уведомления этого не дают.

**ICP для проверки (не выбор):**
- A — GLP-1 + Watch (US/UK);
- B — chronic multi-med, уходящий от Medisafe (US/UK);
- C — ADHD «did I take it?»;
- D — hydration-only (низкий приоритет);
- E — caregivers (отложить).

**Европа.** GLP-1 спрос неравномерен: Shotsy GB 4 210 ≫ DE 1 606 > FR 608 > NL 274 > PL 169. В DE pill-рынок держат локальные бесплатные mediteo и MyTherapy, в PL hydration — польский Waterful [FACT]. Стартовать с US/UK для ICP A и B, PL — как ASO-эксперимент.

**30 дней:**
1. Пройти onboarding Shotsy, MeAgain, Medisafe, Apple Medications вживую; первым проверить, работает ли GLP-1 и вода MyFitnessPal на часах.
2. Опросить 12 тестировщиков.
3. Провести 20 интервью (A + B).
4. Запустить landing с двумя позиционированиями и fake-door цен.
5. Принять решение на 4-й неделе.

Ничего нового не строить до этого, кроме одной TestFlight-ветки «Shot + Water + Protein».

**Главные ограничения исследования:**
- onboarding и paywall не проходились вживую;
- Reddit недоступен;
- downloads и revenue — только низконадёжные оценки AppGoblin и ScreensDesign;
- отзывы — US-выборка по 150 на приложение.

---

## 2. Market map (51 решение в 50 строках)

Рейтинг указан как `средняя/количество оценок` для storefront. «Watch» — наличие нативного Watch-приложения по `supportedDevices` [FACT, API]. «Функции» — упоминания в описании App Store (W = widgets, C = complications/watch face, HK = Apple Health, R = reminders, S = Siri/Shortcuts) [FACT, текст описания; отсутствие упоминания ≠ отсутствие функции]. Цена — `formattedPrice` US + известные IAP (раздел 5).

### 2.1 Hydration / water tracking

| # | Продукт (ID) | Продавец | Аудитория / promise | Watch | Функции | US | GB | DE | PL | FR | NL | Монетизация (US) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Water Tracker by WaterMinder (653031147) | Funn Media, LLC (инди, с 2013) | «Track water, coffee, tea… smart reminders and Apple Watch support» | ✅ standalone | W, HK, R, S | 4.74/35 063 | 4.61/2 818 | 4.55/5 538 | 4.71/911 | 4.49/1 453 | 4.52/1 162 | Free + $2.99/мес, $14.99/год, $49.99 lifetime, 7-дн. trial |
| 2 | Waterllama (1454778585) | Llama Luna Apps Inc | Геймифицированный трекер напитков, персонажи | ✅ | W, HK, R, S | 4.87/162 644 | 4.86/5 972 | 4.79/25 769 | 4.86/1 666 | 4.82/7 819 | 4.80/3 113 | Free + подписка/lifetime $8.99–19.99 |
| 3 | Water Reminder – Daily Tracker (1221965482) | VGFIT LLC | Массовый reminder-трекер | ✅ | W, HK, R | 4.73/78 784 | 4.66/16 051 | 4.49/5 599 | 4.70/2 347 | 4.58/9 333 | 4.51/8 266 | Free + Premium $0.99–79.99 |
| 4 | Plant Nanny (1424178757) | SPARKFUL INC. | Пьёшь воду — растёт растение | ✅ | W, HK, R | 4.72/106 483 | 4.70/10 377 | 4.62/8 090 | 4.80/1 867 | 4.67/2 193 | 4.58/3 077 | $7.99/мес, $69.99/год + расходники |
| 5 | My Water (964748094) | My Water Drink Tracker Oy | Трекер напитков | ✅ | HK, R | 4.65/24 209 | 4.47/2 566 | 4.39/3 039 | 4.66/1 759 | 4.39/1 076 | 4.36/1 251 | $1.99–9.99 нед/мес, $39.99–49.99 год, $59.99 full |
| 6 | Drink water: Drinking reminder (1478980974) | TMEDILAB (VN) | Reminder-трекер | ✅ | HK, R | 4.60/22 559 | — | 4.47/2 887 | — | 4.58/972 | 4.38/218 | Free + IAP [не извлекались] |
| 7 | Drink Water Reminder N Tracker (870372885) | Phoenix Games LLP | Reminder-трекер | ✅ | HK, R | 4.50/152 195 | — | 4.39/1 126 | — | 4.43/438 | 4.23/785 | Free + IAP [не извлекались] |
| 8 | HidrateSpark (1056269374) | Hidrate Inc. | Компаньон умной бутылки | ✅ | W, HK, R | 4.55/19 804 | — | 3.91/856 | — | 3.78/409 | 4.11/311 | Hardware + app [UNKNOWN цены] |
| 9 | waterdrop Hydration App (1535002336) | Waterdrop Microdrink GmbH (DE) | Бренд-компаньон напитков | ✅ | HK, R | 4.82/780 | — | 4.70/2 447 | — | 4.76/806 | 4.67/645 | Free (маркетинг бренда) |
| 10 | Waterful (1515530685) | Listonic sp. z o.o. (**PL**) | «All for completely free!» | ✅ | W, HK, R, S | 4.81/619 | 4.67/174 | 4.61/470 | **4.82/1 843** | 4.74/134 | 4.65/92 | $0.99/мес, $2.99–7.49/год, $7.99–9.99 lifetime (PLN: 4,99 зł/мес, 39,99–49,99 zł lifetime) |
| 11 | Watercat (1579056677) | Orange dog d.o.o. | Милый кот-трекер | ❌ | R | 4.89/1 361 | — | 4.86/565 | **4.94/2 586** | 4.86/496 | 4.86/79 | [UNKNOWN] |
| 12 | Water Tracker: Log & Reminder (1114617196) | Ellisapps Inc. | Минималистичный лог | ✅ | W, C, HK, R, S | 4.76/2 304 | 4.53/68 | — | — | — | — | $2.99/мес, $19.99/год, $29.99 lifetime |
| 13 | Drink Water Aquarium (1315396498) | Andreas Budde (DE, инди) | Аквариум-геймификация | ✅ | R | 4.75/3 596 | — | 4.64/5 492 | — | — | 4.46/190 | [UNKNOWN] |
| 14 | Gerolsteiner TrinkCheck (370892661) | Gerolsteiner Brunnen (DE) | Бренд минеральной воды | ✅ | W, HK | 4.46/13 | — | 4.50/4 094 | — | — | — | Free (маркетинг бренда) |
| 15 | Water reminder & drink tracker (1417038587) | Wachanga LTD | Water reminder | ❌ | — | — | — | — | 4.73/6 022 | — | — | [UNKNOWN] |

**Качество доказательств:** высокое для рейтингов, Watch-наличия и цен (первичные данные App Store); среднее для «функций» (текст описаний); onboarding — не проверялся.

### 2.2 Medication and pill reminders

| # | Продукт (ID) | Продавец | Аудитория / promise | Watch | Функции | US | GB | DE | PL | FR | NL | Монетизация (US) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 16 | Medisafe (573916946) | MediSafe Inc. (VC-backed) | Chronic patients, семьи, «Medfriends» | ✅ | HK, R | 4.71/101 444 | 4.64/13 460 | 4.47/3 675 | 4.60/386 | 4.51/4 903 | 4.43/3 210 | Free (лимит, см. 4.3) + $2.99–9.99/мес, $27.99–39.99/год |
| 17 | MyTherapy (662170995) | smartpatient GmbH (DE, B2B pharma) | Пациенты, дневник симптомов, измерения | ❌ | HK, R | 4.78/8 554 | 4.76/3 204 | **4.65/15 378** | 4.80/1 870 | 4.76/4 037 | 4.65/2 364 | Free + реклама; ad-free $0.99/мес / $9.99/год; Plus lifetime $49.99 |
| 18 | Pill Reminder – All in One (816347839) | Sergio Licea (инди) | Гибкие расписания, refill, PRN, critical alerts | ❌ | R | 4.72/27 923 | 4.74/2 102 | 4.56/518 | 4.52/29 | 4.42/379 | 4.49/1 151 | Free (2 напоминания) + **$2.99 one-time** |
| 19 | Max – Pill reminder (1502063556) | Artify Inc. | Простой reminder | ❌ | R | 4.77/9 803 | 4.74/780 | 4.65/802 | 5.00/19 | 4.76/17 | 4.48/27 | Free, реклама (IAP не найдено) |
| 20 | Pill Buddy (6742357512) | Kai Loh (инди, ex-Duolingo PM) | Маскот-геймификация, звонок-напоминание | ❌ | W, R | 4.88/1 775 | 4.86/93 | — | — | — | — | Free + Supporter $4.99/мес, $35.90/год |
| 21 | EveryDose (1188929364) | Groove Health, Inc. | US, сложные режимы | ❌ | HK, R | 4.76/5 129 | н/д | н/д | н/д | н/д | н/д | $9.99/мес, $59.99/год; только US storefront |
| 22 | Pill Reminder Medication Alarm (863327251) | Aplicativos Legais (BR) | Будильник для таблеток | ✅ | R | 4.58/4 424 | 4.50/1 375 | 4.29/330 | 4.57/60 | 4.38/608 | 4.32/234 | $1.99/нед, $2.99/мес, $24.99–29.99/год, one-time $1.99–5.99 |
| 23 | Hero: Medication Manager (1352848484) | Hero Health, Inc. | Компаньон диспенсера, пожилые и caregivers | ✅ | R | 4.70/10 631 | н/д | н/д | н/д | н/д | н/д | Hardware-членство $29.99–44.99/мес + $99.99 [FACT, herohealth.com] |
| 24 | mediteo (1063257864) | Mediteo GmbH (DE) | Немецкий рынок, «Tabletten Erinnerung» | ❌ | HK | н/д | н/д | **4.67/20 292** | н/д | 4.72/592 | 4.65/51 | [UNKNOWN] |
| 25 | Peach (1512969375) | Mathys Sicaud (FR, инди) | «rappel de médicaments» | ❌ | — | н/д | н/д | н/д | н/д | 4.69/1 325 | н/д | [UNKNOWN] |
| 26 | Medico (1462935634) | Pierre Boudoin (FR) | Справочник + напоминания | ❌ | — | — | — | — | — | 4.56/2 390 | — | [UNKNOWN] |
| 27 | MedApp (1527313551) | MedApp Nederland B.V. (NL) | Связь с аптеками NL | ❌ | — | — | — | — | — | — | 4.15/1 294 | [UNKNOWN] |
| 28 | Tablets App (1322116003) | Sleepy Boy Studios | Простой, ad-free, Watch | ✅ | W, R | 4.38/137 | — | 4.38/163 | 4.55/103 | 4.46/151 | 4.43/256 | [UNKNOWN] |
| 29 | Theraview (1541078407) | Theraview LLC | ADHD-стимуляторы, «wearing off» | ❌ | R | 4.90/329 | — | 5.00/17 | — | 4.88/8 | 4.92/12 | [UNKNOWN] |
| 30 | Birth Control Pill Reminder (953740058) | Sergio Licea | Контрацептивы | ❌ | R | 4.80/9 735 | — | 4.51/1 988 | — | 4.62/850 | 4.62/1 108 | [UNKNOWN] |

**Качество доказательств:** высокое для рейтингов и Watch-наличия; цены извлечены для 9 из 15; локальные игроки (mediteo, Peach, Medico, MedApp) — только рейтинги.

### 2.3 Объединённые daily health routines (включая GLP-1 companions)

GLP-1 категория не была в исходном брифе, но появилась в данных: MyFitnessPal добавил «GLP-1 tracking… custom reminders for your GLP-1 medication» [FACT, описание App Store 341232718], а специализированные приложения сочетают **уколы + воду + белок/клетчатку + побочные эффекты**.

| # | Продукт (ID) | Продавец | Promise | Watch | US | GB | DE | PL | FR | NL | Монетизация (US) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 31 | Shotsy GLP-1 Tracker (6499510249) | Shotsy Co. (релиз 2024-05) | Дозы, побочки, вес, калории, **белок, вода**, «projected levels» | ❌ | 4.83/33 246 | 4.82/4 210 | 4.79/1 606 | 4.85/169 | 4.80/608 | 4.70/274 | $9.99–19.99/мес, $39.99–59.99/год |
| 32 | MeAgain: GLP-1 Tracker (6744178534) | DOTS FUTURE TECHNOLOGI (релиз 2025-04) | «protein and water goals», shot & pill reminders, widgets с маскотом | ❌ | 4.79/36 185 | 4.68/183 | 4.75/28 | 4.56/9 | 5.00/20 | 4.65/23 | «Unlimited» $14.99–119.99; периоды на странице не указаны [UNKNOWN] |
| 33 | Glapp (6756984097) | Glapp, Inc. (релиз 2026-03) | Shots, side effects, «medication level curve» | ✅ | 4.74/987 | 4.65/95 | 4.86/14 | 3.67/6 | 5.00/1 | 4.76/17 | $4.99/нед, $9.99/мес, $39.99/год |
| 34 | Zepbound & Mounjaro Tracker (6670317407) | The Manhattan App Studio | Shot tracker | ❌ | 4.81/3 180 | **4.83/2 065** | 5.00/14 | 5.00/5 | 4.81/37 | 3.67/3 | [UNKNOWN] |
| 35 | Glowise (6730116702) | VOCALBEATS.AI | GLP-1 дневник + калории | ❌ | 4.77/6 615 | 4.73/212 | 4.74/58 | — | 4.78/68 | 4.33/6 | $5.99–6.99/нед, $19.99/мес, $49.99–69.99/год |
| 36 | Revio: GLP-1 & Peptide (6786662993) | IKA DOYA S.R.L. | GLP-1 + пептиды | ✅ | 4.71/95 | 4.31/26 | — | — | — | — | [UNKNOWN] |
| 37 | Daily Health – Healthy Routine (6478650062) | Joysmore Mobile | Набор рутин (вода, лекарства и др.) | ❌ | 4.50/3 086 | 4.20/176 | 4.40/20 | — | 4.57/234 | 4.86/7 | $6.99/нед, $12.99/мес, $49.99/год |
| 38 | Bearable (1482581097) | Bearable Ltd (UK) | Симптомы + лекарства + настроение, chronic illness | ❌ | 4.77/6 447 | 4.66/874 | 4.65/200 | 4.72/40 | 4.68/65 | 4.61/64 | Premium $4.49–49.99 (разные периоды) |
| 39 | MyFitnessPal (341232718) | MyFitnessPal, Inc. | Калории + вода + GLP-1 | ✅ | 4.71/2 374 672 | — | 4.52/79 990 | — | 4.62/51 959 | 4.55/41 320 | Freemium Premium [UNKNOWN текущая цена] |

**Качество доказательств:** высокое для рейтингов и цен GLP-1 приложений; категория новая, состав быстро меняется (многие релизы 2025–2026).

### 2.4 Habit tracking и wellness (только релевантные)

| # | Продукт (ID) | Почему релевантен | Watch | US | DE | Монетизация |
|---|---|---|---|---|---|---|
| 40 | Streaks (963034692) | «automatically knows when you complete tasks linked to the Health app, such as water tracking» — заменитель «одна рутина в день» | ✅ C | 4.81/27 349 | 4.69/3 613 | **Paid upfront $5.99** |
| 41 | Habit Tracker (1438388363) | Высокий ранг в поиске по «water tracker» в US | ✅ | 4.79/147 745 | 4.66/12 926 | Free + IAP |
| 42 | Lifesum (286906691) | Вода внутри калорийного трекера; силён в EU (DE 81 703, FR 34 074, NL 23 777 оценок) | ✅ | 4.65/150 834 | 4.55/81 703 | Freemium |
| 43 | YAZIO (946099227) | Калории + вода, DE-компания; DE 445 188 оценок | ✅ | 4.70/51 105 | 4.62/445 188 | Freemium |
| 44 | HiCoffee / Caffeine App (1507361706 / 1045959983) — два приложения | Caffeine + water, соседний сценарий напитков на Watch | ✅ | 4.82/843; 4.63/341 | 4.82/152; 4.59/100 | Free + IAP |

**Качество доказательств:** высокое для рейтингов; функции Watch у habit-приложений не проверялись глубоко.

### 2.5 Встроенные функции Apple и поведенческие заменители

| # | Решение | Что делает | Подтверждение |
|---|---|---|---|
| 45 | **Apple Health → Medications** (iPhone + Medications app на Watch) | Расписания, напоминания, «Log All as Taken», Taken/Skipped на Watch, follow-up reminders через 30 минут, Critical Alerts для отдельных лекарств, cyclical / specific days (iOS 18+ / watchOS 11+), interaction checks только в США | [FACT] https://support.apple.com/guide/watch/medications-apd3dd24d78b/watchos ; https://support.apple.com/en-ca/105064 |
| 46 | **Apple Health → Nutrition → Water → Add Data** | Ручной ввод воды на iPhone; нативного Watch-интерфейса для воды не найдено | [INFERENCE] из Apple Community и сторонних гайдов (официальной support-страницы не найдено): https://discussions-cn-prz.apple.com/thread/251723735 , https://techtiptuesday.beehiiv.com/p/tech-tip-tuesday-water-tracking-apple-health-app |
| 47 | **Shortcuts → Log Health Sample** | Бесплатный способ «один тап = стакан воды» в Health | [FACT, пример] https://ruk.ca/content/free-and-easy-logging-water-apple-health |
| 48 | **Reminders / Clock** (Apple) | Повторяющиеся напоминания; Reminders — 4.83/1 028 856 US | [FACT, API 1108187841]; отзыв: «I was trying to manage it with the iOS built-in clock and alarm app and it was allot of work» (Pill Reminder All in One, 5★, 2025-12-10) |
| 49 | **watchOS 27** (осень 2026) | На официальной странице: Workout Buddy, perimenopause, treadmill accuracy, step sync. **Ни Medications, ни hydration не упомянуты** | [FACT] https://www.apple.com/watchos/watchos-preview/ ; https://9to5mac.com/2026/07/06/watchos-27-adds-three-new-health-upgrades-for-apple-watch/ (2026-07-06) |
| 50 | Таблетница, крышка-таймер, бутылка с метками, отсутствие трекинга | Физические заменители; «check the empty pill-organizer slot» как подтверждение приёма | [INFERENCE] из пересказа поисковой выдачи; Reddit напрямую недоступен — [UNKNOWN] |

**Качество доказательств:** высокое для Apple Medications (support.apple.com); среднее для ручного ввода воды в Health (нет официальной страницы); низкое для поведенческих заменителей (Reddit недоступен).

**Предварительный shortlist** — раздел 3.

**Вывод по market map**
- Подтверждено: hydration-категория насыщена (≥7 приложений с >20k US-оценок, почти все с Watch). В medication-категории крупные игроки **в основном без нативного Watch-приложения** (MyTherapy, Pill Reminder All in One, Max, Pill Buddy, EveryDose, mediteo); с Watch — Medisafe, Hero, Aplicativos Legais, Tablets App и Apple Medications. В GLP-1 категории (2024–2026, десятки тысяч оценок) Watch есть только у Glapp и Revio.
- Неизвестно: реальная активная аудитория; насколько пользователям нужен нативный Watch, а не зеркальные уведомления.
- Уверенность: **высокая** в структуре рынка (первичные данные App Store), **низкая** в выводах о спросе на Watch.
- Что делать: использовать эту карту как список для ручной установки и прохождения onboarding 5–6 ключевых приложений (раздел 10).

---

## 3. Shortlist: критерии, веса и оценки

**Веса.** Стартовые веса из брифа сохранены. Одно уточнение: в критерий «пересечение аудитории и сценария» включено пересечение с GLP-1 и chronic-сегментами. Причина: в данных именно там лекарства и вода встречаются в одном ежедневном сценарии.

| Критерий | Вес |
|---|---|
| A. Пересечение аудитории и сценария | 25% |
| B. Качество Apple Watch и скорость действий | 20% |
| C. Пересечение hydration + medications / daily routines | 15% |
| D. Сила потребительских сигналов и отзывов | 15% |
| E. Интересность модели монетизации | 10% |
| F. Подтверждённые каналы роста | 10% |
| G. Релевантность для early-stage основателя | 5% |

Оценки 1–5 — инструмент приоритизации исследования, а не оценка качества бизнеса. B основана на наличии Watch-приложения, описании и отзывах; сам Watch-UX вживую не тестировался [UNKNOWN].

| Продукт | A | B | C | D | E | F | G | Итог | В shortlist |
|---|---|---|---|---|---|---|---|---|---|
| WaterMinder | 4 | 5 | 2 | 4 | 4 | 3 | 4 | **3.80** | ✅ |
| Streaks | 3 | 5 | 3 | 4 | 4 | 2 | 4 | **3.60** | ✅ |
| Medisafe | 5 | 3 | 2 | 4 | 4 | 2 | 3 | **3.50** | ✅ |
| MeAgain (GLP-1) | 4 | 1 | 4 | 5 | 5 | 3 | 3 | **3.50** | ✅ |
| Apple Health Medications | 5 | 4 | 2 | 4 | 1 | 1 | 5 | **3.40** | ✅ (baseline) |
| Shotsy (GLP-1) | 4 | 1 | 4 | 5 | 5 | 2 | 3 | **3.40** | ✅ |
| Waterllama | 3 | 4 | 1 | 5 | 4 | 2 | 4 | **3.25** | ✅ |
| MyTherapy | 4 | 2 | 3 | 4 | 3 | 2 | 3 | **3.10** | ✅ |
| Pill Reminder – All in One | 4 | 2 | 1 | 4 | 4 | 1 | 5 | **2.90** | ✅ |
| Pill Buddy | 4 | 1 | 1 | 4 | 3 | 4 | 5 | **2.90** | ✅ |
| Waterful (PL) | 3 | 4 | 1 | 3 | 4 | 1 | 5 | **2.90** | ✅ |
| Glapp (GLP-1, Watch) | 3 | 3 | 3 | 2 | 4 | 1 | 4 | **2.80** | ✅ |
| Water Reminder (VGFIT) | 3 | 4 | 1 | 4 | 3 | 1 | 2 | 2.80 | ✅ (как пример агрессивной монетизации) |
| Pill Reminder Medication Alarm | 3 | 3 | 1 | 3 | 3 | 1 | 3 | 2.50 | ❌ |
| Bearable | 3 | 1 | 2 | 3 | 4 | 2 | 3 | 2.45 | ❌ |
| mediteo (DE) | 3 | 1 | 1 | 4 | 1 | 1 | 3 | 2.05 | ❌ (важен локально для DE) |
| Max – Pill reminder | 3 | 1 | 1 | 3 | 2 | 1 | 3 | 2.00 | ❌ |
| Theraview (ADHD) | 3 | 1 | 1 | 2 | 2 | 1 | 4 | 1.90 | ❌ (сигнал для ADHD-ICP) |

Итог = Σ(оценка × вес). Пример для WaterMinder: 4×0.25 + 5×0.20 + 2×0.15 + 4×0.15 + 4×0.10 + 3×0.10 + 4×0.05 = 3.80.

**Вывод по shortlist**
- Подтверждено: shortlist покрывает три кластера — hydration с Watch (WaterMinder, Waterllama, VGFIT, Waterful), medication (Apple, Medisafe, MyTherapy, Pill Reminder, Pill Buddy) и GLP-1 (Shotsy, MeAgain, Glapp) — плюс Streaks как Watch-бенчмарк.
- Неизвестно: реальный Watch-UX (тапы до действия) — оценки B экспертные, без живого теста. MyFitnessPal не включён в shortlist как калорийный гигант, но его GLP-1 функции требуют отдельной проверки (раздел 7).
- Уверенность: **средняя** — веса субъективны, ранжирование чувствительно к B и A.
- Что делать: при ручной проверке Watch-UX (раздел 10, #6) пересчитать B и итог.

---

## 4. Deep dive по 13 конкурентам

Ограничение по всему разделу: onboarding и paywall **не проходились вживую** (нет устройства и аккаунта в среде исследования). Если не указан сторонний источник с записью экрана, они помечены [UNKNOWN]. Цитаты из отзывов — US storefront, RSS App Store, выборка из 150 свежих отзывов; дата отзыва указана.

### 4.1 Apple Health → Medications (baseline, бесплатно, предустановлено)

**Product.** ICP — все владельцы iPhone/Watch. JTBD: «напомни и запиши, что я принял». Возможности [FACT, support.apple.com/guide/watch/medications-apd3dd24d78b/watchos; support.apple.com/en-ca/105064]:
- на Watch: «Log All as Taken», Taken/Skipped для отдельных лекарств, запись времени и количества;
- follow-up reminder через 30 минут, если доза не отмечена;
- Critical Alerts для отдельных лекарств: «appear on the Lock Screen and play a sound (even if a Focus is on or your iPhone is muted)»;
- cyclical / specific days schedules (iOS 18+ / watchOS 11+), PRN «Log» для as-needed;
- drug interactions — **только в США**.

**Ограничения** [INFERENCE]:
- нет интеграции с Reminders (TidBITS, https://tidbits.com/2022/10/07/an-apple-a-day-ios-16-medications-feature-provides-alerts-logging-and-peace-of-mind/);
- нет воды на Watch;
- нет «одного экрана на день» с водой и лекарствами вместе;
- follow-up фиксирован на 30 минут — в описании Apple интервал не настраивается.

**Monetization.** Бесплатно.

**CX.** Пользователи конкурентов прямо называют Apple как точку ухода: «Fortunately, the stock Apple app seems to work fine» (Medisafe, 2★, 2026-08-31); «Guess I'll have to switch to Apples built in medical reminders but I prefer yours because it's more sophisticated WHEN it works» (Medisafe, 3★, 2026-07-16).

**watchOS 27.** Изменений в Medications или воде на официальной странице нет [FACT, apple.com/watchos/watchos-preview, проверено 2026-10-09]. Риск, что Apple добавит воду в будущем, остаётся [HYPOTHESIS].

**Вывод:** любое позиционирование Nuori «напоминание о таблетках на Watch» конкурирует с бесплатным встроенным решением. Само по себе оно не является преимуществом.

### 4.2 WaterMinder (Funn Media) — лучший прямой аналог по Watch

**Product.** Promise: «Track water, coffee, tea, and more with smart reminders and Apple Watch support. Try every feature free for 7 days.» Standalone Apple Watch app. В последних release notes — «Quicker Other Drinks logging on Apple Watch», redesigned Smart Reminders и Apple Watch settings [FACT, App Store US 653031147]. Есть Mac-версия (id1415257369).

**Onboarding / paywall** [ESTIMATE, ScreensDesign, видеозапись, дата не указана: https://screensdesign.com/showcase/water-tracker-by-waterminder]:
- 13 шагов onboarding, квиз для персональной цели (вес, активность);
- soft paywall с free trial, показывается очень рано (~8-я секунда видео);
- social proof («App of the Day»), один годовой план после 1-week trial.

**Monetization (US)** [FACT, IAP App Store]: Monthly $2.99, Yearly $14.99, Yearly Offer $7.49, Premium One time $49.99, tip jar $0.99–49.99. GB: Yearly £15.49 (также £9.79–29.99), Monthly £2.99, Remove Ads £1.59. PL: 14,99 zł/мес, 87,99 zł/год, 229,99 zł lifetime.

**SDK** [ESTIMATE, AppGoblin]: RevenueCat, Superwall, AppsFlyer, Google/Facebook ad SDK. Отсюда [INFERENCE] — вероятно A/B-тестирование paywall и атрибуция платного трафика; это не доказательство.

**CX.** В 150 свежих US-отзывах 139 — 5★. Тема «notif/remind» — 50 упоминаний, Watch — 16. Пример ценности: «Came back… decided I didn't wanna pay for the subscription so that I went with a free one. Came back because this one is so much better» (5★, 2026-10-03).

**Market evidence.** Apple Developer spotlight (2021): после бесплатной промо-акции и медиа — «hundreds of thousands of downloads» [FACT, пересказ https://www.iphoneincanada.ca/2021/02/12/apple-spotlights-waterminder-app-developer/].

**Вывод:** WaterMinder уже делает «быстрый Watch-лог воды + reminders + Health». Nuori не выиграет у него в hydration-only на качестве Watch, пока не доказано обратное.

### 4.3 Medisafe — лидер medication-категории, ослабленный paywall и регрессиями

**Product.** Chronic patients, семьи (Medfriends), interactions. Watch-приложение и complication [FACT].

**Monetization.**
- IAP US: $2.99–9.99/мес, $27.99–39.99/год. GB: £2.99–4.99/мес, £29.95–39.99/год. PL: 14,99–29,99 zł/мес, 129,99–199,99 zł/год [FACT, App Store].
- С 2026-01-01, по данным конкурента Pillo, free ограничен 2 лекарствами: https://pillo.care/blog/medisafe-no-longer-free-best-free-alternatives (опубликовано 2026-02-19). Это [ESTIMATE/INFERENCE]: официального подтверждения Medisafe не найдено.
- Отзывы подтверждают сам факт перехода на подписку: «I have used this app for YEARS… Now I can't use it AT ALL without paying for it?» (1★, 2026-01-15); «paywall the ENTIRE THING?» (1★, 2026-01-10).

**CX.** 59 из 150 свежих US-отзывов — 1★. Это **регрессия конкретного релиза** (август–сентябрь 2026: crash на Watch, сломанная complication, отключившиеся уведомления), а не устойчивая репутация. Примеры:
- «it will not open up on the apple watch and it has disabled notifications» (1★, 2026-09-05);
- «Watch complication Broke since latest update. Fixed as of 9/11/26» (4★, 2026-09-11).

Устойчивые паттерны на горизонте нескольких лет:
- проблемы синхронизации с Watch: «will not sync correctly with my Apple Watch» (1★, 2026-09-02);
- навязчивые повторы без настройки интервала: «reminds you every 10 minutes… no way to change the time interval… wastes battery» (1★, 2026-08-30);
- ограниченная история: «only lets me look at a month before» (2★, 2026-10-04);
- желание синхронизировать список лекарств с Apple Health (4★, 2026-05-10).

**Market evidence** [ESTIMATE, AppGoblin]: 11.5M installs, ~546K MAU, тренд «Declining» (+14K/мес). Компания заявляла 7M+ registered users при раунде $30M (https://mercomcapital.com/medisafe-raises-30-million-for-medication-management-app/). Similarweb — $10–15M revenue (https://www.similarweb.com/company/medisafe.com). Оценки противоречат друг другу, уверенность низкая.

**Вывод:** есть платящие пользователи, которые недовольны paywall и надёжностью Watch. Это лучший публичный сигнал готовности платить за medication-tracking и одновременно сигнал оттока.

### 4.4 MyTherapy (smartpatient GmbH, DE)

**Product.**
- Promise: «Pill Reminder & Medication Alarm… pill tracker… measurements… family profiles».
- В описании синхронизация с Apple Health: «weight, steps, water intake».
- Нативного Watch-приложения нет [FACT, API], но в отзыве: «Works with Apple Watch» (5★, 2025-08-03) — через зеркальные уведомления [INFERENCE]. Есть и запрос: «It would be nice to have watch app as well!» (5★, 2026-05-20).

**Monetization.** Бесплатно с рекламой; ad-free $0.99/мес или $9.99/год; Plus Lifetime $49.99. PL: 4,99 zł/мес, 49,99 zł/год, 199,99 zł lifetime. Бизнес — B2B с pharma: партнёрство с Merck [FACT, https://edit.smartpatient.eu/blog/press-release-smartpatient-and-merck-announce-new-global-partnership-and-digital-companion].

**CX.** 106/150 — 5★. Тема notifications — 80 упоминаний: и похвала, и сбои. Реклама — 9 упоминаний.

**Market evidence.** Компания заявляет «10,000,000+ users» [FACT как заявление компании, https://edit.smartpatient.eu/platform]. AppGoblin: 3.5M iOS installs, ~205K MAU [ESTIMATE]. Самый сильный medication-игрок в DE по оценкам (15 378), сильный в PL (1 870) и FR (4 037).

**Вывод:** в EU бесплатный MyTherapy задаёт ценовой якорь «почти бесплатно». Платить в EU за чистый pill reminder — слабая гипотеза.

### 4.5 Waterllama — эталон геймификации и lifetime-продаж

**Product.**
- Персонажи, напитки, челленджи, Watch, виджеты, Health.
- В US free version ограничен: «free only lets you click 8, 12, or 16 oz. Every drink besides water is paywalled. Absolutely constant popups» (1★, 2026-09-29).
- Onboarding 10 экранов, отдельный onboarding paywall и locked-feature paywall [ESTIMATE, Lazyweb: https://www.lazyweb.com/flow/waterllama/onboarding].

**Monetization.** US IAP $0.99 (Monthly Full Access) – $19.99. В отзывах lifetime со скидкой: «offered the 75% off for a $10 lifetime subscription, I literally did not hesitate» (5★, 2026-10-04). GB £0.79–14.99; PL 4,99–69,99 zł.

**CX.** Ценность — эмоциональный дизайн: «Category of One… design choices were made with passion and care» (5★, 2026-09-16). Негатив — paywall, регрет lifetime при crash (1★, 2026-09-18).

**Market evidence** [ESTIMATE, AppGoblin]: 18.5M installs, ~898K MAU, тренд «Trending» (+207K/мес). Это самый растущий hydration-игрок; цифра revenue «$10K+» — нижний bucket и неинформативна.

**Вывод:** в hydration деньги приносит сочетание **дизайн + эмоция + lifetime-скидка**, а не утилитарность.

### 4.6 Streaks — лучший Watch-UX среди заменителей

**Product.**
- До 24 задач, Apple Design Award, complications.
- Автозавершение задач из Health: «Streaks automatically knows when you complete tasks linked to the Health app, such as water tracking and caffeine tracking» [FACT, App Store 963034692].
- Пользователь может собрать «вода + таблетки» как две задачи-привычки.

**Monetization.** **Paid upfront $5.99**, без подписки [FACT]. US 4.81/27 349.

**Вывод:** доказывает, что Watch-пользователи платят разово за качественный нативный UX. Это и бенчмарк lifetime-цены для Nuori.

### 4.7 Shotsy — GLP-1, платящая аудитория

**Product.** Promise: «medication history, side effects, weight, calories, protein, and water intake. Supports multiple simultaneous medications», «countdowns», импорт из Apple Health «weight, calories, protein, and water» [FACT]. Watch-приложения нет [FACT, API].

**Monetization.** US: $9.99–19.99/мес, $39.99–59.99/год [FACT, IAP]. Повышение цены вызвало протест: «had access to everything for $20 a year… they want to charge $40» (1★, 2026-09-15); «paywalls for seeing data I previously had access to» (2★, 2026-10-02). Положительный: «Worth the price. Highly recommend» (5★, 2026-10-03).

**Market evidence** [ESTIMATE, AppGoblin]: 2.4M installs, ~200K MAU, +143K/мес; SDK: AppsFlyer, RevenueCat, Mixpanel. US 33 246 оценок с мая 2024 — для такого срока очень быстрое накопление [FACT, API]. GB 4 210, DE 1 606, FR 608, NL 274, PL 169.

### 4.8 MeAgain — GLP-1, вода/белок/клетчатка, запрос на Watch

**Product.** «shot reminders and pill reminders», «protein and water goals», widgets с маскотом Capy [FACT, описание].

**CX — прямой запрос на Watch:**
- «Love the app but needs an Apple Watch app!» (5★, 2026-09-29);
- «I do wish there was an apple watch feature or interface… for checking your protein/fiber/water goals, and quick logging» (4★, 2026-09-16);
- «changing the amount of water instead of having to add it up» (3★, 2026-09-19).

**Канал:** «Found this app from an ad on FB» (4★, 2026-09-17). Это [FACT], что пользователь так сказал, и [INFERENCE], что MeAgain использует Meta ads; проверяется через Meta Ad Library.

**Monetization.** «Unlimited» $14.99–119.99 [FACT, IAP; периоды не видны]. «No free option… I cannot access ANYTHING» (4★, 2026-09-21) — по-видимому, hard paywall [INFERENCE].

**Market evidence** [ESTIMATE, AppGoblin]: 1.9M installs, ~207K MAU, +203K/мес «Declining»; SDK: Superwall, RevenueCat, Stripe, AppsFlyer, React Native. 36 185 US-оценок с апреля 2025 [FACT]. Вне US слабо: GB 183, DE 28.

### 4.9 Glapp — единственный заметный GLP-1 трекер с Watch

**Product.** «Log your shot in seconds — dose, timing, injection site», side effects, «medication level curve». Watch есть [FACT, API].

**Monetization.** $4.99/нед, $9.99/мес, $39.99/год [FACT].

**Market evidence.** Релиз 2026-03, US 987 оценок. Watch-наличие пока не дало заметного масштаба. Выводы о влиянии Watch на рост невозможны.

### 4.10 Pill Reminder – All in One (Sergio Licea, инди)

**Product.** Гибкие расписания (every X hours, PRN), refill alerts, отчёты врачу, multiple users, critical alerts. Нативного Watch-приложения нет, но уведомления приходят на Watch: «On my Apple watch, the first item to click is "skip". Can you possibly change it to take now» (5★, 2025-04-27). Есть и запрос: «It would be amazing to have Apple Watch support for notifications!!» (4★, 2026-01-24).

**Monetization.** Free — без лимита лекарств, но только 2 напоминания; **$2.99 one-time** [FACT, описание и IAP]. Ценится как «not feed the corporate data monster» (5★, 2025-12-10).

**Market evidence.** US 27 923 оценки; AppGoblin: 2.3M installs, ~112K MAU, без SDK аналитики [ESTIMATE].

**Вывод:** доказательство, что соло-разработчик держит позицию за счёт надёжности, приватности и разовой цены. Порядок действий в уведомлении (Taken первым) — мелкая, но реальная UX-деталь, которую Nuori уже учитывает (Taken / Snooze / Skip).

### 4.11 Pill Buddy (Kai Loh) — эталон инди-запуска

**Product.**
- Маскот-дарума, который «gets increasingly annoying if you miss a dose»;
- напоминания через push, **phone calls**, widgets;
- streaks, stars, «No ads, and your personal info stays private».
- Watch-приложения нет.

**Monetization.** Supporter $4.99/мес, $35.90/год.

**Каналы (подтверждено):**
- 9to5Mac Indie App Spotlight (https://9to5mac.com/?p=1004129);
- пост на Indie Hackers (https://www.indiehackers.com/post/just-launched-a-cute-medicine-tracking-app-all-art-is-original-by-me-13e6a403f1), в комментариях совет «expand to ADHD community».
- TikTok/Reddit-кампании не подтверждены [UNKNOWN].

**Market evidence** [ESTIMATE, AppGoblin]: 107K installs, +11K/мес «Trending». US 1 775 оценок с мая 2025.

### 4.12 Waterful (Listonic, Польша) — локальный игрок

**Product.** «All for completely free!»; Apple Health, Siri Shortcuts, Apple Watch; цель с учётом погоды, беременности и кормления.

**Monetization.** Очень дешёвые планы: PL 4,99 zł/мес, 14,99–37,99 zł/год, 39,99–49,99 zł lifetime.

**Market evidence.** PL 1 843 оценки — больше, чем у WaterMinder (911) и Waterllama (1 666) в PL [FACT]. Это означает, что польский hydration-рынок отзывчив к локальному бренду и низкой цене. Listonic — известное польское приложение списков покупок, так что у Waterful есть кросс-промо [INFERENCE].

### 4.13 Water Reminder (VGFIT) — пример агрессивной монетизации

**Monetization.** Premium $0.99–79.99, 10 видимых позиций.

**CX:**
- «Paywall for a sound» (1★, 2026-07-31);
- «Signed up for a free trial and got charged for a year subscription» (1★, 2026-02-04);
- «This app could easily be a one time purchase» (1★, 2026-02-08);
- «Something as simple as an app to remind you to drink water has a paid subscription lol» (1★, 2026-01-25).

**Вывод:** в hydration подписка вызывает сопротивление; lifetime и разовая покупка воспринимаются лучше [INFERENCE по VGFIT, Waterllama, WaterMinder].

### 4.14 Сводка повторяющихся паттернов CX

| Паттерн | Где подтверждается | Значение для Nuori |
|---|---|---|
| Ненадёжность уведомлений и Watch-sync — главная причина 1★ в medication | Medisafe, Pill Reminder Medication Alarm, Max | Надёжность локальных уведомлений и офлайн-Watch — ценность, которую можно проверить |
| Сопротивление подписке на «простую» функцию | VGFIT, Waterllama, Medisafe, Shotsy | Lifetime / разовая покупка как гипотеза по умолчанию |
| Апгрейд free → paywall бьёт по лояльным | Medisafe (2026-01), Shotsy (2026-09) | Не отбирать бесплатные функции после запуска |
| Запрос на Watch-приложение | MeAgain (несколько), MyTherapy, Pill Reminder All in One | Подтверждённый спрос в GLP-1 и medication, где мало Watch-игроков |
| Эмоциональный дизайн и маскоты | Waterllama, Plant Nanny, Pill Buddy, MeAgain (Capy), Finch | Утилитарный Nuori конкурирует в другой плоскости; нужна иная причина выбора |
| Уход к «stock Apple app» | Medisafe | Apple — реальная альтернатива, не теоретическая |
| Пользователи сами логируют воду рядом с лекарствами | Pill Buddy (6 из 150), GLP-1 (MeAgain, Shotsy) | Совмещение ценят в эмоциональном или GLP-1 контексте, не в «медицинском» |

**Вывод по deep dive**
- Подтверждено: цены и планы всех 13; повторяющиеся паттерны отзывов (надёжность уведомлений, сопротивление подписке, запрос Watch в GLP-1 и medication); отток у Medisafe после изменений 2026 года.
- Неизвестно: onboarding и paywall вживую (кроме записей ScreensDesign и Lazyweb для WaterMinder и Waterllama); trial-условия; реальные конверсии; работа GLP-1 функций MyFitnessPal на Watch.
- Уверенность: **высокая** для цен и цитат, **средняя** для паттернов (выборка 150 US-отзывов, свежие отзывы смещены к последним релизам), **низкая** для рыночных метрик.
- Что делать: установить Shotsy, MeAgain, MyFitnessPal (GLP-1 на Watch), Medisafe и Apple Medications; пройти onboarding и записать шаги и тапы до первого лога на iPhone и Watch.

---

## 5. Pricing и monetization matrix

Источник цен: блок In-App Purchases на страницах App Store, 2026-10-09 [FACT]. Apple показывает до 10 позиций без пометки «текущая», поэтому диапазоны включают старые и промо-цены. Trial-условия, если не указаны в описании, — [UNKNOWN].

| Продукт | Модель | Free-часть | US | GB | PL | Trial | Сигналы WTP в отзывах |
|---|---|---|---|---|---|---|---|
| Apple Medications | Встроено | Всё | $0 | £0 | 0 zł | — | Уход к нему от Medisafe |
| WaterMinder | Freemium + подписка + lifetime + tips | Базовый лог | $2.99/мес; $14.99/год (offer $7.49); $49.99 lifetime | £2.99/мес; £9.79–29.99/год | 14,99 zł/мес; 87,99 zł/год; 229,99 zł lifetime | 7 дней [FACT, описание] | «Came back… so much better» |
| Waterllama | Freemium, жёсткий paywall + lifetime | 8/12/16 oz, только вода | $0.99–19.99 | £0.79–14.99 | 4,99–69,99 zł | [UNKNOWN] | Lifetime со скидкой 75% → покупка; жалобы на popups |
| Water Reminder VGFIT | Подписка | Ограниченная | $0.99–79.99 | — | — | Есть (жалоба на списание) | Сильное сопротивление |
| Plant Nanny | Подписка + расходники | Есть | $3.99–7.99/мес; $44.99/6 мес; $69.99/год | — | — | [UNKNOWN] | [не анализировалось] |
| Waterful (PL) | Почти бесплатно + дешёвые планы | Почти всё | $0.99/мес; $2.99–7.49/год; $7.99–9.99 lifetime | £0.99/мес; £2.49–7.49/год | 4,99 zł/мес; 14,99–37,99 zł/год; 39,99–49,99 zł | [UNKNOWN] | — |
| Medisafe | Подписка (с 2026-01 жёстче) | 2 лекарства (по данным Pillo) | $2.99–9.99/мес; $27.99–39.99/год | £2.99–4.99/мес; £29.95–39.99/год | 14,99–29,99 zł/мес; 129,99–199,99 zł/год | [UNKNOWN] | Гнев лояльных; часть платит |
| MyTherapy | Free + реклама; ad-free; lifetime | Всё основное | $0.99/мес; $9.99/год; $49.99 lifetime | £0.99; £9.99; £49.99 | 4,99 zł; 49,99 zł; 199,99 zł | — | Мало жалоб на цену |
| Pill Reminder – All in One | Free (2 напоминания) + one-time | Неограниченно лекарств, 2 напоминания | **$2.99 once** | [не извлекалось] | — | — | Ценят «no monthly fees» |
| Pill Buddy | Free + Supporter | Основное | $4.99/мес; $35.90/год | — | — | [UNKNOWN] | Мало жалоб |
| EveryDose | Подписка | Ограниченная | $9.99/мес; $59.99/год | — | — | [UNKNOWN] | — |
| Hero | Hardware-членство | — | $29.99–44.99/мес + $99.99 | — | — | 90-day money-back | Caregivers платят много за надёжность |
| Streaks | **Paid upfront** | — | **$5.99** | — | — | — | 4.81/27k — разовая цена работает |
| Shotsy | Подписка | Частично (урезается) | $9.99–19.99/мес; $39.99–59.99/год | — | — | [UNKNOWN] | «Worth the price» vs «greed» при росте $20→$40/год |
| MeAgain | Hard paywall (вероятно) | Минимум | $14.99–119.99 | — | — | [UNKNOWN] | Платят «just for Capy»; жалобы «cannot access anything» |
| Glapp | Подписка | [UNKNOWN] | $4.99/нед; $9.99/мес; $39.99/год | — | — | [UNKNOWN] | — |
| Daily Health | Подписка | [UNKNOWN] | $6.99/нед; $12.99/мес; $49.99/год | — | — | — | — |
| Bearable | Подписка | Основное | $4.49–49.99 | — | — | — | — |

**Ценовые якоря** [INFERENCE]:
- hydration-only — $0–15/год или $8–50 lifetime;
- pill reminder — $0–3 разово или $28–40/год (Medisafe), при бесплатном Apple и MyTherapy;
- GLP-1 companion — **$40–120/год**, и пользователи реально платят (отзывы «worth the price», «I have the subscription»);
- Watch-нативный инструмент разово — ~$6 (Streaks).

**Гипотезы WTP по продуктам** [HYPOTHESIS]:
1. Пользователи Medisafe, недовольные paywall, заплатят $10–20 разово за надёжный аналог с Watch, но не $40/год.
2. GLP-1 пользователи заплатят $20–40/год за Watch-companion к уже используемому приложению (или вместо него), если он логирует укол, воду и белок за 1–2 тапа.
3. Hydration-only пользователи без эмоционального слоя не заплатят больше $5–10 разово.

**Что подтверждено:** цены и структура планов. **Неизвестно:** конверсия, trial-длительность, какая цена текущая. **Уверенность:** высокая в ценах, низкая в WTP. **Что делать:** тестировать WTP на landing/TestFlight через fake-door с тремя вариантами (раздел 7).

---

## 6. Публичные метрики и ограничения данных

**Как читать.** Количество оценок App Store — индикатор масштаба, а не пользователей. AppGoblin не раскрывает методологию. Его «installs», по-видимому, глобальные: 370K оценок у Waterllama против 162 644 в US-storefront. Revenue «$10K+» встречается почти у всех и выглядит как нижняя граница bucket. Эти цифры годятся только для сравнения масштаба и направления тренда.

| Продукт | Метрика | Значение | Период | География | Источник | Тип | Уверенность |
|---|---|---|---|---|---|---|---|
| Waterllama | Оценки | 162 644 (4.87) | на 2026-10-09 | US | iTunes API | FACT (индикатор) | Высокая |
| Waterllama | Installs / MAU | 18.5M / ~898K | на 2026-10-08 | вероятно глобально | appgoblin.info/apps/1454778585 | ESTIMATE | Низкая |
| Waterllama | Install trend | +207K/мес, «Trending» | ~сентябрь 2026 | — | AppGoblin | ESTIMATE | Низкая |
| WaterMinder | Оценки | 35 063 (4.74) | 2026-10-09 | US | iTunes API | FACT | Высокая |
| WaterMinder | Installs / MAU | 4M / ~199K | 2026-10-08 | — | appgoblin.info/apps/653031147 | ESTIMATE | Низкая |
| WaterMinder | Revenue | «$10K+»/мес (AppGoblin); «$15K»/мес и «$35.0K/mo» (ScreensDesign, противоречиво) | — | — | AppGoblin; screensdesign.com | ESTIMATE | Очень низкая |
| WaterMinder | Downloads | «hundreds of thousands» после промо | до 2021 | — | Apple Developer spotlight (iphoneincanada.ca, 2021-02-12) | FACT (заявление разработчика) | Средняя |
| WaterMinder Android | Installs | «over 1 million» | — | Google Play | appbrain.com/dev/Funn+Media/ | ESTIMATE/агрегатор | Средняя |
| Medisafe | Оценки | 101 444 (4.71) | 2026-10-09 | US | iTunes API | FACT | Высокая |
| Medisafe | Installs / MAU | 11.5M / ~546K; +14K/мес «Declining» | 2026-10-08 | — | appgoblin.info/apps/573916946 | ESTIMATE | Низкая |
| Medisafe | Registered users | 7M+ | на момент раунда $30M | глобально | mercomcapital.com | FACT (заявление компании) | Средняя |
| Medisafe | Revenue | $10–15M/год | — | — | similarweb.com/company/medisafe.com | ESTIMATE | Низкая |
| MyTherapy | Users | 10M+ (раньше «9M+», 2024-02) | без даты | глобально | edit.smartpatient.eu/platform | FACT (заявление компании) | Средняя |
| MyTherapy | Installs / MAU | 3.5M / ~205K | 2026-10-08 | — | AppGoblin | ESTIMATE | Низкая |
| MyTherapy | Оценки | DE 15 378; US 8 554; FR 4 037; GB 3 204; NL 2 364; PL 1 870 | 2026-10-09 | по странам | iTunes API | FACT | Высокая |
| mediteo | Оценки | DE 20 292 | 2026-10-09 | DE | iTunes API | FACT | Высокая |
| Pill Reminder – All in One | Installs / MAU | 2.3M / ~112K | 2026-10-08 | — | AppGoblin | ESTIMATE | Низкая |
| Pill Buddy | Installs | 107K; +11K/мес «Trending» | 2026-10-07 | — | AppGoblin | ESTIMATE | Низкая |
| Max | Installs; revenue split | 1.4M; «Ad 100%» | 2026-10-08 | — | AppGoblin | ESTIMATE | Низкая |
| Shotsy | Оценки | US 33 246; GB 4 210; DE 1 606; FR 608; NL 274; PL 169 | 2026-10-09 (релиз 2024-05-29) | по странам | iTunes API | FACT | Высокая |
| Shotsy | Installs / MAU | 2.4M / ~200K; +143K/мес | 2026-10-08 | — | AppGoblin | ESTIMATE | Низкая |
| MeAgain | Оценки | US 36 185; GB 183; DE 28 | 2026-10-09 (релиз 2025-04-11) | по странам | iTunes API | FACT | Высокая |
| MeAgain | Installs / MAU | 1.9M / ~207K; +203K/мес «Declining» | 2026-10-08 | — | AppGoblin | ESTIMATE | Низкая |
| Waterful | Оценки | PL 1 843 vs WaterMinder PL 911 | 2026-10-09 | PL | iTunes API | FACT | Высокая |
| Hero | Цена | $29.99–44.99/мес + $99.99 | 2026 | US | herohealth.com/pricing; support.herohealth.com | FACT | Высокая |
| Product Hunt (water trackers с Watch) | Upvotes | 0–4, места #72–#142 за день | разные даты | глобально | hunted.space (зеркало PH) | ESTIMATE/агрегатор | Средняя |

**Бесплатно и проверяемо:**
- рейтинги по storefront (iTunes API);
- IAP-листы;
- RSS-отзывы (только US, нужен цикл по странам);
- AppGoblin (грубо);
- Meta Ad Library (активные объявления);
- Apple Search Ads «популярность» ключевого слова — бесплатно при наличии аккаунта ASA.

**Требует платного инструмента:** Sensor Tower и AppMagic (downloads/revenue по странам), Appfigures (keyword ranks), data.ai.

**Что подтверждено:** относительный масштаб; GLP-1 приложения набрали десятки тысяч US-оценок за 1–2 года. **Неизвестно:** реальные revenue, retention, conversion — ни у одного игрока. **Уверенность:** высокая для рейтингов, низкая для всего остального. **Что делать:** не строить финансовую модель на этих цифрах. Для решения достаточно направления: GLP-1 растёт, Medisafe теряет, hydration насыщен.

---

## 7. Конкурентные возможности (Этап E)

### 7.1 Ответы на вопросы Этапа E

**E2. Какой сценарий плохо обслуживается конкурентами?**

[INFERENCE] **«Несколько ежедневных лог-действий, привязанных к лекарству, — с запястья, без телефона».** Это сценарий человека на GLP-1 (укол раз в неделю, вода и белок каждый день) или на хронической терапии с требованием пить воду.

Доказательства:
- **специализированные** GLP-1 приложения с тысячами и десятками тысяч оценок не имеют Watch: Shotsy, MeAgain, Mounjaro Tracker, Glowise [FACT, API];
- **важное исключение — MyFitnessPal**: Watch-приложение есть [FACT, API], в описании «GLP-1 journey support — log doses and set reminders» и «built-in water tracker» [FACT]. Доступны ли GLP-1 лог и вода **на самих часах** — [UNKNOWN]: описание упоминает complications только для Wear OS. Это главный инкумбент-риск для возможности 1;
- пользователи MeAgain прямо просят Watch для «protein/fiber/water goals, and quick logging» [FACT, отзывы];
- в hydration-приложениях нет лекарств, в medication-приложениях на Watch нет воды;
- Apple Medications не логирует воду на Watch.

**E3. Есть ли проблема, за которую уже платят?** Да, в двух местах:
- GLP-1 трекинг: $40–120/год, «worth the price» [FACT, IAP + отзывы];
- medication reminders у Medisafe ($28–40/год). Но там платёж частично вынужденный, через paywall, и сопровождается оттоком.

Hydration-only монетизируется в основном через lifetime и эмоциональный дизайн (Waterllama).

**E4. Объединять ли hydration и medications?**
- Для массового рынка это **в основном две разные задачи**. Слова water/hydrat/fluid/drink в выборках по 150 свежих US-отзывов: Medisafe — 0, MyTherapy — 0, Max — 0, EveryDose — 0, Pill Reminder Medication Alarm — 0, Pill Reminder All in One — 1 [FACT, выборка].
- Исключение — **Pill Buddy: 6 упоминаний, все позитивные**. Пользователи сами логируют воду рядом с лекарствами: «I used the free version for medication taking, water and pain levels after a multiple teeth extraction» (5★, 2026-08-26); «It's nice to have everything centered in an app» (5★, 2026-07-30) [FACT]. Совмещение ценят в приложении с эмоциональным слоем, а не в медицинском.
- Hydration-аудитория мотивирована фитнесом и внешностью, medication-аудитория — болезнью и надёжностью [INFERENCE].
- Есть ниши, где задачи **естественно совмещены**: GLP-1 (вода против побочек — «my side effects have lessened due to the increased water» — MeAgain, 5★, 2026-09-29), некоторые хронические состояния (почки, литий, мочегонные), беременность (витамины + вода) [HYPOTHESIS для последних двух].
- Вывод: объединение ценно, только если позиционирование называет **конкретную ситуацию, где обе задачи — следствие одного лечения**. «Water + meds в одном приложении» как общий promise вероятно слаб [INFERENCE].

**E6. Что в Apple Health усложняет конкуренцию?**
- Medications бесплатен, предустановлен и есть на Watch: Taken/Skipped, Log All, 30-минутный follow-up, Critical Alerts, которые пробивают Focus и mute [FACT].
- Медленно уходящие пользователи Medisafe называют его альтернативой [FACT, отзывы].
- Данные Health — единый источник: конкурент, который не пишет в Health, проигрывает [INFERENCE].
- Слабые места Apple (не исправлены в watchOS 27 по официальной странице):
  - нет воды и питания на Watch;
  - follow-up только через 30 минут, без кастомного snooze;
  - нет complication «2/3 + next dose» с водой рядом;
  - нет виджета «сегодня» с несколькими рутинами;
  - нет GLP-1-специфики: место укола, неделя дозы.

  Точная проверка complications Apple Medications — [UNKNOWN], нужна ручная проверка на watchOS 27.

**E7. Каким должно быть проверяемое преимущество Nuori?**

Важная оговорка: уведомления iPhone с кнопками **автоматически зеркалируются на Watch**, поэтому «у нас есть Watch-приложение» и «отметка Taken с запястья» — **не преимущество**. Так работает и MyTherapy без Watch-приложения. Преимущество Nuori должно опираться на то, чего зеркальные уведомления не дают:
1. **Глянцевая complication** — сколько доз принято и когда следующая, вместе с прогрессом воды (уже есть: «Medications 2/3 + next dose», «Hydration %»).
2. **Лог незапланированных действий одним тапом** — вода, доп. доза, белок. Уведомления этого не делают.
3. **Офлайн и standalone** — работа без телефона рядом и без аккаунта; локальные данные и приватность.
4. **Snooze 10 min** — гибче фиксированных 30 минут Apple. Ценность нужно проверить.

Формулировка для теста [HYPOTHESIS]: «**Log your shot, water and protein from your wrist in under 2 seconds — no phone, no account.**» Альтернатива для chronic: «**Your meds and water on your watch face. Tap once. Works offline.**»

**E8. Что не стоит разрабатывать до подтверждения спроса:**
- фото-распознавание еды, базы продуктов, AI-калории (Cal AI, MyFitnessPal, Lifesum, YAZIO доминируют);
- «projected drug levels» / кривые концентрации GLP-1: вероятный риск квалификации как medical device software по EU MDR для основателя в ЕС [HYPOTHESIS, нужна юридическая проверка];
- drug interactions, справочники, связь с аптеками;
- облачный аккаунт, семейный доступ / caregivers (до проверки ICP caregivers);
- маскоты и геймификация как основная ценность (дорого, конкуренты сильны);
- Android-версия;
- новые локализации сверх EN/RU/UK/PL.

### 7.2 Пять продуктовых возможностей

| # | Возможность | Evidence | Сегмент | Ценность | Альтернативы | Риски | Самая дешёвая проверка |
|---|---|---|---|---|---|---|---|
| 1 | **GLP-1 Watch companion**: укол (дата, место), вода, белок — quick-add на Watch + complication «days to next shot» | Запросы Watch в отзывах MeAgain; ни у Shotsy, ни у MeAgain нет Watch; WTP $40–120/год | Пользователи GLP-1 в US и UK (UK: Mounjaro Tracker GB 2 065, Shotsy GB 4 210) | Лог за 1–2 тапа, видимость на циферблате | Shotsy, MeAgain, Glapp (с Watch), MyFitnessPal | **MyFitnessPal** уже имеет Watch + GLP-1 + воду (GLP-1 на часах — [UNKNOWN], проверить первым). Категория перегружена (20+ приложений с 2024); медицинская чувствительность; основатель не в целевой группе; низкий спрос в PL | Landing + 2 варианта объявлений в GLP-1 сообществах; 10 интервью; TestFlight-ветка с одним экраном «Shot + Water + Protein» |
| 2 | **Надёжный Watch-первый pill tracker для ушедших от Medisafe** с разовой ценой | 59/150 1★ у Medisafe (регрессия Watch); paywall 2026-01; «stock Apple app» как альтернатива; успех $2.99 one-time у Sergio Licea | Хронические пациенты US/UK с Watch | Надёжность, complication, без подписки | Apple Medications (бесплатно), Pill Reminder All in One, MyTherapy | Apple «достаточно хорош»; отток Medisafe может быть временным; трудно найти этих людей | SEO-страница «Medisafe alternative for Apple Watch» (копируя тактику Pillo) + замер кликов и подписок на TestFlight |
| 3 | **«Did I take it?» для ADHD-стимуляторов** — время приёма на циферблате, «принято N часов назад» | Theraview 4.90/329; совет «expand to ADHD community» для Pill Buddy; запросы «did I already take it» (пересказ поисковой выдачи, Reddit недоступен) | Взрослые с ADHD, US/UK | Снимает двойной приём и пропуск | Apple Medications, Theraview, таблетница | Контролируемые вещества — чувствительность; маленькая ниша; Reddit не проверен | 5 постов в ADHD-сообществах с прототипом complication; 10 интервью |
| 4 | **Hydration + medications для конкретного лечения** (литий, почки, мочегонные, беременность и витамины) | [HYPOTHESIS] — прямых данных нет; MyTherapy синхронизирует воду из Health | Пациенты с назначенной нормой жидкости | Одна complication для двух назначений | WaterMinder + Apple Medications в паре | Сегмент может не существовать в достаточном размере | 5–8 интервью через знакомых медиков, форумы пациентов; вопрос «врач назначал вам норму воды?» |
| 5 | **Приватный «no account, no ads, offline» трекер в EU / PL** с локализацией PL/UK/RU | Waterful лидирует в PL (1 843) с почти бесплатной моделью; MyTherapy free; ценность «not feed the corporate data monster» | PL и UA-диаспора в PL/DE, privacy-conscious | Приватность, родной язык | Waterful, MyTherapy, Apple | Низкая WTP в PL (цены в 3–5× ниже US); маленький рынок | ASO-эксперимент: PL-ключи «przypomnienie o lekach», «picie wody» + PL-скриншоты; замер impressions и installs в App Store Connect |

**Что подтверждено:** незакрытый спрос на Watch в GLP-1; отток у Medisafe; ценовые якоря. **Неизвестно:** размер каждого сегмента среди Watch-владельцев; конверсия. **Уверенность:** средняя для возможностей 1 и 2, низкая для 3–5. **Что делать:** проверять параллельно 1 и 2 (раздел 10), остальные — интервью.

---

## 8. ICP-гипотезы

| ICP | Описание | Evidence | Сила evidence | Против | Приоритет проверки |
|---|---|---|---|---|---|
| **A. GLP-1 user с Apple Watch** | 30–60 лет, US/UK, Ozempic / Mounjaro / Zepbound; уже ведёт трекинг в Shotsy или MeAgain; хочет логировать с запястья | Отзывы MeAgain с прямым запросом Watch; WTP $40–120/год; десятки тысяч оценок за 1–2 года; Meta ads как канал (вероятно) | **Средняя–высокая** для боли и WTP, **низкая** для доли Watch-владельцев | MyFitnessPal с Watch и GLP-1 (на часах — [UNKNOWN]); перегретая категория; основателю трудно говорить с этой аудиторией; медицинские риски | 1 |
| **B. Chronic / multi-med Watch user, уходящий от Medisafe** | 45+, несколько лекарств, US/UK; ценит надёжность и Watch | Отзывы Medisafe о Watch и paywall; «stock Apple app» | **Средняя** | Бесплатный Apple Medications; найти таких людей дорого | 2 |
| **C. ADHD adult** | 20–40 лет, стимуляторы, «did I take it?» | Theraview, косвенно Pill Buddy | **Низкая** | Reddit не проверен; маленькая монетизация | 3 |
| **D. Hydration-only Watch user** | Фитнес и wellness, хочет быстрый лог воды с циферблата | Огромный рынок, все топ-игроки с Watch | **Высокая для спроса, низкая для дифференциации** | WaterMinder и Waterllama уже лучше; подписка вызывает сопротивление | 4 (не основной) |
| **E. Caregiver пожилого родителя** | Взрослые дети, контролирующие приём | Hero ($30–45/мес), Medfriends у Medisafe | **Средняя для WTP, нулевая для Watch-first** | Watch у пожилого — редкость [HYPOTHESIS]; требует облака и шеринга, противоречит local-only | Не проверять сейчас |

**Что подтверждено:** у A и B есть платёжное поведение у конкурентов. **Неизвестно:** какой из них ответит на Nuori. **Уверенность:** средняя. **Что делать:** не выбирать ICP до 20 интервью (по 10 на A и B) и одного дешёвого теста трафика (раздел 10).

---

## 9. Роль calorie tracking

**Данные:**
- калорийная категория — самая крупная и защищённая: MyFitnessPal 2.37M US-оценок, Lose It! 780K, Cal AI 369K, YAZIO 445K в DE [FACT, API];
- все с Watch и AI-логированием;
- в GLP-1 сегменте пользователи говорят не о калориях, а о **«protein, fiber and water»**: «helps me track water, protein and fiber which are most important to me right now» (MeAgain, 5★, 2026-09-12); «helps me focus on protein, water and fiber» (5★, 2026-09-08) [FACT];
- MeAgain позиционируется против «Generic food apps» [FACT, описание].

**Рекомендация [INFERENCE]:**
1. **Убрать калории из позиционирования** (App Store title, subtitle, скриншоты, landing). Как ценностное предложение калории проигрывают, и альтернативная стоимость — внимание пользователя на первом экране.
2. **Не удалять код.** Существующий механизм quick-add +100/+250/+500 и presets дёшево переиспользовать как **трекер одного нутриента** (протеин в граммах, клетчатка) для GLP-1 гипотезы. Это изменение единиц и пресетов, а не новая функция.
3. **Исследовать отдельно как гипотезу:** «protein quick-add на Watch для GLP-1» — один экран, проверка через TestFlight-ветку.
4. Не развивать базы продуктов, сканеры и AI-распознавание.

**Что подтверждено:** калорийный рынок закрыт крупными игроками; в GLP-1 акцент на белок, клетчатку и воду. **Неизвестно:** используют ли текущие тестировщики калории (нужны данные из TestFlight-интервью). **Уверенность:** средняя–высокая. **Что делать:** спросить 12 тестировщиков, пользуются ли они экраном калорий; если меньше 3 — скрыть экран по умолчанию.

---

## 10. Десять ключевых неизвестных и как их проверить

| # | Неизвестное | Почему важно | Способ проверки (дёшево) | Бюджет |
|---|---|---|---|---|
| 1 | Какая доля пользователей GLP-1 приложений носит Apple Watch и хочет логировать с него | Определяет ICP A | Опрос из 3 вопросов в GLP-1 сообществах (Facebook-группы, Discord, r/Mounjaro, r/Zepbound — вручную); цель 50 ответов | $0 |
| 2 | Чем зеркальные уведомления на Watch хуже нативного приложения для приёма лекарств | Основа дифференциации E7 | 10 интервью: «покажите, как вы отмечаете приём сейчас» (screen share) | $0 |
| 3 | Используют ли текущие 12 тестировщиков калории, воду, лекарства и с какой частотой | Решение по калориям и фокусу | Опрос и интервью тестировщиков; локальный счётчик действий только с согласия (без сторонней аналитики) | $0 |
| 4 | Готовность платить и модель (lifetime vs подписка) | Ценовая стратегия | Fake-door на landing: 3 варианта — $4.99/мес, $24.99/год, $29.99 lifetime; кнопка «Join early access» | $0–100 (трафик) |
| 5 | Отклик на позиционирование «GLP-1» vs «chronic meds» vs «hydration» | Выбор ICP | 3 варианта объявления в Meta / Reddit Ads → landing с email; CTR и стоимость email | $100–500 |
| 6 | Реальный onboarding и paywall Shotsy, MeAgain, Medisafe, Apple Medications на watchOS 27 и **GLP-1 и вода MyFitnessPal на Watch** | Deep dive без живого прохождения | Установить и пройти вручную, записать экран, посчитать шаги и тапы до первого лога | $0 (+ trial) |
| 7 | Работают ли каналы конкурентов: Meta ads MeAgain и Shotsy, SEO Pillo | Каналы первых 50–100 пользователей | Meta Ad Library (бесплатно) по названиям; Google по «Medisafe alternative»; в Search Ads — популярность ключей | $0 |
| 8 | Обсуждения в Reddit (ADHD, chronic illness, GLP-1, AppleWatch) | Reddit недоступен в этом исследовании | Вручную: r/AppleWatch, r/ADHD, r/Mounjaro, r/ChronicIllness, r/Ozempic — поиск «watch app», «medication reminder» | $0 |
| 9 | Регуляторные границы для GLP-1 функций в ЕС (MDR) и App Store guideline 1.4.1 | Риск блокировки или ответственности | Прочитать MDCG 2019-11 (qualification of software) и App Review Guidelines 1.4; не делать расчёт доз и кривых уровней | $0 |
| 10 | Спрос в Европе по странам на GLP-1 и Watch | Выбор стартового рынка | Сравнить оценки GLP-1 приложений по storefront (сейчас GB ≫ DE > FR > NL > PL); проверить ключевые слова в ASA для GB | $0 |

**Порядок на 30 дней (кратко):**
- **Неделя 1:** неизвестные 3, 6, 7, 8.
- **Неделя 2:** 10 интервью (ICP A + B), неизвестные 1 и 2.
- **Неделя 3:** landing с двумя позиционированиями и fake-door цен (4, 5), бюджет $0–100.
- **Неделя 4:** решение — GLP-1 Watch companion vs Watch-first pill tracker. Только после этого менять продукт.

---

## Приложение: ключевые источники (доступ 2026-10-09)

- iTunes Search / Lookup API: `https://itunes.apple.com/search?...&country=<cc>`, `https://itunes.apple.com/lookup?id=<ID>&country=<cc>`
- App Store RSS отзывы: `https://itunes.apple.com/us/rss/customerreviews/page=<n>/id=<ID>/sortby=mostrecent/json`
- Apple Watch Medications: https://support.apple.com/guide/watch/medications-apd3dd24d78b/watchos
- Apple Add and log medications: https://support.apple.com/en-ca/105064
- watchOS 27 preview: https://www.apple.com/watchos/watchos-preview/
- 9to5Mac watchOS 27 health (2026-07-06): https://9to5mac.com/2026/07/06/watchos-27-adds-three-new-health-upgrades-for-apple-watch/
- TidBITS iOS 16 Medications (2022-10-07): https://tidbits.com/2022/10/07/an-apple-a-day-ios-16-medications-feature-provides-alerts-logging-and-peace-of-mind/
- Macworld Medications reminders: https://www.macworld.com/article/2521302/how-to-adjust-medications-reminders-on-your-iphone-ipad-and-apple-watch.html
- AppGoblin: https://appgoblin.info/apps/<ID> (573916946, 1454778585, 653031147, 662170995, 816347839, 6742357512, 1502063556, 6499510249, 6744178534)
- ScreensDesign WaterMinder: https://screensdesign.com/showcase/water-tracker-by-waterminder
- Lazyweb Waterllama: https://www.lazyweb.com/flow/waterllama/onboarding
- Pillo о Medisafe (2026-02-19): https://pillo.care/blog/medisafe-no-longer-free-best-free-alternatives
- Medisafe $30M: https://mercomcapital.com/medisafe-raises-30-million-for-medication-management-app/
- Similarweb Medisafe: https://www.similarweb.com/company/medisafe.com
- smartpatient / MyTherapy: https://edit.smartpatient.eu/platform
- Hero pricing: https://herohealth.com/pricing ; https://support.herohealth.com/en/articles/8020001-hero-subscription-options
- WaterMinder Apple spotlight (2021-02-12): https://www.iphoneincanada.ca/2021/02/12/apple-spotlights-waterminder-app-developer/
- Pill Buddy 9to5Mac: https://9to5mac.com/?p=1004129 ; Indie Hackers: https://www.indiehackers.com/post/just-launched-a-cute-medicine-tracking-app-all-art-is-original-by-me-13e6a403f1
- Product Hunt (зеркало): https://hunted.space/product/brim-water-tracker ; https://hunted.space/product/hydrolog
- Shortcut для воды: https://ruk.ca/content/free-and-easy-logging-water-apple-health
