# Elasticsearch Dockerfile
# Solnet Solutions
# Version: 1.5.2

# Pull base image (Java8)
FROM java:8-jre

# Build Instructions:
# When building use the following flags:
#      --tag="elasticsearch:1.5.2" --memory="4429185024" --memory-swap="-1"
#                                            4224 MiB (4GB + 128MB overhead)

# Run Instructions:
# Run a DOC/volume to preserve state of /es-data/data/.
# When running use the following flags:
#      --restart=on-failure

# Information
MAINTAINER Taylor Bertie <taylor.bertie@solnet.co.nz>
LABEL Description="This image is used to stand up an elasticsearch instance. Run with the params --node.name=<name> \
and --cluster.name=<cluster-name> to configure." Version="1.5.2"

# Patch nodes:
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
ENV ES_PKG_NAME elasticsearch-1.5.2
ENV ES_HEAP_SIZE 4g
ENV MAX_MAP_COUNT 262144

# Prepare the various directories in /es-data/
RUN \
    mkdir -p /es-data/data && \
    mkdir -p /es-data/plugins && \
    mkdir -p /es-data/work

# Install Elasticsearch and delete the elasticsearch tarball
RUN \
  cd / && \
  wget https://download.elastic.co/elasticsearch/elasticsearch/$ES_PKG_NAME.tar.gz && \
  tar xvzf $ES_PKG_NAME.tar.gz && \
  rm -f $ES_PKG_NAME.tar.gz && \
  mv /$ES_PKG_NAME /elasticsearch
  
# This part is down atomically in order to ensure that superflious files like the tarball are removed from the
# resulting file system layer, thus reducing the overall size of the image.
  
# Install Elasticsearch head plugin and move it to the correct plugin directory
RUN \
  cd /elasticsearch && \
  bin/plugin --install mobz/elasticsearch-head && \
  mv /elasticsearch/plugins/head /es-data/plugins/
  
# Define mountable volumes. We need to be able to keep the data consistent so this should be mounted as a volume
VOLUME /es-data/data/

# Mount the configuration files
ADD config/elasticsearch.yml /elasticsearch/config/elasticsearch.yml
ADD config/logging.yml       /elasticsearch/config/logging.yml

# Define a working directory
WORKDIR /es-data

# Define default command as entrypoint
ENTRYPOINT ["/elasticsearch/bin/elasticsearch"]

# Expose ports
# Expose 9200: HTTP
# Expose 9300: Transport
# Expose 54328/udp: For multicast
EXPOSE 9200
EXPOSE 9300
EXPOSE 54328/udp

