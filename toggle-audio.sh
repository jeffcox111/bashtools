get_sink_id() {
    local NAME="$1"
    wpctl status | awk -v name="$NAME" '
        /^ ├─ Sinks:/ {insinks=1; next}
        /^ ├─ Sink endpoints:/ {insinks=0; insinks_endpoints=1; next}
        /^ ├─/ && (insinks_endpoints) {insinks_endpoints=0}
        (insinks || insinks_endpoints) && $0 ~ name {
            match($0, /[0-9]+/); print substr($0,RSTART,RLENGTH); exit
        }'
}

# Replace these speaker/headphone names with YOUR device names!
# This can be done by running "wpctl status" and looking for the names of Audio Sinks
SPEAKERS_NAME="Starship/Matisse HD Audio Controller Analog Stereo"
HEADPHONES_NAME="HyperX 7.1 Audio Analog Stereo"

# Get the current default sink (friendly name)
CURRENT_ID=$(wpctl status | awk '
    /^ ├─ Sinks:/ {insinks=1; next}
    /^ ├─ Sink endpoints:/ {insinks=0; insinks_endpoints=1; next}
    /^ ├─/ && (insinks_endpoints) {insinks_endpoints=0}
    (insinks || insinks_endpoints) && /\*/ {
        match($0, /[0-9]+/); print substr($0,RSTART,RLENGTH); exit
    }')

# Get numeric IDs from the friendly names
SPEAKERS_ID=$(get_sink_id "$SPEAKERS_NAME")
HEADPHONES_ID=$(get_sink_id "$HEADPHONES_NAME")

# Debug lines (optional)
echo "Speakers_ID = $SPEAKERS_ID"
echo "Headphones_ID = $HEADPHONES_ID"
echo "Current_ID = $CURRENT_ID"

# Determine which to switch to
if [ "$CURRENT_ID" = "$SPEAKERS_ID" ]; then
    TARGET_ID="$HEADPHONES_ID"
    LABEL="$HEADPHONES_NAME"
else
    TARGET_ID="$SPEAKERS_ID"
    LABEL="$SPEAKERS_NAME"
fi

# Perform the switch
wpctl set-default "$TARGET_ID"
notify-send "Audio Output Switched" "Now using: $LABEL"
echo "Switched to $LABEL."
