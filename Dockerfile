FROM ubuntu:20.04 AS linux
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends \
    apt-transport-https \
    apt-utils \
    ca-certificates \
    curl \
    git \
    iputils-ping \
    jq \
    lsb-release \
    software-properties-common \
    net-tools \
    wget \
    python3.9 \
    unzip \
    zip \
    python3-distutils \
    python-distutils-extra \
    python3-pip \
    lsof \
    && rm -rf /var/lib/apt/lists/*

# Install Kubectl/Helm
RUN curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin/kubectl \
    && curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 \
    && chmod +x get_helm.sh && ./get_helm.sh \ 
    # Install Powershell/Dotnet SDK
    && wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && apt-get update \
    && add-apt-repository universe \
    && apt-get install -y powershell \
    && apt-get install -y dotnet-sdk-6.0 \
    && apt-get install -y dotnet-runtime-6.0 \
    && apt-get install -y aspnetcore-runtime-6.0 \
    # Install SQL Package
    && wget -q -O sqlpackage.zip https://aka.ms/sqlpackage-linux \
    && unzip -qq sqlpackage.zip -d /opt/sqlpackage \
    && chmod +x /opt/sqlpackage/sqlpackage \
    # Install Docker
    #&& curl -sSL https://get.docker.com/ | sh \
    # Install NPM/Yarn
    && curl -sL https://deb.nodesource.com/setup_16.x | bash \
    && apt-get install -y nodejs \
    && apt-get install -y yarn \
    && apt-get install -y build-essential \
    # Install poetry
    && curl -sSL https://install.python-poetry.org | POETRY_HOME=/etc/poetry python3 - \
    && cp /etc/poetry/bin/poetry /usr/local/bin/ \
    # Install Terraform
    && wget --quiet https://releases.hashicorp.com/terraform/0.11.3/terraform_0.11.3_linux_amd64.zip \
    && unzip terraform_0.11.3_linux_amd64.zip \
    && mv terraform /usr/bin \
    && rm terraform_0.11.3_linux_amd64.zip \
    # Install AZ CLI
    && curl -sL https://aka.ms/InstallAzureCLIDeb | bash \
    && rm -rf /var/lib/apt/lists/*

# Can be 'linux-x64', 'linux-arm64', 'linux-arm', 'rhel.6-x64'.
ENV TARGETARCH=linux-x64

WORKDIR /azp

COPY ./start.sh .
RUN chmod +x start.sh

ENTRYPOINT [ "./start.sh" ]
