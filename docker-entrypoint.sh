#!/bin/sh
set -e
# Apply pending migrations, then start the server.
/app/izylay toasty migration apply
exec /app/izylay
