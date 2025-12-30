# SOS App

Emergency SOS beacon with mesh broadcast and sensory alerts.

## Features

- Large press-and-hold activation button (3 seconds)
- Optical beacon (flashlight SOS Morse pattern)
- Acoustic beacon (speaker SOS Morse pattern)
- LoRa mesh broadcast with GPS coordinates
- Clear status indicators

## Permissions

- `mesh.send` - Broadcast emergency over mesh network
- `audio.play` - Play acoustic SOS signal
- `flashlight.control` - Control LED flashlight for optical SOS
- `gps.read` - Include GPS coordinates in broadcast

## Usage

The SOS app provides emergency signaling:

1. Press and hold the SOS button for 3 seconds to activate
2. Toggle optical beacon (flashlight SOS pattern) on/off
3. Toggle acoustic beacon (audio SOS pattern) on/off
4. View LoRa mesh status and GPS coordinates
5. Tap DEACTIVATE to stop all signals

## Morse Code Pattern

SOS in Morse code: `... --- ...` (dit dit dit dah dah dah dit dit dit)

- Dit (short): 150ms
- Dah (long): 450ms
- Element gap: 150ms
- Letter gap: 450ms
- Word gap: 1050ms
