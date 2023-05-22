# mysql-cloud-restore
Restore MySQL from  S3-Storage. 

## Warning
This will potentially put your database in a very bad state or complete destroy your data, be very careful.

## Limitations
This is made to restore a backup made from mysql-backup-s3, if you backup came from somewhere else please check your format.

* Your s3 bucket *must* only contain backups which you wish to restore - it will always grabs the 'latest' based on unix sort with no filtering. Or you can pass a dumpfile-name manually
* They must be gzip encoded text sql files

## Basic usage

```sh
$ docker run -e S3_ACCESS_KEY_ID=key -e S3_SECRET_ACCESS_KEY=secret -e S3_BUCKET=my-bucket -e S3_PREFIX=backup -e MARIADB_USER=user -e MARIADB_PASSWORD=password -e MARIADB_DATABASE=dbname -e MARIADB_HOST=localhost mysql-cloud-restore
```

## Environment variables

- `MARIADB_EXTRA_OPTS` defaults to nothing
- `MARIADB_DATABASE` database you want to backup *required*
- `MARIADB_HOST` the mysql host *required*
- `MARIADB_HOST` the mysql port (default: 3306)
- `MARIADB_HOST` the mysql user *required*
- `MARIADB_HOST` the mysql password *required*
- `S3_ACCESS_KEY_ID` your AWS access key *required*
- `S3_SECRET_ACCESS_KEY` your AWS secret key *required*
- `S3_BUCKET` your AWS S3 bucket path *required*
- `S3_PREFIX` path prefix in your bucket (default: 'backup')
- `S3_ENDPOINT` the AWS Endpoint URL, for S3 Compliant APIs such as [minio](https://minio.io) (default: none)
- `S3_S3V4` set to `yes` to enable AWS Signature Version 4, required for [minio](https://minio.io) servers (default: no)
- `DUMPNAME` provice name of dumpfile to restore. Must exist under s3://bucket/prefix

### Run in Kubernetes
Create secret for S3-Credentials

```
mkdir secrets
cd secrets
echo -n 'ACCESS' > S3_ACCESS_KEY_ID
echo -n 'SECRET' > S3_SECRET_ACCESS_KEY
echo -n 'BUCKET' > S3_BUCKET
kubectl -n NAMESPACE create secret generic s3-keycloak-backup \
    --from-file=./S3_ACCESS_KEY_ID \
    --from-file=./S3_SECRET_ACCESS_KEY \
    --from-file=./S3_BUCKET
cd ..    
rm -rf ./secrets
```

Create Kubernetes Job, run it

```
apiVersion: batch/v1
kind: Job
metadata:
  name: restore
spec:
      backoffLimit: 4
      template:
        spec:
          containers:
          - name: restore
            image: ***/mysql-cloud-backup:0.0.3
            envFrom:
            - secretRef:
                name: s3-secret
            env:
            - name: MARIADB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: db-secret
                  key: mariadb-password
            - name: S3_PREFIX
              value: some-db  
            - name: MARIADB_DATABASE
              value: some-db 
            - name: S3_ENDPOINT
              value: https://s3.*
            - name: MARIADB_USER
              valueFrom:
                secretKeyRef:
                  name: db-secret
                  key: mariadb-username
            - name: MARIADB_HOST
              value: dbhost
          restartPolicy: Never
```






