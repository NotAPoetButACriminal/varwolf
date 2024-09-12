# Loonix
FROM ubuntu:24.04

# Update the system
RUN apt update && apt -y upgrade

# Install system requirements
RUN apt install -y default-jre

# Test
CMD java --version