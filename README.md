# GeoServer Docker Image

## Included

- GeoServer
- PostgreSQL/PostGIS
- SpatiaLite
- Importer extension
- Vector tiles extension

## Build
```sh
~ docker build -t geoserver .
```

## Run GeoServer Docker Container
```sh
~ docker run --name "geoserver" -p 8080:8080 -p 5432:5432 -d -t geoserver
```