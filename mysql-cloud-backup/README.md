# mysql-cloud-backup
Backup MySQL to S3-Storage
## Basic usage

```sh
$ docker run -e S3_ACCESS_KEY_ID=key -e S3_SECRET_ACCESS_KEY=secret -e S3_BUCKET=my-bucket -e S3_PREFIX=backup -e MARIADB_USER=user -e MARIADB_PASSWORD=password -e MARIADB_DATABASE=dbname -e MARIADB_HOST=localhost mysql-cloud-backup
```

## Environment variables

- `MARIADB_EXTRA_OPTS` mysqldump options (default: --quote-names --quick --add-drop-table --add-locks --allow-keywords --disable-keys --extended-insert --single-transaction --create-options --comments --net_buffer_length=16384)
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
- `SCHEDULE` backup schedule time, see explainatons below (default: 'NONE', runs once)
- `RETENTION_DAYS` Defines a bucket-policy in S3

### Automatic Periodic Backups

You can additionally set the `SCHEDULE` environment variable like `-e SCHEDULE="@daily"` to run the backup automatically.

More information about the scheduling can be found [here](http://godoc.org/github.com/robfig/cron#hdr-Predefined_schedules).

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

Create Kubernetes Cronjob (here is one that runs every 4 hours)

```
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: db-backup
spec:
  schedule: "0 */4 * * *"
  successfulJobsHistoryLimit: 1
  failedJobsHistoryLimit: 1
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: db-backup
            image: .../mysql-cloud-backup:0.0.2
            envFrom:
            - secretRef:
                name: s3-keycloak-backup
            env:
            - name: MARIADB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: db-secret
                  key: mariadb-password
            - name: S3_PREFIX
              value: somedb  
            - name: MARIADB_DATABASE
              value: somedb 
            - name: S3_ENDPOINT
              value: https://s3.xxxx
            - name: MARIADB_USER
              valueFrom:
                secretKeyRef:
                  name: db-secret
                  key: mariadb-username
            - name: MARIADB_HOST
              value: mariadb-hostname
          restartPolicy: Never
```






