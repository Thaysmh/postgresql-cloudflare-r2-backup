# PostgreSQL Backup Automation with Cloudflare R2

Guia prático para configurar backups automáticos do PostgreSQL em servidores Linux utilizando Bash, `pg_dump`, `gzip`, `rclone` e Cloudflare R2.

Este tutorial foi criado com base em uma implementação real utilizada em ambiente de produção, com foco em automação.

---

# Objetivo

Automatizar:

- geração de backups PostgreSQL;
- compactação dos arquivos;
- envio automático para Cloudflare R2;
- limpeza de backups antigos;
- execução diária via `cron`.

---

# Tecnologias Utilizadas

- Bash Script
- PostgreSQL (`pg_dump`)
- `gzip`
- `rclone`
- Cloudflare R2
- Linux / Ubuntu
- Cron

---

# Estrutura do Script

```bash
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

        /usr/bin/rclone copy \
        "$BACKUP_DIR/backup_${DB_NAME}_${DATA}.sql.gz" \
        cloudflare:postgres-backups-staging

        echo "Upload realizado com sucesso"
else 
        echo "Erro ao realizar backup"
fi

find $BACKUP_DIR -type f -name "*.gz" -mtime +7 -delete

```

# Como configurar o CRON
### Crie o arquivo logs
```bash
mkdir -p /home/logs
```
### Defina o path do script de backup e de saída dos logs
```bash
0 2 * * * /home/backups/backup_postgres.sh >> /home/logs/backup.log 2>&1
```