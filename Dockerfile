############################
# STEP 1 build executable binary
############################
FROM fedora:latest AS builder
LABEL maintainer="Roman Pavlyuk <roman.pavlyuk@gmail.com>"

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
RUN cp -a /mbmd/go.mod /build
RUN cp -a /mbmd/go.sum /build
RUN go mod download

# build
RUN cp -a /mbmd/* /build
RUN make install
RUN make build

#############################
## STEP 2 build a small image
#############################
FROM fedora:latest

# Refresh container
RUN dnf update -y
RUN dnf install -y ca-certificates tzdata less vim
RUN /usr/bin/update-ca-trust

ENV container=docker

# Enable systemd.
RUN dnf -y install systemd && dnf clean all && \
  (cd /lib/systemd/system/sysinit.target.wants/ ; for i in * ; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i ; done) ; \
  rm -f /lib/systemd/system/multi-user.target.wants/* ;\
  rm -f /etc/systemd/system/*.wants/* ;\
  rm -f /lib/systemd/system/local-fs.target.wants/* ; \
  rm -f /lib/systemd/system/sockets.target.wants/*udev* ; \
  rm -f /lib/systemd/system/sockets.target.wants/*initctl* ; \
  rm -f /lib/systemd/system/basic.target.wants/* ;\
  rm -f /lib/systemd/system/anaconda.target.wants/*

# Copy our static executable
COPY --from=builder /build/mbmd /usr/local/bin/mbmd

# Run as nonroot
RUN adduser -r mbmd -G dialout

# Install system service
COPY dist/mbmd.service /etc/systemd/system/mbmd.service
RUN systemctl enable mbmd.service

# Provide config
COPY dist/mbmd.yaml /etc/mbmd.yaml

# Expose WEB Port
EXPOSE 8080

# Run the binary
VOLUME ["/sys/fs/cgroup"]
CMD ["/sbin/init"]
