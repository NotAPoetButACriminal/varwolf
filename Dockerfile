# Lunix
FROM ubuntu:24.04
WORKDIR /root/

# Update the system
RUN apt-get update && apt-get -y upgrade

# Install system requirements
RUN apt-get install -y \
    build-essential \
    wget \
    zip \
    git \
    autoconf \
    python3 \
    python-is-python3 \
    openjdk-17-jdk \
    perl \
    perl-base

# Install bioinformatics packages
RUN apt-get install -y \
    bwa \
    samtools \
    bcftools

# Clean the packages
RUN apt-get autoremove && \
    apt-get clean

# Install GATK
RUN wget https://github.com/broadinstitute/gatk/releases/download/4.6.0.0/gatk-4.6.0.0.zip && \
    unzip gatk-4.6.0.0.zip && \
    rm gatk-4.6.0.0.zip
ENV PATH="${PATH}:/root/gatk-4.6.0.0/"

# Install VEP dependencies
RUN apt-get install -y \
    cpanminus \
    zlib1g-dev \
    libexpat1-dev \
    libmysqlclient-dev \
    libdbd-mysql-perl \
    libpng-dev \
    libssl-dev \
    libbz2-dev \
    liblzma-dev \
    libcurl4-gnutls-dev \
    libdeflate-dev \
    locales \
    openssl \
    libxml2-dev \
    libxml-perl \
    libxml-libxml-perl

# Install htslib for Bio::DB::HTS
RUN git clone https://github.com/samtools/htslib.git && \
    cd htslib && \
    git submodule update --init --recursive && \
    autoreconf -i && \
    ./configure && \
    make && \
    make install

# Install VEP 
RUN git clone https://github.com/Ensembl/ensembl-vep.git && \
    cd ensembl-vep && \
    wget https://raw.githubusercontent.com/Ensembl/ensembl/main/cpanfile && \
    cpanm --installdeps --with-recommends --notest --cpanfile cpanfile.1 . && \
    cpanm --installdeps --with-recommends --notest --cpanfile cpanfile . && \
    cpanm --verbose Bio::DB::HTS && \
    perl INSTALL.pl -a ap -g AlphaMissense,SpliceAI --no_htslib
ENV PATH="${PATH}:/root/ensembl-vep/"

WORKDIR /root/varwolf/
ENV PATH="${PATH}:/root/varwolf/"
# Test
CMD vep