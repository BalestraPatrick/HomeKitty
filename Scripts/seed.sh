#!/bin/bash

DB_USER="patrickbalestra"
DB_NAME="patrickbalestra"
DB_PORT=5433

set -e
psql -U "$DB_USER" -d "$DB_NAME" -p $DB_PORT -a -f seed_categories.sql || (echo "🚨  Failed seed categories"; exit 1;)
psql -U "$DB_USER" -d "$DB_NAME" -p $DB_PORT -a -f seed_manufacturers.sql || (echo "🚨  Failed seed manufacturers"; exit 1;)
psql -U "$DB_USER" -d "$DB_NAME" -p $DB_PORT -a -f seed_bridges.sql || (echo "🚨  Failed seed bridges"; exit 1;)
psql -U "$DB_USER" -d "$DB_NAME" -p $DB_PORT -a -f seed_lights.sql || (echo "🚨  Failed seed lights"; exit 1;)
psql -U "$DB_USER" -d "$DB_NAME" -p $DB_PORT -a -f seed_outlets.sql || (echo "🚨  Failed seed outlets"; exit 1;)
psql -U "$DB_USER" -d "$DB_NAME" -p $DB_PORT -a -f seed_regions.sql || (echo "🚨  Failed seed regions"; exit 1;)
psql -U "$DB_USER" -d "$DB_NAME" -p $DB_PORT -a -f seed_accessories_count.sql || (echo "🚨  Failed seed accessories count"; exit 1;)

echo "✅ Seed completed ✅"
