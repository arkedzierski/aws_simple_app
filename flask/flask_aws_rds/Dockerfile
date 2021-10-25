FROM python:3 AS builder

LABEL version="v1"
LABEL maintainer="akedzierski"
LABEL name="flask_rds"
LABEL description="Flask app used postgres db"

#RUN apt-get update && apt-get install -y libpq-dev gcc

RUN mkdir /var/www/ && chown www-data:www-data /var/www/

USER www-data

ENV PATH=/var/www/.local/bin/:$PATH

ENV FLASK_ENV=development

COPY requirements.txt /var/www/

RUN pip install --user --no-cache-dir -r /var/www/requirements.txt

FROM python:3-slim AS runtime

RUN mkdir /var/www/ && chown www-data:www-data /var/www/

COPY --from=builder /var/www/.local/ /var/www/.local/

RUN apt-get update && apt-get install -y libpq-dev  && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/

COPY . .

RUN mkdir .aws && echo "[default]\nregion = us-east-2" > .aws/config

EXPOSE 80/tcp

USER www-data

ENV PATH=/var/www/.local/bin/:$PATH

CMD [ "python", "app.py"]