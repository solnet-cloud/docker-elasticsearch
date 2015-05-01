# Elasticsearch Dockerfile
# Solnet Solutions
# Version: 1.0.0
# Elasticsearch Version: 1.5.2

# Pull base image (Java8)
FROM dockerfile/java:oracle-java8

# Information
MAINTAINER Taylor Bertie <taylor.bertie@solnet.co.nz>
LABEL Description="This image is used to stand up an elasticsearch instance. Run with the params --node.name=<name> \
and --cluster.name=<cluster-name> to configure." Version="1.0.0"

# Patch nodes:
# Version 1.0.0
#       - Working version. Logs to console and places logs and data in volume.

# Set the Elasticsearch Version and other enviroment variables
ENV ES_PKG_NAME elasticsearch-1.5.2
ENV ES_HEAP_SIZE 4g
ENV MAX_MAP_COUNT 262144

# Install Elasticsearch and delete the elasticsearch tarball
RUN \
  cd / && \
  wget https://download.elastic.co/elasticsearch/elasticsearch/$ES_PKG_NAME.tar.gz && \
  tar xvzf $ES_PKG_NAME.tar.gz && \
  rm -f $ES_PKG_NAME.tar.gz && \
  mv /$ES_PKG_NAME /elasticsearch
  
# This part is down atomically in order to ensure that superflious files like the tarball are removed from the
# resulting file system layer, thus reducing the overall size of the image.
  
# Install Elasticsearch head plugin
RUN \
  cd /elasticsearch && \
  bin/plugin --install mobz/elasticsearch-head
  
# Define mountable volumes. We need to be able to output the logs and the data
VOLUME /es-data/data/ /es-data/logs/

# Mount the configuration files
ADD config/elasticsearch.yml /elasticsearch/config/elasticsearch.yml
ADD config/logging.yml       /elasticsearch/config/logging.yml

# Define a working directory
WORKDIR /data

# Define default command as entrypoint
ENTRYPOINT ["/elasticsearch/bin/elasticsearch"]

# Expose ports
# Expose 9200: HTTP
# Expose 9300: Transport
# Expose 54328/udp: For multicast
EXPOSE 9200
EXPOSE 9300
EXPOSE 54328/udp

