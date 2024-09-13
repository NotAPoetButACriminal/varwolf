# Lunix
FROM ubuntu:24.04
WORKDIR /root

# Update the system
RUN apt-get update && apt-get -y upgrade

# Install system requirements
RUN apt-get install -y \
    wget \
    zip \
    openjdk-17-jdk \
    perl \
    perl-base \
    git

# Install bioinformatics packages
RUN apt-get install -y \
    bwa \
    samtools \
    bcftools \
    tabix

# Install GATK
RUN wget https://github.com/broadinstitute/gatk/releases/download/4.6.0.0/gatk-4.6.0.0.zip && \
    unzip gatk-4.6.0.0.zip


# Copy local files
COPY bamshee.sh /root
COPY cohortcrawler.sh /root

# Test
CMD java --version