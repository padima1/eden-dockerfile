FROM ubuntu:14.04

MAINTAINER Alex Foster version: 0.1

ENV BTCVERSION=0.14.2

ENV BTCPREFIX=/bitcoin/depends/x86_64-pc-linux-gnu

RUN apt-get update && apt-get install -y git build-essential wget pkg-config curl libtool autotools-dev automake libssl-dev libevent-dev bsdmainutils libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev

WORKDIR /

RUN mkdir -p /berkeleydb && git clone https://github.com/bitcoin/bitcoin.git

WORKDIR /berkeleydb

RUN wget http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz && tar -xvf db-4.8.30.NC.tar.gz && rm db-4.8.30.NC.tar.gz && mkdir -p db-4.8.30.NC/build_unix/build

ENV BDB_PREFIX=/berkeleydb/db-4.8.30.NC/build_unix/build

WORKDIR /berkeleydb/db-4.8.30.NC/build_unix

RUN ../dist/configure --disable-shared --enable-cxx --with-pic --prefix=$BDB_PREFIX

RUN make install

RUN apt-get update && apt-get install -y libminiupnpc-dev libzmq3-dev libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler libqrencode-dev

WORKDIR /bitcoin

RUN git checkout v${BTCVERSION} && mkdir -p /bitcoin/bitcoin-${BTCVERSION}

WORKDIR /bitcoin/depends

RUN make

WORKDIR /bitcoin

RUN ./autogen.sh

RUN ./configure CPPFLAGS="-I${BDB_PREFIX}/include/ -O2" LDFLAGS="-L${BDB_PREFIX}/lib/ -static-libstdc++" --with-gui --prefix=${BTCPREFIX} --disable-ccache --disable-maintainer-mode --disable-dependency-tracking --enable-glibc-back-compat --enable-reduce-exports --disable-bench --disable-gui-tests --enable-static

RUN make 

RUN make install DESTDIR=/bitcoin/bitcoin-${BTCVERSION}

RUN mv /bitcoin/bitcoin-${BTCVERSION}${BTCPREFIX} /bitcoin-${BTCVERSION} && strip /bitcoin-${BTCVERSION}/bin/* && rm -rf /bitcoin-${BTCVERSION}/lib/pkgconfig && find /bitcoin-${BTCVERSION} -name "lib*.la" -delete && find /bitcoin-${BTCVERSION} -name "lib*.a" -delete 

WORKDIR /

RUN tar cvf bitcoin-${BTCVERSION}.tar bitcoin-${BTCVERSION} 
