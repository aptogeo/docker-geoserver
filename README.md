# GeoServer Docker Image

## Included

- GeoServer
- Vector tiles extension
- Mapbox style extension

## Build
```sh
~ docker build -t aptogeo/geoserver .
```

## Run GeoServer Docker Container
```sh
~ docker run --name geoserver -p 8080:8080 -d -t aptogeo/geoserver
```

## Run GeoServer Docker Container with persistant volume
```sh
~ docker volume create geoserver-data-dir
~ docker run --name geoserver -v geoserver-data-dir:/opt/geoserver_data_dir -p 8080:8080 -d -t aptogeo/geoserver
```