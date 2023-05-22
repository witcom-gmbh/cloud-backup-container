FROM alpine:3.17

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
    pip3 install --upgrade awscli s3cmd python-magic six && \
    rm /var/cache/apk/*

RUN addgroup -S cloudbackup && adduser -S cloudbackup -G cloudbackup -u 1001
RUN mkdir /cloudbackup && mkdir /cloudbackup/dumps && \
    chown -Rf cloudbackup:cloudbackup /cloudbackup && \
    chgrp -R 0 /cloudbackup && \
    chmod -R g=u /cloudbackup

# Tell docker that all future commands should run as the appuser user

ENV POSTGRES_DATABASE=NONE \
    POSTGRES_HOST=NONE \
    POSTGRES_PORT=5432 \
    POSTGRES_USER=NONE \
    POSTGRES_PASSWORD=NONE \
    POSTGRES_EXTRA_OPTS='' \
    POSTGRES_CHANGE_OWNER='true' \
    S3_ACCESS_KEY_ID=NONE \
    S3_SECRET_ACCESS_KEY=NONE \
    S3_BUCKET=NONE \
    S3_PREFIX='backup' \
    S3_S3V4=no \
    DUMPNAME=NONE

WORKDIR /cloudbackup

ADD restore.sh restore.sh

USER cloudbackup

CMD ["sh", "restore.sh"]
