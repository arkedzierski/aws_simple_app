FROM python:3-slim AS runtime

LABEL maintainer="akedzierski"
LABEL name="flask_s3"
LABEL description="Flask app used s3 bucket"


RUN mkdir /var/www/ && chown www-data:www-data /var/www/

WORKDIR /var/www/

COPY . .

USER www-data

RUN mkdir ~/.aws && echo "[default]\nregion = us-east-2" > /var/www/.aws/config

ENV PATH=/var/www/.local/bin/:$PATH

ENV FLASK_ENV=development

RUN echo $PATH

RUN pip install --user --no-cache-dir -r /var/www/requirements.txt

EXPOSE 80/tcp

CMD [ "python", "app.py"]