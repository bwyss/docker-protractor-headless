FROM plumbee/nvidia-virtualgl-selenium-node-base

USER root
RUN whoami

RUN apt-get update
RUN apt-get install -y curl && \
#curl -sL https://deb.nodesource.com/setup_9.x | bash # no good, protractor 4 needs to be run with node > 6
curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get install -y nodejs

RUN node -v
RUN npm -v

WORKDIR /tmp
COPY webdriver-versions.js ./
COPY package.json ./
RUN npm install
ENV CHROME_PACKAGE="google-chrome-stable_59.0.3071.115-1_amd64.deb" NODE_PATH=/usr/local/lib/node_modules:/protractor/node_modules

RUN npm install -g protractor@4.0.14 minimist@1.2.0
#USER seluser
RUN node ./webdriver-versions.js --chromedriver 2.32 && \
    webdriver-manager update && \
    apt-get update -y && \
    echo "deb http://ftp.debian.org/debian jessie-backports main" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y xvfb wget sudo && \
    apt-get install -y -t jessie-backports && \
    apt-get install -y openjdk-8-jre && \
    wget https://github.com/webnicer/chrome-downloads/raw/master/x64.deb/${CHROME_PACKAGE} && \
    dpkg --unpack ${CHROME_PACKAGE} && \
    apt-get install -f -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* \
    rm ${CHROME_PACKAGE} && \
    mkdir /protractor
COPY protractor.sh /
COPY environment /etc/sudoers.d/
# Fix for the issue with Selenium, as described here:
# https://github.com/SeleniumHQ/docker-selenium/issues/87
ENV DBUS_SESSION_BUS_ADDRESS=/dev/null SCREEN_RES=1280x1024x24
WORKDIR /protractor
ENTRYPOINT ["/protractor.sh"]