#!/bin/bash

set -e
psql -U patrickbalestra -d patrickbalestra -p 5433 -a -f seed_categories.sql || (echo "🚨  Failed seed categories"; exit 1;)
psql -U patrickbalestra -d patrickbalestra -p 5433 -a -f seed_manufacturers.sql || (echo "🚨  Failed seed manufacturers"; exit 1;)
psql -U patrickbalestra -d patrickbalestra -p 5433 -a -f seed_lights.sql || (echo "🚨  Failed seed lights"; exit 1;)
psql -U patrickbalestra -d patrickbalestra -p 5433 -a -f seed_outlets.sql || (echo "🚨  Failed seed outlets"; exit 1;)
echo "✅  Seed completed ✅"
