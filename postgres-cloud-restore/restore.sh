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

if [ "${S3_ENDPOINT}" == "NONE" ]; then
  AWS_ARGS=""
else
  AWS_ARGS="--endpoint-url ${S3_ENDPOINT}"
fi

if [ "${POSTGRES_DATABASE}" = "NONE" ]; then
  echo "You need to set the POSTGRES_DATABASE environment variable."
  exit 1
fi

if [ "${POSTGRES_HOST}" = "NONE" ]; then
  if [ -n "${POSTGRES_PORT_5432_TCP_ADDR}" ]; then
    POSTGRES_HOST=$POSTGRES_PORT_5432_TCP_ADDR
    POSTGRES_PORT=$POSTGRES_PORT_5432_TCP_PORT
  else
    echo "You need to set the POSTGRES_HOST environment variable."
    exit 1
  fi
fi

if [ "${POSTGRES_USER}" = "NONE" ]; then
  echo "You need to set the POSTGRES_USER environment variable."
  exit 1
fi

if [ "${POSTGRES_PASSWORD}" = "NONE" ]; then
  echo "You need to set the POSTGRES_PASSWORD environment variable or link to a container named POSTGRES."
  exit 1
fi

# env vars needed for aws tools
export AWS_ACCESS_KEY_ID=$S3_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$S3_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION=$S3_REGION

export PGPASSWORD=$POSTGRES_PASSWORD
POSTGRES_HOST_OPTS="-h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER $POSTGRES_EXTRA_OPTS"


if [ "${DUMPNAME}" = "NONE" ]; then
  #get last backup
  DUMPNAME=$(aws s3 ls s3://$S3_BUCKET/$S3_PREFIX/ $AWS_ARGS | sort | tail -n 1 | awk '{ print $4 }') 
fi

echo "Fetching ${DUMPNAME} from S3"

aws s3 cp s3://$S3_BUCKET/$S3_PREFIX/${DUMPNAME} $AWS_ARGS dumps/dump.sql.gz
gzip -d dumps/dump.sql.gz

if [ "${POSTGRES_CHANGE_OWNER}" = "true" ]; then
  echo "Perform owner-change"
  sed -i "/^ALTER.*OWNER TO .*;$/s/OWNER TO .*/OWNER TO $POSTGRES_USER;/g" ./dumps/dump.sql
fi

echo "Restoring ${POSTGRES_DATABASE}"
cat ./dumps/dump.sql | psql $POSTGRES_HOST_OPTS $POSTGRES_DATABASE || exit 2 

rm ./dumps/dump.sql

echo "Restore complete"
