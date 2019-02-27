FROM fedora:29

LABEL maintainer="Aptogeo/Mathieu MAST"

# Bases packages
RUN dnf install -y wget java-1.8.0-openjdk unzip

# Env variables
ENV VERSION 2.14.2
ENV GEOSERVER_HOME /opt/geoserver-${VERSION}
ENV GEOSERVER_DATA_DIR /opt/geoserver_data_dir
ENV JAVA_HOME /etc/alternatives/jre
ENV JAVA_OPTS="-Xms512m -Xmx2048m"

# Add GeoServer
RUN \
    useradd -d ${GEOSERVER_HOME} -m -s /bin/bash geoserver && \
    mkdir -p /opt && \
    cd /opt && \
    wget -q http://sourceforge.net/projects/geoserver/files/GeoServer/${VERSION}/geoserver-${VERSION}-bin.zip && \
    unzip -o geoserver-${VERSION}-bin.zip && \
    rm -f geoserver-${VERSION}-bin.zip && \
    mv ${GEOSERVER_HOME}/data_dir ${GEOSERVER_DATA_DIR}

# Importer extension
RUN wget -q http://sourceforge.net/projects/geoserver/files/GeoServer/${VERSION}/extensions/geoserver-${VERSION}-importer-plugin.zip &&\
    unzip -o geoserver-${VERSION}-importer-plugin.zip -d ${GEOSERVER_HOME}/webapps/geoserver/WEB-INF/lib/ && \
    rm -f geoserver-${VERSION}-importer-plugin.zip
RUN wget -q http://sourceforge.net/projects/geoserver/files/GeoServer/${VERSION}/extensions/geoserver-${VERSION}-importer-bdb-plugin.zip &&\
    unzip -o geoserver-${VERSION}-importer-bdb-plugin.zip -d ${GEOSERVER_HOME}/webapps/geoserver/WEB-INF/lib/ && \
    rm -f geoserver-${VERSION}-importer-bdb-plugin.zip

# Vector tiles extension
RUN wget -q http://sourceforge.net/projects/geoserver/files/GeoServer/${VERSION}/extensions/geoserver-${VERSION}-vectortiles-plugin.zip &&\
    unzip -o geoserver-${VERSION}-vectortiles-plugin.zip -d ${GEOSERVER_HOME}/webapps/geoserver/WEB-INF/lib/ && \
    rm -f geoserver-${VERSION}-vectortiles-plugin.zip

RUN chown -R geoserver ${GEOSERVER_HOME} ${GEOSERVER_DATA_DIR}

# Run
USER geoserver
WORKDIR ${GEOSERVER_HOME}
VOLUME ${GEOSERVER_DATA_DIR}
CMD ${GEOSERVER_HOME}/bin/startup.sh
