# LADO Docker

Запуск [LADO](https://github.com/ladohq/lado) через Docker Compose без клонирования исходного репозитория LADO. Образ устанавливает опубликованный пакет `lado`, Codex CLI, Claude Code и Kilo CLI.

## Быстрый старт

Требуется Docker Desktop с Docker Compose. Склонируйте этот репозиторий и запустите контейнер:

```bash
git clone git@github.com:dosent/lado_docker.git
cd lado_docker
export LADO_UID="$(id -u)"
export LADO_GID="$(id -g)"
docker compose up --build -d
```

Посмотрите логи и откройте напечатанную ссылку `LADO UI` целиком — она содержит токен доступа:

```bash
docker compose logs lado
```

Веб-интерфейс доступен на [http://localhost:9898](http://localhost:9898). Не публикуйте ссылку с токеном или логи, содержащие её.

## Авторизация Codex

Запустите вход в интерактивном режиме и завершите его в браузере на той же машине, где работает Docker:

```bash
docker compose exec -it lado codex login
docker compose exec lado codex login status
```

OAuth callback Codex на порту `1455` проброшен на localhost хоста. После успешной авторизации создайте новую сессию LADO:

```bash
docker compose exec -it lado lado start /workspace --provider codex
```

## Рабочая папка

По умолчанию текущая папка монтируется в контейнер как `/workspace`. Чтобы подключить другой локальный Git-репозиторий, задайте абсолютный путь в `.env`:

```dotenv
LADO_WORKSPACE=/полный/путь/к/рабочему/репозиторию
```

Подробнее об авторизации Claude Code и Kilo, volumes, логах и остановке контейнера — в [DOCKER.md](DOCKER.md).
