# GeoServer Docker Image

## Included

- GeoServer
- Vector tiles extension
- Mapbox style extension

## Build
```sh
~ docker build -t geoserver .
```

## Run GeoServer Docker Container
```sh
~ docker run --name geoserver -p 8080:8080 -d -t geoserver
```