ARG UBUNTU_VER="focal"
FROM ubuntu:${UBUNTU_VER}

# build arguments
ARG DEBIAN_FRONTEND=noninteractive
ARG RELEASE

# environment variables
ENV \
	farmer_address="null" \
	farmer="false" \
	farmer_port="null" \
	full_node_port="null" \
	harvester="false" \
	keys="generate" \
	log_level="INFO" \
	outbound_peer_count="20" \
	peer_count="20" \
	plots_dir="/plots" \
	testnet="false" \
	TZ="UTC"

# install dependencies
RUN \
	apt-get update \
	&& apt-get install -y \
	--no-install-recommends \
		acl \
		bc \
		ca-certificates \
		curl \
		git \
		jq \
		lsb-release \
		openssl \
		python3 \
		sudo \
		tar \
		tzdata \
		unzip \
	\
# set timezone
	\
	&& ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime \
	&& echo "$TZ" > /etc/timezone \
	&& dpkg-reconfigure -f noninteractive tzdata \
	\
# cleanup
	\
	&& rm -rf \
		/tmp/* \
		/var/lib/apt/lists/* \
		/var/tmp/*

# set workdir for build stage
WORKDIR /tranzact-blockchain

# set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# build package
RUN \
	if [ -z ${RELEASE+x} ]; then \
	RELEASE=$(curl -u "${SECRETUSER}:${SECRETPASS}" -sX GET "https://api.github.com/repos/Tranzact-Network/tranzact-blockchain/releases/latest" \
	| jq -r ".tag_name"); \
	fi \
	&& git clone -b "${RELEASE}" https://github.com/Tranzact-Network/tranzact-blockchain.git \
		/tranzact-blockchain \		
	&& git submodule update --init mozilla-ca \
	&& sh install.sh \
	\
# cleanup
	\
	&& rm -rf \
		/root/.cache \
		/tmp/* \
		/var/lib/apt/lists/* \
		/var/tmp/*

# set additional runtime environment variables
ENV \
	PATH=/tranzact-blockchain/venv/bin:$PATH \
	CONFIG_ROOT=/root/.tranzact/mainnet

# copy local files
COPY docker-*.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-*.sh

# entrypoint
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["docker-start.sh"]
