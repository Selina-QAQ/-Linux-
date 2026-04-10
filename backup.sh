#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR=/opt/backup
mkdir -p $BACKUP_DIR

# ==================== 修复1：安全登录（不暴露密码）====================
MYSQL_USER=root
MYSQL_PASS=Root@123456
# ==================== 修复2：带压缩 + 安全备份 ====================
mysqldump -u$MYSQL_USER -p$MYSQL_PASS --all-databases --single-transaction --quick | gzip > $BACKUP_DIR/all_db_$DATE.sql.gz

# ==================== 修复3：判断备份是否成功 ====================
if [ $? -eq 0 ]; then
    echo "$DATE 备份成功 " >> $BACKUP_DIR/backup.log
else
    echo "$DATE 备份失败 " >> $BACKUP_DIR/backup.log
    exit 1
fi

# 保留7天
find $BACKUP_DIR -name "*.sql.gz" -type f -mtime +7 -delete