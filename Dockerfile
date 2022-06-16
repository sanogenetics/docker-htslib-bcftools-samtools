FROM amazonlinux:2 as buildenv
ARG VERSION=1.15.1

RUN yum update -y && yum install -y \
  wget \
  tar \
  bzip2 bzip2-devel \
  autoconf automake make \
  gcc \
  zlib-devel \
  xz-devel \
  curl-devel \
  openssl-devel \
  gsl-devel \
  ncurses-devel


# get htslib
WORKDIR /tmp/htslib
RUN wget https://github.com/samtools/htslib/releases/download/${VERSION}/htslib-${VERSION}.tar.bz2
RUN tar -x -f htslib-${VERSION}.tar.bz2
WORKDIR /tmp/htslib/htslib-${VERSION}

# build htslib
RUN ./configure --prefix=/tmp/htslib/output
RUN make
RUN make install


# get bcftools
WORKDIR /tmp/bcftools
RUN wget https://github.com/samtools/bcftools/releases/download/${VERSION}/bcftools-${VERSION}.tar.bz2
RUN tar -x -f bcftools-${VERSION}.tar.bz2
WORKDIR /tmp/bcftools/bcftools-${VERSION}

# build bcftools
RUN ./configure --prefix=/tmp/bcftools/output
RUN make
RUN make install


# get samtools
WORKDIR /tmp/samtools
RUN wget https://github.com/samtools/samtools/releases/download/${VERSION}/samtools-${VERSION}.tar.bz2
RUN tar -x -f samtools-${VERSION}.tar.bz2
WORKDIR /tmp/samtools/samtools-${VERSION}

# build samtools
RUN ./configure --prefix=/tmp/samtools/output
RUN make
RUN make install

# put in a fresh container to discard build tooling
# size from ~1Gb -> ~100Mb
FROM amazonlinux:2
COPY --from=buildenv /tmp/htslib/output/bin /usr/local/bin/
COPY --from=buildenv /tmp/bcftools/output/bin /usr/local/bin/
COPY --from=buildenv /tmp/samtools/output/bin /usr/local/bin/