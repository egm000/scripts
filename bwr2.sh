#!/bin/bash

# Coordinates for Göteborg
LAT=57.7089
LON=11.9746

# Fetch forecast data from SMHI
DATA=$(curl -s "https://opendata-download-metfcst.smhi.se/api/category/pmp3g/version/2/geotype/point/lon/$LON/lat/$LAT/data.json")

# Check if data was fetched
if [[ -z "$DATA" ]]; then
  echo "Error: Failed to fetch data from SMHI API."
  exit 1
fi

# Helper: convert wind degrees to compass direction
wind_dir() {
  local deg=$1
  if [[ -z "$deg" ]]; then
    echo "-"
    return
  fi
  local dirs=(N NE E SE S SW W NW)
  local idx=$(( (deg + 22) / 45 % 8 ))
  echo "${dirs[$idx]}"
}

# Loop through today and next two days
for i in {0..2}; do
  DATE=$(date -d "+$i day" +"%Y-%m-%d")
  DAY=$(date -d "$DATE" +"%A")

  # Extract morning (06:00) and afternoon (15:00) data
  MORNING=$(echo "$DATA" | jq '.timeSeries[] | select(.validTime | startswith("'"$DATE"'")) | select(.validTime | contains("T06"))')
  AFTERNOON=$(echo "$DATA" | jq '.timeSeries[] | select(.validTime | startswith("'"$DATE"'")) | select(.validTime | contains("T15"))')

  echo "$DAY ($DATE):"

  for PERIOD in MORNING AFTERNOON; do
    ENTRY=${!PERIOD}

    if [[ -z "$ENTRY" ]]; then
      echo "  ${PERIOD^}: No forecast data available."
      continue
    fi

    TEMP=$(echo "$ENTRY" | jq '.parameters[] | select(.name=="t") | .values[0]')
    PREC=$(echo "$ENTRY" | jq '.parameters[] | select(.name=="pmean") | .values[0]')
    WIND_S=$(echo "$ENTRY" | jq '.parameters[] | select(.name=="ws") | .values[0]')
    WIND_D=$(echo "$ENTRY" | jq '.parameters[] | select(.name=="wd") | .values[0]')
    WIND_DIR=$(wind_dir "$WIND_D")

    if [[ "$PERIOD" == "MORNING" ]]; then
      LABEL="Morning (06:00)"
    else
      LABEL="Afternoon (15:00)"
    fi

    echo "  $LABEL: ${TEMP}°C, Precip ${PREC} mm, Wind ${WIND_S} m/s $WIND_DIR"
  done

  echo
done
