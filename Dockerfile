FROM fedora:33

LABEL maintainer="AptoGéo/Mathieu MAST"

# Env variables
ENV GEOSERVER_VERSION_MAJOR 2.18
ENV GEOSERVER_VERSION_MINOR 2
ENV GEOSERVER_HOME /opt/geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}
ENV GEOSERVER_DATA_DIR /opt/geoserver_data_dir
ENV GEOSERVER_CSRF_DISABLED false
ENV GEOSERVER_PATH geoserver
ENV JAVA_HOME /etc/alternatives/jre
ENV JAVA_OPTS="-Xms512m -Xmx2048m"

# Packages
RUN dnf install -y java-11-openjdk unzip procps-ng net-tools ftp wget wput curl passwd

# Add GeoServer
RUN \
    mkdir -p /opt && \
    cd /opt && \
    wget -q http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}/geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-bin.zip && \
    unzip -o geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-bin.zip -d ${GEOSERVER_HOME} && \
    rm -f geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-bin.zip && \
    mv ${GEOSERVER_HOME}/data_dir ${GEOSERVER_DATA_DIR}

# Importer extension
RUN wget -q http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}/extensions/geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-importer-plugin.zip &&\
    unzip -o geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-importer-plugin.zip -d ${GEOSERVER_HOME}/webapps/geoserver/WEB-INF/lib/ && \
    rm -f geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-importer-plugin.zip

# Vector tiles extension
RUN wget -q http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}/extensions/geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-vectortiles-plugin.zip &&\
    unzip -o geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-vectortiles-plugin.zip -d ${GEOSERVER_HOME}/webapps/geoserver/WEB-INF/lib/ && \
    rm -f geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-vectortiles-plugin.zip

# Mapbox style extension
RUN wget -q http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}/extensions/geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-mbstyle-plugin.zip &&\
    unzip -o geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-mbstyle-plugin.zip -d ${GEOSERVER_HOME}/webapps/geoserver/WEB-INF/lib/ && \
    rm -f geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-mbstyle-plugin.zip

# WPS extension
RUN wget -q http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}/extensions/geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-wps-plugin.zip &&\
    unzip -o geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-wps-plugin.zip -d ${GEOSERVER_HOME}/webapps/geoserver/WEB-INF/lib/ && \
    rm -f geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-wps-plugin.zip

# Move GeoServer app
RUN mv ${GEOSERVER_HOME}/webapps/ ${GEOSERVER_HOME}/savwebapps/

USER root
EXPOSE 8080
VOLUME ${GEOSERVER_DATA_DIR}
WORKDIR ${GEOSERVER_HOME}
CMD rm -rf ${GEOSERVER_HOME}/webapps/ && mkdir ${GEOSERVER_HOME}/webapps/ && cp -r ${GEOSERVER_HOME}/savwebapps/geoserver/ ${GEOSERVER_HOME}/webapps/${GEOSERVER_PATH}/ && ${GEOSERVER_HOME}/bin/startup.sh
