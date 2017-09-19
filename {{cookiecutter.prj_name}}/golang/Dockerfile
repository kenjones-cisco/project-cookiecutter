FROM alpine:3.6

RUN apk add --no-cache \
        ca-certificates \
        bash \
    && rm -f /var/cache/apk/*

ARG VERSION
ENV {{cookiecutter.prj_name|upper}} ${VERSION}

COPY bin/{{cookiecutter.binary_name}} /usr/local/bin/{{cookiecutter.binary_name}}

CMD ["/usr/local/bin/{{cookiecutter.binary_name}}"]
