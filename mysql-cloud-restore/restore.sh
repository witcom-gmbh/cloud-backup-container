#! /bin/sh

set -e
set -o pipefail

if [ "${S3_ACCESS_KEY_ID}" = "NONE" ]; then
  echo "You need to set the S3_ACCESS_KEY_ID environment variable."
  exit 1
fi

if [ "${S3_SECRET_ACCESS_KEY}" = "NONE" ]; then
  echo "You need to set the S3_SECRET_ACCESS_KEY environment variable."
  exit 1
fi

if [ "${S3_BUCKET}" = "NONE" ]; then
  echo "You need to set the S3_BUCKET environment variable."
  exit 1
fi

if [ "${S3_PREFIX}" = "NONE" ]; then
  echo "You need to set the S3_PREFIX environment variable."
  exit 1
fi

if [ "${MARIADB_DATABASE}" = "NONE" ]; then
  echo "You need to set the MARIADB_DATABASE environment variable."
  exit 1
fi

if [ "${MARIADB_HOST}" = "NONE" ]; then
    echo "You need to set the MARIADB_HOST environment variable."
    exit 1
fi

if [ "${MARIADB_USER}" = "NONE" ]; then
  echo "You need to set the MARIADB_USER environment variable."
  exit 1
fi

if [ "${MARIADB_PASSWORD}" = "NONE" ]; then
  echo "You need to set the MARIADB_PASSWORD environment variable or link to a container named POSTGRES."
  exit 1
fi

if [ "${S3_ENDPOINT}" == "NONE" ]; then
  AWS_ARGS=""
else
  AWS_ARGS="--endpoint-url ${S3_ENDPOINT}"
fi

# env vars needed for aws tools
export AWS_ACCESS_KEY_ID=$S3_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$S3_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION=$S3_REGION

#AWS_ARGS="--access_key=$S3_ACCESS_KEY_ID --secret_key=$S3_SECRET_ACCESS_KEY --host=$S3_ENDPOINT --host-bucket=$S3_ENDPOINT"

MARIADB_HOST_OPTS="-h $MARIADB_HOST -P $MARIADB_PORT -u $MARIADB_USER -p$MARIADB_PASSWORD $MARIADB_EXTRA_OPTS"

if [ "${DUMPNAME}" = "NONE" ]; then
  #get last backup
  DUMPNAME=$(aws s3 ls s3://$S3_BUCKET/$S3_PREFIX/ $AWS_ARGS | sort | tail -n 1 | awk '{ print $4 }') 
fi

echo "Fetching ${DUMPNAME} from S3"

aws s3 cp s3://$S3_BUCKET/$S3_PREFIX/${DUMPNAME} $AWS_ARGS dumps/dump.sql.gz
gzip -d dumps/dump.sql.gz

echo "Restoring ${MARIADB_DATABASE}"

mysql $MARIADB_HOST_OPTS $MARIADB_DATABASE <  ./dumps/dump.sql

rm ./dumps/dump.sql

echo "Restore complete"
