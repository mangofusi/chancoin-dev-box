# testnet docker image

# Use phusion/baseimage as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/baseimage-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM phusion/baseimage:0.11
MAINTAINER MangoFusion <mangofusi@gmail.com>

ENV LAST_REFRESHED 20160629
ENV HOME /home/tester

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# add bitcoind from the official PPA
RUN apt-get update && \
    apt-get install --yes

# Yes, you need to run apt-get update again after adding the bitcoin ppa
RUN apt-get update

# install some other essential packages for building bitcoin
RUN apt-get install --yes \
  autoconf \ 
  autotools-dev \ 
	bsdmainutils \ 
	build-essential \ 
	gcc \ 
	git \ 
	libboost-all-dev \ 
	libssl-dev \ 
	libcurl4-openssl-dev \ 
	libncurses-dev \ 
	libjansson-dev \ 
        beignet-opencl-icd \ 
        ocl-icd-opencl-dev \ 
        clinfo \
  libevent-dev \
	libtool \ 
  make \
	pkg-config \ 
	sudo \
  vim  

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# change root password, should still be able to change back to root
RUN echo 'root:abc123' |chpasswd

# create a non-root user
RUN useradd -d /home/tester -m -s /bin/bash tester && echo "tester:tester" | chpasswd && adduser tester sudo && adduser tester video

# download and extract berkeley db 4.8 for wallets
# Bitcoin needs bdb for building properly
WORKDIR /home/tester
COPY ./data/db-4.8.30.NC.tar.gz /home/tester/
RUN tar -xzvf /home/tester/db-4.8.30.NC.tar.gz

# Copy files needed: Makefile, configs, vimrc file
COPY ./hometester/ /home/tester/

# make tester user own the testnet
RUN chown -R tester:tester /home/tester

# run following commands from user's home directory
# use the tester user when running the image
USER tester

# git clone the chancoin sourcecode
# This allows users to modify the bitcoin source code and rebuild it if they desire
RUN git clone https://github.com/Chancoin-core/CHANCOIN.git chancoin
WORKDIR /home/tester/db-4.8.30.NC/build_unix
RUN mkdir -p /home/tester/chancoin/db4
RUN ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=/home/tester/chancoin/db4
RUN make install
WORKDIR /home/tester/chancoin
RUN sh ./autogen.sh
RUN ./configure LDFLAGS="-L/home/tester/chancoin/db4/lib" CPPFLAGS="-I/home/tester/chancoin/db4/include"
RUN make -j2
USER root
RUN make install
USER tester
WORKDIR /home/tester
RUN rm -rf db-4.8.30.NC
RUN rm -rf db-4.8.30.NC.tar.gz


# git clone the sgminer sourcecode
#RUN git clone --recurse-submodules --branch inc_fix https://github.com/mangofusi/sgminer.git sgminer
#WORKDIR /home/tester/sgminer
#RUN sh ./autogen.sh
#RUN ./configure --prefix=/usr/local --disable-nvml
#RUN make -j2
#USER root
#RUN make install

# git clone the cpuminer sourcecode
RUN git clone --recurse-submodules --branch inc_fix https://github.com/Chancoin-core/cpuminer-multi.git sgminer
WORKDIR /home/tester/cpuminer
RUN sh ./autogen.sh
RUN ./configure --prefix=/usr/local
RUN make -j2
USER root
RUN make install
USER tester

# run commands from inside the testnet-box directory
WORKDIR /home/tester/testnet
RUN ln -s /home/tester/chancoin /home/tester/testnet/src
RUN ln -s /home/tester/testnet /home/tester/chancoin/testnet

# expose two rpc ports for the nodes to allow outside container access
EXPOSE 19001 19011
CMD ["/bin/bash"]
