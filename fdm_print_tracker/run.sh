#!/bin/bash
set -e

mkdir -p /data/fdm/keys
rm -rf /app/data
ln -s /data/fdm /app/data

OPTIONS_FILE="/data/options.json"
if [ -f "$OPTIONS_FILE" ]; then
    export TZ="$(jq -r '.tz // "Europe/Dublin"' "$OPTIONS_FILE")"
    export Mqtt__Broker="$(jq -r '.mqtt_broker // "core-mosquitto"' "$OPTIONS_FILE")"
    export Mqtt__Port="$(jq -r '.mqtt_port // 1883' "$OPTIONS_FILE")"

    MQTT_USER="$(jq -r '.mqtt_username // ""' "$OPTIONS_FILE")"
    MQTT_PASS="$(jq -r '.mqtt_password // ""' "$OPTIONS_FILE")"
    GEMINI_KEY="$(jq -r '.gemini_api_key // ""' "$OPTIONS_FILE")"

    [ -n "$MQTT_USER" ] && [ "$MQTT_USER" != "null" ] && export Mqtt__Username="$MQTT_USER"
    [ -n "$MQTT_PASS" ] && [ "$MQTT_PASS" != "null" ] && export Mqtt__Password="$MQTT_PASS"
    [ -n "$GEMINI_KEY" ] && [ "$GEMINI_KEY" != "null" ] && export Gemini__ApiKey="$GEMINI_KEY"
fi

export Database__Provider="Sqlite"
export ConnectionStrings__DefaultConnection="Data Source=/data/fdm/printtracker.db"
export ASPNETCORE_ENVIRONMENT="Production"
export ASPNETCORE_URLS="http://+:8080"

exec dotnet /app/FDMPrintTrackerPro.dll
