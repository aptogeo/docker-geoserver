FROM fedora:31

LABEL maintainer="AptoGéo/Mathieu MAST"

# Env variables
ENV GEOSERVER_VERSION_MAJOR 2.16
ENV GEOSERVER_VERSION_MINOR 0
ENV GEOSERVER_HOME /opt/geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}
ENV GEOSERVER_DATA_DIR /opt/geoserver_data_dir
ENV JAVA_HOME /etc/alternatives/jre
ENV JAVA_OPTS="-Xms512m -Xmx2048m"

# Packages
RUN dnf install -y wget java-1.8.0-openjdk unzip procps-ng net-tools

# Add GeoServer
RUN \
    useradd -d ${GEOSERVER_HOME} -m -s /bin/bash geoserver && \
    mkdir -p /opt && \
    cd /opt && \
    wget -q http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}/geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-bin.zip && \
    unzip -o geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-bin.zip && \
    rm -f geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-bin.zip && \
    mv ${GEOSERVER_HOME}/data_dir ${GEOSERVER_DATA_DIR}

# Importer extension
RUN wget -q http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}/extensions/geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-importer-plugin.zip &&\
    unzip -o geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-importer-plugin.zip -d ${GEOSERVER_HOME}/webapps/geoserver/WEB-INF/lib/ && \
    rm -f geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-importer-plugin.zip
RUN wget -q http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}/extensions/geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-importer-bdb-plugin.zip &&\
    unzip -o geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-importer-bdb-plugin.zip -d ${GEOSERVER_HOME}/webapps/geoserver/WEB-INF/lib/ && \
    rm -f geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-importer-bdb-plugin.zip

# Vector tiles extension
RUN wget -q http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}/extensions/geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-vectortiles-plugin.zip &&\
    unzip -o geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-vectortiles-plugin.zip -d ${GEOSERVER_HOME}/webapps/geoserver/WEB-INF/lib/ && \
    rm -f geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-vectortiles-plugin.zip

# Mapbox style extension
RUN wget -q https://build.geoserver.org/geoserver/${GEOSERVER_VERSION_MAJOR}.x/community-latest/geoserver-${GEOSERVER_VERSION_MAJOR}-SNAPSHOT-mbstyle-plugin.zip &&\
    unzip -o geoserver-${GEOSERVER_VERSION_MAJOR}-SNAPSHOT-mbstyle-plugin.zip -d ${GEOSERVER_HOME}/webapps/geoserver/WEB-INF/lib/ && \
    rm -f geoserver-${GEOSERVER_VERSION_MAJOR}-SNAPSHOT-mbstyle-plugin.zip

# WPS extension
RUN wget -q http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}/extensions/geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-wps-plugin.zip &&\
    unzip -o geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-wps-plugin.zip -d ${GEOSERVER_HOME}/webapps/geoserver/WEB-INF/lib/ && \
    rm -f geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-wps-plugin.zip

RUN chown -R geoserver ${GEOSERVER_HOME} ${GEOSERVER_DATA_DIR}

USER root
EXPOSE 8080
VOLUME ${GEOSERVER_DATA_DIR}
WORKDIR ${GEOSERVER_HOME}
CMD su - geoserver -c "JAVA_HOME=${JAVA_HOME} GEOSERVER_DATA_DIR=${GEOSERVER_DATA_DIR} ${GEOSERVER_HOME}/bin/startup.sh"
