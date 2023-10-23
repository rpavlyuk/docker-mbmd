############################
# STEP 1 build executable binary
############################
FROM fedora:latest as builder
MAINTAINER "Roman Pavlyuk" <roman.pavlyuk@gmail.com>

# Install git + SSL ca certificates.
# Git is required for fetching the dependencies.
# Ca-certificates is required to call HTTPS endpoints.
RUN dnf update -y 
RUN dnf install -y git ca-certificates tzdata go
RUN  /usr/bin/update-ca-trust

# Clone the MBMD project
RUN /usr/bin/git clone https://github.com/volkszaehler/mbmd.git /mbmd

WORKDIR /build

# cache modules
COPY /mbmd/go.mod .
COPY /mbmd/go.sum .
RUN go mod download

COPY /mbmd/* .
RUN make install
RUN make build
