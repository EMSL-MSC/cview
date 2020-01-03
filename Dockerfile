FROM ubuntu:bionic
MAINTAINER karcaw@gmail.com

#you should be able to build and run this docker file to get cview deb files:
#  docker build -t cbuild
#  docker run -t -i -v /home/<user>/.gnupg:/root/.gnupg cbuild

#RUN echo "deb http://ppa.launchpad.net/thjc/ppa/ubuntu precise main" > /etc/apt/sources.list.d/custom.list
RUN echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup

RUN apt-get update && apt-get -y dist-upgrade && apt-get clean
RUN apt-get install -y software-properties-common

RUN /usr/bin/apt-add-repository ppa:karcaw/atb
RUN apt-get update

RUN apt-get install -y build-essential gdebi-core devscripts

ADD . /src/
RUN mkdir /build/

WORKDIR /src
ENV DEBIAN_FRONTEND noninteractive 
RUN apt-get install -y --allow-unauthenticated `gdebi --quiet --apt-line debian/control`
VOLUME /.gnupg
VOLUME /output

CMD /src/dockerbuild
