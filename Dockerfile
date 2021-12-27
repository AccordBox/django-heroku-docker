# Please remember to rename django_heroku to your project directory name
FROM node:14-stretch-slim as frontend-builder

WORKDIR /app/frontend

COPY ./frontend/package.json /app/frontend
COPY ./frontend/package-lock.json /app/frontend

ENV PATH ./node_modules/.bin/:$PATH

RUN npm ci

COPY ./frontend .

RUN npm run build

#################################################################################
FROM python:3.10-slim-buster

WORKDIR /app

ENV PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app \
    DJANGO_SETTINGS_MODULE=django_heroku.settings \
    PORT=8000 \
    WEB_CONCURRENCY=3

# Install system packages required by Wagtail and Django.
RUN apt-get update --yes --quiet && apt-get install --yes --quiet --no-install-recommends \
    build-essential curl \
    libpq-dev \
    libmariadbclient-dev \
    libjpeg62-turbo-dev \
    zlib1g-dev \
    libwebp-dev \
 && rm -rf /var/lib/apt/lists/*

RUN addgroup --system django \
    && adduser --system --ingroup django django

# Requirements are installed here to ensure they will be cached.
COPY ./requirements.txt /requirements.txt
RUN pip install -r /requirements.txt

# Copy project code
COPY . .
COPY --from=frontend-builder /app/frontend/build /app/frontend/build

RUN python manage.py collectstatic --noinput --clear

# Run as non-root user
RUN chown -R django:django /app
USER django

# Run application
CMD gunicorn django_heroku.wsgi:application
