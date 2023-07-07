FROM eclipse-temurin:11-jdk-focal

LABEL maintainer="AptoGéo/Mathieu MAST"

# Env variables
ENV GEOSERVER_VERSION_MAJOR 2.23
ENV GEOSERVER_VERSION_MINOR 1
ENV GEOSERVER_HOME /opt/geoserver
ENV GEOSERVER_DATA_DIR /opt/geoserver_data_dir
ENV GEOSERVER_CSRF_DISABLED true
ENV CLUSTER_CONFIG_DIR ${GEOSERVER_DATA_DIR}/cluster
ENV CLUSTER_INSTANCE_NAME ""
ENV BROKER_URL ""
ENV HTTP_PORT 8080
ENV XMS 256m
ENV XMX 1024m
ENV JAVA_OPTS "-XX:SoftRefLRUPolicyMSPerMB=36000 -XX:+UseParallelGC -Xbootclasspath/a:/opt/marlin-0.9.4.7-Unsafe-OpenJDK11.jar -Dsun.java2d.renderer=org.marlin.pisces.MarlinRenderingEngine"

# Volumes
VOLUME $GEOSERVER_DATA_DIR

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

ADD web.xml /opt/geoserver/webapps/geoserver/WEB-INF/web.xml

ADD cluster.properties /opt/geoserver/cluster.properties

# Define user geoserver
RUN groupadd --system -g 1000 geoserver
RUN useradd --system --gid geoserver --no-create-home --home-dir $GEOSERVER_DATA_DIR --shell /use/sbin/nologin --uid 1000 geoserver
RUN chown -Rf geoserver:geoserver $GEOSERVER_HOME
RUN chown -Rf geoserver:geoserver $GEOSERVER_DATA_DIR

USER 1000:1000
EXPOSE ${HTTP_PORT}
WORKDIR $GEOSERVER_HOME
CMD (test -d $GEOSERVER_DATA_DIR/security && true || cp -rf /opt/geoserver/data_dir/* $GEOSERVER_DATA_DIR) \
&& mkdir -p $CLUSTER_CONFIG_DIR && cp -f /opt/geoserver/cluster.properties $CLUSTER_CONFIG_DIR/cluster.properties \
&& sed -i "s,^CLUSTER_CONFIG_DIR=.*$,CLUSTER_CONFIG_DIR=$CLUSTER_CONFIG_DIR,g" $CLUSTER_CONFIG_DIR/cluster.properties \
&& sed -i "s,^instanceName=.*$,instanceName=$CLUSTER_INSTANCE_NAME,g" $CLUSTER_CONFIG_DIR/cluster.properties \
&& sed -i "s,^brokerURL=.*$,brokerURL=$BROKER_URL,g" $CLUSTER_CONFIG_DIR/cluster.properties \
&& sed -i "s,^jetty.http.port=.*$,jetty.http.port=$HTTP_PORT,g" /opt/geoserver/start.ini \
&& export JAVA_OPTS="$JAVA_OPTS -Xms$XMS -Xmx$XMX -DGEOSERVER_CSRF_DISABLED=$GEOSERVER_CSRF_DISABLED -DCLUSTER_CONFIG_DIR=$CLUSTER_CONFIG_DIR" \
&& echo $JAVA_OPTS \
&& /opt/geoserver/bin/startup.sh
