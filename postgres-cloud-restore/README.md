# postgres-cloud-restore
Restore Postgres database from S3-Storage. 

## Warning
This will potentially put your database in a very bad state or complete destroy your data, be very careful.

## Limitations
This is made to restore a backup made from postgres-cloud-backup, if your backup came from somewhere else please check your format.

* Your s3 bucket *must* only contain backups which you wish to restore - it will always grabs the 'latest' based on unix sort with no filtering. Or you can pass a dumpfile-name manually
* The backups must be gzip encoded text sql files

## Basic usage

```sh
$ docker run --rm -e S3_ACCESS_KEY_ID=*** -e S3_SECRET_ACCESS_KEY=*** -e S3_BUCKET=postgres-cloud-backup -e S3_PREFIX=keycloak-auth-dev -e S3_ENDPOINT=https://*** -e POSTGRES_DATABASE=restoredb -e POSTGRES_USER=keycloak2 -e POSTGRES_HOST=db-host -e POSTGRES_PASSWORD=mysecretpassword postgres-cloud-restore
```

## Environment variables

- `POSTGRES_EXTRA_OPTS` defaults to nothing
- `POSTGRES_DATABASE` database to restore to. must exist. *required*
- `POSTGRES_HOST` the postgres host *required*
- `POSTGRES_PORT` the postgres port (default: 5432)
- `POSTGRES_USER` the postgres user *required*
- `POSTGRES_PASSWORD` the postgres password *required*
- `POSTGRES_CHANGE_OWNER` change the owner of postgres-objects to `POSTGRES_USER`. Defaults to true
- `S3_ACCESS_KEY_ID` your AWS access key *required*
- `S3_SECRET_ACCESS_KEY` your AWS secret key *required*
- `S3_BUCKET` your AWS S3 bucket path *required*
- `S3_PREFIX` path prefix in your bucket (default: 'backup')
- `S3_ENDPOINT` the AWS Endpoint URL, for S3 Compliant APIs such as [minio](https://minio.io) (default: none)
- `S3_S3V4` set to `yes` to enable AWS Signature Version 4, required for [minio](https://minio.io) servers (default: no)
- `DUMPNAME` provice name of dumpfile to restore. Must exist under s3://bucket/prefix
