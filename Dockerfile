# Lunix
FROM ubuntu:24.04
WORKDIR /root

# Update the system
RUN apt-get update && apt-get -y upgrade

# Install system requirements
RUN apt-get install -y \
    build-essential \
    wget \
    zip \
    git \
    python3 \
    python-is-python3 \
    openjdk-17-jdk \
    perl \
    perl-base \
    cpanminus

# Install bioinformatics packages
RUN apt-get install -y \
    bwa \
    samtools \
    bcftools \
    tabix

# Clean the packages
RUN apt-get autoremove && \
    apt-get clean

# Install GATK
RUN wget https://github.com/broadinstitute/gatk/releases/download/4.6.0.0/gatk-4.6.0.0.zip && \
    unzip gatk-4.6.0.0.zip && \
    rm gatk-4.6.0.0.zip
ENV PATH="${PATH}:/root/gatk-4.6.0.0"

# Install VEP
RUN git clone https://github.com/Ensembl/ensembl-vep.git && \
    cd ensembl-vep && \
    cpanm --installdeps --with-recommends --notest --cpanfile ensembl_cpanfile . && \
    perl INSTALL.pl -a a

# Copy local files
COPY bamshee.sh /root
COPY cohortcrawler.sh /root

# Test
CMD java --version