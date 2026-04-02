# -------------------------------
# Base Image
# -------------------------------
FROM docker.io/python:3.12.2-slim-bookworm as python


# -------------------------------
# Stage 1: Build dependencies
# -------------------------------
FROM python AS python-build-stage

ARG BUILD_ENVIRONMENT=local

RUN apt-get update && apt-get install --no-install-recommends -y \
  build-essential \
  libpq-dev \
  && rm -rf /var/lib/apt/lists/*

COPY ./requirements /requirements

RUN pip wheel --wheel-dir /usr/src/app/wheels \
  -r /requirements/${BUILD_ENVIRONMENT}.txt


# -------------------------------
# Stage 2: Runtime
# -------------------------------
FROM python AS python-run-stage

ARG BUILD_ENVIRONMENT=local
ARG APP_HOME=/app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV BUILD_ENV=${BUILD_ENVIRONMENT}

WORKDIR ${APP_HOME}


# -------------------------------
# System dependencies
# -------------------------------
RUN apt-get update && apt-get install --no-install-recommends -y \
  libpq-dev \
  gettext \
  sudo \
  git \
  bash-completion \
  nano \
  ssh \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && rm -rf /var/lib/apt/lists/*


# -------------------------------
# Create user
# -------------------------------
RUN addgroup --system django && \
    adduser --system --ingroup django django


# -------------------------------
# Install Python dependencies
# -------------------------------
COPY --from=python-build-stage /usr/src/app/wheels /wheels/

RUN pip install --no-cache-dir --no-index --find-links=/wheels /wheels/* \
  && rm -rf /wheels/


# -------------------------------
# Copy scripts
# -------------------------------
COPY --chown=django:django ./docker/local/django/entrypoint.sh /entrypoint
RUN sed -i 's/\r$//g' /entrypoint && chmod +x /entrypoint

COPY --chown=django:django ./docker/local/django/start.sh /start
RUN sed -i 's/\r$//g' /start && chmod +x /start

COPY --chown=django:django ./docker/local/django/celery/worker/start.sh /start-celeryworker
RUN sed -i 's/\r$//g' /start-celeryworker && chmod +x /start-celeryworker

COPY --chown=django:django ./docker/local/django/celery/beat/start.sh /start-celerybeat
RUN sed -i 's/\r$//g' /start-celerybeat && chmod +x /start-celerybeat

COPY --chown=django:django ./docker/local/django/celery/flower/start.sh /start-flower
RUN sed -i 's/\r$//g' /start-flower && chmod +x /start-flower


# -------------------------------
# Copy application code
# -------------------------------
COPY --chown=django:django . ${APP_HOME}


# -------------------------------
# 🔥 CRITICAL FIX (permissions)
# -------------------------------
RUN mkdir -p ${APP_HOME}/staticfiles && \
    chown -R django:django ${APP_HOME}/staticfiles && \
    chmod -R 775 ${APP_HOME}/staticfiles


# -------------------------------
# Switch to non-root user
# -------------------------------
USER django


# -------------------------------
# Entrypoint
# -------------------------------
ENTRYPOINT ["/entrypoint"]