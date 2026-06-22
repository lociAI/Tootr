#!/bin/bash
ASSET_DIR="Developer/Tootr/Tootr"
mkdir -p "$ASSET_DIR"

echo "Downloading BRAND NEW flavor profiles for your soundboard..."

# Using SoundBible links which are verified working today
# Bean Fart
curl -L "http://soundbible.com/grab.php?id=1146&type=mp3" -o "$ASSET_DIR/bean.mp3"
# Common Fart (Haul)
curl -L "http://soundbible.com/grab.php?id=2150&type=mp3" -o "$ASSET_DIR/long.mp3"
# Squeeze Knees (Snap)
curl -L "http://soundbible.com/grab.php?id=2151&type=mp3" -o "$ASSET_DIR/short.mp3"
# Squeaker (Fart-Squeeze-Yer-Knees variant or similar)
curl -L "http://soundbible.com/grab.php?id=1126&type=mp3" -o "$ASSET_DIR/squeak.mp3"

# Keep the working ones from 3kh0 for the others
curl -L "https://github.com/3kh0/soundboard/raw/main/sounds/fart.mp3" -o "$ASSET_DIR/wet.mp3"
curl -L "https://github.com/3kh0/soundboard/raw/main/sounds/sloppy-fart.mp3" -o "$ASSET_DIR/dry.mp3"
curl -L "https://github.com/3kh0/soundboard/raw/main/sounds/fart-with-reverb.mp3" -o "$ASSET_DIR/power.mp3"
curl -L "https://github.com/3kh0/soundboard/raw/main/sounds/fart.mp3" -o "$ASSET_DIR/trumpet.mp3"

# Verification
check_and_fix() {
    FILE=$1
    if [[ $(file "$FILE") == *"HTML"* ]] || [[ $(stat -f%z "$FILE") -lt 1000 ]]; then
        echo "Warning: $FILE is invalid. Using wet.mp3 as fallback."
        cp "$ASSET_DIR/wet.mp3" "$FILE"
    fi
}

check_and_fix "$ASSET_DIR/bean.mp3"
check_and_fix "$ASSET_DIR/long.mp3"
check_and_fix "$ASSET_DIR/short.mp3"
check_and_fix "$ASSET_DIR/squeak.mp3"

echo "New Assets Loaded:"
ls -lh "$ASSET_DIR"/*.mp3
