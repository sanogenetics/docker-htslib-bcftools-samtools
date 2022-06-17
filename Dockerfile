FROM amazonlinux:2 as buildenv
ARG VERSION

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
RUN ./configure --prefix=/tmp/samtools/output
RUN make -j4
RUN make install

# from https://github.com/aws/aws-cli/blob/v2/docker/Dockerfile
FROM amazonlinux:2 as awscli
RUN yum update -y \
  && yum install -y unzip curl \
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
FROM amazonlinux:2
# install dependencies
RUN yum update -y \
  && yum install -y less groff curl jq \
  && yum clean all

# install aws cli
# requires less groff
COPY --from=awscli /usr/local/aws-cli/ /usr/local/aws-cli/
COPY --from=awscli /aws-cli-bin/ /usr/local/bin/

# install htslib + bcftools + samtools
COPY --from=buildenv /tmp/htslib/output/bin /usr/local/bin/
COPY --from=buildenv /tmp/bcftools/output/bin /usr/local/bin/
COPY --from=buildenv /tmp/samtools/output/bin /usr/local/bin/

# install s3role convenience script
# requires jq curl
COPY bin/s3role /usr/local/bin/