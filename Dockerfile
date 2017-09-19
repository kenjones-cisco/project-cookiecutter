FROM python:3.4-alpine

RUN apk add --no-cache \
        git \
    && pip install --no-cache-dir -U pip \
    && pip install --no-cache-dir git+https://github.com/audreyr/cookiecutter.git

ENV PYTHONIOENCODING UTF-8

WORKDIR /mnt
ENTRYPOINT ["cookiecutter"]
