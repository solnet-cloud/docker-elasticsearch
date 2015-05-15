# docker-elasticsearch
Elasticsearch is a distributed, open source search and analytics engine, designed for horizontal scalability, reliability, and easy management. It combines the speed of search with the power of analytics via a sophisticated, developer-friendly query language covering structured, unstructured, and time-series data.

More details on the Elasticsearch product can be found at the elastic website at https://www.elastic.co/products/elasticsearch

Under the most basic usage you will make sure this container is operating in the same network (i.e. same machine) as the cluster it will be connected to. You can utilise <a href="https://github.com/weaveworks/weave">Weave</a> and other technologies to distirbute multiple nodes over multiple hosts. It is recommend you use restart on-failure, prevent swaping, and limit RAM usage of the container to just over 4GiB.

    docker run -d --restart=on-failure --memory="4429185024" --memory-swap="-1" solnetcloud/elasticsearch:latest

This container's entrypoint is directly into the Elasticsearch executable, which means that you can use --node.name={name} and --cluster.name={cluster_name} to override the default configuration.

You can utilise a --log-driver=syslog, however this is optional, and as you will likely be using this with logstash consuming the syslog entries for the host. It is probably wise to leave this logging to files.

This container by default expects there to be at least two nodes in the same cluster, and is tuned for relatively low event input. If this is not your use case you are welcome to fork this build and modify it to suit your needs.
