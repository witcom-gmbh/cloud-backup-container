FROM alpine:3.11

RUN apk -v --update add \
        python3 \
        py-pip \
        groff \
        less \
        mailcap \
        mysql-client \
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

# Tell docker that all future commands should run as the appuser user

ENV MARIADB_DATABASE=NONE MARIADB_HOST=NONE MARIADB_PORT=3306 MARIADB_USER=NONE MARIADB_PASSWORD=NONE MARIADB_EXTRA_OPTS='' S3_ACCESS_KEY_ID=NONE S3_SECRET_ACCESS_KEY=NONE S3_BUCKET=NONE \
    S3_PREFIX='backup' \
    S3_S3V4=no \
    DUMPNAME=NONE

WORKDIR /cloudbackup

ADD restore.sh restore.sh

USER cloudbackup

CMD ["sh", "restore.sh"]
