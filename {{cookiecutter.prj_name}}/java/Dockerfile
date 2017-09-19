FROM openjdk:8-jre-alpine

ARG VERSION
ENV {{cookiecutter.prj_name|upper}}_VERSION ${VERSION}

WORKDIR /opt/{{cookiecutter.prj_name}}

RUN addgroup -S appy \
    && adduser -D -S -h /opt/{{cookiecutter.prj_name}} -s /sbin/nologin -G appy appy \
    && chown -R appy /opt/{{cookiecutter.prj_name}}

COPY target/{{cookiecutter.prj_name}}-${VERSION}.jar /opt/{{cookiecutter.prj_name}}/{{cookiecutter.prj_name}}.jar

RUN chown appy:appy /opt/{{cookiecutter.prj_name}}/{{cookiecutter.prj_name}}.jar

# run as non-root user
USER appy

# urandom = http://stackoverflow.com/a/33882286/5608849 (one of several references but this one specific to docker)
# heap size = http://stackoverflow.com/a/41098096/5608849 (one of serveral, just very specific here)
CMD ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "-Xmx1024m", "/opt/{{cookiecutter.prj_name}}/{{cookiecutter.prj_name}}.jar"]
