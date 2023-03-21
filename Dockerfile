FROM eclipse-temurin:11-jdk-focal

LABEL maintainer="AptoGéo/Mathieu MAST"

# Env variables
ARG GEOSERVER_VERSION_MAJOR=2.22
ARG GEOSERVER_VERSION_MINOR=2
ARG GEOSERVER_HOME=/opt/geoserver
ARG GEOSERVER_DATA_DIR=/opt/geoserver_data_dir
ENV GEOSERVER_CSRF_DISABLED false
ENV HTTP_PORT=8080
ENV XMS=256m
ENV XMX=1024m

# Volumes
VOLUME $GEOSERVER_DATA_DIR

# Packages
RUN apt-get update && apt-get install unzip

# Add GeoServer
RUN \
    mkdir -p /opt && \
    cd /opt && \
    wget -q http://sourceforge.net/projects/geoserver/files/GeoServer/$GEOSERVER_VERSION_MAJOR.$GEOSERVER_VERSION_MINOR/geoserver-$GEOSERVER_VERSION_MAJOR.$GEOSERVER_VERSION_MINOR-bin.zip && \
    unzip -o geoserver-$GEOSERVER_VERSION_MAJOR.$GEOSERVER_VERSION_MINOR-bin.zip -d $GEOSERVER_HOME && \
    rm -f geoserver-$GEOSERVER_VERSION_MAJOR.$GEOSERVER_VERSION_MINOR-bin.zip

# Vector tiles extension
RUN wget -q http://sourceforge.net/projects/geoserver/files/GeoServer/$GEOSERVER_VERSION_MAJOR.$GEOSERVER_VERSION_MINOR/extensions/geoserver-$GEOSERVER_VERSION_MAJOR.$GEOSERVER_VERSION_MINOR-vectortiles-plugin.zip &&\
    unzip -o geoserver-$GEOSERVER_VERSION_MAJOR.$GEOSERVER_VERSION_MINOR-vectortiles-plugin.zip -d $GEOSERVER_HOME/webapps/geoserver/WEB-INF/lib/ && \
    rm -f geoserver-$GEOSERVER_VERSION_MAJOR.$GEOSERVER_VERSION_MINOR-vectortiles-plugin.zip

# Mapbox style extension
RUN wget -q http://sourceforge.net/projects/geoserver/files/GeoServer/$GEOSERVER_VERSION_MAJOR.$GEOSERVER_VERSION_MINOR/extensions/geoserver-$GEOSERVER_VERSION_MAJOR.$GEOSERVER_VERSION_MINOR-mbstyle-plugin.zip &&\
    unzip -o geoserver-$GEOSERVER_VERSION_MAJOR.$GEOSERVER_VERSION_MINOR-mbstyle-plugin.zip -d $GEOSERVER_HOME/webapps/geoserver/WEB-INF/lib/ && \
    rm -f geoserver-$GEOSERVER_VERSION_MAJOR.$GEOSERVER_VERSION_MINOR-mbstyle-plugin.zip

# Make directory GEOSERVER_DATA_DIR
RUN mkdir $GEOSERVER_DATA_DIR

# Define user geoserver
RUN groupadd --system -g 1000 geoserver
RUN useradd --system --gid geoserver --no-create-home --home-dir $GEOSERVER_DATA_DIR --shell /use/sbin/nologin --uid 1000 geoserver
RUN chown -Rf geoserver:geoserver $GEOSERVER_HOME
RUN chown -Rf geoserver:geoserver $GEOSERVER_DATA_DIR

USER 1000:1000
EXPOSE ${HTTP_PORT}
WORKDIR $GEOSERVER_HOME
CMD (test -d /opt/geoserver_data_dir/security && true || cp -rf /opt/geoserver/data_dir/* /opt/geoserver_data_dir) && sed -i "s/^jetty.http.port=.*$/jetty.http.port=${HTTP_PORT}/g" /opt/geoserver/start.ini && /opt/geoserver/bin/startup.sh
