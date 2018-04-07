FROM ubuntu:14.04

MAINTAINER Padima

ENV EDENVERSION=1.0.2

ENV EDENPREFIX=/eden/depends/x86_64-w64-mingw32 

RUN apt-get update && apt-get install -y g++-mingw-w64-x86-64 zip unzip git build-essential wget pkg-config curl libtool autotools-dev automake libssl-dev libevent-dev bsdmainutils libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev

WORKDIR /

RUN mkdir -p /berkeleydb && git clone https://github.com/padima1/eden.git

WORKDIR /berkeleydb

RUN wget http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz && tar -xvf db-4.8.30.NC.tar.gz && rm db-4.8.30.NC.tar.gz && mkdir -p db-4.8.30.NC/build_unix/build

ENV BDB_PREFIX=/berkeleydb/db-4.8.30.NC/build_unix/build

WORKDIR /berkeleydb/db-4.8.30.NC/build_unix

RUN ../dist/configure --disable-shared --enable-cxx --with-pic --prefix=$BDB_PREFIX

RUN make install

RUN apt-get update && apt-get install -y libminiupnpc-dev libzmq3-dev libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler libqrencode-dev

WORKDIR /eden

RUN  mkdir -p /padima1/eden-${EDENVERSION}

WORKDIR /eden/depends

RUN make

WORKDIR /eden

RUN ./autogen.sh

RUN ./configure CPPFLAGS="-I${BDB_PREFIX}/include/ -O2" LDFLAGS="-L${BDB_PREFIX}/lib/ -static-libstdc++" --with-gui --prefix=${EDENPREFIX}  --disable-ccache --disable-maintainer-mode --disable-dependency-tracking --enable-glibc-back-compat --enable-reduce-exports --disable-bench --disable-gui-tests --enable-static

RUN make 

RUN make install DESTDIR=/padima1/eden-${EDENVERSION}

RUN mv /padima1/eden-${EDENVERSION}${EDENPREFIX} /eden-${EDENVERSION} && strip /eden-${EDENVERSION}/bin/* && rm -rf /eden-${EDENVERSION}/lib/pkgconfig && find /eden-${EDENVERSION} -name "lib*.la" -delete && find /eden-${EDENVERSION} -name "lib*.a" -delete 

WORKDIR /

RUN  zip eden-${EDENVERSION}.zip eden-${EDENVERSION}
