# Node is available for installing optional npm-based provider CLIs in a derived image.
FROM node:22-bookworm-slim AS node-runtime

FROM python:3.12-slim-bookworm

ARG LADO_UID=1000
ARG LADO_GID=1000
ARG CODEX_CLI_VERSION=0.162.1
ARG CLAUDE_CODE_VERSION=2.1.295
ARG KILO_CLI_VERSION=7.8.8

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    LADO_HOME=/var/lib/lado

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates git libatomic1 libstdc++6 socat tmux \
    && rm -rf /var/lib/apt/lists/* \
    && (getent group "${LADO_GID}" >/dev/null || groupadd --gid "${LADO_GID}" lado) \
    && useradd --uid "${LADO_UID}" --gid "${LADO_GID}" --create-home --shell /bin/bash lado \
    && install -d -o "${LADO_UID}" -g "${LADO_GID}" -m 0700 /var/lib/lado

COPY --from=node-runtime /usr/local/bin/node /usr/local/bin/node
COPY --from=node-runtime /usr/local/lib/node_modules/npm/ /usr/local/lib/node_modules/npm/
RUN ln -s ../lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -s ../lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

RUN pip install --no-cache-dir lado \
    && npm install --global --no-audit --no-fund \
        "@openai/codex@${CODEX_CLI_VERSION}" \
        "@anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}" \
        "@kilocode/cli@${KILO_CLI_VERSION}"

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod 0755 /usr/local/bin/docker-entrypoint

USER lado
WORKDIR /workspace
EXPOSE 8000

ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]
