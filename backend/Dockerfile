FROM python:3.12-slim AS base
WORKDIR /app
COPY requirements/base.txt .
RUN pip install --no-cache-dir -r base.txt

FROM base AS dev
COPY requirements/dev.txt .
RUN pip install --no-cache-dir -r dev.txt
CMD ["flask", "--app", "app", "run", "--host=0.0.0.0", "--port=5000", "--debug"]

FROM base AS prod
COPY requirements/prod.txt .
RUN pip install --no-cache-dir -r prod.txt
COPY . .
CMD ["gunicorn", "-c", "gunicorn.conf.py", "app:create_app('production')"]