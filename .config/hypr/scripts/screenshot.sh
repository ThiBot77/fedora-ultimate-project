#!/bin/bash
# Hyprland Screenshot Script

# Directory to save screenshots
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"

# Filename with timestamp
FILENAME="$SCREENSHOT_DIR/screenshot_$(date +%Y%m%d_%H%M%S).png"

case $1 in
    "area")
        # Screenshot of selected area
        grim -g "$(slurp)" "$FILENAME"
        ;;
    "screen")
        # Full screen screenshot
        grim "$FILENAME"
        ;;
    "window")
        # Active window screenshot
        grim -g "$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" "$FILENAME"
        ;;
    *)
        echo "Usage: $0 {area|screen|window}"
        exit 1
        ;;
esac

# Notify user
if [ -f "$FILENAME" ]; then
    notify-send "Screenshot" "Saved to $FILENAME" -i "$FILENAME"
    wl-copy < "$FILENAME"
    echo "$FILENAME"
else
    notify-send "Screenshot" "Failed to capture screenshot" -u critical
    exit 1
fi
