# LADO в Docker

Папка с Docker-файлами не зависит от исходников репозитория LADO. При сборке образ устанавливает опубликованный пакет `lado`, Codex CLI, Claude Code и Kilo CLI. Текущие версии CLI закреплены в Dockerfile; при обновлении можно поменять значения соответствующих `ARG`.

## Запуск

Задайте UID и GID текущего пользователя и соберите контейнер:

```bash
export LADO_UID="$(id -u)"
export LADO_GID="$(id -g)"
docker compose up --build -d
```

Контейнер напечатает готовый URL с токеном после запуска сервера. Посмотреть его можно так:

```bash
docker compose logs lado
```

Откройте ссылку `LADO UI: ...` целиком. Порт `9898` опубликован на всех интерфейсах сервера; используйте адрес машины, где запущен Docker. По умолчанию это `http://vm-neshin-test.simbirsoft:9898`; для другого адреса укажите `LADO_PUBLIC_URL` в `.env`. Доступ к порту ограничьте firewall-ом: UI использует HTTP без шифрования, а токен разрешает выполнять команды в LADO. Не пересылайте URL с токеном или вывод логов другим.

## Авторизация CLI

CLI уже установлены, но для работы каждый провайдер требует своей авторизации. Запускайте нужный вход в интерактивном режиме:

```bash
docker compose exec -it lado codex login
docker compose exec -it lado claude
docker compose exec -it lado kilo auth
```

Для Codex OAuth callback на `http://127.0.0.1:1455/auth/callback` проброшен на localhost хоста. В контейнере работает TCP-прокси к loopback listener Codex, поэтому запускайте `codex login` из `docker compose exec`, а страницу авторизации открывайте в браузере на той же машине, где работает Docker.

Данные авторизации сохраняются в Docker volume `lado-home` (`/home/lado`). Состояние LADO и UI token сохраняются отдельно в `lado-data` (`/var/lib/lado`). Для каждого провайдера понадобится действующая учётная запись или ключ доступа.

## Подключение рабочего репозитория

По умолчанию текущая папка монтируется в контейнер как `/workspace`. Чтобы использовать другой локальный репозиторий, задайте абсолютный путь в `.env` рядом с Compose-файлом:

```dotenv
LADO_WORKSPACE=/полный/путь/к/рабочему/репозиторию
```

Репозиторий должен быть Git-репозиторием с хотя бы одним коммитом. Запуск сессии, например через Codex:

```bash
docker compose exec -it lado lado start /workspace --provider codex
```

Агенты работают в контейнере. Смонтированная папка доступна им для изменений. Не добавляйте секреты в Compose-файл или Git.

## Управление

```bash
docker compose logs -f lado
docker compose down
```

`docker compose down -v` удалит оба volume — состояние LADO, токен и сохранённую авторизацию CLI.
