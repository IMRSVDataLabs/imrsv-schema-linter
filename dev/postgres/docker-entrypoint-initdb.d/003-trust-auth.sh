#! /bin/sh

# What's correct.
#echo 'INFO:Changing all trust authentication to peer authentication'
#exec sed -i 's/trust/peer/g' "$PGDATA/pg_hba.conf"

# What we need for some linting rules.
echo 'INFO:Enabling insecure auth modes for testing'
#exec sed -i 'a/TODO/' "$PGDATA/pg_hba.conf"
