FROM eclipse-temurin:11-jdk-focal

LABEL maintainer="AptoGéo/Mathieu MAST"

# Env variables
ENV GEOSERVER_VERSION_MAJOR 2.22
ENV GEOSERVER_VERSION_MINOR 2
ENV GEOSERVER_HOME /opt/geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}
ENV GEOSERVER_DATA_DIR /opt/geoserver_data_dir
ENV GEOSERVER_CSRF_DISABLED false
ENV GEOSERVER_PATH geoserver
ENV JAVA_OPTS="-Xms512m -Xmx2048m"

# Volumes
VOLUME ${GEOSERVER_DATA_DIR}

# Packages
RUN apt-get update && apt-get install unzip

# Add GeoServer
RUN \
    mkdir -p /opt && \
    cd /opt && \
    wget -q http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}/geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-bin.zip && \
    unzip -o geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-bin.zip -d ${GEOSERVER_HOME} && \
    rm -f geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-bin.zip

# Vector tiles extension
RUN wget -q http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}/extensions/geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-vectortiles-plugin.zip &&\
    unzip -o geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-vectortiles-plugin.zip -d ${GEOSERVER_HOME}/webapps/geoserver/WEB-INF/lib/ && \
    rm -f geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-vectortiles-plugin.zip

# Mapbox style extension
RUN wget -q http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}/extensions/geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-mbstyle-plugin.zip &&\
    unzip -o geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-mbstyle-plugin.zip -d ${GEOSERVER_HOME}/webapps/geoserver/WEB-INF/lib/ && \
    rm -f geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-mbstyle-plugin.zip

# Move GeoServer app
RUN mv ${GEOSERVER_HOME}/webapps/ ${GEOSERVER_HOME}/savwebapps/

# USER root
EXPOSE 8080
WORKDIR ${GEOSERVER_HOME}
CMD (test -d ${GEOSERVER_DATA_DIR} && test -d ${GEOSERVER_DATA_DIR}/security && true || cp -rf ${GEOSERVER_HOME}/data_dir/* ${GEOSERVER_DATA_DIR}) && rm -rf ${GEOSERVER_HOME}/webapps/ && mkdir ${GEOSERVER_HOME}/webapps/ && cp -r ${GEOSERVER_HOME}/savwebapps/geoserver/ ${GEOSERVER_HOME}/webapps/${GEOSERVER_PATH}/ && export GEOSERVER_CSRF_DISABLED=true && ${GEOSERVER_HOME}/bin/startup.sh
