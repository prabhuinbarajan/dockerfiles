FROM java:8-jre
MAINTAINER Piotr Bocheński <bochenski.piotr@gmail.com>

RUN echo "deb http://debian.datastax.com/community stable main" > /etc/apt/sources.list.d/cassandra.sources.list \
	&& curl -s -L http://debian.datastax.com/debian/repo_key | apt-key add - \
	&& apt-get update
