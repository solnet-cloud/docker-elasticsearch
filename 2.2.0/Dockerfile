# Elasticsearch Dockerfile
# Solnet Solutions
# Version: 2.2.0

# Pull base image (Java8)
FROM java:8-jre

# Build Instructions:
# When building use the following flags:
#      --tag="elasticsearch:1.6.0" -

# Run Instructions:
# Run a DOC/volume to preserve state of /es-data/data/.
# When running use the following flags:
#      --restart=on-failure  --log-driver=syslog --memory="10737418240" --memory-swap="-1"
#                                                      10240 MiB (8GiB heap + 2GiB overhead)

# NOTICE: As this build is designed to run using multicast it is recommend you utilise Weave, or bridge your docker0 on
# a common subnet in order to facilate the multicast. If you require unicast please override the configuration file.

# It is important to note that this elasticsearch build does not support SSL or HTTP Basic Auth. If you wish
# to enable this functionary you will need to do this using an haproxy container. If you do this make sure your
# Elasticsearch ports are not exposed outside the docker0 bridge (or whatever network you are running them on)

# Information
MAINTAINER Taylor Bertie <taylor.bertie@solnet.co.nz>
LABEL Description="This image is used to stand up an elasticsearch instance. Run with the params --node.name=<name> \
and --cluster.name=<cluster-name> to configure." Version="2.2.0"

# Patch notes:
# Version 2.2.0
#       - Upgraded to version 2.2.0
# Version 1.6.0-r1
#       - Moved to 8GiB heap with 2GiB overhead defaults
# Version 1.6.0
#       - Created a new version for 1.6.0 version of Elasticsearch
# Version 1.5.2
#       - Synced verison numbers with software for ease of reference
#       - Moved to java:8-jre as the dockerfile/java:oracle-java8 has been pulled from the repo and is not licensed
# Version 1.0.3
#       - Fixed work directory to /es-data/
# Version 1.0.2
#       - Created build instructions to specify required build paramaters
#       - Created run instructions to specify required run paramaters
# Version 1.0.1
#       - Removed redundant logs volume from volume list.
#       - Moved other path objects into /es-data directory in container for consistency
#       - Updated plugin fetch command to move into /es-data/plugins after creation
# Version 1.0.0
#       - Working version. Logs to console and places logs and data in volume.

# Set the Elasticsearch Version and other enviroment variables
ENV ES_PKG_NAME elasticsearch-2.2.0
ENV ES_HEAP_SIZE 8g
ENV MAX_MAP_COUNT 262144

# Needed to fix issues with mutlicast plugin:
ENV ES_USE_IPV4 true

# Prepare the various directories in /es-data/
RUN \
    mkdir -p /es-data/data && \
    mkdir -p /es-data/work

# Add the elasticsearch user
RUN \
    useradd -s /usr/sbin/nologin -r -M -d /es-data elasticsearch && \ 
    chown -R elasticsearch:elasticsearch /es-data/

# Install Elasticsearch and delete the elasticsearch tarball
RUN \
  cd / && \
  wget https://download.elastic.co/elasticsearch/elasticsearch/$ES_PKG_NAME.tar.gz && \
  tar xvzf $ES_PKG_NAME.tar.gz && \
  rm -f $ES_PKG_NAME.tar.gz && \
  mv /$ES_PKG_NAME /elasticsearch && \
  chown -R elasticsearch:elasticsearch /elasticsearch
  
# This part is down atomically in order to ensure that superflious files like the tarball are removed from the
# resulting file system layer, thus reducing the overall size of the image.
  
# Install Multicast Discovery plugin
# This feature will be removed in 3.0.0 so we need to work out another way to handle this multi-node problem
RUN \
  cd /elasticsearch && \
  bin/plugin install discovery-multicast && \
  chown -R elasticsearch:elasticsearch /elasticsearch/plugins/*

# Install Elasticsearch head plugin
RUN \
  cd /elasticsearch && \
  bin/plugin install mobz/elasticsearch-head && \
  chown -R elasticsearch:elasticsearch /elasticsearch/plugins/head
  
# Define mountable volumes. We need to be able to keep the data consistent so this should be mounted as a volume
VOLUME /es-data/data/

# Mount the configuration files
ADD config/elasticsearch.yml /elasticsearch/config/elasticsearch.yml
ADD config/logging.yml       /elasticsearch/config/logging.yml

# Define a working directory
WORKDIR /es-data

# Define default command as entrypoint
USER elasticsearch
ENTRYPOINT ["/elasticsearch/bin/elasticsearch"]

# Expose ports
# Expose 9200: HTTP
# Expose 9300: Transport
# Expose 54328/udp: For multicast
EXPOSE 9200
EXPOSE 9300
EXPOSE 54328/udp

