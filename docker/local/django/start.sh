#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

# Ensure the staticfiles folder exists and is writable
STATIC_DIR="/app/staticfiles"
mkdir -p "${STATIC_DIR}"
chown -R django:django "${STATIC_DIR}"
chmod -R 775 "${STATIC_DIR}"

# Run migrations
python manage.py migrate --no-input

# Collect static files
python manage.py collectstatic --no-input

# Start the Django development server
exec python manage.py runserver 0.0.0.0:8000