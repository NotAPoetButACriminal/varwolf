# Lunix
FROM ubuntu:24.04
WORKDIR /root

# Update the system
RUN apt-get update && apt-get upgrade

# Install system requirements
RUN apt-get install -y \
    default-jre \
    perl \
    perl-base \
    git

# Install bioinformatics packages
RUN apt-get install -y \
    bwa \
    samtools \
    bcftools \
    tabix

# Copy local files
COPY bamshee.sh /root
COPY cohortcrawler.sh /root

# Test
CMD java --version