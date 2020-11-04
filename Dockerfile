# Etherpad Lite Dockerfile
#
# https://github.com/ether/etherpad-lite
#
# Author: muxator

FROM node:10-buster-slim

ENV ETHERPAD_VERSION 1.8.6

LABEL maintainer="Etherpad team, https://github.com/ether/etherpad-lite"

# plugins to install while building the container. By default no plugins are
# installed.
# If given a value, it has to be a space-separated, quoted list of plugin names.
#
# EXAMPLE:
#   ETHERPAD_PLUGINS="ep_codepad ep_author_neat"
ARG ETHERPAD_PLUGINS="ep_adminpads"

# By default, Etherpad container is built and run in "production" mode. This is
# leaner (development dependencies are not installed) and runs faster (among
# other things, assets are minified & compressed).
ENV NODE_ENV=production

# Follow the principle of least privilege: run as unprivileged user.
#
# Running as non-root enables running this image in platforms like OpenShift
# that do not allow images running as root.
# Also fix issue that would arise when installing libreoffice
RUN useradd --uid 5001 --create-home etherpad && \
    mkdir -p /usr/share/man/man1

WORKDIR /opt/


RUN apt-get update && \
    apt-get install -y curl unzip mariadb-client libreoffice && \
    curl -SL \
      https://github.com/ether/etherpad-lite/archive/${ETHERPAD_VERSION}.zip \
      > etherpad.zip && unzip etherpad && rm etherpad.zip && \
    mv etherpad-lite-${ETHERPAD_VERSION} etherpad-lite && \
    chown -R etherpad:0 etherpad-lite && \
    apt-get purge -y curl unzip && \
    apt-get autoremove -y && \
    rm -r /var/lib/apt/lists/*

WORKDIR etherpad-lite

USER etherpad

# install node dependencies for Etherpad
RUN bin/installDeps.sh && \
	rm -rf ~/.npm/_cacache && \
        rm settings.json

# Install the plugins, if ETHERPAD_PLUGINS is not empty.
#
# Bash trick: in the for loop ${ETHERPAD_PLUGINS} is NOT quoted, in order to be
# able to split at spaces.
RUN for PLUGIN_NAME in ${ETHERPAD_PLUGINS}; do npm install "${PLUGIN_NAME}"; done

# Copy the configuration file.
ADD assets /

VOLUME /opt/etherpad-lite/var
RUN ln -s var/settings.json settings.json

# Fix permissions for root group
RUN chmod -R g=u .

EXPOSE 9001
ENTRYPOINT ["/entrypoint.sh"]
CMD ["node", "node_modules/ep_etherpad-lite/node/server.js"]

