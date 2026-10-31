# Nuori — Task 2: Marketing & Growth Intelligence

Дата исследования и дата доступа ко всем источникам: **2026-10-09** (если не указано иное).
Метки: **[FACT]**, **[ESTIMATE]**, **[INFERENCE]**, **[UNKNOWN]**, **[HYPOTHESIS]** — по Shared Research Brief.

Методологические ограничения (важно прочитать до выводов):

- Данные App Store (рейтинги, IAP, subtitles, описания) получены из публичного iTunes Lookup/Search API (`https://itunes.apple.com/lookup?id=<id>&country=<cc>`) и веб-страниц `https://apps.apple.com/us/app/id<id>`. Количество рейтингов ≠ количество пользователей.
- Списки IAP на странице App Store — это до 10 SKU, включая устаревшие и региональные. **Ни один paywall, onboarding или trial не был просмотрен напрямую** (приложения не устанавливались). Единственное прямое свидетельство о trial — строка в описании WaterMinder.
- Порядок выдачи iTunes Search API ≠ ранжирование в поиске App Store на устройстве. Используется только как грубый прокси конкуренции.
- Reddit (reddit.com) был недоступен для автоматического чтения. Выводы о Reddit основаны на зеркалах и вторичных источниках — помечены соответственно.
- Ни один сервис оценок (Sensor Tower, AppMagic, Similarweb) не был доступен; цифр загрузок/выручки от них в отчёте нет.

---

## 1. Executive summary

1. **Встроенная функция Apple закрывает базовый сценарий «напомнить и отметить лекарство на часах».** [FACT] В Apple Medications на Apple Watch из уведомления доступны *Skipped*, *Taken* и *Remind Me in 10 Minutes*, плюс follow-up reminder через 30 минут, если доза не отмечена ([Apple Support 105064](https://support.apple.com/en-us/105064)). Значит, «Taken / Snooze / Skip в уведомлении» — **не дифференциатор** Nuori на часах; на iPhone у Apple в уведомлении только Skipped/Taken. Дифференциацию нужно искать в другом: (а) вода + лекарства в одном взгляде/complication, (б) скорость логирования воды с запястья, (в) приватность и модель без подписки, (г) локальные рынки и языки. Всё это — **[HYPOTHESIS]**, требующие проверки.
2. **Ближайший прямой аналог «Watch-first water + meds» не показывает публичной тяги.** [FACT] WatchRipple (Yi Fang): вода + лекарства на Apple Watch, $1.99 платно, релиз 2025-10-24, с тех пор без обновлений, 0 рейтингов в US/GB/DE/PL. [INFERENCE] Само по себе позиционирование «water + meds on Watch» спрос не генерирует; узкое место — дистрибуция и/или ценность. 0 рейтингов ≠ 0 пользователей, это слабый сигнал.
3. **Самый показательный indie-кейс — не Watch-first.** [FACT] Pill Buddy (Kai Loh, бывший PM Duolingo по данным [9to5Mac](https://9to5mac.com/?p=1004129)) — iPhone-only, маскот, streaks, подписка «Supporter» $4.99/мес и $35.90/год (US); релиз 2025-05-21, 1 775 рейтингов в US на 2026-10-09 и почти ноль в Европе (GB 93, DE 4, PL 8). [INFERENCE] Рост indie-приложения в этой категории возможен через эмоциональную механику (маскот, streak) + indie-прессу + сильный англоязычный (US) рынок. Это ставит под сомнение «Watch-first» как *крючок роста* (не как ценность продукта).
4. **Гидратация — переполненная категория с крупными игроками.** [FACT] Waterllama — 162 644 рейтингов US, WaterMinder — 35 063, Plant Nanny — 106 483, Water Reminder (VGFIT) — 78 784. Все имеют Apple Watch. [INFERENCE] Конкурировать за общие запросы «water tracker» соло-фаундеру без бюджета бесперспективно; нужен ниша-вход.
5. **Medication-категория в ЕС устроена иначе, чем в США.** [FACT] Лидеры в DE/FR/NL — MyTherapy (smartpatient, бизнес-модель B2B с фармой) и локальные игроки (mediteo в DE, 20 292 рейтинга). Ключевой тактический факт: лидеры **локализуют название** под запрос («MyTherapy Tabletten Erinnerung», «Medicijn en Pil Herinnering»; Waterllama в DE — «Wasser trinken Erinnerung Lama»). [INFERENCE, слабая] В PL выдача по «przypomnienie o lekach» выглядит тоньше (топ-5 по API — 1 870 / 229 / 22 820 (системное Reminders) / 103 / 1 рейтингов), что может давать соло-фаундеру шанс в локальной выдаче — с оговоркой, что API ≠ реальное ранжирование.
6. **Product Hunt — слабый первичный канал для consumer iOS.** [FACT] Indie iOS-разработчик Söka: «there was no real benefit to using Product Hunt» ([ретроспектива, 2023-06-04](https://roddymunro.substack.com/p/soka-launch-retrospective)); найденные medication-запуски на PH (GoodPill, PillMind) в зеркале hunted.space в ранних снимках показывали 0 голосов. [INFERENCE] PH стоит делать позже как credibility-точку, не как один из двух первых каналов.
7. **Рекомендация по двум первым каналам** (раздел 7): **(1) ручной founder-led рекрутинг 25–50 релевантных тестировщиков в узких сообществах + личной сети, с жёсткой обратной связью;** **(2) локализованный ASO + Apple featuring nomination + indie-press pitch** к публичному релизу. SEO — одна «инструментальная» страница как долгосрочная ставка; Product Hunt — после накопления отзывов. Уверенность: средняя.
8. **Платёжный сигнал рынка:** у конкурентов сосуществуют подписки ($2.99–$9.99/мес в US) и lifetime/one-time ($2.99–$49.99). [FACT] Cadence (indie, 2026) построил messaging вокруг «Pill reminder, no monthly fee» и one-time $9.99. [HYPOTHESIS] Для Nuori на старте разумно проверять готовность платить через fake-door/предзаказ на one-time vs подписку, а не угадывать.

**Что подтверждено:** функции Apple Medications; ценовые SKU и рейтинги конкурентов на 6 storefront; локализация названий лидерами; существование PR/спонсорских активностей (MacStories, 9to5Mac); B2B-модели Medisafe/MyTherapy.
**Что неизвестно:** реальные загрузки, конверсии, retention, CAC любого конкурента; эффективность их каналов; поисковый спрос по ключам; стоимость Apple Ads по ключам.
**Уверенность:** средняя для выводов о структуре рынка и тактиках; низкая для любых выводов об эффективности каналов (публичных данных о результатах почти нет).
**Что делать:** не расширять функциональность; за 30 дней получить 25–50 релевантных тестировщиков, измерить активацию/удержание по воде и лекарствам раздельно, проверить 2–3 позиционирования и готовность платить (раздел 9 — план на 30 дней).

---

## 2. Карта каналов конкурентов с evidence

### 2.1. Шорт-лист (13 + 3 микро-аналога)

Рейтинги — количество рейтингов App Store по storefront (не пользователи). Источник: iTunes Lookup API, доступ 2026-10-09.

| Приложение (разработчик) | Категория | US | GB | DE | FR | NL | PL | Watch | Subtitle (US, оригинал) |
|---|---|---|---|---|---|---|---|---|---|
| Waterllama (Llama Luna Apps) | Hydration | 162 644 | 5 972 | 25 769 | 7 819 | 3 113 | 1 666 | да | Hydration drink reminder - app |
| Plant Nanny (SPARKFUL) | Hydration, gamified | 106 483 | 10 377 | 8 090 | 2 193 | 3 077 | 1 867 | да | Drinking & Hydration Reminder |
| Water Reminder (VGFIT) | Hydration | 78 784 | 16 051 | 5 599 | 9 333 | 8 266 | 2 347 | да | Nutrition & Calorie counter |
| WaterMinder (Funn Media) | Hydration | 35 063 | 2 818 | 5 538 | 1 453 | 1 162 | 911 | да | Drink More, Hydration Reminder |
| HidrateSpark (Hidrate) | Hydration + hardware | 19 804 | 1 099 | 856 | 409 | 311 | 226 | да | Drink More Water Reminder |
| Medisafe | Medication | 101 444 | 13 460 | 3 675 | 4 903 | 3 210 | 386 | да | Pill and Medicine Reminder |
| Pill Reminder – All in One (Sergio Licea, indie) | Medication | 27 923 | 2 102 | 518 | 379 | 1 151 | 29 | нет | Medication Reminders, Tracker |
| Hero (Hero Health) | Medication + hardware | 10 631 | — | — | — | — | — | да | — |
| Max – Pill reminder (Artify) | Medication, маскот | 9 803 | 780 | 802 | 17 | 27 | 19 | нет (Only for iPhone) | Health Routine Alarm Tracker |
| MyTherapy (smartpatient, DE) | Medication | 8 554 | 3 204 | 15 378 | 4 037 | 2 364 | 1 870 | нет (по листингу: iPhone, iPad) | Health & Medication Tracker |
| Gentler Streak (Gentler Stories, indie, SI) | Watch health utility | 8 825 | 727 | 1 120 | 348 | 468 | 277 | да | Activity, Exercise and Health |
| Pill Buddy (Kai Loh, indie) | Medication, маскот | 1 775 | 93 | 4 | 4 | 3 | 8 | нет (Only for iPhone) | Track medicine, supplements |
| Cadence (Alex Stewart / PaperCloud Studios, indie) | Medication | 12 | 3 | 3 | 2 | 0 | 0 | да | Pill reminder, no monthly fee |
| WatchRipple (Yi Fang, indie) | Water + meds, Watch | 0 | 0 | 0 | — | — | 0 | да | — |
| mediteo (DE) | Medication | — | — | 20 292 | — | — | — | — | (title: «mediteo: Tabletten Erinnerung») |
| Apple Medications (встроенное) | Medication | — | — | — | — | — | — | да | — |

Источники листингов: [Waterllama](https://apps.apple.com/us/app/id1454778585), [Plant Nanny](https://apps.apple.com/us/app/id1424178757), [Water Reminder VGFIT](https://apps.apple.com/us/app/id1221965482), [WaterMinder](https://apps.apple.com/us/app/id653031147), [HidrateSpark](https://apps.apple.com/us/app/id1056269374), [Medisafe](https://apps.apple.com/us/app/id573916946), [Pill Reminder – All in One](https://apps.apple.com/us/app/id816347839), [Max](https://apps.apple.com/us/app/id1502063556), [MyTherapy](https://apps.apple.com/us/app/id662170995), [Gentler Streak](https://apps.apple.com/us/app/id1576857102), [Pill Buddy](https://apps.apple.com/us/app/id6742357512), [Cadence](https://apps.apple.com/us/app/id6758649306), [WatchRipple](https://apps.apple.com/us/app/id6747939802), [Apple Medications support](https://support.apple.com/en-us/105064).

### 2.2. Цены (IAP SKU, US storefront, USD) — paywall не наблюдался

| Приложение | SKU, видимые на странице App Store (US) | Модель [INFERENCE] |
|---|---|---|
| WaterMinder | Monthly $2.99; Premium Yearly $14.99; Yearly Offer $7.49; Premium One time $49.99; Tip Jar $0.99–$49.99 | Подписка + lifetime + чаевые; описание: «Try every feature free for 7 days» [FACT] |
| Waterllama | «Monthly - Full Access» $0.99; множество SKU $8.99–$19.99 | Подписка/one-time (точная структура paywall [UNKNOWN]) |
| Plant Nanny | Monthly $7.99/$3.99; Annual $69.99; Biannual $44.99; внутриигровые «Clovers» $1.99–$19.99 | Подписка + игровая валюта |
| Water Reminder (VGFIT) | Premium $0.99–$79.99 (10 SKU) | Подписка, детали [UNKNOWN] |
| HidrateSpark | PREMIUM $1.99 / $14.99; Glow Studio $4.99 | Подписка + hardware-бутылка |
| Medisafe | Monthly $2.99–$9.99; 1 Year $27.99–$39.99 | Freemium подписка + B2B с фармой |
| MyTherapy | Ad-free Subscription $0.99 / $9.99; Plus — Lifetime $49.99 | Бесплатно для пациента, B2B с фармой |
| Pill Reminder – All in One | Full Version $2.99 | One-time |
| Pill Buddy | Supporter Monthly $4.99; Yearly $35.90 | Подписка «supporter» |
| Cadence | Cadence Pro $9.99 | One-time; бесплатно — «Unlimited medications free» [FACT, описание] |
| Gentler Streak | Monthly $8.99; Yearly $39.99; Lifetime $59.99–$179.99; Family | Подписка + lifetime |
| WatchRipple | Платное $1.99 (GB £1.99, DE 1,99 €, PL 9,99 zł) | Paid upfront |
| Max | IAP на странице не найдено | [UNKNOWN] |

### 2.3. Карта каналов: присутствие vs доказательство эффективности

Обозначения: **●** — подтверждённая активность в канале (факт публикации/кампании); **○** — только присутствие (аккаунт, бейдж); **?** — не найдено/не проверено. Эффективность почти везде **[UNKNOWN]**.

| Приложение | Product Hunt | SEO/контент | ASO + локализация | Соцсети фаундера | Creators/UGC | PR/обзоры | Paid (ASA, спонсорство) | B2B/партнёрства | Apple featuring | Reddit/сообщества | Email/waitlist/referral |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Waterllama | ○ (бейдж PH на сайте; листинг не найден) | ● калькулятор нормы воды на waterllama.com | ● 22 языка; DE-title «Wasser trinken Erinnerung Lama» | ? | ○ TikTok/IG/X аккаунты; вакансия ищет UGC/influencer-менеджера | ● ADA 2022 finalist, App Store Award 2022, ТВ-сюжет 2026 | вакансия упоминает Apple Search Ads (намерение, не факт кампании) | ? | ● Editors' Choice, App Store Award | ? (не проверено: reddit.com недоступен) | ? |
| WaterMinder | ? (не найден) | ● блог (еженедельные «всплески» в 2025; на первой странице новых постов нет с 2026-01-12), «Hydration Hub», книга | ● 24 языка | ? | ? | ● MacStories, 9to5Mac, Healthline и др. (по сайту) | ● спонсорство MacStories (дата ~2023, по метаданным изображения — [INFERENCE]) | ? | ● Editors' Choice; «App of the Day» (заявление компании) | ? (не проверено: reddit.com недоступен) | ? |
| Plant Nanny | ? | ? | 5 языков; цитаты прессы в описании | ? | ? | ● цитаты TGDaily и др. в описании | ? | ? | ? | ? (не проверено: reddit.com недоступен) | ? |
| Medisafe | ? | ? | ● 16 языков | ? | ? | ● «seen on Fox TV, ABC, Mashable…» (заявление в описании) | ? | ● фарма-партнёрства (Boehringer Ingelheim/Pradaxa и др.) | ? | ? (не проверено: reddit.com недоступен) | ? |
| MyTherapy | ? | ? | ● 32 языка, локализованные titles (DE/FR/NL) | ? | ? | ? | ? | ● Merck, Novartis, Pfizer; связь с Redcare Pharmacy (по вторичному источнику) | ? | ? (не проверено: reddit.com недоступен) | ● family profiles (листинг) |
| Gentler Streak | ? | ? | ● 10 языков | ○ | ? | ● The Verge, Forbes, TechCrunch (по описанию) | ? | ? | ● ADA 2024 Social Impact, Apple Watch App of the Year 2022, Editors' Choice | ? (не проверено: reddit.com недоступен) | ? |
| Pill Buddy | ? (только каталог productcool) | ? | ✗ только EN | ? | ? (TikTok-присутствие не подтверждено) | ● 9to5Mac Indie App Spotlight 2025-06-07; Tuttotech 2025-06-09 | ? | — | ? | ? (не проверено: reddit.com недоступен) | ? |
| Cadence | ? | ? | ● 7 языков; ценовой subtitle | ? | ? | ? | ? | — | ? | ? (не проверено: reddit.com недоступен) | ? |
| Max – Pill reminder | ? | ? | ● 10 языков; DE-title «Max - Pillen Erinnerung» | ? | ? | ? | ? | — | ? | ? (не проверено: reddit.com недоступен) | ● «Share & Care: Invite family or friends to manage medication reminders together» (листинг) |
| WatchRipple | ? | ? | EN | ? | ? | ? | ? | — | ? | ? (не проверено: reddit.com недоступен) | ? |
| Indie med-apps на PH (GoodPill, PillMind, PillChime, PillRem, Pilly) | ● запуски (зеркало hunted.space) | ? | ? | ? | ? | ? | ? | — | ? | ? (не проверено: reddit.com недоступен) | ? |

Ключевые источники карты:
- Waterllama сайт ([waterllama.com](https://waterllama.com)): «Water tracker app», «Water reminder Apple Watch, iPhone, Widget», бейджи «Apple Design Award, App of the Day, AppsWeLove, Product Hunt, Vogue», калькулятор, ссылки на TikTok `@waterllama_app`, Instagram, Twitter.
- Вакансия Llama Luna Apps на [Djinni](https://djinni.co/jobs/835286-head-of-acquisition-and-growth-ios-apps/) (опубликована «3 July», год на странице не указан): influencer partnerships, «Organic UGC at scale: TikTok, Instagram, X, and Lemon8», «ASO and Apple Search Ads: full ownership». [FACT] это **требования к найму**, а не доказательство кампаний. Заявления компании: «8M+ combined downloads», команда из 10 человек.
- WaterMinder сайт ([waterminder.com](https://waterminder.com)): заявление «10M+ downloads» — [FACT] *компания заявляет*; блог ([blog.waterminder.com](https://blog.waterminder.com)).
- MacStories: [WaterMinder sponsor post](https://www.macstories.net/sponsored/waterminder-stay-hydrated-all-day-every-day-sponsor/), [обзор](https://www.macstories.net/reviews/track-your-water-consumption-with-waterminder/); 9to5Mac: [WaterMinder iOS 18 update](https://9to5mac.com/2024/09/30/waterminder-calory-ios-18-update/).
- Waterllama PR: [AIN.ua, 2022-06-06](https://en.ain.ua/2022/06/06/ukrainian-app-waterllama-among-the-apple-design-awards-finalists/) (основатели — украинская пара Vitalii и Polina Mogylevets; ADA finalist), [WRDW, 2026-07-07](https://www.wrdw.com/2026/07/07/what-tech-waterllama-makes-drinking-water-feel-less-like-chore/).
- Medisafe B2B: [MobiHealthNews — Boehringer Ingelheim / Pradaxa](https://www.mobihealthnews.com/news/boehringer-ingelheim-taps-medisafe-bundled-pradaxa-offering) (дата статьи не установлена).
- MyTherapy B2B: [smartpatient «We're Turning 10!»](https://www.smartpatient.eu/blog/smartpatient-at-ten-a-decade-of-digital-patient-engagement), [пресс-релиз Merck](https://edit.smartpatient.eu/blog/press-release-smartpatient-and-merck-announce-new-global-partnership-and-digital-companion). Заявления «9 млн / 12 млн пользователей» — [FACT] *компания заявляет*.
- Pill Buddy PR: [9to5Mac Indie App Spotlight, 2025-06-07](https://9to5mac.com/?p=1004129), [Tuttotech, 2025-06-09](https://www.tuttotech.net/news/2025/06/09/pill-buddy-app-ios-promemoria-medicine.html/amp); пост на [Indie Hackers](https://www.indiehackers.com/post/just-launched-a-cute-medicine-tracking-app-all-art-is-original-by-me-13e6a403f1) («just launched a cute medicine tracking app, all art is original by me») — содержимое недоступно (HTTP 403), только заголовок.
- PH indie-запуски (зеркало, данные снимков ранние): [GoodPill](https://hunted.space/product/goodpill), [PillMind](https://hunted.space/product/pillmind), [PillChime](https://hunted.space/product/pillchime), [PillRem](https://hunted.space/product/pillrem), [AQUAJOY](https://hunted.space/product/aquajoy), [IdroFlow](https://hunted.space/product/idroflow-water-tracker), [Hydrabit на PH](https://www.producthunt.com/products/hydrabit).

**Что подтверждено:** присутствие и отдельные активности в каналах (PR, спонсорство MacStories, блог WaterMinder, локализация названий, B2B-модели Medisafe/MyTherapy, Apple-награды).
**Что неизвестно:** вклад любого канала в установки и оплату у любого конкурента; наличие Apple Search Ads-кампаний (публичных рекламных библиотек для ASA нет); бюджеты.
**Уверенность:** высокая — что каналы существуют; низкая — что они работают.
**Что делать основателю:** копировать не «каналы лидеров», а дешёвые подтверждённые механики: локализованный title/subtitle, PR-питч indie-прессе, featuring nomination, полезную «инструментальную» страницу. Не копировать B2B-фарма-модель (недоступна соло-фаундеру на этой стадии).

---

## 3. Разбор 7 наиболее полезных маркетинговых примеров

### 3.1. Apple Medications — «бесплатный конкурент по умолчанию»

- [FACT] Добавление лекарств в Health на iPhone; логирование в Health или в приложении Medications на Apple Watch. На часах из уведомления: *Skipped*, *Taken*, *Remind Me in 10 Minutes*. Follow-up reminders через 30 минут. Сканирование этикетки и drug interactions — только США. ([Apple Support 105064](https://support.apple.com/en-us/105064))
- [UNKNOWN] Есть ли у Apple Medications complication/виджет с прогрессом доз — страница поддержки об этом не говорит. Это проверяется за 5 минут на собственных часах основателя.
- [FACT] Пользователь с ADHD описывает встроенную функцию как достаточную: «the Apple Watch specifically has Medication Reminders as a baked in feature» ([gomakethings.com](https://gomakethings.com/articles/apple-watch-and-adhd-medication-reminders/)).
- **Урок для Nuori** [INFERENCE]: любое сообщение «medication reminders on Apple Watch» сравнивается с бесплатным и предустановленным решением. Messaging должен называть то, чего у Apple нет или что неудобно: вода и лекарства в одном взгляде, логирование воды за 1 тап с запястья, отсутствие необходимости «копаться» в Health.

### 3.2. Pill Buddy — indie, маскот, пресса, US-рынок

- Discovery: [9to5Mac Indie App Spotlight](https://9to5mac.com/?p=1004129) (2025-06-07, ~2 недели после релиза 2025-05-21), итальянский Tuttotech (2025-06-09), пост на Indie Hackers.
- Message (App Store, оригинал): «A cute mascot that reminds you to take your medications & supplements on time. But watch out: he gets increasingly annoying if you miss a dose!»; «No ads, and your personal info stays private and protected».
- Механика удержания (описание): streaks, звёзды за своевременный приём, кастомизация маскота, напоминания push / phone calls / widgets.
- Результат: 1 775 рейтингов US за ~16,5 месяцев, почти 0 в ЕС (только EN-локализация).
- **Урок** [INFERENCE]: (1) indie-пресса (9to5Mac Indie App Spotlight) реально доступна соло-разработчику; (2) эмоциональная механика (маскот, «guilt») — сильный дифференциатор в скучной категории; (3) без локализации рост остаётся в англоязычных странах. Причинно-следственную связь «пресса → рейтинги» подтвердить нельзя [UNKNOWN].

### 3.3. Cadence — позиционирование через ценовую боль

- Subtitle (US): «Pill reminder, no monthly fee».
- Первые строки описания: «Every other medication reminder wants a monthly subscription. Cadence does not. Unlimited medications free, and one payment if you ever want the deeper features. That is the whole pricing model. No account, no ads, no renewal date.»
- Цена: Cadence Pro $9.99 one-time; Apple Watch; 7 языков; релиз 2026-02-19; 12 рейтингов US.
- **Урок**: [FACT] сообщение «no subscription / no account / data stays on device» уже занято как минимум одним свежим indie-конкурентом. [INFERENCE] Само по себе оно не создаёт тягу (12 рейтингов за ~8 месяцев), но это готовая формулировка для A/B-проверки ценностного сообщения. Схожий нарратив: maker GoodPill на PH — приложение создано после того, как конкурент закрыл базовые напоминания paywall'ом ([hunted.space](https://hunted.space/product/goodpill)).

### 3.4. WaterMinder — долгий бренд, контент, спонсорство, multi-platform

- Сайт: «The Water Tracker App That Builds A Daily Habit», «Drink More Water Without Having To Think About It», CTA «Build My Hydration Habit», «See how it works»; соц. доказательство «10M+ downloads», «4.7», «App Store Editors' Choice» ([waterminder.com](https://waterminder.com)).
- App Store: «Trusted by millions. Track water, coffee, tea, and more with smart reminders and Apple Watch support. Try every feature free for 7 days.»
- Контент: блог; в Aug–Sep 2025 — еженедельные посты, затем пауза ~10 недель, последние посты Dec 2025 – 2026-01-12; на 2026-10-09 новых постов на первой странице нет ~9 месяцев (темы: симптомы обезвоживания, кофеин, беременность, спортсмены) ([blog.waterminder.com](https://blog.waterminder.com)) — классическая SEO-кластеризация «hydration + X».
- Paid: спонсорский пост MacStories с CTA «visiting the app's website today» ([MacStories](https://www.macstories.net/sponsored/waterminder-stay-hydrated-all-day-every-day-sponsor/)). Цена спонсорства [UNKNOWN].
- **Урок** [INFERENCE]: SEO-контент WaterMinder строится годами (бренд с 2013). Соло-фаундеру стоит взять только идею «hydration + конкретная ситуация» и сделать 3–5 страниц, а не блог.

### 3.5. Waterllama — дизайн → Apple-награды → локализация → команда роста

- Сайт: «Water tracker app» / «Water reminder Apple Watch, iPhone, Widget»; калькулятор нормы воды; press kit (Google Drive); бейджи наград ([waterllama.com](https://waterllama.com)).
- App Store: «** 2022 APP STORE AWARD Winner ** ** 2022 APPLE DESIGN AWARD Finalist ** You know you need to drink more water!»; длинный список фич: Challenges, 140 персонажей, «Track Calories», Apple Watch, widgets, Siri.
- Локализация: 22 языка, DE-title «Wasser trinken Erinnerung Lama» (результат поиска DE storefront).
- Рост: судя по вакансии — переход к UGC/influencer/ASA-модели с командой из 10 человек [FACT: намерение по вакансии; эффективность UNKNOWN].
- **Урок**: [INFERENCE] ранний рост этой украинской пары разработчиков, вероятно, связан с качеством продукта + Apple-признанием, но публичных данных о первых пользователях нет [UNKNOWN]. Переносимое: press kit, калькулятор как SEO/шэр-актив, локализованный title, Apple featuring.

### 3.6. MyTherapy / Medisafe — B2B-дистрибуция (не копировать, но понять)

- MyTherapy: бесплатно и без рекламы для пациента; деньги — программы для фармы (Merck, Novartis, Pfizer), агрегированные данные; заявленные 9–12 млн пользователей ([smartpatient](https://www.smartpatient.eu/blog/smartpatient-at-ten-a-decade-of-digital-patient-engagement)).
- Medisafe: «wraparound app experience» для пациентов Pradaxa по партнёрству с Boehringer Ingelheim ([MobiHealthNews](https://www.mobihealthnews.com/news/boehringer-ingelheim-taps-medisafe-bundled-pradaxa-offering)).
- **Урок** [INFERENCE]: крупные medication-приложения получают пользователей через врачей/фарму/аптеки, а не через PH/TikTok. Для Nuori — это аргумент против конкуренции «в лоб» за «medication management» и за узкий consumer-сценарий. Привлечение через локальные аптеки/врачей в Польше — теоретически возможная offline-гипотеза, но с регуляторными рисками и долгим циклом [HYPOTHESIS, низкий приоритет].

### 3.7. Söka и PH-кейсы — что реально даёт запуск соло-разработчика

- Söka (indie iOS, 2023): 270+ бета-тестеров к запуску через TestFlight + соцсети; 300+ загрузок за 2 дня «mostly from social media»; Product Hunt — «no real benefit»; 20 журналистов — 0 публикаций; Mastodon (~400 подписчиков) работал лучше Twitter (~3 000) ([ретроспектива](https://roddymunro.substack.com/p/soka-launch-retrospective)).
- ASO.dev: первый PH-запуск — 69 голосов и top-10 дня, команда сочла его провалом ([Medium](https://medium.com/@gorniv/how-we-launched-on-producthunt-twice-insights-and-lessons-454668eb6ca6)).
- Индикатор для соло-разработчика (комментарий на Indie Hackers к посту разработчика supplement-трекера без пользователей): найти людей, которые уже обсуждают проблему (забывают дозы, путаются в добавках), и помогать им до упоминания приложения; 100 реальных пользователей для ниши может занять 3–6 месяцев ([Indie Hackers](https://www.indiehackers.com/post/solo-dev-here-nobody-using-my-app-how-do-you-actually-do-marketing-4e4bfad079)) — это мнение одного комментатора [ESTIMATE, низкая надёжность].

**Что подтверждено:** тексты позиционирования, цены SKU, публикации в прессе, содержание ретроспектив.
**Что неизвестно:** вклад каждой активности в установки/выручку.
**Уверенность:** средняя (качественные паттерны повторяются в нескольких источниках, количественных подтверждений нет).
**Что делать:** использовать как шаблоны для своих экспериментов (разделы 8–9): indie-press pitch, ценовой/приватный message-тест, маскот/streak — только как гипотеза удержания, без разработки до проверки.

---

## 4. Воронки от discovery до оплаты

Ни один paywall/onboarding не наблюдался напрямую; этапы после установки — реконструкция по описанию App Store и публичным материалам, помечены соответственно.

### 4.1. WaterMinder

| Этап | Что видит пользователь / обещание | Источник / статус |
|---|---|---|
| Discovery | Поиск App Store («water tracker»), Editors' Choice, пресса (MacStories, 9to5Mac), блог, спонсорство MacStories | [FACT] присутствие; доля каналов [UNKNOWN] |
| Message | «Drink More Water Without Having To Think About It»; «Trusted by millions» | [FACT] сайт/App Store |
| Landing / App Store | CTA «Build My Hydration Habit»; 4.7, 35K рейтингов (US); цитаты прессы | [FACT] |
| Возражения | «сложно/лень» → «без раздумий»; «работает ли» → «millions», награды | [INFERENCE] |
| Install → Onboarding | Цель «Based on your body weight (or your personal goal)» | [FACT] описание; экраны не видели |
| Aha | Визуальное «заполнение» и процент гидратации | [FACT] описание |
| Paywall | «Try every feature free for 7 days»; Monthly $2.99, Yearly $14.99 (Offer $7.49), Lifetime $49.99 (US) | [FACT] SKU; показ paywall [UNKNOWN] |
| Retention | Reminders, Watch complications, widgets, achievements | [FACT] фичи; retention [UNKNOWN] |

### 4.2. Waterllama

| Этап | Что видит пользователь | Статус |
|---|---|---|
| Discovery | Apple-награды/featuring, TikTok/IG-аккаунты, локализованный поиск (22 языка), калькулятор на сайте, ТВ-сюжет 2026 | [FACT] присутствие; эффективность [UNKNOWN] |
| Message | «You know you need to drink more water!»; персонажи, челленджи | [FACT] |
| App Store | «2022 APP STORE AWARD Winner», 4.9, 163K рейтингов | [FACT] |
| Onboarding | Цель по «weight, activity & weather» | [FACT] описание |
| Aha | Каждый напиток «заполняет» персонажа-ламу | [FACT] по описанию и вторичному источнику |
| Paywall | SKU $0.99–$19.99; точная структура [UNKNOWN] | |
| Retention | Challenges, streaks, monthly in-app events, коллекция 140 персонажей | [FACT] фичи |

### 4.3. Medisafe

| Этап | Что видит пользователь | Статус |
|---|---|---|
| Discovery | Врач/фарм-программа, App Store поиск, «seen on Fox TV, ABC…» | [FACT] заявления; доли [UNKNOWN] |
| Message | «Never forget another medication»; страх: «125,000 deaths a year (one every 4 minutes)» | [FACT] описание App Store |
| Возражения | Безопасность → drug interaction warnings (US), импорт из Health Records | [FACT] |
| Paywall | Monthly $2.99–$9.99, Yearly $27.99–$39.99 (US) | [FACT] SKU; показ [UNKNOWN] |
| Retention | Ежедневные напоминания, «Medfriend»/семья — [UNKNOWN] без установки | |

### 4.4. Pill Buddy

| Этап | Что видит пользователь | Статус |
|---|---|---|
| Discovery | 9to5Mac Indie App Spotlight, Indie Hackers, поиск App Store по «cute pill reminder» | [FACT] публикации; вклад [UNKNOWN] |
| Message | «A cute mascot… he gets increasingly annoying if you miss a dose!» | [FACT] |
| Aha | Маскот реагирует на первую отмеченную дозу | [INFERENCE] по описанию и 9to5Mac |
| Paywall | «Supporter» $4.99/мес, $35.90/год — формулировка «поддержать», а не «разблокировать» | [FACT] SKU; что за paywall'ом [UNKNOWN] |
| Retention | Streaks, звёзды, кастомизация, телефонные звонки-напоминания | [FACT] |

### 4.5. Cadence

| Этап | Что видит пользователь | Статус |
|---|---|---|
| Message | «Pill reminder, no monthly fee» | [FACT] |
| Возражения | Подписочная усталость, приватность («No account, no servers, no ads») | [FACT] |
| Onboarding | «Scan a prescription label to add medications instantly» | [FACT] описание |
| Paywall | Free: unlimited meds; Pro $9.99 one-time — insights, Apple Health корреляции, PDF export | [FACT] описание + SKU |
| Retention | «Confirm, skip or snooze from the lock screen without opening the app» | [FACT] |

### 4.6. Метрики, которые Nuori должен измерять сам (вместо чужих конверсий)

Публичных конверсий по этим приложениям нет; подставлять чужие «средние по рынку» нельзя. Минимальный набор для Nuori (без сторонней аналитики — через App Store Connect / TestFlight + локальные счётчики, которые пользователь сам может отправить, или короткий опрос):

| Этап | Метрика | Откуда |
|---|---|---|
| Discovery → визит | Установки по отдельной TestFlight public link на канал/вариант (без UTM и трекинг-скриптов — landing обещает «no tracking») | Отдельная external-группа + public link на канал |
| Визит → установка | Установки TestFlight по каждой public link; позже App Store Connect «Product Page Views → First-Time Downloads» | TestFlight, App Store Connect Analytics |
| Активация | % пользователей, сделавших 1-й лог воды **и** добавивших ≥1 лекарство в первые 24 ч | Опрос/внутренний счётчик |
| Watch-активация | % установивших Watch-app и добавивших complication | Опрос + вопрос в интервью |
| Retention | D1/D7/D14 «логировал хотя бы раз» отдельно для воды и для лекарств | Внутренний счётчик (локально) + self-report |
| Ценность | «Насколько расстроитесь, если Nuori исчезнет?» (very / somewhat / not) | Опрос после 14 дней |
| WTP | Клик по fake-door «Nuori Pro» / предзаказ / ответ на ценовой опрос | Landing page, опрос |

**Что подтверждено:** публичные части воронок (message, App Store, SKU, фичи удержания).
**Что неизвестно:** все конверсии, trial-to-paid, retention, реальные paywall-экраны.
**Уверенность:** средняя для качественной реконструкции; любые количественные выводы — невозможны.
**Что делать:** до запуска в App Store установить измерение по таблице 4.6 — без этого ни один канал не будет оценим.

---

## 5. Swipe file (оригинальные тексты, с прямыми ссылками)

| # | Источник / ссылка | Дата | Оригинальный текст | ЦА | CTA | Механика | Воспроизводимость для Nuori |
|---|---|---|---|---|---|---|---|
| 1 | [Cadence, App Store subtitle](https://apps.apple.com/us/app/id6758649306) | доступ 2026-10-09 | «Pill reminder, no monthly fee» | Уставшие от подписок | Get | Ценовой анти-message в subtitle (индексируется ASO) | Высокая: тест subtitle/landing |
| 2 | [Cadence, описание](https://apps.apple.com/us/app/id6758649306) | там же | «Every other medication reminder wants a monthly subscription. Cadence does not.» | То же | — | Позиционирование против категории | Высокая, но занято |
| 3 | [Pill Buddy, описание](https://apps.apple.com/us/app/id6742357512) | там же | «But watch out: he gets increasingly annoying if you miss a dose!» | Молодые взрослые, supplements | — | Юмор + эмоция, shareable | Средняя: требует арт/маскота |
| 4 | [9to5Mac Indie App Spotlight: Pill Buddy](https://9to5mac.com/?p=1004129) | 2025-06-07 | «'Pill Buddy' is a really fun way to keep track of your medicines» | Читатели Apple-прессы | Ссылка на App Store | Indie-press pitch | Высокая: бесплатный питч |
| 5 | [WaterMinder, сайт](https://waterminder.com) | доступ 2026-10-09 | «Drink More Water Without Having To Think About It» / CTA «Build My Hydration Habit» | Общая аудитория гидратации | Build My Hydration Habit | Habit-framing | Средняя (общая ниша) |
| 6 | [WaterMinder, App Store](https://apps.apple.com/us/app/id653031147) | там же | «Try every feature free for 7 days.» | — | — | Trial в первых строках описания | Только при подписке |
| 7 | [Waterllama, сайт](https://waterllama.com) | там же | «Water reminder Apple Watch, iPhone, Widget» + калькулятор | Поиск «water reminder apple watch» | GET | SEO-заголовок = ключевой запрос + инструмент | Высокая: калькулятор/страница |
| 8 | [Waterllama, App Store](https://apps.apple.com/us/app/id1454778585) | там же | «You know you need to drink more water!» | — | — | Признание проблемы пользователем | Средняя |
| 9 | [Waterllama DE title — поиск DE storefront](https://itunes.apple.com/search?term=Wasser%20trinken%20Erinnerung&country=de&entity=software) | там же | «Wasser trinken Erinnerung Lama» | DE | — | Локализованный title под запрос | Высокая: PL/DE/UA titles |
| 10 | MyTherapy titles — поиск [DE](https://itunes.apple.com/search?term=Tabletten%20Erinnerung&country=de&entity=software), [FR](https://itunes.apple.com/search?term=rappel%20m%C3%A9dicament&country=fr&entity=software), [NL](https://itunes.apple.com/search?term=medicijn%20herinnering&country=nl&entity=software) | там же | «MyTherapy Tabletten Erinnerung», «MyTherapy Rappel de Médicament», «Medicijn en Pil Herinnering» | Локальные рынки | — | То же | Высокая |
| 11 | [Medisafe, App Store](https://apps.apple.com/us/app/id573916946) | там же | «Never forget another medication.» + «125,000 deaths a year (one every 4 minutes)» | Пациенты с Rx, US | — | Страх/безопасность | Низкая: медицинские claims рискованны для Nuori |
| 12 | [Gentler Streak, App Store](https://apps.apple.com/us/app/id1576857102) | там же | «For those of us who want to move consistently, not constantly. Built with care by a small indie team.» / «PRIVATE DATA STAYS PRIVATE» | Watch-владельцы, усталость от «жёсткого» фитнеса | — | Ценностный тон + indie + приватность | Высокая по тону |
| 13 | [Max – Pill reminder, App Store](https://apps.apple.com/us/app/id1502063556) | там же | «Now you can easily look after your parents' meds from afar. No more daily "Did you take your pills?" calls!» | Взрослые дети пожилых родителей | — | Caregiver-сценарий | Низкая сейчас (Nuori — локальные данные, нет шаринга) |
| 14 | [WatchRipple, App Store](https://apps.apple.com/us/app/id6747939802) | там же | «Track water intake and medication compliance effortlessly…» / «DESIGNED FOR APPLE WATCH» | Watch-владельцы | — | Прямой аналог Nuori | Анти-пример: позиционирование без дистрибуции |
| 15 | [Söka, ретроспектива](https://roddymunro.substack.com/p/soka-launch-retrospective) | 2023-06-04 | «From what I can tell, there was no real benefit to using Product Hunt.» | — | — | Урок по PH | — |
| 16 | [GoodPill, PH (зеркало)](https://hunted.space/product/goodpill) | дата [UNKNOWN] | Приложение создано после того, как конкурент перенёс базовые напоминания за paywall (пересказ, не цитата) | Пользователи, обиженные paywall'ом | — | Нарратив «я сделал это, потому что…» | Высокая для founder story |
| 17 | [Plant Nanny, App Store](https://apps.apple.com/us/app/id1424178757) | там же | «"Making Drinking Fun Again."-TGDaily» | — | — | Цитата прессы в первой строке описания | Высокая после первой публикации |

**Что подтверждено:** все тексты — дословно с указанных страниц (кроме #16 — пересказ, помечен).
**Что неизвестно:** какой из этих messages конвертирует лучше; A/B-результаты конкурентов не публичны.
**Уверенность:** высокая в достоверности текстов, низкая — в их эффективности.
**Что делать:** использовать #1, #3, #7, #9, #12 как основу для своих message-тестов (8.6).

---

## 6. Сравнение каналов для Nuori

Оценки 1–5 — **[INFERENCE]/[ESTIMATE]** автора отчёта на основе собранных кейсов, а не измеренные данные. Время — оценка.

| Канал | Стоимость запуска | Время до 1-го результата (оценка) | Личный доступ к аудитории | Релевантность аудитории | Измеримость | Повторяемость/масштаб | Главные риски |
|---|---|---|---|---|---|---|---|
| Ручной рекрутинг в нишевых сообществах (Reddit, Discord, FB-группы, форумы) | $0 | дни | 5 | 4–5 (если ниша выбрана) | 4 (отдельная TestFlight-ссылка) | 2 | Бан за self-promo; время фаундера |
| Личная сеть + университет (PL) | $0 | дни | 5 | 2–3 (нерелевантные «друзья») | 4 | 1 | Ложно-позитивная обратная связь |
| Текущие 12 TestFlight-тестировщиков (интервью, рефералы) | $0 | дни | 5 | неизвестно | 5 | 2 | Малая выборка |
| ASO + локализованный листинг (EN/PL/UK/DE) | $0 | недели после релиза | 1 | 4 (намеренный поиск) | 4 (App Store Connect) | 5 | Конкуренция в EN; API-выдача ≠ реальность |
| Apple featuring nomination | $0 | ≥2 недели lead time, рекомендовано до 3 мес. | 1 | 3 | 3 | 2 | Непредсказуемо; эффект [UNKNOWN] |
| Indie-press pitch (9to5Mac Indie App Spotlight, MacStories, местная пресса PL/UA) | $0 | 1–4 недели | 3 | 3 | 3 (всплеск в аналитике) | 2 | Нет гарантии публикации (Söka: 0 из 20) |
| SEO (страницы-инструменты, кластеры) | $0 (уже есть GitHub Pages) | месяцы | 1 | 3–4 | 3 | 5 | Долгий цикл, зрелые конкуренты |
| Founder-led соцсети (X/Threads/LinkedIn/TikTok) | $0 | недели–месяцы | 3 | 2–3 | 3 | 3–4 | Маленькая аудитория на старте; время |
| Short-form видео (TikTok/Reels/Shorts) | $0 | недели | 2 | 2–3 | 2 | 4 | Алгоритм, высокая дисперсия, временные затраты |
| Product Hunt | $0 | 1 день | 2 | 2 (мейкеры, не пациенты) | 3 | 1 | Слабые подтверждения для iOS consumer, спам |
| Apple Ads (Basic CPI / Advanced CPT) | от ~$50–100 тест (оценка) | дни | 1 | 4 | 5 | 4 | CPI/CPT по нишевым ключам [UNKNOWN]; без paywall не окупается |
| Micro-creators | $0 (бартер) – $$ | недели | 2 | 3 | 3 | 3 | Цены [UNKNOWN], медицинские claims |
| B2B (аптеки, врачи, фарма) | высокая (время) | месяцы | 2 | 5 | 3 | 4 | Регуляторика (MDR/ЕС), длинный цикл — не сейчас |

Факты, на которых основаны строки: Apple Ads — модели «Basic (cost-per-install): Pay only for installs at a cost you choose» и «Advanced (cost-per-tap)», лимит Basic «Up to $10,000 (U.S.) per app, per month», минимальный бюджет на странице не указан ([Apple Ads pricing](https://ads.apple.com/app-store/help/advanced/0003-how-pricing-works)); PL, DE, FR, NL, UK, US — в списке стран Apple Ads без разделения Basic/Advanced ([countries and regions](https://ads.apple.com/app-store/countries-and-regions)). Featuring — минимум 2 недели, рекомендовано до 3 месяцев, критерии включают «Localization» и «App Store product page» ([Apple Developer](https://developer.apple.com/app-store/getting-featured/)).

### 6.1. Оценка гипотез основателя

| Гипотеза основателя | Вердикт | Обоснование |
|---|---|---|
| **Product Hunt** | Не первый канал; позже, как credibility-точка | [FACT] Söka — без измеримого эффекта; medication-запуски в зеркале hunted.space — 0 голосов в снимках; бенчмарки Smol Launch (200–400 голосов «средний» день, кейс Tally — 3 900 визитов/766 пользователей) относятся к web-продуктам ([Smol Launch](https://smollaunch.com/guides/launching-on-product-hunt), вторичный источник, [ESTIMATE]). Аудитория PH — мейкеры, а не люди, пропускающие лекарства. |
| **SEO** | Да, но узко: 1 страница-инструмент + 3–5 страниц под ситуации; ожидать эффект через месяцы | [FACT] Даже WaterMinder (с 2013 г.) не удерживает регулярность блога: последний пост на первой странице — 2026-01-12; Waterllama вместо блога держит калькулятор. [INFERENCE] Регулярный блог — дорогой канал даже для команды; соло-фаундеру — только страницы-инструменты. Поисковый спрос по ключам [UNKNOWN] (данных SEO-инструментов нет). |
| **Личные соцсети** | Да как «журнал разработки» и поддержка других каналов; не как основной источник пользователей на старте | [FACT] у Söka установки за 2 дня пришли «mostly from social media», но при 270+ бета-тестерах и существующей аудитории. Размер аудитории основателя [UNKNOWN]. |

**Что подтверждено:** модели и лимиты Apple Ads, правила featuring, отдельные кейсы PH/соцсетей.
**Что неизвестно:** CPI/CPT в нише, поисковые объёмы, размер и вовлечённость личной аудитории основателя, эффект featuring для Nuori.
**Уверенность:** средняя в ранжировании для стадии «первые 50–100 релевантных пользователей»; низкая в любой оценке масштаба.
**Что делать:** первые 30 дней — каналы с личным доступом и максимальной измеримостью (ручной рекрутинг + текущие тестировщики); параллельно готовить ASO-листинг и featuring nomination к релизу.


---

## 7. Рекомендация: два первых канала для Nuori

### Канал 1 — Founder-led ручной рекрутинг в узких сообществах + текущие тестировщики

**Что:** лично найти 25–50 людей с конкретной ситуацией (ежедневные лекарства/добавки + носят Apple Watch), дать им отдельную TestFlight public link (требует external-группы и прохождения TestFlight App Review — см. неделю 1 в разделе 9), провести 10–15 коротких интервью.

**Почему первым:**
- [FACT] Nuori сейчас в TestFlight, App Store-листинга нет — ASO и Apple Ads пока недоступны как источник.
- [FACT] Индивидуальный доступ и максимальная измеримость (отдельная public link на сообщество).
- [INFERENCE] Главный неизвестный параметр — не «какой канал масштабируется», а «для кого Nuori ценен». Его отвечает только разговор с релевантными людьми. Без этого любой масштабируемый канал будет оптимизировать неправильный message.
- [FACT] Совет из indie-сообщества: искать людей, уже обсуждающих проблему (забытые дозы, путаница с добавками), и помогать им до упоминания продукта ([Indie Hackers](https://www.indiehackers.com/post/solo-dev-here-nobody-using-my-app-how-do-you-actually-do-marketing-4e4bfad079)) — одно мнение, низкая надёжность.

### Канал 2 — Локализованный ASO + Apple featuring nomination + indie-press pitch (к публичному релизу)

**Что:** один пакет «App Store-релиза»: title/subtitle/keywords на EN, PL, UK (+ DE как тест), скриншоты с главным message, featuring nomination в App Store Connect, питч 9to5Mac Indie App Spotlight и 3–5 изданиям/блогерам PL/UA.

**Почему вторым:**
- [FACT] Лидеры в ЕС локализуют title под запрос (Waterllama DE, MyTherapy DE/FR/NL).
- [FACT] Apple явно называет «Localization» и «App Store product page» критериями featuring; нужно ≥2 недель, лучше до 3 месяцев.
- [FACT] Nuori уже локализован на EN/RU/UK/PL — [INFERENCE] заметное преимущество для indie на старте (Pill Buddy — только EN; но Cadence — 7 языков, так что это не уникально).
- [FACT] 9to5Mac опубликовал Pill Buddy через ~2 недели после релиза.
- [INFERENCE, слабая] PL-выдача по medication-запросам в API выглядит менее конкурентной, чем US.

**Почему не PH / SEO / соцсети первыми:** см. 6.1. Соцсети основателя — вспомогательный канал для обоих (журнал разработки, призыв к тестированию), SEO — одна страница-инструмент как долгосрочная ставка.

**Что подтверждено:** состояние продукта (TestFlight), тактики лидеров по локализации, правила featuring, пример indie-прессы.
**Что неизвестно:** конверсия любого из каналов для Nuori; отклик сообществ на конкретные сообщения; реальная конкуренция в PL-выдаче.
**Уверенность:** средняя. Канал 1 — высокая в полезности для обучения, низкая в объёме. Канал 2 — средняя: зависит от качества листинга и случайности (featuring, пресса).
**Что делать:** неделя 1–2 — канал 1; неделя 3–4 — готовить канал 2 параллельно с итерацией продукта; публичный релиз — после того, как ≥10 тестировщиков отметят ценность (критерии дня 30 в разделе 9).

---

## 8. Приоритизированные эксперименты (12)

Прогнозы просмотров/установок/оплат не даются. Пороги — стартовые критерии решения, а не обещание результата. Время фаундера — **[ESTIMATE]**.

| # | Гипотеза | ICP / потребность | Канал | Message | Asset | CTA | Бюджет | Время | Этап воронки | Метрика успеха | Стоп / продолжить | Если + / если − | Основание приоритета |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Текущие 12 тестировщиков дадут ясный сигнал, кто из них «core user» | Существующие тестировщики | Личный контакт | «Помогите решить, что убрать» | 15-мин интервью + опрос «если Nuori исчезнет» | Записаться на звонок | $0 | 4–6 ч | Ценность, retention | ≥5 интервью; доля «very disappointed» | Продолжить при ≥3 «very disappointed» с общей ситуацией | + : описать их ситуацию как ICP-черновик; − : вывод «нет core user» → менять сегмент поиска | Самая дешёвая информация |
| 2 | Существует сегмент «ежедневные лекарства/добавки + Apple Watch», который хочет воду и лекарства в одном взгляде | Взрослые с ежедневным приёмом + Watch | 3–5 нишевых сообществ (по правилам) | Message A (см. 8.6) | Пост-вопрос «как вы помните о таблетках на часах?» + ссылка только в ответ/по разрешению | Join TestFlight | $0 | 6–8 ч | Discovery → install | ≥10 установок по ссылке сообщества; ≥30% логируют ≥3 дней из 7 | Стоп при <3 установок после 2 постов в сообществе | + : удвоить в похожих сообществах; − : пробовать сегмент из #3 | Гипотеза основателя + Apple-пробел требует проверки |
| 3 | Сегмент «supplements / gym stack» (креатин, витамины + вода) ценит быстрые лог-кнопки | Тренирующиеся 18–35, Watch | Gym/supplement-сообщества | Message C (см. 8.6) | Пост + 20-сек видео логирования с запястья | Join TestFlight | $0 | 6 ч | Discovery → активация | То же, что #2 | То же | + : позиционировать как «daily stack»; − : исключить сегмент | [FACT] существуют нишевые «Water & Creatine» приложения (напр. Hydra Fuel, 14 рейтингов) — спрос не доказан |
| 4 | Польскоязычный сегмент реагирует лучше (локализация + меньшая конкуренция) | PL-пользователи iPhone/Watch | PL-группы, Wykop, университет, личная сеть | Message A/B на польском | Пост PL + landing PL | Dołącz do testów | $0 | 4 ч | Discovery → install | Конверсия «клик → установка» выше, чем у EN-постов | Сравнить после ≥50 кликов на группу | + : PL как стартовый рынок для ASO; − : EN/US фокус | [INFERENCE] по выдаче API; слабая |
| 5 | «No subscription, no account, private» конвертирует лучше, чем функциональный message | Privacy-/subscription-уставшие | Landing page (docs/ GitHub Pages) | Message B vs A | 2 отдельные страницы-варианта hero (без трекинг-скриптов — landing обещает «no tracking»), у каждой своя TestFlight public link | Join TestFlight | $0 | 3 ч | Message → install | Установки по public link каждого варианта (TestFlight показывает установки по группе/ссылке) | После ≥20 установок суммарно или 3 недель | + : в subtitle/скриншоты; − : не использовать как главный | [FACT] Cadence и GoodPill используют этот нарратив |
| 6 | Готовность платить существует, и формат известен | Активные тестировщики (≥7 дней) | In-app / опрос | «Nuori Pro: one-time vs yearly» | Fake-door экран или опрос Van Westendorp-lite (4 вопроса) | «Хочу Pro» / указать цену | $0 | 4 ч | Paywall (WTP) | ≥30% активных кликают/называют цену > 0 | После ≥15 ответов | + : определить модель к релизу; − : free + tip jar | Платящих нет; цены конкурентов $2.99–$49.99 |
| 7 | Featuring nomination даст шанс на редакционное внимание | — | App Store Connect | Локализация 4 языка, Watch-first, приватность | Nomination + промо-ассеты | — | $0 | 3 ч | Discovery | Подано за ≥2 недели (лучше 6–12) до релиза | — (дешёвая ставка) | + : использовать бейдж; − : без последствий | [FACT] правила Apple |
| 8 | Indie-пресса опубликует короткий обзор | Читатели Apple-медиа | Email-питч | Founder story + что умеет на часах | Press kit (скриншоты, GIF Watch, 3 абзаца) | Promo code / TestFlight | $0 | 5 ч | Discovery | ≥1 публикация из 10 питчей | Стоп после 15 питчей без ответа → менять угол | + : цитата в описание (как Plant Nanny); − : менять историю | [FACT] 9to5Mac/Pill Buddy; Söka 0/20 — высокая дисперсия |
| 9 | Страница-инструмент «Water goal calculator» привлечёт органический трафик | Ищущие «how much water should I drink» | SEO | «Calculate your water goal — then track it from your wrist» | 1 страница-калькулятор EN + PL | Get Nuori / Join beta | $0 | 6–8 ч | Discovery | Индексация + первые показы в Search Console за 6–8 недель | Оценить через 8–12 недель | + : 3–5 страниц кластера; − : SEO заморозить | [FACT] Waterllama делает так же; спрос [UNKNOWN] |
| 10 | Founder build-in-public приводит релевантных людей, а не только разработчиков | — | X/Threads/LinkedIn | Журнал: решения, ошибки, данные тестов | 2 поста/неделю, 1 GIF с часов | «Ищу 10 человек, которые…» | $0 | 2 ч/нед | Discovery | Доля релевантных (не-разработчиков) среди пришедших | После 4 недель | + : продолжать; − : оставить как поддерживающий | [FACT] Söka: соцсети дали основную часть загрузок, но при готовой аудитории |
| 11 | Apple Ads на 3–5 точных ключах даёт измеримый CPI в PL/UK | Намеренный поиск | Apple Ads Advanced (CPT) или Basic (CPI) | Листинг | Exact-match кампания, 2 недели | Install | $50–$100 [ESTIMATE] | 3 ч | Install | Фактический CPI и конверсия листинга | Только после релиза и paywall | + : основа unit-экономики; − : стоп, ASA позже | Модели [FACT]; CPI [UNKNOWN] |
| 12 | Product Hunt даёт credibility и отзывы, а не пользователей | Мейкеры/ранние адоптеры | Product Hunt | «Watch-first water + meds, private, no account» | Листинг, GIF, первый комментарий-история | Get on App Store | $0 | 8–10 ч | Discovery / доверие | Отзывы/комментарии, не голоса | Только при выполнении условий 8.1 | — | [FACT] слабые свидетельства для iOS consumer |

### 8.1. Подготовка к Product Hunt — что должно быть до запуска

Запуск имеет смысл, когда выполнены условия (пороги — [HYPOTHESIS], их задаёт сам основатель):
1. Приложение публично в App Store (PH-трафику нужна кнопка «Get», а не TestFlight).
2. Есть ≥10 активных пользователей, которые логируют ≥5 из 7 дней, и ≥3 цитаты, которые можно процитировать (с разрешения).
3. Победивший message из эксперимента #5 и #2/#3 (не «трекер всего»).
4. Готовы: 1 GIF/видео логирования с часов (≤20 сек), 4–5 изображений, первый комментарий фаундера (история «почему» + что *не* умеет), ответ на вопрос «чем лучше Apple Health Medications».
5. Список из 30–50 людей, лично знающих продукт (тестировщики, сообщества), которых можно уведомить — без накрутки голосов (правила PH и риск спама описаны в [ретроспективе Söka](https://roddymunro.substack.com/p/soka-launch-retrospective)).
6. Тайминг: избегать WWDC/сентябрьских релизов Apple — Söka связывает отсутствие прессы с запуском рядом с WWDC.

**Метрика PH:** установки по отдельной ссылке (campaign link App Store Connect) + качественные комментарии, а не место в рейтинге.

### 8.2. SEO-кластеры, которые реально сделать одному

[UNKNOWN] Поисковые объёмы — данных SEO-инструментов нет; первая задача — проверить ключи в Google Search Console/Keyword Planner (бесплатно) после публикации страниц. Кластеры ниже — [HYPOTHESIS].

| Кластер | Пример страницы (EN) | PL-вариант | Asset | Почему |
|---|---|---|---|---|
| Инструмент «норма воды» | «How much water should I drink? Calculator» | «Ile wody dziennie pić — kalkulator» | Калькулятор на JS на текущем GitHub Pages | Waterllama использует; полезно и шэрится |
| «Apple Watch + вода» | «How to track water on Apple Watch (with and without apps)» | «Jak liczyć wodę na Apple Watch» | Честный гайд, включая встроенные возможности | Намерение = владелец часов |
| «Apple Watch + лекарства» | «Apple Watch medication reminders: built-in Medications vs apps» | «Przypomnienia o lekach na Apple Watch» | Сравнение с Apple Medications, честно | Пользователь уже выбирает; [FACT] Apple — бесплатная альтернатива |
| «Ситуации» | «Remember vitamins and water every morning»; «Daily supplement stack tracker» | аналог | 1 страница на ситуацию | Под ICP из экспериментов #2/#3 |
| Сравнения | «Nuori vs WaterMinder / Waterllama / Apple Health» | — | Таблица фактов | Поздняя стадия, после релиза |

Правила: без медицинских обещаний; 1 страница в неделю максимум; не блог «о пользе воды» (зрелая ниша WaterMinder).

### 8.3. Построение founder-led канала

- Платформы: одна основная (выбрать там, где основатель уже имеет хоть какую-то аудиторию [UNKNOWN]), одна вторичная. Mastodon/iOS-dev сообщество давал Söka лучшую вовлечённость, чем Twitter — единичный кейс.
- Формат 2×/неделю: (1) «что я узнал от тестировщиков» с цифрами; (2) короткий GIF «лог за 2 секунды с часов»; (3) решение и почему (например, «почему калории не в фокусе»).
- Каждый 3-й пост — конкретный призыв: «Ищу 10 человек, которые принимают таблетки/витамины ежедневно и носят Apple Watch».
- Метрика: не лайки, а количество релевантных людей, ставших тестировщиками (отдельная TestFlight-ссылка).

### 8.4. Ручной поиск первых 25–50 релевантных тестировщиков

1. Выбрать 2 сегмента для параллельной проверки (например, «ежедневные лекарства + Watch» и «supplement stack + Watch»).
2. Найти 8–10 сообществ (subreddit, Discord, FB-группы, польские форумы, университетские чаты). **Сначала прочитать правила self-promotion вручную** — reddit.com автоматически недоступен, правила [UNKNOWN].
3. Для каждого: отдельная TestFlight public link (или короткая ссылка с меткой), чтобы считать установки по сообществу.
4. Сначала вопрос/помощь, затем предложение: «Делаю бесплатное приложение под эту ситуацию, ищу 10 тестировщиков, которые дадут честный фидбек через неделю».
5. DM/email только тем, кто сам описал проблему; шаблон — в 8.6.
6. Через 7 дней — 3 вопроса: что логировали; что раздражало; что бы сделали, если Nuori исчезнет.
7. Стоп-критерий по сообществу: <3 установок после 2 честных попыток.

### 8.5. Отзывы и кейсы от текущих 12 тестировщиков

- Сегментировать 12 по факту использования (если данные есть) или по самоотчёту: кто логирует воду, кто лекарства, кто часы.
- Интервью 15 мин (5 вопросов): последний раз, когда забыли лекарство/воду, — что произошло; что использовали до Nuori; что в Nuori используете чаще всего; что бы убрали; сколько бы заплатили/как.
- Опрос «If Nuori disappeared tomorrow, how would you feel?» (very / somewhat / not disappointed) + «кому бы порекомендовали».
- Попросить у довольных: 1 цитату с разрешением, 1 скрин complication на их циферблате, 1 рекомендацию знакомому (реферал вручную).
- Результат — 3–5 «мини-кейсов» (ситуация → как Nuori помогает) для landing, PH и прессы.

**Что подтверждено:** механики конкурентов, на которых основаны эксперименты; правила Apple Ads/featuring.
**Что неизвестно:** результат любого эксперимента для Nuori; правила конкретных сообществ; поисковые объёмы.
**Уверенность:** средняя в порядке приоритетов (от дешёвой информации к масштабируемым каналам); низкая в исходах.
**Что делать:** запустить #1, #2, #3, #5 в первые 2 недели; #6–#9 — недели 3–4; #11–#12 — только после релиза.

### 8.6. Позиционирования и тексты для теста (Stage G)

Все тексты — **[HYPOTHESIS]**. Никакой вариант не считается лучшим до данных эксперимента #5.

Важно: «Taken / Snooze / Skip в уведомлении» **нельзя** подавать как уникальное — у Apple Medications на Watch есть Taken / Skipped / Remind Me in 10 Minutes ([Apple Support](https://support.apple.com/en-us/105064)).

#### A. «Water + meds в одном взгляде на запястье» (гипотеза основателя)

- Landing headline: **«Your water and your meds. One glance at your wrist.»**
- Subhead: «Log a glass in one tap. See what's left to take today right on your watch face. No account, data stays on your devices.»
- PL: **«Woda i leki. Jedno spojrzenie na zegarek.»**
- Пост в сообществе (EN): «Apple Watch users who take daily meds or vitamins: how do you keep track of both meds and water? I built a small watch app that shows both on one complication, and I'm looking for 10 people to try it for a week and tell me what's annoying. Not selling anything; it's free on TestFlight.»
- Чем рискует: сравнение с бесплатной функцией Apple; нужно доказать, что «одновременно вода + лекарства» — реальная потребность, а не сумма двух мелких.

#### B. «Private, no subscription, no account»

- Headline: **«Water and medication reminders. No account. No subscription.»** (подсказано паттерном Cadence; формулировку подписки менять только после выбора модели оплаты)
- Subhead: «Everything stays on your iPhone and Apple Watch. Nothing to sign up for.»
- PL: **«Przypomnienia o wodzie i lekach. Bez konta. Bez subskrypcji.»**
- Риск: message уже используют Cadence и GoodPill; если Nuori выберет подписку — конфликт.

#### C. «Daily stack: vitamins, meds and water in 2 seconds» (альтернативный сегмент)

- Headline: **«Your daily stack, logged in two seconds from your wrist.»**
- Subhead: «Vitamins, supplements, meds and water — tap, done. Streaks on your watch face.»
- Пост: «Gym people with a daily stack (creatine, vitamins, etc.) + Apple Watch: would a 1-tap 'took my stack + drank 500 ml' button on your watch be useful? Looking for 10 testers.»
- Риск: сегмент может хотеть трекинг макросов/белка — то есть калорий; это как раз проверка стратегической ценности калорий.

#### DM-шаблон (ручной рекрутинг)

> «Hi! Saw your comment about forgetting [meds/vitamins/water] — that's exactly the problem I'm working on. I'm a solo developer in Poland building a small iPhone + Apple Watch app for it. Would you try it free for a week and tell me honestly what doesn't work? No account needed, nothing to buy. If not, no worries at all.»

#### Заметка о калориях (из данных, без вердикта)

[FACT] Конкуренты в гидратации используют калории как дополнительный ASO/продуктовый элемент: subtitle Water Reminder (VGFIT) — «Nutrition & Calorie counter»; Waterllama указывает «Track Calories»; у Llama Luna есть отдельное приложение Foodllama (AI calorie tracker, по вакансии). [INFERENCE] Калории в лидерских продуктах — вторичная фича/отдельный продукт, а не главное позиционирование. Для Nuori: не продвигать калории в messaging, но не удалять до результатов эксперимента #3 (сегмент «stack» может их ценить).

**Что подтверждено:** функции Apple, тексты конкурентов, на которых основаны варианты.
**Что неизвестно:** какой message конвертирует для Nuori.
**Уверенность:** низкая в выборе победителя (данных нет); средняя в том, что A требует отстройки от Apple.
**Что делать:** прогнать A/B/C через эксперименты #2, #3, #5 и решить по данным.

---

## 9. Практический план на первые 30 дней

Время — **[ESTIMATE]**, ~8–12 ч/неделю на маркетинг.

| Неделя | Задачи | Результат к концу недели |
|---|---|---|
| 1 (дни 1–7) | **Зависимость:** public links существуют только у external-групп, а build для внешнего тестирования должен пройти TestFlight App Review («The first build you submit requires a full review») — [Apple Developer](https://developer.apple.com/help/app-store-connect/test-a-beta-version/invite-external-testers). Если текущие 12 — internal testers, первым делом отправить build на ревью и создать по одной external-группе/ссылке на канал. Проверить на своих часах: есть ли у Apple Medications complication/виджет (5 мин). Интервью 5–8 из 12 тестировщиков (#1). Выбрать 2 сегмента. Отдельные TestFlight public links на канал. Обновить landing (docs/index.html) двумя hero-вариантами A/B (#5) + форма email/«хочу Pro». Решить вопрос названия: в репозитории и на сайте — «Nouri», в брифе — «Nuori» (до ASO нужно одно имя). | ICP-черновик; инфраструктура измерения |
| 2 (дни 8–14) | Эксперименты #2 и #3: 6–8 сообществ, 2 поста/ответа в каждом по правилам, DM тем, кто описал проблему. 2 founder-поста (#10). Первые ответы на опрос у ранних новых тестировщиков. | 15–25 новых релевантных установок (цель, не прогноз) |
| 3 (дни 15–21) | 7-дневные интервью с новыми тестировщиками. WTP-опрос/fake-door (#6). Калькулятор воды EN+PL (#9). Подготовка листинга App Store: title/subtitle/keywords EN/PL/UK, скриншоты под лидирующий message. | Данные retention 7 дней по сегментам; WTP-сигнал |
| 4 (дни 22–30) | Решение: какой сегмент/message ведёт. Press kit + 10 питчей (#8) — с датой релиза. Featuring nomination (#7). Набор 3–5 мини-кейсов от тестировщиков. Решение о модели оплаты (one-time vs подписка vs free + tip). | Go/no-go на публичный релиз; план PH (условия 8.1) |

### Бюджетные сценарии (все суммы — [ESTIMATE], не подтверждённый бюджет)

| Сценарий | Куда | Что не делать |
|---|---|---|
| **$0** | Весь план выше; только время фаундера | Не покупать рекламу до релиза и paywall |
| **$100** | $0-план + благодарности тестировщикам за интервью (например, 5–10 × небольшой подарочный код — сумма на усмотрение) **или** после релиза — 2-недельный Apple Ads тест на 3–5 точных ключах в одном storefront (#11) для получения реального CPI | Не делить $100 на много каналов — данные станут нечитаемыми |
| **$500** | $100-сценарий + Apple Ads тест в 2 storefront (например, PL и UK) + 2–3 бартер/малых коллаборации с micro-creators в выбранной нише (цены [UNKNOWN] — запрашивать) + при необходимости дизайнер для скриншотов | Не тратить на PH-«продвижение»/накрутку и общие «water tracker» ключи в US (конкуренция с 35K–163K рейтингов) |

### Критерии решения на день 30 ([HYPOTHESIS], задаёт основатель)

- ≥25 релевантных тестировщиков (не друзья) установили по каналам.
- ≥30% из них логировали ≥3 дня из 7 на второй неделе.
- ≥3 человека — «very disappointed», если Nuori исчезнет, и их ситуация совпадает.
- ≥1 явный WTP-сигнал (клик Pro, предзаказ, названная цена > 0) от ≥20% активных.

Если не выполнено — менять сегмент/message, а не добавлять функции.

**Что подтверждено:** доступность бесплатных инструментов (TestFlight public links, featuring nomination, Apple Ads в PL/UK/DE/FR/NL/US).
**Что неизвестно:** реальное время на каждую задачу; размер личной аудитории; CPI.
**Уверенность:** средняя — план опирается на дешёвые, обратимые шаги с ясными метриками.
**Что делать:** начать с недели 1 завтра; ключевая первая задача — интервью с текущими тестировщиками.

---

## 10. Список неизвестных, без которых нельзя оценить эффективность

| Неизвестное | Почему важно | Как получить |
|---|---|---|
| Загрузки, MAU, retention, выручка конкурентов | Масштаб рынка и бенчмарки | Sensor Tower/AppMagic (платно, только [ESTIMATE]); не критично сейчас |
| Конверсии воронок конкурентов (install→trial→paid) | Бенчмарки paywall | Не публичны; измерять свои |
| Реальные paywall/onboarding экраны конкурентов | Цены и офферы, реально показываемые | Установить 5 приложений на тестовое устройство, сделать скриншоты (1–2 ч) |
| Есть ли complication/виджет у Apple Medications | Ядро дифференциации message A | Проверить на своих часах |
| Поисковые объёмы ключей (Google, App Store) | Приоритет SEO и ASO | Google Search Console/Keyword Planner; Apple Ads keyword popularity после создания аккаунта |
| CPI/CPT Apple Ads в нише по storefront | Сценарии $100/$500 | Тест #11 |
| Реальное ранжирование App Store в PL/DE (не API) | Вывод о «тонкой» PL-выдаче | Поиск на устройстве с PL storefront; после релиза — App Store Connect |
| Правила self-promotion конкретных subreddit/сообществ | Риск бана | Прочитать вручную (reddit.com недоступен для автоматического чтения) |
| Эффективность PH, прессы, featuring для похожих приложений | Ожидания от запуска | Единичные кейсы; измерять свои через campaign links |
| Размер и релевантность аудитории основателя в соцсетях | Вес founder-led канала | Самооценка основателя |
| Готовность платить за Nuori и предпочтительная модель | Модель монетизации | Эксперимент #6 |
| Какой сегмент — core user | Всё позиционирование | Эксперименты #1–#3 |
| Ценность калорий для сегментов | Удалять или оставить | Эксперимент #3 + интервью |
| Источники роста Pill Buddy, Waterllama (раннего этапа) | Воспроизводимые тактики | Написать основателям напрямую (короткий вопрос) — публичных данных нет |
| Публичные рекламные библиотеки (Meta Ad Library, TikTok Ads Library) по Waterllama, Medisafe, Plant Nanny, WaterMinder | Подтвердить/опровергнуть платную рекламу конкурентов | Не проверялись (JS-страницы); 10-минутная ручная проверка в браузере |
| Регуляторные требования ЕС к medication-reminder приложениям (MDR) | Риск для messaging и B2B | Отдельное исследование, не входит в эту задачу |

**Что подтверждено:** перечень пробелов, которые не удалось закрыть публичными данными на 2026-10-09.
**Что неизвестно:** см. таблицу.
**Уверенность:** высокая в том, что эти пробелы блокируют количественную оценку каналов.
**Что делать:** закрыть дешёвые пункты (complication Apple, paywall-скриншоты конкурентов, правила сообществ) в первую неделю; остальное — через собственные эксперименты.
