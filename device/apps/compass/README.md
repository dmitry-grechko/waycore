# Compass App

Navigation compass with magnetic heading, GPS coordinates, and elevation display.

## Features

- **Magnetic Compass**: Rotating compass rose showing true heading
- **Heading Display**: Degrees and cardinal direction (N, NE, E, etc.)
- **GPS Coordinates**: Shows latitude/longitude when GPS is available
- **Elevation**: Shows altitude from barometric/GPS data
- **Calibration**: Status indicator with calibration trigger

## Sensors

| Sensor | Required | Purpose |
|--------|----------|---------|
| Magnetometer | Yes | Compass heading |
| GPS | No | Coordinates and position |
| Barometer | No | Elevation data |

## Usage

The compass app displays:
1. A rotating compass rose that keeps North pointing to magnetic north
2. A fixed indicator at the top showing your current direction
3. Your heading in degrees (0-359°) in the center
4. Cardinal direction (N, NE, E, SE, S, SW, W, NW)
5. GPS coordinates and accuracy when available
6. Elevation when barometer data is available

### Calibration

If the magnetometer needs calibration:
1. The status bar will show "⚠ Needed"
2. Tap the "Calibrate" button
3. Follow the on-screen instructions (figure-8 motion)
4. Wait for "✓ OK" confirmation

## Technical Details

- **App ID**: `com.waycore.compass`
- **Category**: Navigation
- **Tier**: 2 (main apps grid)
- **Update Rate**: 10 Hz (100ms refresh)

## Files

```
device/apps/compass/
├── manifest.json      # App manifest
├── qml/
│   └── CompassMain.qml  # Main UI component
├── assets/            # Future: compass rose graphics
└── README.md          # This file
```

## Development

### Testing

The app works with both real magnetometer data and mock data:
- **Mock mode**: Shows simulated heading that slowly rotates
- **Live mode**: Connects to actual magnetometer via SensorBridge

To verify the app is discovered:

```bash
python -c "
from device.apps.core.loader import AppLoader
from pathlib import Path
loader = AppLoader(Path('device/apps'))
apps = loader.discover_apps()
compass = [a for a in apps if a.id == 'com.waycore.compass']
print('Compass found:', len(compass) > 0)
"
```

### Future Improvements

- [ ] Custom compass rose SVG graphics
- [ ] Declination adjustment setting
- [ ] Heading lock/follow mode
- [ ] Waypoint navigation
- [ ] Night mode (red display)
