FROM alpine:3.24.4

LABEL maintainer="shpaq@shpaq.org"

ENV RESTORE=false
ENV ARCHIVE_FILE=""

RUN echo "@edge http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && apk --no-cache add python3-dev libffi-dev gcc libc-dev py3-pip py3-cffi py3-cryptography ca-certificates bash

WORKDIR /opt/grafana-backup-tool
ADD . /opt/grafana-backup-tool

RUN chmod -R a+r /opt/grafana-backup-tool \
 && find /opt/grafana-backup-tool -type d -print0 | xargs -0 chmod a+rx

# Create a dedicated virtual environment to avoid PEP 668 restrictions
RUN python3 -m venv /opt/venv \
 && /opt/venv/bin/pip install --no-cache-dir --upgrade pip \
 && /opt/venv/bin/pip install --no-cache-dir .

# Ensure the venv binaries are first on PATH
ENV PATH="/opt/venv/bin:$PATH"

RUN chown -R 1337:1337 /opt/grafana-backup-tool /opt/venv
USER 1337
CMD ["sh","-c","if [ \"$RESTORE\" = true ]; then if [ ! -z \"$AWS_S3_BUCKET_NAME\" ] || [ ! -z \"$AZURE_STORAGE_CONTAINER_NAME\" ] || [ ! -z \"$GCS_BUCKET_NAME\" ]; then grafana-backup restore $ARCHIVE_FILE; else grafana-backup restore _OUTPUT_/$ARCHIVE_FILE; fi; else grafana-backup save; fi"]
