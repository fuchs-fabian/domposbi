FROM debian:latest

# ╔═════════════════════╦══════════════════════╗
# ║                                            ║
# ║             BASIC IMAGE SETUP              ║
# ║                                            ║
# ╚═════════════════════╩══════════════════════╝

RUN echo "Basic image setup..."

RUN apt-get update -y

RUN apt-get install -y \
    git \
    cron

ENV SHELL /bin/bash
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# ┌─────────────────────┬──────────────────────┐
# │            REPO SCRIPT INSTALLER           │
# └─────────────────────┴──────────────────────┘

RUN echo "Adding script to install scripts from git repositories..."

COPY repo_script_installer.bash /tmp/repo_script_installer.bash
RUN chmod +x /tmp/repo_script_installer.bash

# ╔═════════════════════╦══════════════════════╗
# ║                                            ║
# ║                 SIMBASHLOG                 ║
# ║                                            ║
# ╚═════════════════════╩══════════════════════╝

RUN echo "Installing 'simbashlog' core..."

RUN apt-get install -y \
    procps \
    jq

RUN /tmp/repo_script_installer.bash "https://github.com/fuchs-fabian/simbashlog.git" "v1.1.3"

# ╔═════════════════════╦══════════════════════╗
# ║                                            ║
# ║                  DOCKER                    ║
# ║                                            ║
# ╚═════════════════════╩══════════════════════╝

# Reference: https://docs.docker.com/engine/install/debian/#install-using-the-repository

RUN echo "Installing 'docker'..."

RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources
RUN echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker packages
RUN apt-get update && apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# ╔═════════════════════╦══════════════════════╗
# ║                                            ║
# ║                  DOMPOSY                   ║
# ║                                            ║
# ╚═════════════════════╩══════════════════════╝

RUN echo "Installing 'domposy'..."

RUN /tmp/repo_script_installer.bash "https://github.com/fuchs-fabian/domposy.git" "v2.2.0"

# ╔═════════════════════╦══════════════════════╗
# ║                                            ║
# ║                  CLEANUP                   ║
# ║                                            ║
# ╚═════════════════════╩══════════════════════╝

RUN echo "Cleanup..."

RUN apt-get clean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

# ╔═════════════════════╦══════════════════════╗
# ║                                            ║
# ║                INIT SCRIPT                 ║
# ║                                            ║
# ╚═════════════════════╩══════════════════════╝

RUN echo "Adding init script..."

COPY init.bash /usr/bin/init.bash
RUN chmod +x /usr/bin/init.bash

CMD ["/usr/bin/init.bash"]
