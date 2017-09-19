FROM alpine:3.6

RUN apk add --no-cache \
        bash \
        ca-certificates \
        coreutils \
        curl \
        gettext \
        wget \
    && rm -f /var/cache/apk/*

ARG VERSION
ENV {{cookiecutter.prj_name|upper}} ${VERSION}

COPY lib/ /usr/local/lib/
COPY bin/{{cookiecutter.binary_name}} /usr/local/bin/{{cookiecutter.binary_name}}

CMD ["/usr/local/bin/{{cookiecutter.binary_name}}"]
