# Loonix
FROM ubuntu:24.04

# Update the system
RUN apt-get update && apt-get -y upgrade

# Install system requirements
RUN apt-get install -y \
    default-jre 

# Install bioinformatics packages
RUN apt-get install -y \
    bwa \
    samtools \
    bcftools \
    tabix

# Test
CMD java --version