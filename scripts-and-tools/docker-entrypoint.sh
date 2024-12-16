#!/bin/sh

log() {
    type="$1"; shift
    printf '%s [%s] [Entrypoint]: %s\n' "$(date -Iseconds)" "$type" "$*"
}

log Note "Entrypoint script for Lighthouse $SERVER started"

if [ ! -d "/lighthouse/data" ]; then
    log Note "Creating data directory"
    mkdir -p "/lighthouse/data"
fi

if [ ! -d "/lighthouse/data/StaticFiles" ]; then
    cp -r /lighthouse/temp/StaticFiles /lighthouse/data
fi

# Start server

log Note "Startup tasks finished, starting $SERVER..."
cd /lighthouse/data || exit
dotnet /lighthouse/app/LBPUnion.ProjectLighthouse.Servers."$SERVER".dll

exit $? # Expose error code from dotnet command
