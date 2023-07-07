FROM eclipse-temurin:11-jdk-focal

LABEL maintainer="AptoGéo/Mathieu MAST"

# Env variables
ENV GEOSERVER_VERSION_MAJOR 2.23
ENV GEOSERVER_VERSION_MINOR 1
ENV GEOSERVER_HOME /opt/geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}
ENV GEOSERVER_DATA_DIR /opt/geoserver_data_dir
ENV GEOSERVER_CSRF_DISABLED true
ENV GEOSERVER_PATH geoserver
ENV JAVA_OPTS="-Xms512m -Xmx2048m -XX:SoftRefLRUPolicyMSPerMB=36000 -XX:+UseParallelGC -DGEOSERVER_CSRF_DISABLED=${GEOSERVER_CSRF_DISABLED} -Xbootclasspath/a:/opt/marlin-0.9.4.7-Unsafe-OpenJDK11.jar -Dsun.java2d.renderer=org.marlin.pisces.MarlinRenderingEngine"

# Packages
RUN apt-get update && apt-get install unzip

# Add GeoServer
RUN \
    mkdir -p /opt && \
    cd /opt && \
    wget -q https://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}/geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-bin.zip && \
    unzip -o geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-bin.zip -d ${GEOSERVER_HOME} && \
    rm -f geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-bin.zip && \
    mv ${GEOSERVER_HOME}/data_dir ${GEOSERVER_DATA_DIR}

# Vector tiles extension
RUN wget -q https://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}/extensions/geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-vectortiles-plugin.zip &&\
    unzip -o geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-vectortiles-plugin.zip -d ${GEOSERVER_HOME}/webapps/geoserver/WEB-INF/lib/ && \
    rm -f geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-vectortiles-plugin.zip

# Mapbox style extension
RUN wget -q https://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}/extensions/geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-mbstyle-plugin.zip &&\
    unzip -o geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-mbstyle-plugin.zip -d ${GEOSERVER_HOME}/webapps/geoserver/WEB-INF/lib/ && \
    rm -f geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}-mbstyle-plugin.zip

# Clustering extension
RUN wget -q https://build.geoserver.org/geoserver/${GEOSERVER_VERSION_MAJOR}.x/community-latest/geoserver-${GEOSERVER_VERSION_MAJOR}-SNAPSHOT-jms-cluster-plugin.zip &&\
    unzip -o geoserver-${GEOSERVER_VERSION_MAJOR}-SNAPSHOT-jms-cluster-plugin.zip -d ${GEOSERVER_HOME}/webapps/geoserver/WEB-INF/lib/ && \
    rm -f geoserver-${GEOSERVER_VERSION_MAJOR}-SNAPSHOT-jms-cluster-plugin.zip

ADD web.xml /opt/geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}/webapps/geoserver/WEB-INF/web.xml

# Move GeoServer app
RUN mv ${GEOSERVER_HOME}/webapps/ ${GEOSERVER_HOME}/savwebapps/

# USER root
EXPOSE 8080
VOLUME ${GEOSERVER_DATA_DIR}
WORKDIR ${GEOSERVER_HOME}
CMD rm -rf ${GEOSERVER_HOME}/webapps/ && mkdir ${GEOSERVER_HOME}/webapps/ && cp -r ${GEOSERVER_HOME}/savwebapps/geoserver/ ${GEOSERVER_HOME}/webapps/${GEOSERVER_PATH}/ && ${GEOSERVER_HOME}/bin/startup.sh
