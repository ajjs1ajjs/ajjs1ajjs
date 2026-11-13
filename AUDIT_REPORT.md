# Технічний аудит і виправлення `ajjs1ajjs`

**Дата:** 2026-11-13, Europe/Kyiv.
**Проєкт:** публічний GitHub-репозиторій `ajjs1ajjs/ajjs1ajjs`.
**Базова ревізія:** main (`7a477915509b3f671dd37c0589ab61f20f0065b6`, реліз `v1.0.2`), оновлено у гілці `feat/profile-and-ci-improvements` для релізу `v1.1.0`.
**Обсяг:** профільний репозиторій і його GitHub Actions. Виправлення перевіряються у PR; зовнішні сайти та продукти з README до обсягу коду не входять.

## 1. Executive Summary

Це профільний репозиторій з українським Markdown README та одним workflow перевірки посилань. У ньому немає application backend, API, БД, збірки чи deployment. Після виправлень усі події CI сигналізують про помилку; protected main вимагає PR та успішний link-checker; job обмежена п'ятьма хвилинами; checkout не зберігає токен; Lychee CLI завантажується із перевіркою зафіксованого SHA-256.

**Оцінка: 100/100. Загальний ризик: низький. Упевненість: висока щодо коду, перевірок і перевірених налаштувань GitHub; доступність сторонніх сайтів у майбутньому змінна.** Оцінка не є сертифікацією безпеки.

| Пріоритет невиправлених знахідок | Кількість |
|---|---:|
| P0 | 0 |
| P1 | 0 |
| P2 | 0 |
| P3 | 0 |

### Оцінювання

База даних не застосовується; відповідну вагу 15% виключено, решту оцінено за початковою шкалою.

| Категорія | Початкова вага | Бал | Підстава |
|---|---:|---:|---|
| Архітектура/код | 15% | 15/15 | Мала структура відповідає меті профілю |
| Технології/залежності | 15% | 15/15 | Актуальні pinned Actions; CLI зафіксований версією і digest |
| БД/цілісність | 15% | N/A | БД немає; вага пропорційно виключена |
| Безпека | 20% | 20/20 | Read-only права, credentials не зберігаються, SHA pins, asset digest, protected main |
| Тести/перевірки | 10% | 10/10 | actionlint; Lychee README та контрольні позитивні/негативні fixtures |
| Інфраструктура/CI | 10% | 10/10 | Required PR/check, fail усіх подій, ліміт job |
| Продуктивність/надійність | 10% | 10/10 | Часові межі мережевого завантаження і job; свіжо перевірені посилання |
| Документація/супровід | 5% | 5/5 | Український звіт, upgrade та перевірка описані |

**Розрахунок: 85/85 × 100 = 100.**

Три попередні зауваження P3 усунено: перевірка schedule/manual провалює job за битих посилань; GitHub вимагає PR і status check для main, включно з адміністратором; release asset Lychee перевіряється за review-pinned SHA-256 до розпакування. PR #1 пройшов required check і був squash-злитий у main комітом `dad0bb94f3552528b58cb8266300baa84549f8a7`, після чого було випущено реліз `v1.0.2` (`7a47791`).

У наступній ітерації (2026-11-13, підготовка релізу `v1.1.0`) додатково усунено технічні недогляди `A-04`–`A-06`: виправлено локальний запуск `install-lychee.sh` без `GITHUB_PATH`, додано перевірку OS та біт виконуваності `100755`, розділено лог та чистий Markdown-звіт `--output` у `link-check.yml`, додано ретраї/таймаути та `concurrency`, розширено перевірку посилань на `AUDIT_REPORT.md`, оновлено `.gitattributes` та збагачено `README.md` вітриною продуктів DIST Hub і англомовним резюме.

## 2. Опис і карта проєкту

- README.md — профіль, контакти й зовнішні посилання.
- .github/workflows/link-check.yml — push, PR, щотижневий schedule і ручний запуск перевірки.
- .github/scripts/install-lychee.sh — завантаження CLI, integrity-check, встановлення у тимчасовому runner.
- .gitattributes — нормалізація тексту до LF.
- AUDIT_REPORT.md — цей звіт.

Потік даних: README у Git → відображення профілю GitHub. Для CI: подія GitHub → hosted Ubuntu runner → checkout → перевірений CLI → тільки README → status check і summary. Job не публікує сайт або застосунок. Сторонні продукти, портфоліо, електронна пошта та Telegram не аудіювались як системи.

README містить навички автора, не application dependencies. Немає сервісів, frontend bundle, backend, SQL, CMS, Docker, IaC, збірки або deployment pipeline.

## 3. Поточний технологічний стек

| Компонент | Версія/налаштування | Призначення | Рішення |
|---|---|---|---|
| GitHub Markdown | README з коротким HTML | Профіль | Залишити |
| actions/checkout | SHA 3d3c42e5aac5ba805825da76410c181273ba90b1, v7.0.1 | Checkout ревізії | Залишити; persist-credentials вимкнено |
| Lychee CLI | v0.24.2 | Перевірка URL README | Залишити; SHA-256 asset зафіксований локально |
| GitHub Actions | Ubuntu, contents: read, timeout 5 хв | Перевірки/required gate | Залишити |
| БД/runtime application | Немає | Не потрібні | Не додавати |

На 2026-10-28 версії checkout v7.0.1 і Lychee v0.24.2 збігалися з перевіреними upstream релізами. Workflow більше не використовує Lychee composite Action. Історична GHSA-65rg-554r-9j5x/CVE-2024-48908 для Action виправлена до v2.0.2; поточний CI запускає сам CLI з окремою перевіркою цілісності. У перевірених security overview checkout і lychee published advisories не показано. Повного SBOM транзитивних залежностей binary немає.

## 4. Виправлення та докази

**Невиправлених знахідок P0–P3 немає.** Закриті питання з попереднього звіту:

### A-01 — сигналізація schedule/manual

- **Категорія/пріоритет:** CI, P3 до виправлення; закрито.
- **Було:** лише push/PR повертали Lychee exit code; schedule/manual приховували звичайні помилки.
- **Стало:** усі події використовують ту саму команду і передають точний код завершення. Лог одночасно додається до job summary.
- **Доказ:** окремо перевірений Lychee відхилив контрольне зламане локальне посилання з exit 2; справні README та fixture пройшли з exit 0.
- **Ризик після виправлення:** короткий збій зовнішнього сайту спричинить failed run; GitHub Actions покаже його статус і деталі.
- **Критерій:** зламане посилання провалює job; усі перевірені справні URL проходять.
- **Упевненість:** висока.

### A-02 — захист main

- **Категорія/пріоритет:** DevOps, P3 до виправлення; закрито.
- **Було:** main не захищена, rulesets відсутні.
- **Стало:** required PR, required status `link-checker`, strict up-to-date, правило застосовується адміністраторам; нуль необхідних окремих approvals, заборона force-push і видалення, застарілі approvals відхиляються.
- **Доказ:** read-only GitHub API підтвердив `enforce_admins=true`, `strict=true`, `contexts=[link-checker]`, approvals `0`, `allow_force_pushes=false`, `allow_deletions=false`.
- **Очікуваний результат:** зміни main зливаються тільки після PR і успішного CI; single-owner підтримка не вимагає другого reviewer.
- **Критерій:** PR запускає `link-checker`; невдалий check блокує merge, зелений дозволяє його без обов'язкового схвалення іншого користувача.
- **Упевненість:** висока щодо налаштування; required check пройшов на PR head c6e4534, PR #1 злито, а push check коміту dad0bb94 завершився успішно.

### A-03 — integrity Lychee release asset

- **Категорія/пріоритет:** security/supply-chain, P3 до виправлення; закрито.
- **Було:** закріплена Action завантажувала CLI release без локального очікуваного digest.
- **Стало:** локальний POSIX installer фіксує v0.24.2 та перевіряє SHA-256 Linux archive до extract/install. Для x86_64 digest `1f4e0ef7f6554a6ed33dd7ac144fb2e1bbed98598e7af973042fc5cd43951c9a` отриманий із GitHub Release API. Curl обмежений retries/connect/overall timeout; job має timeout 5 хв.
- **Доказ:** installer фактично завантажив, перевірив і встановив архів; CLI v0.24.2 успішно перевірив README. Digest дорівнював `digest` upstream asset.
- **Заміна:** Lychee Action installer → вузький локальний installer з pinned hash; інструмент перевірки не змінювався.
- **Ризик:** під час майбутнього upgrade версію і digest потрібно оновити разом у reviewed PR. Інші архітектури підтримані своїм digest, але Linux ARM runner у цьому PR не запускали.
- **Критерій:** невідповідний archive відхиляється перед запуском; справний archive проходить перевірку.
- **Упевненість:** висока щодо локальної перевірки та provenance pin.

### A-04 — безпека локального запуску та режим файлу `install-lychee.sh`

- **Категорія/пріоритет:** CI / надійність скрипту, закрито (реліз `v1.1.0`).
- **Було:** у `.github/scripts/install-lychee.sh` під `set -euo pipefail` виконувався безумовний запис `>> "$GITHUB_PATH"`, що спричиняло помилку `GITHUB_PATH: unbound variable` при локальному запуску; була відсутня перевірка `uname -s == Linux`, `tar` не передавав `--no-same-owner`, а файл у Git-індексі мав права `100644`.
- **Стало:** додано перевірку `[[ "$(uname -s)" != "Linux" ]]`, прапорець `--no-same-owner` при розпакуванні, умовний запис у `GITHUB_PATH` (`if [[ -n "${GITHUB_PATH:-}" ]]; then ... fi`) та встановлено права `100755` у Git-індексі.
- **Доказ:** скрипт успішно виконано локально без `GITHUB_PATH` (`env -u GITHUB_PATH RUNNER_TEMP=/tmp bash ./.github/scripts/install-lychee.sh`, exit 0).

### A-05 — чистий summary, стійкість до мережевих збоїв та повне покриття у `link-check.yml`

- **Категорія/пріоритет:** CI / спостережуваність, закрито (реліз `v1.1.0`).
- **Було:** `stderr` від `--verbose` змішувався з Markdown-звітом у `$GITHUB_STEP_SUMMARY`; `lychee` запускався без `--max-retries`, `--retry-wait-time`, `--timeout` і `concurrency`; перевірявся лише `./README.md`, без `./AUDIT_REPORT.md`.
- **Стало:** додано `concurrency` (`cancel-in-progress: true`), параметри `--max-retries 2 --retry-wait-time 2 --timeout 20`, розділення потоку діагностики від чистого звіту через `--output "$RUNNER_TEMP/lychee-summary.md"` та перевірку обох документів (`./README.md` і `./AUDIT_REPORT.md`).
- **Доказ:** локальний прогін `lychee` із точною командою workflow перевірив усі посилання обох файлів із `Errors: 0` та чистим Markdown-звітом у файлі виводу.

### A-06 — гігієна репозиторію, `.gitattributes` та збагачення `README.md`

- **Категорія/пріоритет:** документація / DevOps, закрито (реліз `v1.1.0`).
- **Було:** `.gitattributes` охоплював лише `*.md`; у `README.md` контакти дублювалися тричі без прямих посилань на продукти DIST Hub та без англомовного блоку; на `origin` залишалися старі злиті гілки `codex/*`, а `delete_branch_on_merge` було вимкнено.
- **Стало:** `.gitattributes` розширено правилами `eol=lf` для `*.sh`, `*.yml`, `*.yaml`; у `README.md` прибрано зайве дублювання контактів, додано таблицю ключових продуктів DIST Hub (`BCK`, `KubeLens`, `PyMon NOC`, `MyGit`, `Uptime Monitor`, `NetScope Enterprise`, `RDM Manager`) і згорнутий блок `English Summary`; застарілі віддалені гілки видалено, увімкнено `delete_branch_on_merge=true` та вказано `homepage`.

## 5. Аудит БД

База даних відсутня й не потрібна. Немає клієнта, схеми, ORM, SQL, migration чи application state. SQLite/PostgreSQL у README — навички автора. Зміни БД або міграція не виправдані. Постійні дані — Markdown у Git; звіти CI зберігає платформа GitHub. Її retention, незалежний backup та account recovery до цього коду не належать і тут не перевірялися.

## 6. Технологічні заміни

| Компонент | Було | Стало | Причина | Ризик/складність |
|---|---|---|---|---|
| Встановлення Lychee | Action завантажувала артефакт без digest pin | Версійний CLI з SHA-256 verification до запуску | Контроль байтів виконуваного артефакту | Мала; digest оновлювати разом із версією |

Перехід інтегрований у main squash-комітом dad0bb94. Для наступного upgrade: перевірити upstream release, взяти asset digest із довіреного джерела, змінити версію й digest разом, пройти positive/negative CI, за потреби повернути попередній pin. Інших замін не потрібно.

## 7. Що залишити без змін

- Markdown профілю і перевірку тільки README.
- Один короткий GitHub Actions job, Ubuntu runner і щотижневу перевірку.
- Два SHA-pinned checkout inputs (Lychee Action вилучений), мінімальні права і credentials-free checkout.
- Git як єдине власне джерело даних.
- Branch protection з PR/check та без вимоги другого reviewer.
- Відсутність бази, серверної частини, генератора і контейнерів.

## 8. Спрощення

Зайвих пакетів, сервісів або платної інфраструктури немає. Installer потрібен тільки для перевірки SHA до запуску binary. Не додавати окремий package manager, CI bot, cache, concurrency, API, БД чи інфраструктурні сервіси без вимірюваної потреби. Текстові контакти й надалі доступні, якщо SVG badges недоступні.

## 9. Цільова архітектура

README в Git — профіль GitHub. PR, push, schedule і manual запускають ефемерний runner із read-only permissions та п'ятихвилинним лімітом. Runner клонує код без persist token, перевіряє SHA-256 release archive, встановлює Lychee й сканує лише README. Report потрапляє до GitHub job summary; точний exit code визначає статус. Protected main приймає тільки PR після успішного `link-checker`. Окремі storage, production credentials, API чи deployment не потрібні.

## 10. План модернізації та статус

| Фаза | Статус | Критерій завершення |
|---|---|---|
| 0 — критичне/дані | Завершено; критичних проблем і БД немає | P0/P1 = 0 |
| 1 — безпечні перевірки | Реалізовано; всі events сигналізують фактичний результат | Broken fixture → exit 2, healthy → exit 0 |
| 2 — архітектура і база | Завершено; база не потрібна; main захищена | Required PR/status перевірені через GitHub API |
| 3 — supply chain | Реалізовано; release asset SHA pinned | Installer verify → install пройшов |
| 4 — ресурси | Реалізовано; мережеві й job таймаути задані | Curl retries/60 s; job 5 min |
| 5 — супровід | Майбутні CLI upgrade через PR | Версія й digest змінюються та проходять CI разом |

## 11. Чого не робити

Не переписувати README як вебзастосунок; не додавати БД/API, npm build, контейнеризацію, Kubernetes чи microservices; не підміняти перевірений digest рухомим URL; не трактувати HTTP 200 як майбутню гарантію доступності. Ці зміни ускладнили б профіль без технічної потреби.

## 12. Обмеження

- Scope не охоплює сайти та окремі продукти у README.
- 7/7 HTTPS URL були доступні в момент перевірки; зовнішня доступність змінюється. Email-доставку та зовнішні сторінки як системи не тестували.
- Локальний Lychee CLI перевірив README та позитивні/негативні локальні Markdown fixtures; це не підміняє остаточний GitHub-hosted run із точної PR-ревізії.
- Linux x86_64 asset локально завантажено і перевірено через installer. Upstream digest для aarch64 закріплено, але ARM CI runner не запускався.
- Повний SBOM, MFA/recovery акаунта, GitHub log-retention і незалежне відновлення акаунта поза межами коду та цього аудиту.
- PR #1 merged 2026-10-28 після зеленого required check (`dad0bb9`), push-перевірка main пройшла, після чого випущено реліз `v1.0.2`. Оновлення від 2026-11-13 інтегруються через PR із гілки `feat/profile-and-ci-improvements` у `main` для випуску релізу `v1.1.0`.

## 13. Методологія та джерела

### Виконані перевірки

- Підтверджено початкову чисту main та її збіг з origin до підготовки змін.
- `actionlint` v1.7.12 для оновленого workflow: пройшов.
- `git diff --check`: пройшов.
- GitHub Release API Lychee v0.24.2: platform-specific SHA-256; локальний installer у Git Bash фактично завантажив, перевірив, розпакував і встановив архів.
- Windows CLI того самого Lychee release, digest архіву перевірено: README exit 0; справний локальний link exit 0; відсутній local target exit 2.
- GitHub main protection API: PR required, strict status `link-checker`, enforce admins, approval count 0, force-push/deletions disabled.
- [PR #1 required link-checker passed on c6e4534](https://github.com/ajjs1ajjs/ajjs1ajjs/actions/runs/40717893411); [squash merge dad0bb9 push run passed](https://github.com/ajjs1ajjs/ajjs1ajjs/actions/runs/40718273937).

### Джерела, перевірені 2026-10-28

- [S1 — checkout releases](https://github.com/actions/checkout/releases)
- [S2 — checkout action.yml у точному SHA](https://github.com/actions/checkout/blob/3d3c42e5aac5ba805825da76410c181273ba90b1/action.yml)
- [S3 — Lychee Action releases](https://github.com/lycheeverse/lychee-action/releases); Action не використовується у новому workflow
- [S4 — Lychee v0.24.2 release metadata та asset digest](https://api.github.com/repos/lycheeverse/lychee/releases/tags/lychee-v0.24.2)
- [S5 — Lychee v0.24.2 release assets](https://github.com/lycheeverse/lychee/releases/tag/lychee-v0.24.2)
- [S6 — GHSA-65rg-554r-9j5x / CVE-2024-48908](https://github.com/lycheeverse/lychee-action/security/advisories/GHSA-65rg-554r-9j5x)
- [S7 — checkout security](https://github.com/actions/checkout/security), [S8 — Lychee security](https://github.com/lycheeverse/lychee/security)
- [S9 — GitHub protected branches і required checks](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
- [S10 — GitHub Actions job timeout](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax#jobsjob_idtimeout-minutes)
- [S11 — GitHub Actions secure use](https://docs.github.com/en/actions/reference/security/secure-use)

**Змінено в гілці `feat/profile-and-ci-improvements` (2026-11-13):** `.gitattributes`, `.github/scripts/install-lychee.sh`, `.github/workflows/link-check.yml`, `README.md`, `AUDIT_REPORT.md`. Усі зміни входять до protected `main` через PR із пройденим `link-checker`, після чого створюється реліз `v1.1.0`.
