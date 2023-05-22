FROM alpine:3.11

RUN apk -v --update add \
        python3 \
        py-pip \
        groff \
        less \
        mailcap \
        postgresql \
        curl \
        py-crcmod \
        bash \
        libc6-compat \
        gnupg \
        coreutils \
        gzip \
        && \
    pip3 install --upgrade awscli s3cmd python-magic && \
    apk -v --purge del py-pip && \
    curl -L --insecure https://github.com/odise/go-cron/releases/download/v0.0.6/go-cron-linux.gz | zcat > /usr/local/bin/go-cron && \
    chmod u+x /usr/local/bin/go-cron && \
    rm /var/cache/apk/*

RUN addgroup -S cloudbackup && adduser -S cloudbackup -G cloudbackup -u 1001
RUN mkdir /cloudbackup && mkdir /cloudbackup/dumps && chown -Rf cloudbackup:cloudbackup /cloudbackup
RUN chgrp -R 0 /cloudbackup && \
    chmod -R g=u /cloudbackup 


ENV POSTGRES_DATABASE=NONE POSTGRES_HOST=NONE POSTGRES_PORT=5432 POSTGRES_USER=NONE POSTGRES_PASSWORD=NONE POSTGRES_EXTRA_OPTS='' S3_ACCESS_KEY_ID=NONE S3_SECRET_ACCESS_KEY=NONE S3_BUCKET=NONE \
    S3_PREFIX='backup' \
    S3_S3V4=no \
    RETENTION_DAYS=30 \
    S3_ENDPOINT=NONE \
    SCHEDULE=NONE

WORKDIR /cloudbackup

ADD lifecycle.json.tmpl lifecycle.json.tmpl
ADD run.sh run.sh
ADD backup.sh backup.sh

USER cloudbackup

CMD ["sh", "run.sh"]

