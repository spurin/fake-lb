FROM alpine

# Install kubectl and jq
RUN apk add --no-cache curl jq bash

# Determine architecture and download the appropriate version of kubectl
RUN ARCH="" && \
    case $(uname -m) in \
        x86_64) ARCH="amd64" ;; \
        arm64) ARCH="arm64" ;; \
        aarch64) ARCH="arm64" ;; \
        arm*) ARCH="arm" ;; \
        *) echo "Unsupported architecture" && exit 1 ;; \
    esac && \
    curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/$ARCH/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl

# Copy the script into the container
COPY update-lb-services.sh /update-lb-services.sh
RUN chmod +x /update-lb-services.sh

# Command to run the script
CMD ["/update-lb-services.sh"]
