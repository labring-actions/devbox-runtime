#!/bin/bash


if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <image> <template_json> <template_repo_json>"
    exit 1
fi

# 提取环境变量
IMAGE=$1
TEMPLATE_JSON=$2
TEMPLATE_REPO_JSON=$3

echo "IMAGE=$IMAGE"
echo "TEMPLATE_JSON=$TEMPLATE_JSON"
echo "TEMPLATE_REPO_JSON=$TEMPLATE_REPO_JSON"

SQL_DIR="sql"
SQL_FILE="$SQL_DIR/$RUNTIME_NAME-$SHORT_COMMIT_ID.sql.tmp"
# IMAGE="ghcr.io/labring-actions/devbox/$RUNTIME_NAME:$SHORT_COMMIT_ID"
RUNTIME_NAME=$(echo "$TEMPLATE_REPO_JSON" | jq -r '.name')
IS_PUBLIC=$(echo "$TEMPLATE_REPO_JSON" | jq -r '.isPublic')
KIND=$(echo "$TEMPLATE_REPO_JSON" | jq -r '.kind')
VERSION=$(echo "$TEMPLATE_JSON" | jq -r '.name')
PORT=$(echo "$TEMPLATE_JSON" | jq -r '.port')
TEMPLATE_CONFIG=$(bash script/generate_template_config.sh --app-port $PORT)


# 创建目录（如果不存在）
mkdir -p $SQL_DIR

# 生成 UUID
# TEMPLATE_UID=$(uuidgen)
# TEMPLATE_REPOSITORY_TAG_UID=$(uuidgen)

# 生成 SQL 文件
cat <<EOF
--1. 如果没有找到，创建一个新的 TemplateRepository
WITH org_uid AS (
    SELECT "uid" FROM "Organization"
    WHERE "name" = 'labring'
    LIMIT 1
)
INSERT "TemplateRepository" ("uid", "name", "description", "kind", "organizationUid", "regionUid", "isPublic", "createdAt", "updatedAt")
SELECT
    '$(uuidgen)',
    '$RUNTIME_NAME',
    'A new template repository',
    '$KIND',
    org_uid.uid,
    '<region_uid>',  -- 必须替换为实际存在的 regionUid，空字符串会导致外键错误
    $IS_PUBLIC::boolean,
    now(),
    now()
WHERE NOT EXISTS (
    SELECT 1 FROM "TemplateRepository"
    WHERE "name" = '$RUNTIME_NAME' AND "organizationUid" = '$ORG_UID' AND "regionUid" = '$REGION_UID'
);

-- 2. 更新已存在的 Template为 isDeleted (如果有)
WITH org_uid AS (
    SELECT "uid" FROM "Organization"
    WHERE "name" = 'labring'
    LIMIT 1
),
template_repository_uid AS (
    SELECT "uid" FROM "TemplateRepository"
    WHERE "name" = '$RUNTIME_NAME' AND "organizationUid" = org_uid.uid AND "regionUid" = 'region_uid_placeholder'
    LIMIT 1
)

UPDATE "Template"
SET "image" = '$IMAGE',
    "config" = '$TEMPLATE_CONFIG',
    "updatedAt" = now(),
    "deletedAt" = now(),
    "isDeleted" = FALSE
WHERE "name" = '$VERSION' AND "isDeleted" = false;

-- 3. 插入 新的Template
WITH org_uid AS (
    SELECT "uid" FROM "Organization"
    WHERE "name" = 'labring'
    LIMIT 1
),
template_repository_uid AS (
    SELECT "uid" FROM "TemplateRepository"
    WHERE "name" = '$RUNTIME_NAME' AND "organizationUid" = org_uid.uid AND "regionUid" = 'region_uid_placeholder'
    LIMIT 1
)
INSERT "Template" ("name", "image", "config", "templateRepositoryUid", "createdAt", "updatedAt")
SELECT
    '$VERSION',
    '$IMAGE',
    '$TEMPLATE_CONFIG',
    template_repository_uid.uid,
    now(),
    now();
EOF
