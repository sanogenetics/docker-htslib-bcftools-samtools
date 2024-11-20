FROM ubuntu:latest as buildenv
ARG VERSION

# make sure nothing is promted for during install
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y \
    build-essential \
    libbz2-dev \
    liblzma-dev \
    libcurl4-gnutls-dev \
    libssl-dev \
    perl \
    wget \
    zlib1g-dev
# TODO use libdeflate?

# get htslib
WORKDIR /tmp/htslib
RUN wget https://github.com/samtools/htslib/releases/download/${VERSION}/htslib-${VERSION}.tar.bz2 \
  && tar -x -f htslib-${VERSION}.tar.bz2

# build htslib
WORKDIR /tmp/htslib/htslib-${VERSION}
RUN ./configure --prefix=/tmp/htslib/output --enable-libcurl --enable-s3
RUN make -j4
RUN make install


# get bcftools
WORKDIR /tmp/bcftools
RUN wget https://github.com/samtools/bcftools/releases/download/${VERSION}/bcftools-${VERSION}.tar.bz2 \
  && tar -x -f bcftools-${VERSION}.tar.bz2

# build bcftools
WORKDIR /tmp/bcftools/bcftools-${VERSION}
RUN ./configure --prefix=/tmp/bcftools/output
RUN make -j4
RUN make install


# get samtools
WORKDIR /tmp/samtools
RUN wget https://github.com/samtools/samtools/releases/download/${VERSION}/samtools-${VERSION}.tar.bz2 \
  && tar -x -f samtools-${VERSION}.tar.bz2

# build samtools
WORKDIR /tmp/samtools/samtools-${VERSION}
RUN ./configure --prefix=/tmp/samtools/output --without-curses
RUN make -j4
RUN make install

# from https://github.com/aws/aws-cli/blob/v2/docker/Dockerfile
FROM ubuntu:latest  as awscli
# make sure nothing is promted for during install
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y \
    curl \
    unzip \
  && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
  && unzip "awscliv2.zip" \
  && rm "awscliv2.zip" \
  # The --bin-dir is specified so that we can copy the
  # entire bin directory from the installer stage into
  # into /usr/local/bin of the final stage without
  # accidentally copying over any other executables that
  # may be present in /usr/local/bin of the installer stage.
  && ./aws/install --bin-dir /aws-cli-bin/

# put in a fresh container to discard build tooling
# size from ~1Gb -> ~100Mb
FROM ubuntu:latest
# make sure nothing is promted for during install
ENV DEBIAN_FRONTEND=noninteractive

# install dependencies
RUN apt-get update \
  && apt-get install -y \
    curl \
    groff \
    jq \
    less \
    libcurl4-gnutls-dev \
    libssl-dev

# install aws cli
# requires less groff
COPY --from=awscli /usr/local/aws-cli/ /usr/local/aws-cli/
COPY --from=awscli /aws-cli-bin/ /usr/local/bin/

# install htslib + bcftools + samtools
COPY --from=buildenv /tmp/htslib/output/bin /usr/local/bin/
COPY --from=buildenv /tmp/bcftools/output/bin /usr/local/bin/
COPY --from=buildenv /tmp/samtools/output/bin /usr/local/bin/
# also copy plugins
COPY --from=buildenv /tmp/bcftools/output/libexec /usr/libexec/
# set an environment variable to point at the plugin location
ENV BCFTOOLS_PLUGINS=/usr/libexec/bcftools

# install s3role convenience script
# requires jq curl
COPY bin/s3role /usr/local/bin/
