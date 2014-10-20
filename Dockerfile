# Trusty
FROM ubuntu:14.04

MAINTAINER Ron Kurr <kurr@kurron.org>

# fetch the latest software updates
RUN apt-get --quiet update

# install wget
RUN apt-get --quiet --yes install wget

# download the repository key
RUN wget --quiet --output-document=/tmp/rabbitmq-signing-key-public.asc http://www.rabbitmq.com/rabbitmq-signing-key-public.asc

# import the RabbitMQ public key
RUN apt-key add /tmp/rabbitmq-signing-key-public.asc

# add the RabbitMQ repository
RUN echo 'deb http://www.rabbitmq.com/debian/ testing main' | tee /etc/apt/sources.list.d/rabbitmq.list

# fetch the latest software update
RUN apt-get --quiet update

# install RabbitMQ
RUN apt-get --quiet --yes install rabbitmq-server

# install plug-ins
RUN rabbitmq-plugins enable rabbitmq_management
RUN rabbitmq-plugins enable rabbitmq_consistent_hash_exchange
RUN rabbitmq-plugins enable rabbitmq_federation
RUN rabbitmq-plugins enable rabbitmq_shovel
RUN rabbitmq-plugins enable rabbitmq_stomp
RUN rabbitmq-plugins enable rabbitmq_tracing
RUN rabbitmq-plugins enable rabbitmq_mqtt
RUN rabbitmq-plugins enable rabbitmq_web_stomp
RUN rabbitmq-plugins list

# allow access from non-localhost clients
RUN echo '[{rabbit, [{loopback_users, []}]}].' > /etc/rabbitmq/rabbitmq.config

# Add custom launch script
ADD rabbitmq-start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/rabbitmq-start.sh

# Define environment variables so we can use external file system for persistence.
ENV RABBITMQ_LOG_BASE /data/log
ENV RABBITMQ_MNESIA_BASE /data/mnesia

# Define mount points.
VOLUME ["/data/log", "/data/mnesia"]

# Define working directory.
WORKDIR /data

# expose both the amqp and admin ports
EXPOSE 5672 15672

# run RabbitMQ each time the container is started
ENTRYPOINT /usr/local/bin/rabbitmq-start.sh

# we need this to keep the container from exiting when we detach
CMD tail -F /var/log/dmesg

