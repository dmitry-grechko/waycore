# Sensors App

Sensor data display and monitoring.

## Features

- Time display (from backend or local)
- Battery level and charging status
- Temperature reading with unit conversion
- Backend connection status

## Permissions

- `sensors.all` - Access all sensor data

## Sensors

- `temperature` - Environmental temperature (optional)
- `battery` - Device battery level (optional)
- `gps` - Location data (optional)

## Usage

The Sensors app provides a singleton data model that other apps can access for sensor readings. It bridges to the Python SensorBridge backend and falls back to mock values when unavailable.
