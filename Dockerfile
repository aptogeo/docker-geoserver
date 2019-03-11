FROM fedora:29

LABEL maintainer="Aptogeo/Mathieu MAST"

# Env variables
ENV GEOSERVER_VERSION_MAJOR 2.14
ENV GEOSERVER_VERSION_MINOR 2
ENV GEOSERVER_HOME /opt/geoserver-${GEOSERVER_VERSION_MAJOR}.${GEOSERVER_VERSION_MINOR}
ENV GEOSERVER_DATA_DIR /opt/geoserver_data_dir
ENV JAVA_HOME /etc/alternatives/jre
ENV JAVA_OPTS="-Xms512m -Xmx2048m"
ENV PG_VERSION_MAJOR 11
ENV PG_VERSION_MINOR 2
ENV PGIS_VERSION 25_${PG_VERSION_MAJOR}
ENV POSTGRESQL_DATA_DIR /var/lib/pgsql/${PG_VERSION_MAJOR}/data

# Add the PostgreSQL PGP key to verify the official yum repository packages
RUN rpm --import https://yum.postgresql.org/RPM-GPG-KEY-PGDG-${PG_VERSION_MAJOR}

# Add PostgreSQL's repository
RUN dnf -y install https://download.postgresql.org/pub/repos/yum/${PG_VERSION_MAJOR}/fedora/fedora-29-x86_64/pgdg-fedora${PG_VERSION_MAJOR}-${PG_VERSION_MAJOR}-${PG_VERSION_MINOR}.noarch.rpm

# Update repository metadata
RUN dnf -y install deltarpm
RUN dnf -y update

# Bases packages
RUN dnf install -y wget java-1.8.0-openjdk unzip postgresql${PG_VERSION_MAJOR}-server postgresql${PG_VERSION_MAJOR}-contrib procps-ng net-tools postgis${PGIS_VERSION} postgis${PGIS_VERSION}-client

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

# SpatiaLite extension
RUN dnf install -y sqlite sqlite-devel libspatialite proj proj-epsg
RUN ln -s /usr/lib64/libproj.so.12 /usr/lib64/libproj.so.0
RUN wget -q https://build.geoserver.org/geoserver/${GEOSERVER_VERSION_MAJOR}.x/community-latest/geoserver-${GEOSERVER_VERSION_MAJOR}-SNAPSHOT-spatialite-plugin.zip  &&\
    unzip -o geoserver-${GEOSERVER_VERSION_MAJOR}-SNAPSHOT-spatialite-plugin.zip -d ${GEOSERVER_HOME}/webapps/geoserver/WEB-INF/lib/ && \
    rm -f geoserver-${GEOSERVER_VERSION_MAJOR}-SNAPSHOT-spatialite-plugin.zip


RUN chown -R geoserver ${GEOSERVER_HOME} ${GEOSERVER_DATA_DIR}

# Use postgres user
USER postgres

# Init PostgreSQL
RUN /usr/pgsql-${PG_VERSION_MAJOR}/bin/initdb -D ${POSTGRESQL_DATA_DIR} -A trust 2>&1 < /dev/null

# PostgreSQL configuration
RUN echo "host all  all    0.0.0.0/0  md5" >> ${POSTGRESQL_DATA_DIR}/pg_hba.conf
RUN echo "listen_addresses='*'" >> ${POSTGRESQL_DATA_DIR}/postgresql.conf

# Create 'geoserver' user with 'geoserver' password
RUN /usr/pgsql-${PG_VERSION_MAJOR}/bin/pg_ctl -D ${POSTGRESQL_DATA_DIR} start && \
    sleep 5 && \
    psql --command "CREATE USER geoserver WITH SUPERUSER PASSWORD 'geoserver';" && \
    createdb -O geoserver geoserver && \
    psql --dbname geoserver --command "CREATE EXTENSION postgis;" && \
    /usr/pgsql-${PG_VERSION_MAJOR}/bin/pg_ctl -D ${POSTGRESQL_DATA_DIR} stop

USER root
EXPOSE 5432
VOLUME ${POSTGRESQL_DATA_DIR}
VOLUME ${GEOSERVER_DATA_DIR}
WORKDIR ${GEOSERVER_HOME}
CMD su - postgres -c "/usr/pgsql-${PG_VERSION_MAJOR}/bin/pg_ctl -D ${POSTGRESQL_DATA_DIR} start" && su - geoserver -c "JAVA_HOME=${JAVA_HOME} GEOSERVER_DATA_DIR=${GEOSERVER_DATA_DIR} ${GEOSERVER_HOME}/bin/startup.sh"
