#!/bin/bash

set -o pipefail
set -e

DATA=$(date +"%Y-%m-%d_%H-%M")
BACKUP_DIR="/home/backups/postgres"
DB_NAME="DB_NAME"
DB_USER="DB_USER"

export PGPASSWORD="DB_PASSWORD"

mkdir -p $BACKUP_DIR

pg_dump -U $DB_USER $DB_NAME | gzip > $BACKUP_DIR/backup_${DB_NAME}_${DATA}.sql.gz

if [ $? -eq 0 ]; then
        echo "Backup realizado com sucesso"
        /usr/bin/rclone copy "$BACKUP_DIR/backup_${DB_NAME}_${DATA}.sql.gz" cloudflare:postgres-backups-staging
        echo "Upload realizado com sucesso"
else 
        echo "Erro ao realizar backup"
fi


find $BACKUP_DIR -type f -name "*.gz" -mtime +7 -delete