# Base Python image
FROM python:3.12.2-slim-bookworm AS base

# ---- Build stage ----
FROM base AS build-stage

ARG BUILD_ENVIRONMENT=local

# Install build dependencies
RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and build wheels
COPY ./requirements ./
RUN pip wheel --wheel-dir /wheels -r ${BUILD_ENVIRONMENT}.txt

# ---- Run stage ----
FROM base AS run-stage

ARG APP_HOME=/app
ARG BUILD_ENVIRONMENT=local

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV BUILD_ENV=${BUILD_ENVIRONMENT}

WORKDIR ${APP_HOME}

# Install runtime dependencies
RUN apt-get update && apt-get install --no-install-recommends -y \
    libpq-dev \
    gettext \
    sudo \
    git \
    bash-completion \
    nano \
    && rm -rf /var/lib/apt/lists/*

# Create django user and staticfiles directory
RUN addgroup --system django && \
    adduser --system --ingroup django django && \
    mkdir -p ${APP_HOME}/staticfiles && \
    chown -R django:django ${APP_HOME} && \
    chmod -R 775 ${APP_HOME}

# Install Python dependencies
COPY --from=build-stage /wheels /wheels
RUN pip install --no-cache-dir --no-index --find-links=/wheels /wheels/* \
    && rm -rf /wheels

# Copy entrypoints
COPY --chown=django:django ./docker/local/django/entrypoint.sh /entrypoint
RUN chmod +x /entrypoint

COPY --chown=django:django ./docker/local/django/start.sh /start
RUN chmod +x /start

COPY --chown=django:django ./docker/local/django/celery/worker/start.sh /start-celeryworker
RUN chmod +x /start-celeryworker

COPY --chown=django:django ./docker/local/django/celery/beat/start.sh /start-celerybeat
RUN chmod +x /start-celerybeat

COPY --chown=django:django ./docker/local/django/celery/flower/start.sh /start-flower
RUN chmod +x /start-flower

# Copy project files
COPY --chown=django:django . ${APP_HOME}

# Switch to django user
USER django

ENTRYPOINT ["/entrypoint"]