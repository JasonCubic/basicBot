# node/docker best practices:  https://github.com/nodejs/docker-node/blob/master/docs/BestPractices.md
# FROM node:10
FROM docker-registry-dtna.app.corpintra.net/library/node:10

# WORKDIR /root
WORKDIR /usr/src/app

# copy only files/folders needed for deployment
COPY bots bots
COPY cognitiveModels cognitiveModels
COPY dialogs dialogs
COPY PostDeployScripts PostDeployScripts
COPY Properties Properties
COPY .deployment .deployment
COPY .env .env
COPY .eslintrc.js .eslintrc.js
COPY deploy.cmd deploy.cmd
COPY iisnode.yml iisnode.yml
COPY index.js index.js
COPY package-lock.json package-lock.json
COPY package.json package.json
COPY publish.cmd publish.cmd
COPY README.md README.md
COPY web.config web.config

# populate node_modules folder (note: npm install must be done in the same environment the app is run in)
RUN npm install --proxy http://webproxy.us164.corpintra.net:8080/ --https-proxy http://webproxy.us164.corpintra.net:8080/

# populate the /dist folder (these are static files that are served by the express webserver)
# RUN npm run build

# log contents of dist folder to make sure it populated correctly
# RUN ls -al dist/

# no longer need these files/folders after npm run build has completed
# RUN rmdir --ignore-fail-on-non-empty src
# RUN rmdir --ignore-fail-on-non-empty public
# RUN rm -rf src/
# RUN rm -rf public/

# https://github.com/Yelp/dumb-init
RUN wget -e use_proxy=yes -e http_proxy=webproxy.us164.corpintra.net:8080 -e https_proxy=webproxy.us164.corpintra.net:8080 https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64.deb
RUN dpkg -i dumb-init_*.deb

# USER root
# RUN NODE_ENV=$ENV \
#     && useradd -s /sbin/nologin XXX \
#     && usermod -aG XXXX XXXX \
#     && chown -R XXXX:XXXX /usr/src/app

# # Switch context to this user to start the service
# USER XXXXX


CMD ["/usr/bin/dumb-init", "node", "./index.js"]
