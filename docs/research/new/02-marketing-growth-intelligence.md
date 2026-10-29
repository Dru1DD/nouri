# Nuori — Task 2: Marketing & Growth Intelligence

**Дата исследования и доступа ко всем источникам: 2026-10-10**, если не указано иное.
Метки по Shared Research Brief: **[FACT]**, **[ESTIMATE]**, **[INFERENCE]**, **[UNKNOWN]**, **[HYPOTHESIS]**.

> Это исследование рынка, а не доказательство product-market fit. Данные конкурентов показывают, какие механики существуют. Работают ли они для Nuori, можно узнать только из собственных экспериментов.

---

## 0. Методология и ограничения

| Что | Как получено (2026-10-10) | Ограничения |
|---|---|---|
| Количество оценок, даты релиза и обновлений, наличие Watch-приложения, локализованные названия | iTunes Lookup API `itunes.apple.com/lookup?id=<id>&country=<cc>` по storefront US, GB, DE, FR, NL, PL | Количество оценок относится к одному storefront. Это **не** количество пользователей и не загрузки |
| Subtitle и список In-App Purchases | HTML-страницы `apps.apple.com/<cc>/app/id<id>` (US, DE, PL) | Apple показывает до 10 SKU без указания, какие актуальны, и без условий trial. **Paywall и onboarding ни одного конкурента не наблюдались напрямую**: приложения не устанавливались |
| Скриншоты App Store | Первые 3 скриншота US product page: Shotsy, WaterMinder, Cadence, Pill Buddy (просмотрены 2026-10-10) | Остальные скриншоты и другие storefront не просматривались |
| Выдача по локальным запросам | iTunes Search API с параметром `country` | Порядок выдачи API ≠ ранжирование в поиске App Store на устройстве. Это грубый прокси конкуренции |
| Платная реклама | Meta Ad Library (активные объявления), просмотр через браузер | Показывает факт показа объявления, текст и дату старта. Бюджет, охват (кроме EU-метки) и эффективность не видны. Google Ads Transparency Center и TikTok Ad Library **не проверялись**. Apple Ads не имеет публичной библиотеки |
| Reddit | www.reddit.com через браузер (old.reddit и JSON API требуют логина / заблокированы) | Выборка тредов по поисковым запросам, не систематическая |
| Product Hunt | producthunt.com и зеркало hunted.space | Снимки hunted.space могут быть устаревшими |
| SEO | sitemap.xml сайтов конкурентов, содержимое страниц | Позиции в Google и трафик **не измерялись**: нет доступа к Ahrefs/Semrush/Search Console. WebSearch в этом исследовании — не Google, поэтому порядок результатов не равен позиции в Google |
| Поисковый спрос (Google Trends, Keyword Planner, Apple Ads popularity) | Не получено | Все утверждения об объёме запросов — [UNKNOWN] |
| Sensor Tower, AppMagic, Similarweb | Не использовались (платные) | Оценок загрузок и выручки от этих сервисов в отчёте нет |

Предыдущая версия этого отчёта (`docs/research_old/02-marketing-growth-intelligence.md`, 2026-10-09) использовалась только как список гипотез для проверки. Все цифры ниже перепроверены 2026-10-10. Одна цитата из старой версии оказалась неточной: в ретроспективе Söka нет фразы «no real benefit». Ниже приведены точные цитаты.

---

## 1. Executive summary

1. **У большинства успешных health-приложений рост начался с узкого сообщества или с Apple, а не с Product Hunt.**
   - [FACT] Shotsy (GLP-1 tracker) начинался с «subreddit buzz» и spreadsheet threads. Бета-места заполнились «in minutes». По состоянию на декабрь 2025 основательница «hasn't spent a dollar on ads» ([RevenueCat, 2025-12-03](https://www.revenuecat.com/blog/growth/aja-beckett-shotsy-launched-podcast-2025)).
   - [FACT] Gentler Streak и Waterllama получили Apple-награды и featuring. [INFERENCE] Это заметная часть их роста, но доля не измерена.
   - [FACT] Hydration- и medication-запуски на Product Hunt, найденные в исследовании, набрали 0–3 голоса. Hydrabit (iPhone + Watch, 2026) — 0 points ([PH](https://www.producthunt.com/products/hydrabit)).

2. **Платная реклама появляется после product-market fit, а не до него.**
   - [FACT] У Shotsy сейчас ~29 активных объявлений в Meta (в просмотренной выборке старт — июль–сентябрь 2026) с текстом «1M+ downloads, 4.9 stars» и «Free 7-day trial».
   - [FACT] MeAgain использует partnership ads от имени GLP-1-креаторов (например, «theglp1rn with MeAgain App»): так оформлены 24 из 25 загруженных объявлений.
   - [FACT] WaterMinder с 2026-09-21 крутит десятки persona-объявлений: фитнес, предприниматели, родители, путешественники.
   - [INFERENCE] Для Nuori с 12 тестировщиками и без измеренного удержания платная реклама пока может только проверить формулировку сообщения, но не масштабировать рост.

3. **Самый воспроизводимый для соло-фаундера кейс — Cadence** (indie medication reminder, релиз 2026-02-19). Его стратегия состоит из трёх частей:
   - (а) позиционирование через боль «no subscription», включая subtitle «Pill reminder, no monthly fee» и локализованный DE-subtitle «Pillen-Erinnerung ohne Abo»;
   - (б) около 33 SEO-страниц, в том числе «Cadence vs Apple Health», «Medisafe alternative 2026», «Apple Watch medication reminders», «Medication reminders ADHD»;
   - (в) раздача промокодов в r/AppHookup: 67 очков, 88 комментариев, автор заявляет «700+ users» ([Reddit, 2026-05-23](https://www.reddit.com/r/AppHookup/comments/1tl6c1i/ios_cadence_medication_reminders_that_actually/)).

   [FACT] При этом у Cadence всего 12 оценок в US. [INFERENCE] Тактики воспроизводимы, но сами по себе не дают масштаба.

4. **Главное возражение аудитории — встроенный Apple Health Medications.**
   - [FACT] В r/AppleWatch на вопрос «app or widget for daily medication tracking» топ-ответ (45 очков) — встроенный Apple Health ([2026-10-06](https://www.reddit.com/r/AppleWatch/comments/1wz3edq/looking_for_an_app_or_widget_for_daily_medication/)).
   - [FACT] Под постом Cadence первый содержательный вопрос: «The native Health app medication reminder is pretty good… How is this different?».
   - [FACT] Apple Watch даёт Skipped / Taken / Remind Me in 10 Minutes и follow-up через 30 минут ([Apple Support 105064](https://support.apple.com/en-us/105064), опубликовано 2026-09-14).
   - [FACT] У Apple Medications на Watch (разработчик — Apple) есть complication: «Use the Medications app as a complication on your watch face to see your schedule or quickly open the app» ([App Store](https://apps.apple.com/us/app/medications/id1621166653)).
   - [INFERENCE] «Лекарства на циферблате» и «Taken / Skip с часов» — **не** отличия Nuori. Остающиеся кандидаты в отличия: вода и лекарства в **одном** взгляде или complication, логирование воды одним касанием с запястья, единый дневной статус «доза + вода». Все они — [HYPOTHESIS].
   - [INFERENCE] Любой message Nuori должен заранее отвечать на вопрос «чем это лучше Health?». Иначе ручной рекрутинг будет упираться в это возражение.

5. **Найден конкретный незакрытый сценарий: hydration + ADHD + complication.** [FACT] Пользователь r/AppleWatch с ADHD просит «a hydration app with a complication… at most one touch interactions». В качестве обходного пути ему советуют использовать Medications для воды ([2026-07-30](https://www.reddit.com/r/AppleWatch/comments/1vaykj7/hydration_reminder_app_with_minimal_interface/)). [HYPOTHESIS] Сегмент «ADHD: вода + лекарства + одно касание с запястья» — кандидат для ручного рекрутинга. Это один тред, а не измеренный спрос.

6. **Польский рынок — дешёвая ASO-ниша, но маленькая.**
   - [FACT] Ни одно из 15 проверенных приложений не имеет польского title или subtitle в PL storefront. В DE, FR и NL лидеры локализуют названия: «MyTherapy Tabletten Erinnerung», «Wasser trinken Erinnerung Lama», «Medicatie & Pil Herinnering».
   - [FACT] Количество оценок в PL на порядок ниже, чем в DE: MyTherapy PL 1 871 против DE 15 381; Waterllama 1 669 против 25 778.
   - [FACT] Польские medication-приложения существуют (APPteczka — 1 оценка, AppTeczka — 3), то есть польское название само по себе тяги не даёт (раздел 2.2a).
   - [INFERENCE] Польский — место для дешёвого эксперимента с ASO и локальной прессой. Строить на нём бизнес нельзя.

7. **У Nuori есть три проблемы маркетинговой инфраструктуры, которые блокируют любой канал.** Их нужно исправить до экспериментов.
   - [FACT] Сайт `dru1dd.github.io/nouri` ведёт с «water, calories and medication reminders» и «Log it in seconds», а не с гипотезой Watch-first meds + hydration.
   - [FACT] На сайте нет ни email-формы, ни ссылки на TestFlight. Конверсию из любого поста измерить нельзя.
   - [FACT] Имя «Nouri» в US App Store уже занято как минимум четырьмя приложениями, включая «Nouri: AI Calorie Tracker». В брифе используется «Nuori». Брендовый поиск будет вести к чужому калорийному трекеру.

8. **Рекомендация по двум первым каналам** (подробно в разделе 7):
   - **(1) Founder-led ручной рекрутинг** в узких сообществах (r/AppleWatch, ADHD-, GLP-1-сообщества, iOS-dev круг основателя) с честным ответом на возражение «vs Apple Health».
   - **(2) «Apple + ASO»-канал к публичному релизу:** локализованный product page, отдельно PL/DE, featuring nomination за 2+ недели, indie-press pitch.
   - SEO — одна-три страницы-инструмента по шаблону Cadence как долгосрочная ставка.
   - Product Hunt — позже, только как credibility-точка.

   Уверенность: средняя. Логика основана на кейсах, а не на данных Nuori.

**Что подтверждено:** каналы и сообщения конкурентов в Meta Ad Library на 2026-10-10; SEO-структура Cadence и WaterMinder; результаты PH для категории; Reddit-кейсы Cadence и Shotsy; локализация названий; коллизия имени Nouri.
**Что неизвестно:** эффективность любого канала конкурентов (CAC, конверсии, удержание); поисковый спрос; позиции в Google; Apple Ads.
**Уверенность:** средняя для «какие механики используются»; низкая для «какие работают лучше».
**Что делать:** за 30 дней исправить инфраструктуру (сообщение, захват, имя), получить 25–50 релевантных тестировщиков из 2–3 сегментов, измерить активацию и удержание отдельно по сегментам, проверить готовность платить через fake door. Функциональность не расширять (раздел 9).

---

## 2. Карта каналов конкурентов с evidence

### 2.1. Шорт-лист и масштаб (количество оценок App Store ≠ пользователи)

Источник: iTunes Lookup API, доступ 2026-10-10. Ссылка на каждое приложение: `https://apps.apple.com/us/app/id<ID>`.

| Приложение (ID) | Тип | US | GB | DE | FR | NL | PL | Watch-app | Релиз |
|---|---|---|---|---|---|---|---|---|---|
| Waterllama (1454778585) | Hydration, маскоты | 162 702 | 5 976 | 25 778 | 7 823 | 3 114 | 1 669 | да | 2019 |
| Plant Nanny (1424178757) | Hydration, игра | 106 490 | 10 378 | 8 091 | 2 193 | 3 078 | 1 867 | да | 2019 |
| Water Reminder VGFIT (1221965482) | Hydration | 78 802 | 16 058 | 5 601 | 9 336 | 8 267 | 2 347 | да | 2017 |
| WaterMinder (653031147) | Hydration | 35 117 | 2 823 | 5 555 | 1 457 | 1 166 | 917 | да | 2013 |
| HidrateSpark (1056269374) | Hydration + бутылка | 19 803 | 1 099 | 856 | 409 | 311 | 226 | да | 2015 |
| Medisafe (573916946) | Medication, B2B pharma | 101 447 | 13 460 | 3 675 | 4 904 | 3 210 | 386 | да | 2012 |
| MyTherapy (662170995) | Medication, B2B pharma (DE) | 8 556 | 3 205 | 15 381 | 4 039 | 2 364 | 1 871 | нет | 2016 |
| Pill Reminder – All in One (816347839) | Medication, indie | 27 927 | 2 102 | 518 | 379 | 1 151 | 29 | нет | 2014 |
| Max – Pill reminder (1502063556) | Medication, маскот | 9 802 | 780 | 803 | 17 | 27 | 19 | нет | 2020 |
| Pill Buddy (6742357512) | Medication, indie, маскот | 1 788 | 93 | 4 | 4 | 3 | 8 | нет | 2025-05 |
| Cadence (6758649306) | Medication, indie | 12 | 3 | 3 | 2 | 0 | 0 | да | 2026-02 |
| WatchRipple (6747939802) | Water + meds на Watch, indie | 0 | 0 | 0 | 0 | 0 | 0 | да | 2025-10, без обновлений |
| Shotsy (6499510249) | GLP-1 companion | 33 276 | 4 211 | 1 613 | 608 | 273 | 169 | нет | 2024-05 |
| MeAgain (6744178534) | GLP-1 companion | 36 543 | 185 | 29 | 20 | 23 | 9 | нет | 2025-04 |
| Gentler Streak (1576857102) | Watch health utility, indie | 8 825 | 728 | 1 122 | 348 | 468 | 277 | да | 2021 |
| mediteo (DE) | Medication, локальный | — | — | 20 294 | — | — | — | — | — |
| Apple Health Medications | Встроенный | — | — | — | — | — | — | да | watchOS 9 |

[INFERENCE] Из таблицы следует три вывода:
- Ни одно приложение, объединяющее воду и лекарства на Watch (WatchRipple), не показывает публичной тяги.
- Самые быстрорастущие новички последних двух лет (Shotsy, MeAgain, Pill Buddy) — iPhone-only. Их рост объясняется сегментом и эмоциональной механикой, а не Watch.
- MeAgain почти не существует вне US: GB 185, DE 29. Это говорит о US-центричной дистрибуции (paid + creators), а не о глобальном ASO.

### 2.2. Локализация названий и subtitle (ASO), DE и PL

| Приложение | DE title / subtitle | PL title / subtitle |
|---|---|---|
| Waterllama | Wasser trinken Erinnerung Lama / Trink app drink water reminder | Water tracker Waterllama / Water reminder vitality app |
| WaterMinder | WaterMinder® ∙ Water Tracker / Wasser Trinken, Erinnerung App | Water Tracker by WaterMinder / Drink Reminder Daily Hydration |
| VGFIT | Wassertracker: Trinkerinnerung / Wassererinnerung - Trinkwasser | Water Reminder - Daily Tracker / #1 Water Tracker |
| Medisafe | Arznei & Medikamente Alarm / Arzneimittel korrekt einnehmen | Medisafe Pill Reminder / Medication and Tablet Tracker |
| MyTherapy | MyTherapy Tabletten Erinnerung / Pillen, Gesundheit & Wecker | Pill Reminder MyTherapy / Medication & Health Tracker |
| Cadence | Tabletten-Erinnerung: Cadence / Pillen-Erinnerung ohne Abo | Medication Reminder: Cadence / Pill reminder, no monthly fee |
| Shotsy | Mounjaro Tracker - Shotsy / Für GLP-1, Ozempic, Wegovy | GLP1 Tracker - Shotsy / GLP-1 Mounjaro, Ozempic jabs |

[FACT] В DE локализуют почти все лидеры. В PL ни одно из 15 приложений не использует польские слова в title или subtitle. FR и NL названия тоже локализованы: «MyTherapy Rappel de Médicament», «Medicijn en Pil Herinnering».

[FACT] Выдача iTunes Search API в PL по «przypomnienie o lekach»: MyTherapy (1 871), PillBox (229), системный Reminders (22 859), Tablets App (103), дальше приложения с 0–1 оценкой. По «picie wody»: Watercat (2 586), Water Time (3 867), Wachanga (6 022), My Water (1 759), **Waterful от польской компании Listonic sp. z o.o.** (1 843).
- [INFERENCE, слабая] Польская выдача по лекарствам тонкая. Нативное польское название имеет шанс подняться в локальной выдаче. Проверить это можно только после публичного релиза.
- [UNKNOWN] Объём польских запросов.

### 2.2a. Европа по странам (локальные игроки и выдача)

Источник: iTunes Search API с параметром `country`, локальные запросы, 2026-10-10. Числа — количество оценок в storefront этой страны.

| Страна | Запросы | Локальные / нишевые игроки | Особенности | Вывод для Nuori [INFERENCE] |
|---|---|---|---|---|
| **PL** | «przypomnienie o lekach», «leki przypomnienie», «picie wody» | Waterful (Listonic sp. z o.o., польская компания, 1 843); «Drink Water Reminder - Tracker App» (id1341658567, на странице — английский title, 414); APPteczka (Rafal Mirowski, 1); AppTeczka (ONEPHARMA, 3) | Medication-выдача: MyTherapy 1 871, дальше ≤229. Польская tech-пресса пишет о польских приложениях ([Spider's Web о Waterful, 2021](https://spidersweb.pl/2021/02/waterful-aplikacja-picie-wody.html)) | Локальные польские приложения есть, но с единицами оценок: польское название само по себе не даёт тяги. Окно для ASO есть, но рынок маленький |
| **DE** | «Tabletten Erinnerung», «Wasser trinken» | mediteo (20 294), MyTherapy (15 381), TOM – Tabletten Erinnerung (Innovation 6 GmbH, 419); Gerolsteiner TrinkCheck (4 095) — приложение бренда минеральной воды | Лидеры локализуют title; MyTherapy крутит GLP-1-рекламу в DE [FACT] | Самый конкурентный из EU-рынков: бесплатные локальные лидеры и paid. Не стартовый рынок |
| **FR** | «rappel medicament» | Peach : rappel de médicaments (1 325; по App Store — команда фармацевтов, пациентов и инженеров), Medicaments • Medico (Pierre Boudoin, 2 390), TOM (391) | MyTherapy (4 039) и Medisafe (4 904) локализованы | Есть французские indie-игроки с тысячами оценок; языка FR у Nuori нет |
| **NL** | «medicijn herinnering» | MedApp Nederland B.V. (1 296) | MyTherapy, Medisafe, Pill Reminder AiO локализованы на NL | Маленький рынок с локальным игроком; языка NL у Nuori нет |
| **GB** | «medication reminder» | — (лидеры US) | Pill Buddy 93 против 1 788 в US | Англоязычный, без перевода; кандидат №2 после US для EN-сообщений |

**Что подтверждено:** состав выдачи API по странам; наличие локальных игроков.
**Что неизвестно:** реальное ранжирование на устройствах; объём запросов в каждой стране.
**Уверенность:** средняя в составе игроков; низкая в оценке «окна» в PL.
**Что делать основателю:** PL — дешёвый ASO-эксперимент (E9), не стартовый рынок. DE, FR, NL — не трогать до проверки ценности на EN-аудитории.

### 2.3. Матрица каналов: присутствие против доказательства эффективности

Легенда: **E** — есть свидетельство результата (цифры, отзывы, публичный кейс); **P** — подтверждено присутствие или активность канала, эффективность неизвестна; **—** — не найдено; **?** — не проверялось.

| Канал | Shotsy | MeAgain | WaterMinder | Waterllama | Medisafe / MyTherapy | Pill Buddy | Cadence | Gentler Streak |
|---|---|---|---|---|---|---|---|---|
| 1. Product Hunt | — | — | — | P (бейдж PH на сайте) | — | — | — | ? |
| 2. SEO / контент | ? | ? | **P+** (532 URL, программный SEO) | — (контента нет) | Medisafe: B2B-контент для pharma | — | **P+** (~33 статьи, «vs»-страницы) | ? |
| 3. ASO и локализация | **P** (основательница называет ASO фокусом; результат не измерен) | — (только EN) | P (24 языка) | P (22 языка, локальные title) | P (локальные title в DE/FR/NL) | — (1 язык) | P (7 языков, DE-subtitle) | P (10 языков) |
| 4. Соцсети фаундера | E (подкасты, «I wanted to support her») | ? | ? | ? | — | P (бывший Duolingo PM в прессе) | P (Reddit-аккаунт автора) | ? |
| 5. TikTok / Reels / креаторы | ? | **P+** (partnership ads с креаторами) | ? | P (TikTok в футере; найм «UGC at scale») | — | ? | — | ? |
| 6. Reddit / сообщества | **E** (subreddit buzz, скриншоты графиков) | P (реклама от «glp1_newbies_group») | — | P (рекомендации пользователей в r/AppleWatch) | — | ? | **E** (r/AppHookup 67 / 88) | ? |
| 7. Influencer / affiliate | — | **P+** | ? | P (найм на influencer partnerships) | — | — | — | ? |
| 8. PR / медиа / Apple | P (RevenueCat, подкасты, Silicon Florist) | ? | **P+** (MacStories sponsor, Apple Spotlight, Editors' Choice) | **E** (App Store Award 2022, ADA finalist) | P | **P** (9to5Mac Indie Spotlight) | — | **E** (Watch App of the Year 2022, ADA 2024) |
| 9. Email / waitlist / referral | P (бета-лист) | ? | — (email-формы нет) | — (email-формы нет) | — | — | — | ? |
| 10. Paid (Meta) | **P+** (~29 активных) | **P+** (~420 по фразе) | **P+** (≥26 активных) | — (активных по ключу не найдено, US) | MyTherapy **P+** (~61 в DE); Medisafe — вероятно, в рекламе pharma-бренда [INFERENCE] | P (1 активное) | — | — (активных по ключу не найдено) |
| 10. Apple Ads | ? | ? | ? | P (найм «Apple Search Ads — full ownership») | ? | ? | ? | ? |

Дополнительные приложения (те же обозначения; проверены Meta Ad Library и App Store, остальное — не исследовалось глубоко):

| Канал | Plant Nanny | HidrateSpark | Max – Pill reminder | Pill Reminder – All in One | Peach (FR) |
|---|---|---|---|---|---|
| ASO и локализация | P (5 языков, EN title везде) | P (18 языков, NL title) | P (DE: «Max - Pillen Erinnerung») | P (DE / FR / NL title) | P (FR) |
| Монетизация (SKU US) | Подписка $3.99–7.99 в месяц, $69.99 в год + игровая валюта | PREMIUM $1.99 / $14.99 + бутылка (hardware) | IAP на странице не найдено | $2.99 one-time | ? |
| Paid (Meta) | — (активных по ключу не найдено, US) | ? | ? | ? | ? |
| Остальные каналы | ? | Hardware-ритейл [INFERENCE] | ? | ? | ? |

Ключевые источники матрицы:
- Meta Ad Library, доступ 2026-10-10:
  - [WaterMinder US](https://www.facebook.com/ads/library/?active_status=active&ad_type=all&country=US&q=WaterMinder&search_type=keyword_unordered&media_type=all)
  - [Shotsy US](https://www.facebook.com/ads/library/?active_status=active&ad_type=all&country=US&q=Shotsy&search_type=keyword_unordered&media_type=all)
  - [MeAgain US](https://www.facebook.com/ads/library/?active_status=active&ad_type=all&country=US&q=%22MeAgain%22&search_type=keyword_exact_phrase&media_type=all)
  - [MyTherapy DE](https://www.facebook.com/ads/library/?active_status=active&ad_type=all&country=DE&q=%22MyTherapy%22&search_type=keyword_exact_phrase&media_type=all)
  - [Pill Buddy US](https://www.facebook.com/ads/library/?active_status=active&ad_type=all&country=US&q=%22Pill%20Buddy%22&search_type=keyword_exact_phrase&media_type=all)
- Вакансия Llama Luna на [Djinni](https://djinni.co/jobs/835286-head-of-acquisition-and-growth-ios-apps/) (опубликована 3 июля, обновлена 5 октября; год не указан).
- [Sitemap Cadence](https://www.cadencehealth.app/sitemap.xml), [sitemap WaterMinder](https://waterminder.com/sitemap.xml).

Важные оговорки:
- [FACT] Количество результатов в Meta Ad Library — это число объявлений, а не бюджет. Длительность показа и количество версий — слабые косвенные сигналы того, что объявление окупается. Это [INFERENCE], а не доказательство.
- [FACT] Поиск по ключу «Medisafe» в US возвращает 2 активных объявления pharma-бренда OGSIVEO (nirogacestat). Их текст скрыт за возрастной проверкой, поэтому само упоминание Medisafe не видно. [INFERENCE] Поиск по ключу находит объявление, где слово встречается в тексте или ссылке, поэтому вероятно, что реклама упоминает Medisafe. Это согласуется с B2B-моделью Medisafe «solutions/for-pharma» ([medisafe.com](https://medisafe.com/solutions/for-pharma)): pharma продвигает приложение среди своих пациентов. Для Nuori это не воспроизводимо.
- [UNKNOWN] Google Ads Transparency Center и TikTok Ad Library не проверялись. Отсутствие отметок в строке 10 по Google и TikTok не означает отсутствия рекламы.

### 2.4. Собственные активы Nuori (аудит, 2026-10-10)

| Актив | Состояние | Проблема для роста |
|---|---|---|
| Сайт [dru1dd.github.io/nouri](https://dru1dd.github.io/nouri/) | H1 «Log it in seconds.», title «Nouri — Water, calories and medication reminders»; EN / RU / UK / PL | Сообщение не совпадает с гипотезой «Watch-first meds + hydration»: калории идут вторым пунктом. Нет ответа на «vs Apple Health» |
| Захват интереса | Нет email-формы, нет ссылки на TestFlight, нет аналитики | Ни один пост или эксперимент нельзя измерить в конверсиях |
| Имя | Сайт и репозиторий — «Nouri», бриф — «Nuori» | [FACT] В US App Store уже есть «Nouri: AI Calorie Tracker» (Jacks Labs LLC), «Nouri: Personalized Nutrition», «Hey Nouri», «Looksmaxxing & Glow Up・Nouri». Брендовый поиск и упоминания в соцсетях будут конфликтовать |
| Приватность | «No account, no ads, no tracking» | Сильный аргумент, но Cadence и GoodPill используют тот же («No account. No cloud.»). Это не уникальное отличие |
| Локализация | EN / RU / UK / PL на сайте и в приложении | Польский — реальное преимущество для PL storefront (см. 2.2). DE / FR / NL нет |

**Что подтверждено:** присутствие и сообщения каналов, перечисленные в матрице; аудит активов Nuori.
**Что неизвестно:** эффективность каналов, бюджеты, Google и TikTok реклама, Apple Ads по конкурентам, реальные позиции в поиске.
**Уверенность:** высокая — в фактах присутствия; низкая — в выводах об эффективности (публичных результатов почти нет).
**Что делать основателю:** до любых внешних экспериментов привести в порядок три вещи — сообщение на сайте, захват интереса (email и TestFlight), решение по имени (раздел 9, неделя 1).

---

## 3. Разбор 8 наиболее полезных маркетинговых примеров

### 3.1. Shotsy — сообщество → ASO → paid после PMF (самый поучительный кейс)

- **Факты:**
  - [FACT] Седьмое приложение основательницы Aja Beckett. Создано для себя во время собственного GLP-1-лечения.
  - [FACT] До запуска: «spreadsheet threads, subreddit buzz», бета «filled up in minutes». После запуска пользователи сами делились скриншотами графиков. Основательница «didn't set out to build a social loop». Фокус — ASO, без рекламы на тот момент: «She hasn't spent a dollar on ads». Источник: [RevenueCat, 2025-12-03](https://www.revenuecat.com/blog/growth/aja-beckett-shotsy-launched-podcast-2025).
  - [FACT] В феврале 2025 сообщалось о 100 000+ загрузок, run-rate $1M и seed $2.25M ([Silicon Florist, 2025-02-20](https://siliconflorist.com/2025/02/20/shotsy-lands-2-million-for-weight-loss-shot-tracking-app/)). Цифры заявлены компанией, независимо не проверены.
  - [FACT] Сейчас ~29 активных Meta-объявлений; в 5 просмотренных образцах старт 2026-07-27 … 2026-09-29, формат — видео с текстом «The app people recommend to anyone tracking their GLP-1 journey. 1M+ downloads, 4.9 stars, and it actually gets it.» и CTA «Download», «Free 7-day trial».
  - [FACT] В r/Zepbound пользователь пишет: «I got the paid version simply because I really admire her» — конверсия через историю основательницы ([2026-08-09](https://www.reddit.com/r/Zepbound/comments/1vk1gt7/if_you_use_an_app_like_shotsy_what_metrics_do_you/)).
- **[INFERENCE] Механика:** (1) фаундер — член сообщества с острой и регулярной проблемой; (2) продукт производит контент, которым хочется делиться (графики уровня препарата); (3) ASO по брендам препаратов (subtitle «GLP1 Shot - Zepbound, Wegovy»; DE-title «Mounjaro Tracker - Shotsy»); (4) только после этого — деньги и paid.
- **Что воспроизводимо для Nuori:**
  - работа фаундера внутри сообщества;
  - shareable-артефакт (например, недельная карточка «water + doses»);
  - ASO по языку сообщества.
- **Что не воспроизводимо:** сама категория была новой и взрывной, и в ней фаундер — пациент.
- **Риск [INFERENCE]:** торговые марки препаратов в метаданных могут нарушать App Store Review Guidelines (раздел 2.3.7 о чужих торговых марках в метаданных) и правила рекламы рецептурных препаратов в ЕС. Shotsy это делает, но это не доказательство безопасности.

### 3.2. MeAgain — creator-led paid (масштаб без органики в Европе)

- [FACT] ~420 объявлений по точной фразе «MeAgain» в US. В загруженной выборке (25 из ~420) объявления стартовали 2026-09-02, и 24 из 25 — partnership ads от имени креаторов и групп: «theglp1rn with MeAgain App», «glp1_newbies_group with MeAgain App», «losing_with_michele with MeAgain App».
- [FACT] Тексты от первого лица:
  - «Two months into my GLP-1 I couldn't answer three basic questions about my own week…»;
  - «Nobody tells you what GLP-1 shot day is supposed to look like… Now the app knows when my dose is due, so the checklist is just there on the day».
- [FACT] Оценки: US 36 543 против GB 185 и DE 29.
- [INFERENCE] Рост MeAgain — это US-paid через креаторов. Механика дорогая и требует бюджета и команды. Для Nuori полезен **формат сообщения**: история «shot day checklist» от первого лица. Сам канал не подходит.

### 3.3. Cadence — indie playbook «no subscription + SEO + Reddit-промокоды»

- [FACT] Релиз 2026-02-19. Subtitle «Pill reminder, no monthly fee». DE: «Pillen-Erinnerung ohne Abo». Pro — $9.99 one-time. Watch-приложение есть.
- [FACT] SEO-структура ([sitemap](https://www.cadencehealth.app/sitemap.xml)) — около 33 статей:
  - сравнения: `/blog/cadence-vs-apple-health/`, `-vs-medisafe/`, `-vs-mytherapy/`, `-vs-everydose/`, `-vs-bearable/`, `-vs-round-health/`, `-vs-careclinic/`;
  - перехват боли: `/blog/medisafe-alternative-2026/`, `/blog/medication-apps-no-subscription/`;
  - сценарии: `/blog/apple-watch-medication-reminders/`, `/blog/medication-reminders-adhd/`, `/blog/track-medications-elderly-parents/`;
  - справочные: `/blog/what-does-prn-mean/`, `/blog/missed-a-dose-what-to-do/`.
- [FACT] Страница «Cadence vs Apple Health Medications (2026)» от 2026-06-01 честно признаёт, что Apple Health — «a solid, free reminder with a real adherence history… for one or two simple medications it may be all you need». Там же сказано, что логирование с Apple Watch «are no longer points of difference». Отличия Cadence: dose windows, учёт запасов, корреляция с метриками Health, PDF для врача ([страница](https://www.cadencehealth.app/blog/cadence-vs-apple-health/)).
- [FACT] Пост в r/AppHookup от 2026-05-23: «[iOS] Cadence: medication reminders that actually work [Pro ($9.99) → free with code]». 67 очков, 88 комментариев. В теле: «App currently has 700+ users». Комментарии: запросы функций («every other day»), «left a review on app store», возражение «How is this different?» от native Health.
- [FACT] При этом у Cadence 12 оценок в US.
- [INFERENCE] Связка из трёх тактик воспроизводима одним человеком. Видимый результат — сотни пользователей, но не тысячи. Честная «vs Apple Health»-страница — лучший найденный шаблон ответа на главное возражение категории.

### 3.4. WaterMinder — зрелый бренд: программный SEO + PR + persona-paid

- [FACT] Сайт: H1 «The Water Tracker App That Builds A Daily Habit», CTA «Build My Hydration Habit». Social proof — «10M+ Downloads worldwide», «4.7», «App Store Editors' Choice», «Featured as App of the Day by Apple». Press: MacStories, 9to5Mac, Healthline, Lifehacker. Email-формы нет ([waterminder.com](https://waterminder.com)).
- [FACT] Sitemap — 532 URL: articles (167), water-content (101), dehydration (82), calculator (63), compare (60), guides (58).
  - Калькуляторы по весу и условиям: `water-intake-for-100-lbs.html`, `hydration-hot-weather.html`, `water-intake-diabetes.html`.
  - Большинство URL имеют lastmod 2026-06-24. [INFERENCE] Похоже на массовую генерацию или обновление.
- [FACT] Спонсорство MacStories ([MacStories sponsor post](https://www.macstories.net/sponsored/waterminder-stay-hydrated-all-day-every-day-sponsor/), дата не указана). Apple Developer Spotlight ([iPhone in Canada, 2021-02-12](https://www.iphoneincanada.ca/2021/02/12/apple-spotlights-waterminder-app-developer/)).
- [FACT] Meta, старт 2026-09-21, ≥26 активных объявлений в US. Тексты сегментированы по персонам:
  - «You already make hundreds of decisions every day. Don't waste energy remembering water. … Running your business»;
  - «As a mom/dad you remember everyone else's needs…»;
  - «Travel changes everything… You remembered your passport… But did you remember your water?»;
  - фитнес-версия.
- [INFERENCE] Программный SEO и тестирование персон в рекламе — механики компании с 13-летней историей. Для Nuori из этого реально скопировать **один калькулятор** и **подход «сообщение под персону»** для органических постов.

### 3.5. Pill Buddy — бывший Duolingo PM: геймификация + indie-пресса + маленький paid

- [FACT] Релиз 2025-05-21. iPhone-only, 1 язык. US 1 788 оценок, почти ноль вне US. Supporter-подписка: $4.99 в месяц или $35.90 в год (US).
- [FACT] 9to5Mac Indie App Spotlight от 2025-06-07: «Designed by a former Duolingo Product Manager». Маскот, звонок-напоминание, streaks ([9to5Mac](https://9to5mac.com/?p=1004129)).
- [FACT] Одно активное Meta-объявление с 2026-02-28: «Forgot to take your meds again? This app can help!», CTA «Install now».
- [INFERENCE] Сочетание «узнаваемая история фаундера + эмоциональный маскот + узкая indie-пресса» дало заметный для indie результат в US. Watch не участвовал. Для Nuori воспроизводимо: питч в 9to5Mac Indie App Spotlight (по данным неподтверждённого зеркала X, в теме письма нужно «indie», плюс скриншоты и press kit).

### 3.6. MyTherapy (DE) — pharma-B2B и GLP-1 paid в Германии

- [FACT] ~61 объявление в DE:
  - потребительское: «Verlässliche Erinnerungen für deine Abnehm-Präparate. Jetzt MyTherapy App downloaden.» — CTA «Install now», ведёт в Google Play, старт 2026-09-14;
  - B2B: «Reach your patients when it counts most… engage 25M+ patients via MyTherapy & Redcare»;
  - disease awareness: «Acne Inversa…».
- [INFERENCE] В Германии крупнейший локальный medication-игрок уже покупает GLP-1-аудиторию («Abnehm-Präparate»). Значит, GLP-1 в DE — не пустая ниша. Paid-конкуренция там сильнее, чем в органике.

### 3.7. Waterllama — дизайн → Apple → команда роста

- [FACT] Apple App Store Award 2022 (Cultural Impact) ([Tom's Guide](https://www.tomsguide.com/news/apples-favorite-iphone-and-ipad-apps-of-the-year-revealed-all-the-2022-winners)). Сайт: «Water tracker app», «100K+ ratings», бейджи Apple Design Award / App of the Day / Product Hunt / Vogue, press kit, ссылки на TikTok и Instagram, email-формы нет.
- [FACT] Вакансия Llama Luna: «ASO and Apple Search Ads — full ownership», «Influencer partnerships», «Organic UGC at scale — TikTok, Instagram, X, Lemon8 across multiple accounts», «8M+ combined downloads» (заявление компании).
- [FACT] Активных Meta-объявлений по ключу «Waterllama» в US на 2026-10-10 не найдено (Ad Library показывает только активные объявления, неактивные не проверялись).
- [INFERENCE] Waterllama растёт через Apple, ASO, Apple Ads и UGC. На момент проверки Meta, судя по всему, не используется. Для соло-фаундера воспроизводимы featuring nomination и сильный product page. UGC «across multiple accounts» требует команды.

### 3.8. Что на самом деле дают запуски у соло-разработчиков

- **Söka** ([ретроспектива, 2023-06-04](https://roddymunro.substack.com/p/soka-launch-retrospective)), indie iOS:
  - [FACT] «just over 270 beta testers», «Many of them opened the app just once and then never opened it again».
  - [FACT] Product Hunt: «my comments were filled with spam by new accounts», «there was no indication that the number of downloads I received increased by having Söka on Product Hunt».
  - [FACT] Соцсети: «much better engagement from ~400 followers on Mastodon than I ever did with ~3000 followers on Twitter».
  - [FACT] Итог: «over 300 downloads in the first two days» без затрат. Пресса — «not even a paragraph» (запуск перед WWDC).
- **Product Hunt в категории:**
  - [FACT] Hydrabit (iPhone + Apple Watch, «One-time purchase», 2026, мейкер Simo Ahava) — 0 points, 1 follower ([PH](https://www.producthunt.com/products/hydrabit)).
  - [FACT] PillChime («The pill reminder your parents won't swipe away») — 3 upvotes, #121 ([hunted.space](https://hunted.space/dashboard/pillchime)).
  - [FACT] GoodPill («Free medication reminders. No account. No cloud.») — 0 upvotes, #50, не featured ([hunted.space](https://hunted.space/dashboard/goodpill)).
- **Бесплатный indie water tracker в r/iosapps** ([2026-08-11](https://www.reddit.com/r/iosapps/comments/1vlj9tt/big_update_for_free_water_tracker_app_try_it_and/)):
  - [FACT] 23 очка, 65 комментариев.
  - [FACT] Автор: «out of more than a thousand users, 11 people have looked into this section and donated a total of $18».
  - [INFERENCE] Модель «бесплатно + донаты» в hydration почти не монетизируется. Сообщение «it's actually free» привлекает пользователей, но не деньги.

### 3.9. Скриншоты App Store (первые три, US, просмотрены 2026-10-10)

| Приложение | Скриншот 1 | Скриншот 2 | Скриншот 3 | Что из этого следует [INFERENCE] |
|---|---|---|---|---|
| Shotsy | «GLP-1 Tracker» + карточка «It's shot day!» + график «Estimated Medication Levels» | «Works with any GLP1»: Tirzepatide, Wegovy Pill, Zepbound, Semaglutide, Ozempic, Retatrutide, «…and 30+ more» | «Track results by dose» + «Over 1 Million Downloads», «4.9» | Сразу называет сегмент и препараты; социальное доказательство на третьем экране |
| WaterMinder | «Receive reminders on Apple Watch and iPhone»: часы и телефон с уведомлением «We know you're busy, but it's time to drink some water» | «Track your water intake With a simple tap» + «Editors' Choice» | «See water intake history Compared to goal» | **Первый экран — Watch.** Watch-first подача в hydration уже занята лидером |
| Cadence | «medication reminders simplified» — iPhone с «Lisinopril is overdue» | «spot the patterns — Cadence connects the dots» (insights) | iPhone-экраны | Watch-скриншот — последний (6-й). Продаёт insights, а не запястье |
| Pill Buddy | «A fun way to track your meds» — маскот | «Reminders & phone calls you won't ignore»: «I Will Haunt Your Phone», «You Can't Ghost Me!» | «Playful widgets to stay on track»: «Meds due!» | Эмоция и юмор вместо функций; обещание «не проигнорируешь» |

[INFERENCE] Совет «первый скриншот — запястье» для Nuori имеет опору (WaterMinder так делает), но это значит, что Watch-first визуал сам по себе не выделит Nuori среди hydration-приложений. Отличие должно быть в содержимом кадра: **доза и вода в одном взгляде**. В medication-категории Watch на первых экранах не показывает ни Cadence, ни Pill Buddy, ни Shotsy. Там это может быть заметнее [HYPOTHESIS].

**Сводный вывод по разделу:**
- **Что подтверждено:** механики и тексты восьми кейсов; слабые результаты PH в категории; масштаб Reddit-промо (сотни пользователей).
- **Что неизвестно:** вклад каждого канала в рост Shotsy, Pill Buddy и Cadence; удержание; CAC.
- **Уверенность:** средняя. Кейсы согласуются между собой, но их мало, и почти все цифры заявлены самими компаниями.
- **Что делать основателю:** копировать механики Shotsy (фаундер внутри сообщества и shareable-артефакт) и Cadence (честное «vs Apple Health», Reddit-промо, SEO-сравнения). Не копировать MeAgain, WaterMinder-paid и программный SEO.

---

## 4. Воронки от discovery до оплаты

Paywall и onboarding конкурентов **не наблюдались напрямую**. Всё, что относится к этапам после установки, взято из описаний, рекламы, отзывов и материалов компаний. Публичных конверсий нет ни у одного конкурента: [UNKNOWN].

### 4.1. Shotsy

| Этап | Что видит пользователь / обещание | Возражение, которое снимают | CTA | Проверяемо? |
|---|---|---|---|---|
| Discovery | Reddit-обсуждения и скриншоты графиков от других пациентов; сейчас — Meta-видео | «Это для таких, как я?» — да, рекомендует сообщество | — / «Download» | Reddit и Meta — да |
| Message | «The app people recommend to anyone tracking their GLP-1 journey. 1M+ downloads, 4.9 stars» | Доверие: social proof, «Led by real medical experts» | «Start tracking your GLP-1 today!» | Да (Meta) |
| App Store | Subtitle «GLP1 Shot - Zepbound, Wegovy»; DE-title «Mounjaro Tracker» | Находимость по названию препарата | Get | Да |
| Onboarding / Aha | [UNKNOWN] напрямую. Пользователи ценят расчётный уровень препарата и места уколов (r/Zepbound) | — | — | Нет |
| Paywall | «All the important stuff is free… free forever» (RevenueCat); реклама: «Free 7-day trial»; SKU $9.99–19.99 в месяц, $39.99–59.99 в год | «Не заставят ли платить?» — ядро бесплатно | [UNKNOWN] | SKU — да, экран — нет |
| Retention | Еженедельный цикл уколов — встроенная частота возврата [INFERENCE] | — | — | [UNKNOWN] |

### 4.2. Cadence

| Этап | Что видит пользователь | Возражение | CTA | Проверяемо? |
|---|---|---|---|---|
| Discovery | Reddit r/AppHookup с промокодом; SEO «Medisafe alternative», «vs Apple Health» | «Ещё одна подписка?» | «free with code» | Да |
| Landing | H1 «Medication reminders that actually work»; «Cadence Pro is a one-time purchase of $9.99» | Подписочная усталость; приватность («No account. No third-party servers.») | «Download Cadence on the App Store» | Да |
| App Store | Subtitle «Pill reminder, no monthly fee» | То же | Get | Да |
| Aha | Сканирование этикетки рецепта; напоминание, пробивающее Focus | «Долго вводить лекарства» | — | Нет (заявлено в посте) |
| Paywall | Free: «Unlimited medications»; Pro $9.99 one-time — insights, Health-метрики, PDF | — | [UNKNOWN] | Цена — да |
| Retention | Follow-up, smart timing | — | — | [UNKNOWN] |

### 4.3. WaterMinder

| Этап | Что видит пользователь | Возражение | CTA | Проверяемо? |
|---|---|---|---|---|
| Discovery | SEO-калькуляторы «how much water should I drink»; Meta-persona-объявления; пресса и Apple | «Я забываю» / «я занят» | «Learn More», «Start Your Healthy Routine» | Да |
| Landing | «Drink More Water Without Having To Think About It»; «10M+», «Editors' Choice»; секция «Hydration That Lives On Your Wrist» | Доверие, Watch-удобство | «Build My Hydration Habit» | Да |
| App Store | Subtitle «Drink More, Hydration Reminder»; описание: «Try every feature free for 7 days» [FACT, проверено 2026-10-10] | — | Get | Да |
| Paywall | SKU: Monthly $2.99; Yearly $14.99–29.99; Yearly Offer $7.49; tip jar | Цена — через «Yearly Offer» [INFERENCE] | [UNKNOWN] | SKU — да |
| Retention | Reminders, complications, achievements | — | — | [UNKNOWN] |

### 4.4. Pill Buddy

| Этап | Что видит пользователь | Возражение | CTA |
|---|---|---|---|
| Discovery | 9to5Mac Indie Spotlight; Meta: «Forgot to take your meds again? This app can help!» | Стыд и забывчивость | «Install now» |
| App Store | Title «Pill Buddy: Cute Med Reminders»; subtitle «Track medicine, supplements» | «Скучно» — снято маскотом | Get |
| Aha | Маскот радуется или грустит; streak; звонок-напоминание (9to5Mac) | «Я игнорирую пуши» — снято звонком | — |
| Paywall | «Supporter»: $4.99 в месяц / $35.90 в год. Формулировка «supporter» [INFERENCE] смягчает отказ платить | — | [UNKNOWN] |

### 4.5. MyTherapy (DE)

Discovery идёт через Meta-видео («Abnehm-Präparate») и через pharma и аптеку Redcare (B2B). Магазин — локализованный title «MyTherapy Tabletten Erinnerung». Paywall: «Ad-free Subscription» $0.99–9.99 и «Plus — Lifetime» $49.99 (US). Основная монетизация — B2B [INFERENCE по рекламе «engage 25M+ patients»]. Для Nuori эта воронка не воспроизводима, но объясняет, почему в DE бесплатные лидеры сильны.

### 4.6. Метрики, которые Nuori должен измерять сам (вместо чужих конверсий)

Нельзя подставлять «средние по индустрии» конверсии: рынки, цены и каналы несопоставимы. Вместо этого нужна собственная минимальная воронка.

| Этап | Метрика | Как измерить без SDK аналитики (приватность) |
|---|---|---|
| Discovery → visit | Клики по ссылке из каждого поста | UTM / разные короткие ссылки на каждый канал; счётчик GitHub Pages недоступен, поэтому нужна приватная аналитика вроде Plausible или GoatCounter [ESTIMATE: бесплатный или ~$9 в месяц тариф — проверить на сайтах сервисов] |
| Visit → sign-up | % оставивших email или нажавших «Join TestFlight» | Форма (Tally / Google Forms) с полем «source» и полем сегмента |
| Sign-up → install | % принявших TestFlight-инвайт | TestFlight → App Store Connect → Testers (Installs, Sessions) |
| Install → activation | Сделал ли человек в первые 24 ч: (а) добавил ≥1 лекарство, (б) залогировал воду ≥3 раза, (в) добавил complication | Вопрос в анкете на 3-й день + разговор; при желании — opt-in локальный «summary», который пользователь сам отправляет |
| Retention | Пользовался ли на D7 и D14 (по сегментам: meds / water / оба) | TestFlight Sessions + короткий check-in |
| Willingness to pay | % выбравших платный вариант в fake door; % внёсших предоплату или донат | Fake-door экран или лендинг (эксперимент E7) |

**Сводный вывод по разделу:**
- **Что подтверждено:** верхние этапы воронок (сообщения, CTA, SKU).
- **Что неизвестно:** все конверсии, onboarding и paywall-экраны.
- **Уверенность:** низкая для этапов после установки.
- **Что делать основателю:** настроить свою минимальную воронку из таблицы 4.6 до первого внешнего поста.

---

## 5. Swipe file (оригинальные тексты, прямые ссылки)

Дата доступа — 2026-10-10. «Старт» означает дату начала показа в Meta Ad Library.

| # | Источник / дата | Оригинальное сообщение | Аудитория | CTA | Механика [INFERENCE] | Воспроизводимость для Nuori |
|---|---|---|---|---|---|---|
| 1 | [Shotsy Meta](https://www.facebook.com/ads/library/?active_status=active&ad_type=all&country=US&q=Shotsy&search_type=keyword_unordered&media_type=all), старт 2026-07-27 | «The app people recommend to anyone tracking their GLP-1 journey. 1M+ downloads, 4.9 stars, and it actually gets it.» | GLP-1 US | «Start tracking your GLP-1 today!» / «Free 7-day trial» | Social proof | Формат «recommended by people like you» — после первых отзывов |
| 2 | [MeAgain Meta](https://www.facebook.com/ads/library/?active_status=active&ad_type=all&country=US&q=%22MeAgain%22&search_type=keyword_exact_phrase&media_type=all), 2026-09-02 | «Nobody tells you what GLP-1 shot day is supposed to look like… Now the app knows when my dose is due, so the checklist is just there on the day» | GLP-1 новички | (видео) | Creator partnership ad, первое лицо | Текст-формат — да; канал — нет |
| 3 | То же | «Just started a GLP-1 and have NO idea what to eat? You can literally see what 50,000 users are buying 👇» | GLP-1 новички | — | Сообщество как продукт | Нет |
| 4 | [WaterMinder Meta](https://www.facebook.com/ads/library/?active_status=active&ad_type=all&country=US&q=WaterMinder&search_type=keyword_unordered&media_type=all), 2026-09-21 | «You already make hundreds of decisions every day. Don't waste energy remembering water.» | Предприниматели | «Learn More» | Persona-тест | Да — как органические посты под персоны |
| 5 | То же | «Travel changes everything… You remembered your passport. Your charger. Your luggage. But did you remember your water?» | Путешественники | «Learn More» | Ситуационный триггер | Да |
| 6 | То же | «As a mom/dad you remember everyone else's needs. But when was the last time you remembered your own?» | Родители | «Learn More» | Забота о себе | Частично |
| 7 | [Pill Buddy Meta](https://www.facebook.com/ads/library/?active_status=active&ad_type=all&country=US&q=%22Pill%20Buddy%22&search_type=keyword_exact_phrase&media_type=all), 2026-02-28 | «Forgot to take your meds again? This app can help!» | Забывающие | «Install now» | Боль в вопросе | Да (если будет paid-тест) |
| 8 | [MyTherapy Meta DE](https://www.facebook.com/ads/library/?active_status=active&ad_type=all&country=DE&q=%22MyTherapy%22&search_type=keyword_exact_phrase&media_type=all), 2026-09-14 | «Verlässliche Erinnerungen für deine Abnehm-Präparate. Jetzt MyTherapy App downloaden.» | GLP-1 DE | «Install now» | Сегмент на родном языке | Сигнал о конкуренции в DE |
| 9 | [Cadence r/AppHookup](https://www.reddit.com/r/AppHookup/comments/1tl6c1i/ios_cadence_medication_reminders_that_actually/), 2026-05-23 | «[iOS] Cadence: medication reminders that actually work [Pro ($9.99) → free with code]» / «Your data stays yours. No account. No third-party servers. No subscription by default.» | Охотники за скидками на iOS | Промокод | Раздача → отзывы и фидбек | **Да, сразу после публичного релиза** |
| 10 | [Cadence vs Apple Health](https://www.cadencehealth.app/blog/cadence-vs-apple-health/), 2026-06-01 | «a solid, free reminder with a real adherence history… for one or two simple medications it may be all you need» | Ищущие сравнение | «Download on the App Store» | Честное сравнение снимает возражение | **Да — шаблон для Nuori** |
| 11 | Cadence App Store (DE) | «Pillen-Erinnerung ohne Abo» | DE, усталость от подписок | Get | ASO по боли | Да (PL: «bez abonamentu» — [HYPOTHESIS]) |
| 12 | [WaterMinder site](https://waterminder.com) | «Drink More Water Without Having To Think About It» / «Hydration That Lives On Your Wrist» | Общая | «Build My Hydration Habit» | Watch как отдельная секция | Да |
| 13 | [WaterMinder calculator](https://waterminder.com/calculator/how-much-water-should-i-drink.html) | Калькулятор нормы воды | SEO «how much water» | В приложение | Инструмент-магнит | Да (1 страница) |
| 14 | [PillChime PH](https://hunted.space/dashboard/pillchime) | «The pill reminder your parents won't swipe away.» | Взрослые дети пожилых | Upvote | Сильный хук, но 3 голоса | Хук — да; PH — нет |
| 15 | [GoodPill PH](https://hunted.space/dashboard/goodpill) | «Free medication reminders. No account. No cloud.» | Приватность | Upvote | 0 голосов: приватность сама по себе не вирусна | Предупреждение |
| 16 | [9to5Mac Pill Buddy](https://9to5mac.com/?p=1004129), 2025-06-07 | «Designed by a former Duolingo Product Manager» | Читатели Apple-медиа | — | История фаундера как хук | Да: «student developer in Poland, built for my own meds + water» — [HYPOTHESIS] |
| 17 | [r/AppleWatch](https://www.reddit.com/r/AppleWatch/comments/1vaykj7/hydration_reminder_app_with_minimal_interface/), 2026-07-30 | «I want a hydration app with a complication for the watch that only reminds me to drink water… at most one touch interactions» | ADHD + Watch | — | Голос клиента | **Использовать как формулировку ICP** |
| 18 | [Free water tracker r/iosapps](https://www.reddit.com/r/iosapps/comments/1vlj9tt/big_update_for_free_water_tracker_app_try_it_and/), 2026-08-11 | «It's actually free. No freemium model, no locked features.» → «11 people… donated a total of $18» | r/iosapps | «try it and leave your feedback» | Бесплатно = внимание без денег | Предупреждение |

---

## 6. Сравнение каналов для Nuori

Все оценки времени и стоимости — **[ESTIMATE]** автора отчёта для одного человека. Это не измерения.

| Канал | Стоимость запуска | Время до первого сигнала | Личный доступ к аудитории | Релевантность | Измеримость | Повторяемость | Главные риски | Итог для Nuori |
|---|---|---|---|---|---|---|---|---|
| Ручной рекрутинг в сообществах (Reddit-комментарии на запросы, DM, группы) | $0 | Дни | Высокий | Высокая (люди сами описывают проблему) | Высокая (UTM + форма) | Средняя | Правила сабреддитов о самопромо; бан; «vs Apple Health» | **Канал №1** |
| Текущие 12 тестировщиков и личная сеть | $0 | Дни | Максимальный | Неизвестна (друзья ≠ ICP) | Высокая | Низкая | Вежливые, а не честные ответы | Обязательно, но как фидбек, не как рост |
| ASO + локализация (PL / DE / EN) | $0 + время | Недели после релиза | Нет | Высокая (intent-поиск) | Средняя (App Store Connect: Impressions, Product Page Views, Conversion Rate) | Высокая | Нужен публичный релиз; конкуренция в US и DE | **Канал №2** (к релизу) |
| Apple featuring nomination | $0 | 2 недели – 3 месяца (рекомендация Apple) | Нет | Средняя | Высокая | Низкая (разово) | Нет гарантии | Включить в канал №2 |
| Indie-пресса (9to5Mac Indie Spotlight, iMagazine.pl, Spider's Web) | $0 | Недели | Средний (email) | Средняя | Высокая (пик загрузок) | Низкая | Нет ответа (как у Söka); тайминг перед WWDC или сентябрём плохой | Включить в канал №2 |
| r/AppHookup-раздача / r/iosapps-пост | $0 (промокоды) | 1–2 дня | Средний | Средняя (охотники за скидками ≠ ICP) | Высокая | Низкая | Мусорные установки; правила сабов | Разово, при релизе |
| Личные соцсети фаундера (X / Threads / Bluesky / Mastodon / LinkedIn) | $0 | Недели – месяцы | Средний | **Низкая для пациентов**, высокая для iOS-разработчиков | Средняя | Высокая | Аудитория = разработчики, а не пользователи | Вспомогательный (пресса, credibility) |
| Short-form video (TikTok / Reels / Shorts) | $0 | Недели | Низкий | Неизвестна | Средняя | Высокая | Требует регулярности; алгоритмическая лотерея | Дешёвый тест 6–8 роликов |
| SEO (1–3 страницы-инструмента) | $0–15 за домен в год [ESTIMATE] | 2–6 месяцев [ESTIMATE] | Нет | Высокая (intent) | Средняя (Search Console) | Высокая | Долгий цикл; github.io-домен; конкуренция vendor-блогов (MyTherapy, Pillo, Cadence) | Долгая ставка, 1–3 страницы |
| Product Hunt | $0 | 1 день | Низкий | **Низкая** для consumer health | Высокая | Низкая | 0–3 голоса в категории; спам (Söka) | Отложить |
| Креаторы / инфлюенсеры | $0 (бартер) – $$ | Недели | Средний | Высокая при узком нише-креаторе | Средняя | Средняя | Цена; медицинские claims | Позже, 1–2 бартер-теста |
| Meta / Apple Ads | $100–500 | Дни | Нет | Средняя | Высокая | Высокая | Без удержания — сжигание бюджета; нужна публичная версия | Только message-тест после релиза |

### 6.1. Оценка гипотез основателя

| Гипотеза | Evidence «за» | Evidence «против» | Вердикт |
|---|---|---|---|
| **Product Hunt** | Даёт бейдж и backlink (Waterllama показывает бейдж PH) [FACT]; хорошо для B2B / dev-tools [INFERENCE] | Hydrabit 0, GoodPill 0, PillChime 3 голоса [FACT]; Söka: «no indication that the number of downloads… increased» [FACT] | **Не первый канал.** Запускать после 20+ отзывов и релиза, как credibility-точку. Уверенность средняя |
| **SEO** | Cadence и WaterMinder вкладываются в SEO [FACT]; intent-запросы «Medisafe alternative», «apple watch medication reminder» существуют, судя по vendor-страницам под них [INFERENCE] | Эффективность у конкурентов не измерена [UNKNOWN]; vendor-блоги уже занимают «Medisafe alternative»; домен github.io; цикл — месяцы | **Долгая ставка, 1–3 страницы.** Не полноценный канал на 30 дней. Уверенность низкая–средняя |
| **Личные соцсети** | Söka: Mastodon ~400 подписчиков дал больше, чем ~3000 в Twitter [FACT]; история фаундера конвертирует (Pill Buddy, Shotsy) [FACT] | Подписчики основателя — вероятно, разработчики и знакомые, а не пациенты [HYPOTHESIS]; размер аудитории [UNKNOWN] | **Вспомогательный канал:** для прессы, бета-тестеров из iOS-круга и «build in public». Не основной канал к ICP. Уверенность средняя |

### 6.2. Бюджетные сценарии (суммы не подтверждены как бюджет основателя, все цифры — [ESTIMATE])

| Сценарий | На что тратить | Чего не делать |
|---|---|---|
| **$0** | Ручной рекрутинг; Reddit (с соблюдением правил); 1 лендинг с формой (GitHub Pages + Tally, бесплатные тарифы — проверить лимиты); ASO-тексты PL / EN; featuring nomination; питч в прессу; 1–3 SEO-страницы на github.io; промокоды при релизе (бесплатны в App Store Connect) | Product Hunt как главный запуск |
| **$100** | Всё из $0 + домен (~$10–15 в год) для SEO и бренда + один message-тест в Meta на ~$60–80 после публичного релиза: 2–3 варианта текста, одна страна. Цель — сравнить CTR сообщений, а не получить пользователей | Apple Ads на широкие ключи «water tracker» (там лидеры с 100k+ оценок) |
| **$500** | Всё из $100 + Apple Ads на узкие или брендовые ключи PL / UK (~$150–200) + 1–2 бартер- или микро-платных интеграции с нишевыми креаторами (ADHD / GLP-1 / Watch) (~$150–250) + приватная аналитика сайта (~$9–19 в месяц) | Масштабировать любой канал до D7-удержания ≥ целевого (раздел 9) |

Цены на Apple Ads, Meta и креаторов **не проверялись** в рамках исследования: [UNKNOWN]. Основателю нужно посмотреть рекомендованные ставки в кабинетах перед тратой.

**Сводный вывод по разделу:**
- **Что подтверждено:** слабость PH в категории; использование SEO и paid конкурентами.
- **Что неизвестно:** эффективность SEO и соцсетей для health-приложений соло-разработчиков; стоимость рекламы.
- **Уверенность:** средняя для ранжирования каналов; низкая для оценок времени и стоимости.
- **Что делать основателю:** $0-сценарий первые 30 дней; деньги — только после публичного релиза и данных об удержании.

---

## 7. Рекомендация: два первых канала для Nuori

### Канал 1 — Founder-led ручной рекрутинг в узких сообществах + текущие тестировщики

**Почему:**
- [FACT] Все три кейса быстрого раннего роста начинаются в сообществах: Shotsy в Reddit, Cadence в r/AppHookup, Söka через Mastodon и ручной отбор.
- [FACT] В r/AppleWatch реальные люди регулярно спрашивают ровно про «meds on watchface» и «hydration complication, one tap».
- Это единственный канал, который за 30 дней даёт **разговоры**, а не только установки. Разговоры нужны, чтобы ответить на главные вопросы брифа: кому важно, чем лучше Apple Health, готовность платить.

**Сегменты для параллельной проверки (не выбор ICP):**

| Сегмент | Почему | Где искать | Главное возражение |
|---|---|---|---|
| A. ADHD + Watch: вода и лекарства «одним касанием» | Тред r/AppleWatch про hydration complication [FACT]; Cadence делает отдельную страницу «medication-reminders-adhd» [FACT] | r/AppleWatch (ответы на запросы), r/adhdwomen, r/ADHD (только по правилам), ADHD-Discord | «У меня уже Health / Streaks» |
| B. GLP-1 + Watch: день укола + вода + (белок) | Task 1: GLP-1 companions платят $40–120 в год, но без Watch [из Task 1]; MyTherapy и MeAgain уже покупают этот трафик [FACT] | r/Zepbound, r/Mounjaro, r/WegovyWeightLoss, FB-группы | «Shotsy бесплатен»; часть пользователей «do not intend to track… water» [FACT] |
| C. Multi-med, уставшие от подписок (Medisafe) | Medisafe-paywall с 2026-01 обсуждается в vendor-блогах [FACT, вторичные] | Ответы в тредах «Medisafe alternative», r/iosapps | «Apple Health бесплатен и достаточен» |
| D. iOS-разработчики и Apple-энтузиасты из личной сети | Доступны сразу | X / Mastodon / Bluesky, польские iOS-митапы | Не ICP: годятся для фидбека о качестве, не для спроса |

### Канал 2 — «Apple + ASO»: product page, локализация, featuring, indie-пресса (к публичному релизу)

**Почему:**
- [FACT] Waterllama, Gentler Streak и WaterMinder получили Apple-награды и featuring и имеют сильные product pages. [INFERENCE] Вклад Apple в их рост, вероятно, значимый, но не измерен.
- [FACT] Apple прямо называет «Localization» и «App Store product page» критериями featuring. Nomination подаётся минимум за 2 недели, лучше — до 3 месяцев.
- [FACT] PL storefront не локализован конкурентами, а у Nuori уже есть польский язык.
- Канал не требует бюджета и работает после того, как ручной рекрутинг закончится.

**Состав:**
1. Product page на EN и PL (и DE, если будет время). Title и subtitle под проверенное сообщение. Первый скриншот — запястье: «доза + вода в одном взгляде».
2. Featuring nomination в App Store Connect (тип: App Launch), подача ≥2 недель до релиза.
3. Питч: 9to5Mac Indie App Spotlight; польские iMagazine.pl и Spider's Web (Spider's Web писал про польский Waterful — [статья 2021](https://spidersweb.pl/2021/02/waterful-aplikacja-picie-wody.html)).
4. В день релиза — пост с промокодами в r/AppHookup или r/iosapps по модели Cadence (если модель платная).

**Почему не PH и не SEO первыми:** см. 6.1. SEO делается параллельно в минимальном объёме (1–3 страницы), потому что эффект отложен.

**Что подтверждено:** паттерны каналов у конкурентов; критерии Apple; PL-разрыв в локализации.
**Что неизвестно:** будет ли Nuori отобран Apple; объём PL-поиска; реакция сообществ на Nuori.
**Уверенность:** средняя. Логика согласуется с несколькими кейсами, но собственных данных нет.
**Что делать основателю:** канал 1 — с этой недели; канал 2 — готовить параллельно и запускать к публичному релизу.

---

## 8. Приоритизированные эксперименты (13)

Порог «успеха» в каждом эксперименте — это **[HYPOTHESIS]**, выбранная как разумная точка решения для ~25–50 человек. Это не бенчмарк. Основатель может их сдвигать, но должен зафиксировать **до** запуска.

| # | Гипотеза | ICP и потребность | Канал | Message (тест) | Asset | CTA | Бюджет | Время фаундера [ESTIMATE] | Этап воронки | Метрика успеха | Стоп / продолжение | Если «+» / если «−» | Основание приоритета |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **E1** | Без захвата и ясного сообщения ни один канал не измерим | Все | Сайт | 3 варианта H1 (раздел 8.6) | Лендинг с формой (email, сегмент, «откуда узнали») + кнопка TestFlight | «Join the beta» | $0 | 4–6 ч | Visit → signup | Форма работает; UTM по каналам | — (инфраструктура) | — | Аудит 2.4: захвата нет [FACT] |
| **E2** | Текущие 12 тестировщиков покажут, что реально используется | 12 текущих | Личные сообщения + 15-мин созвоны | «Help me decide what Nuori should be» | Анкета из 6 вопросов + 5 созвонов (раздел 8.5) | Ответить / созвон | $0 | 5–7 ч | Activation, retention | ≥8 из 12 ответили; ≥5 созвонов | Если <5 ответов — сократить анкету до 2 вопросов | «+»: выделить используемую функцию. «−»: вывод «тестировщики не ICP» | Нулевая стоимость, данные уже есть |
| **E3** | ADHD-пользователи Watch хотят воду и лекарства «одним касанием» | A | Ответы на запросы в r/AppleWatch + посты, где разрешено | «Water and meds in one glance on your watch face. Built for ADHD brains that forget both.» (не «meds on your watch face»: это уже есть у Apple) | Комментарий с раскрытием («I'm the dev») + ссылка на лендинг | «Join the beta» | $0 | 3–4 ч в неделю | Discovery → signup → activation | ≥10 signup из сегмента A за 2 недели; ≥40% активированы на D3 | Стоп, если <3 signup после 10 ответов | «+»: делать ADHD-страницу и ASO. «−»: сегмент менее острый, проверить B / C | Тред r/AppleWatch [FACT]; страница Cadence [FACT] |
| **E4** | GLP-1-пользователи Watch хотят «shot day + water» на запястье | B | r/Zepbound / r/Mounjaro (по правилам), FB-группы | «Shot day, water and protein — on your wrist. Shotsy for your Watch.» [HYPOTHESIS; осторожно с брендами препаратов] | Пост-вопрос «Would you use…?» + fake-door лендинг | «Join the beta» | $0 | 4 ч | Message → signup | ≥10 signup; ≥3 спонтанно упоминают Watch | Стоп, если комментарии — «Shotsy is enough» без интереса к Watch | «+»: добавить минимальный «shot day» в бету (ничего больше). «−»: GLP-1 не Watch-сегмент | Task 1; рост категории; реклама MyTherapy DE [FACT] |
| **E5** | Возражение «vs Apple Health» снимается честным сравнением | A, C | Сайт / SEO | «When Apple Health is enough — and when it isn't» | Страница «Nuori vs Apple Health Medications» | «Try Nuori» | $0 | 4–6 ч | Message (возражение) | Время на странице и доля переходов в форму; использовать как ссылку в ответах E3 / E4 | Продолжить, если ≥1 из 5 собеседников говорит «понятно, чем отличается» | «+»: шаблон для «vs WaterMinder». «−»: отличие не воспринимается — пересмотреть продукт | Cadence-шаблон [FACT]; возражение в 2 тредах [FACT] |
| **E6** | Готовность платить: one-time против подписки | Все signup | Лендинг или TestFlight-экран | «Nuori Pro: $X once» против «$Y / year» против «free + tip» | Fake-door экран (честно: «Pricing not live yet — want early access at this price?») | Выбрать вариант | $0 | 3–4 ч | Paywall | ≥30% выбирают платный вариант; распределение one-time / подписка | Нужно ≥20 ответов для вывода | «+»: внедрить выбранную модель. «−»: проверить другой сегмент, а не цену | Cadence (one-time), Pill Buddy (supporter), донаты $18 на 1000+ пользователей [FACT] |
| **E7** | Founder story повышает отклик | D, затем все | X / Threads / Bluesky / Mastodon / LinkedIn | «I'm a student in Poland. I forget my meds and water, so I built a Watch app that fixes both in one tap.» (**только если это правда**; иначе — реальная причина, по которой основатель делает Nuori) | 8 постов за 4 недели (раздел 8.3) | «Beta link» | $0 | 2 ч в неделю | Discovery | ≥15 signup за 4 недели из соцсетей (UTM) | Продолжить, если ≥1 пост дал ≥5 signup | «+»: регулярность. «−»: оставить только для прессы | Söka (Mastodon), Pill Buddy, Shotsy [FACT] |
| **E8** | Короткое видео «2 секунды с запястья» понятнее текста | A, B | TikTok / Reels / Shorts | «Logging water + meds in 2 seconds on Apple Watch» | 6 вертикальных роликов по 10–20 с | «Link in bio → beta» | $0 | 4–6 ч | Discovery → visit | ≥1 ролик с ≥2× медианы просмотров аккаунта; ≥5 переходов | Стоп после 6 роликов без переходов | «+»: серия. «−»: закрыть канал | Waterllama нанимает под UGC [FACT]; эффективность [UNKNOWN] |
| **E9** | PL ASO: польский title / subtitle даёт показы в PL | Польские пользователи | App Store (PL) | Например: «Nuori: woda i leki na zegarku» / «Przypomnienie o lekach i wodzie» [HYPOTHESIS] | Локализованный product page | Get | $0 | 3 ч | App Store → install | Impressions и Conversion Rate в App Store Connect (PL) против EN storefronts за 4 недели | Нужен публичный релиз | «+»: повторить для DE. «−»: PL не приоритет | PL-разрыв [FACT] |
| **E10** | Apple featuring + indie-пресса дают пик загрузок | Общая | Apple / пресса | История фаундера + Watch-first | Nomination + press kit (1 страница, 5 скриншотов, видео) + 5 писем | — | $0 | 6–8 ч | Discovery | Ответ ≥1 издания; featuring (да / нет) | Разово | «+»: повторять на крупных апдейтах. «−»: повторить в «тихий сезон» (Söka) | Waterllama, Gentler, Pill Buddy [FACT] |
| **E11** | r/AppHookup-раздача даёт отзывы и первые оценки | Охотники за скидками | Reddit | «[iOS] Nuori: water + meds on your Apple Watch [Pro → free with code]» | Пост + 50–100 промокодов | Код | $0 | 2 ч + ответы | Install → review | ≥10 отзывов в App Store; ≥5 запросов функций | Разово при релизе | «+»: повторять на мажорных апдейтах. «−»: аудитория не та | Cadence 67 / 88 [FACT] (но 12 оценок) |
| **E12** | SEO-страница-инструмент начнёт давать показы | Intent-поиск | Сайт | См. кластеры 8.2 | 2 страницы: «vs Apple Health» (= E5) + «Apple Watch water + medication reminder setup guide» | «Try Nuori» | $0–15 | 6–8 ч | Discovery | Показы в Search Console через 8–12 недель | Оценить на 90-й день | «+»: +1 страница в месяц. «−»: SEO не приоритет | Cadence, WaterMinder [FACT]; эффективность [UNKNOWN] |
| **E13** | Message-тест в Meta покажет, какой угол сильнее | A / B / C | Meta | 3 варианта (раздел 8.6) | 3 статичных креатива | «Learn more» | $60–100 | 3 ч | Message (CTR) | Разница CTR между вариантами, видимая на одинаковом бюджете | Только после релиза и E3 / E4 | «+»: использовать победителя в ASO. «−»: углы равны — решать качественно | Persona-тесты WaterMinder [FACT] |

Product Hunt не входит в топ-13. Условия для запуска описаны ниже (8.1).

### 8.1. Подготовка к Product Hunt: какие доказательства нужны до запуска

Запускать PH **только** при выполнении всех условий [HYPOTHESIS, условия выбраны по кейсам 3.8]:
1. Приложение в App Store (не TestFlight), есть ≥20 отзывов или оценок.
2. Есть 3–5 цитат реальных пользователей из целевого сегмента (из E2–E4) для первого комментария и галереи.
3. Есть список из 30–50 людей, которые **реально используют** Nuori и готовы оставить содержательный комментарий в день запуска. Не накрутка: PH и Söka фиксируют спам-аккаунты.
4. Tagline проверен в E3 / E4 / E13 (не «water, calories and meds tracker»).
5. Цель запуска сформулирована как credibility (бейдж, backlink, отзывы), а не как «первые 100 пользователей».

Asset: 4–5 изображений (запястье → complication → уведомление → неделя), 30-секундное видео, первый комментарий-история («why I built it»), оффер (промокод).

### 8.2. SEO-кластеры, которые реально сделать одному

[UNKNOWN] Объёмы запросов. Кластеры выбраны по тому, что под них **уже пишут страницы конкуренты** (Cadence, WaterMinder, Pillo, MyTherapy). Это [INFERENCE] о наличии спроса, а не его измерение.

| Кластер | Примеры страниц | Конкуренция [INFERENCE] | Приоритет |
|---|---|---|---|
| «vs / alternative» | «Nuori vs Apple Health Medications», «WaterMinder alternative with medication reminders» | Средняя: Cadence и Pillo уже пишут | **1** (= E5) |
| Apple Watch how-to | «How to log water on Apple Watch (with and without an app)», «Medication reminders on Apple Watch: setup + complications» | Средняя: iGeeksBlog, PCRisk | **2** |
| Сценарии сегментов | «Water and medication reminders for ADHD», «GLP-1 shot day checklist: water, protein, dose» | Нишевая | 3 (после E3 / E4) |
| Польский | «Przypomnienie o lekach na Apple Watch», «Jak pić więcej wody — aplikacja na zegarek» | Вероятно, низкая [HYPOTHESIS] | 3 |
| Калькулятор | «How much water should I drink» | Очень высокая (WaterMinder: 60+ страниц) | Не делать |

Ограничение: `github.io` — общий домен. Для SEO и бренда стоит купить домен, но **после** решения по имени (Nouri / Nuori).

### 8.3. Founder-led канал

- **Где:** одна основная площадка, где уже есть люди из iOS-круга основателя (X, Threads, Bluesky или Mastodon) + LinkedIn в Польше. [UNKNOWN] Текущий размер аудитории основателя — это первое, что нужно проверить.
- **Ритм:** 2 поста в неделю, 4 недели. Чередовать:
  - (а) «why» — история и проблема;
  - (б) «how» — 10-секундное видео с запястья;
  - (в) «learned» — честные цифры беты: «12 testers → 3 use meds daily»;
  - (г) «ask» — вопрос аудитории.
- **Правило:** каждый пост с UTM-ссылкой. Метрика — signup, а не лайки.
- **Цель канала [INFERENCE]:** контакты с прессой и iOS-сообществом, тестировщики качества, публичная история для PH и Apple. Не основной путь к пациентам.

### 8.4. Ручной поиск первых 25–50 релевантных тестировщиков

1. **Список мест (день 1–2).**
   - Reddit: r/AppleWatch, r/iosapps, r/adhdwomen, r/ADHD, r/Zepbound, r/Mounjaro, r/HydroHomies, r/TheGirlSurvivalGuide (там есть запрос про water tracking).
   - Discord-серверы ADHD и Apple.
   - FB-группы GLP-1.
   - Польские группы (ADHD, Apple Watch Polska).
   - **Для каждого места прочитать правила о самопромо и записать их.**
2. **Мониторинг запросов.** Ежедневный поиск Reddit (за неделю): «medication reminder apple watch», «water reminder complication», «medisafe alternative», «forget to take meds adhd». Отвечать **по существу** первым: если Apple Health достаточно, сказать это. Затем: «Disclosure: I'm building an app for X — happy to add you to the beta».
3. **Собственные посты** только там, где правила разрешают (r/iosapps, r/AppHookup — при релизе). В остальных местах — пост-вопрос без ссылки: «How do you remember both meds and water? What does your watch face look like?» Ответы — это исследование и источник DM.
4. **DM-шаблон** (только тем, кто сам описал проблему):
   > «Hi! Saw your comment about [forgetting meds / water on the watch]. I'm a solo dev building Nuori — one tap on the Apple Watch for water and meds, no account. Would you try the beta for 2 weeks and tell me honestly what's missing? No pressure if not.»
5. **Квалификация в форме:** Watch есть? Принимаете лекарства ежедневно? Сколько? Чем пользуетесь сейчас (Health / приложение / ничего)? → отбирать ICP, а не всех подряд.
6. **Цель:** 25–50 signup, из них ≥60% — сегменты A / B / C. Друзья и разработчики идут отдельным списком.

### 8.5. Отзывы и кейсы от текущих 12 тестировщиков

1. **Анкета (5 минут)** в TestFlight-описании и в личном сообщении:
   1. Что вы залогировали в Nuori за последние 7 дней (вода / лекарства / калории / ничего)?
   2. Откуда чаще — с часов, с телефона, из уведомления, из виджета?
   3. Если бы Nuori завтра исчез, что бы вы использовали вместо?
   4. Пользовались ли Apple Health Medications? Чем Nuori лучше или хуже?
   5. Одной фразой: для кого это приложение?
   6. Заплатили бы вы? Если да, что выбрали бы: $X один раз, $Y в год или чаевые?
2. **5 созвонов по 15 минут** с самыми активными. Попросить показать watch face и последний лог (наблюдение > мнение).
3. **Сбор цитат:** с разрешения записывать дословно — для лендинга, PH и прессы.
4. **Вопрос 3 — ключевой** (альтернатива): ответ «ничего / Health» означает, что ценность не доказана.
5. **Ожидание [INFERENCE]:** 12 тестировщиков, набранных из личного круга, могут не быть ICP. Их ответы проверяют качество продукта, а не спрос.

### 8.6. Позиционирования и тексты для теста (Stage G)

Это **гипотезы для проверки**. Ни один вариант не доказан как лучший.

**A. ADHD / «one tap» (сегмент A)**
- Landing H1: «Water and meds. One tap on your wrist.»
- Sub: «For brains that forget both. Glance at your watch face, tap once, done. No account.»
- Пост (**только если это правда про основателя**; в health-сообществах выдуманная история — серьёзный репутационный риск): «I have [N] meds and I forget water until 4pm. Apple Health does meds, but I wanted one glance for both — so I built it. Looking for 20 Apple Watch users to break it.»

**B. GLP-1 Watch companion (сегмент B)** — осторожно с брендами препаратов и медицинскими claims.
- Landing H1: «Shot day, water, and doses — on your Apple Watch.»
- Sub: «The trackers you love live on your phone. Nuori puts today's essentials on your wrist.»
- Пост-вопрос: «GLP-1 folks with an Apple Watch: what do you check on shot day? I'm building a watch-first companion and want to get it right.»

**C. «Simple, no subscription, private» (сегмент C)**
- Landing H1: «Medication and water reminders. No account. No subscription.»
- Sub: «Taken, Snooze, Skip from your wrist. Data stays on your devices.»
- [INFERENCE] Сообщение уже занято Cadence («no monthly fee») и GoodPill («No account. No cloud.» — 0 голосов на PH). Слабое как самостоятельный угол, сильное как дополнение.

**PL (для E9):** «Leki i woda — jednym dotknięciem na zegarku.» [HYPOTHESIS, нужна вычитка носителем]

**О калориях:** в 2 из 3 углов калории не упоминаются. [INFERENCE] Если в E2 тестировщики активно логируют калории, это сигнал для отдельного разговора, а не повод вернуть калории в главное сообщение. В Task 1 предлагается переиспользовать quick-add для белка в GLP-1-сценарии.

---

**Сводный вывод по разделу 8:**
- **Что подтверждено:** каждый эксперимент опирается на механику, которая наблюдалась у конкурентов или в сообществах (колонка «Основание приоритета»).
- **Что неизвестно:** все пороги успеха — гипотезы; реакция конкретных сообществ на Nuori; ограничения самопромо.
- **Уверенность:** средняя в порядке экспериментов (сначала инфраструктура и свои данные, потом рекрутинг, потом релизные каналы); низкая в порогах.
- **Что делать основателю:** E1 и E2 — на этой неделе; E3–E6 — следующие две недели; E9–E11 — к публичному релизу; E12–E13 — после.

---

## 9. Практический план на первые 30 дней

| Неделя | Задачи | Результат к концу недели |
|---|---|---|
| **1 (инфраструктура + свои данные)** | Решить имя: «Nouri» конфликтует с 4+ приложениями в US. Проверить «Nuori» и альтернативы в App Store, на домены и в соцсетях. Переписать лендинг под 2–3 угла (E1). Добавить форму и ссылку на TestFlight, UTM. Отправить анкету 12 тестировщикам, 5 созвонов (E2). Поставить рядом на циферблат complication Apple Medications и Nuori, сделать скриншот: это сравнение для страницы «vs Apple Health» (E5) | Работающая воронка; ответы ≥8 из 12; решение по имени |
| **2 (рекрутинг A + C)** | Список сообществ и правил; ежедневные ответы на запросы в Reddit (E3); страница «vs Apple Health» (E5); 2 founder-поста (E7) | ≥10–15 signup; первые D3-активации |
| **3 (рекрутинг B + цена)** | GLP-1 пост-вопрос и fake door (E4); экран цены (E6); 3 коротких видео (E8); ещё 2 поста | ≥25 signup суммарно; ≥20 ответов о цене |
| **4 (решение + подготовка релиза)** | D7 / D14 по сегментам; выбрать 1 сегмент и 1 сообщение; PL / EN product page (E9); press kit; featuring nomination (≥2 недели до релиза) (E10); черновик поста r/AppHookup (E11) | Решение «какой сегмент» + дата публичного релиза |

**Критерии решения на 30-й день** — [HYPOTHESIS]. Зафиксировать до старта.

| Сигнал | Порог | Действие |
|---|---|---|
| Сегмент набирает signup | ≥10 из сегмента за 2 недели при ≤5 ч работы | Продолжать сегмент |
| Активация | ≥50% новых в сегменте сделали первый лог на запястье в первые 24 ч | Продукт понятен |
| Удержание | ≥30% сегмента используют на D14 | Готовить релиз под этот сегмент |
| Готовность платить | ≥30% выбирают платный вариант в fake door | Внедрять монетизацию в релиз |
| Ни один сегмент не проходит | — | Не расширять функции. Вернуться к интервью: проблема или сегмент выбраны неверно |

**Что подтверждено:** план опирается на подтверждённые паттерны (раздел 3).
**Что неизвестно:** все пороги — гипотезы; реакция сообществ.
**Уверенность:** средняя для последовательности шагов; низкая для порогов.
**Что делать основателю:** начать с недели 1 — без неё результаты недель 2–4 нельзя будет измерить.

---

## 10. Неизвестные, без которых нельзя обоснованно оценить эффективность

| Неизвестное | Почему важно | Как получить |
|---|---|---|
| Поисковый спрос (Google и App Store) по ключам EN / PL / DE | Приоритизация SEO и ASO | Google Search Console (после домена), Google Keyword Planner (бесплатный аккаунт Google Ads), Apple Ads keyword popularity (кабинет Apple Ads) |
| Позиции Cadence, WaterMinder, Pillo в Google по «medisafe alternative», «apple watch medication reminder» | Реальная конкуренция за SEO | Ручная проверка в Google (режим инкогнито, US VPN) или Ahrefs / Semrush (платно) |
| Конверсии и удержание любого конкурента | Нельзя сравнивать воронки | Публично недоступно; не подставлять средние |
| Эффективность рекламы конкурентов (бюджеты, CAC) | Оценка paid | Недоступно; длительность показа объявлений — только косвенный сигнал |
| Google Ads и TikTok-реклама конкурентов | Полнота картины paid | Google Ads Transparency Center; TikTok Ad Library (EU) — не проверялись |
| Apple Ads-активность конкурентов | Конкуренция по ключам | Публичной библиотеки нет. Косвенно — через свой кабинет Apple Ads |
| Ценят ли пользователи «вода + лекарства в одном взгляде» больше, чем две отдельные complication (Apple Medications + любой water tracker) | Это единственное оставшееся отличие на циферблате (у Apple Medications complication есть — [FACT]) | E2, E3: показать оба варианта на созвоне |
| Размер и состав личной аудитории основателя | Вес founder-канала | Посчитать подписчиков и долю не-разработчиков |
| Правила самопромо в каждом целевом сообществе | Риск бана | Прочитать правила перед постом |
| Реальный onboarding и paywall Shotsy, Cadence, WaterMinder, Pill Buddy | Паттерны монетизации | Установить и пройти (без оплаты), сделать скриншоты для swipe file |
| Юридические рамки упоминания препаратов (Ozempic / Mounjaro) в ASO и рекламе в ЕС и US | Риск отказа в ревью и нарушений | App Store Review Guidelines 2.3.7, политика Meta по рекламе лекарств; при необходимости — консультация |
| Поведение 12 тестировщиков | Основа всех решений | E2 |

---

## Приложение A. Ключевые источники (доступ 2026-10-10)

- Apple Support — Medications: https://support.apple.com/en-us/105064 (опубликовано 2026-09-14)
- Apple — Getting featured: https://developer.apple.com/app-store/getting-featured/
- RevenueCat — Shotsy: https://www.revenuecat.com/blog/growth/aja-beckett-shotsy-launched-podcast-2025 (2025-12-03)
- Silicon Florist — Shotsy funding: https://siliconflorist.com/2025/02/20/shotsy-lands-2-million-for-weight-loss-shot-tracking-app/ (2025-02-20)
- 9to5Mac — Pill Buddy: https://9to5mac.com/?p=1004129 (2025-06-07)
- Söka retrospective: https://roddymunro.substack.com/p/soka-launch-retrospective (2023-06-04)
- Cadence: https://www.cadencehealth.app, https://www.cadencehealth.app/sitemap.xml, https://www.cadencehealth.app/blog/cadence-vs-apple-health/ (2026-06-01)
- WaterMinder: https://waterminder.com, https://waterminder.com/sitemap.xml, https://www.macstories.net/sponsored/waterminder-stay-hydrated-all-day-every-day-sponsor/
- Waterllama: https://waterllama.com; вакансия: https://djinni.co/jobs/835286-head-of-acquisition-and-growth-ios-apps/
- Medisafe B2B: https://medisafe.com/solutions/for-pharma
- Product Hunt / hunted.space: https://www.producthunt.com/products/hydrabit, https://hunted.space/dashboard/pillchime, https://hunted.space/dashboard/goodpill
- Reddit:
  - https://www.reddit.com/r/AppHookup/comments/1tl6c1i/ (2026-05-23)
  - https://www.reddit.com/r/AppleWatch/comments/1wz3edq/ (2026-10-06)
  - https://www.reddit.com/r/AppleWatch/comments/1vaykj7/ (2026-07-30)
  - https://www.reddit.com/r/iosapps/comments/1vlj9tt/ (2026-08-11)
  - https://www.reddit.com/r/Zepbound/comments/1vk1gt7/ (2026-08-09)
- Vendor-страницы «Medisafe alternative» (вторичные, заинтересованные): https://edit.mytherapyapp.com/blog/medisafe-alternatives-free, https://pillo.care/blog/medisafe-no-longer-free-best-free-alternatives
- Spider's Web — Waterful (PL): https://spidersweb.pl/2021/02/waterful-aplikacja-picie-wody.html
- Meta Ad Library — ссылки в разделах 2.3 и 5.
- App Store: `https://apps.apple.com/<cc>/app/id<ID>`; ID — в таблице 2.1.
