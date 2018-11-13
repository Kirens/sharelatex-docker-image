# Sharelatex Community Edition (sharelatex/sharelatex)

FROM sharelatex/sharelatex-base:latest

ENV baseDir .

# Install sharelatex settings file
ADD ${baseDir}/settings.coffee /etc/sharelatex/settings.coffee
ENV SHARELATEX_CONFIG /etc/sharelatex/settings.coffee

ADD ${baseDir}/runit            /etc/service

RUN rm /etc/nginx/sites-enabled/default
ADD ${baseDir}/nginx/nginx.conf /etc/nginx/nginx.conf
ADD ${baseDir}/nginx/sharelatex.conf /etc/nginx/sites-enabled/sharelatex.conf

ADD ${baseDir}/logrotate/sharelatex /etc/logrotate.d/sharelatex

COPY ${baseDir}/init_scripts/  /etc/my_init.d/

# Install ShareLaTeX
RUN git clone https://github.com/sharelatex/sharelatex.git /var/www/sharelatex; \
  cd /var/www/sharelatex; \
  git checkout 5064b4cb3afad68bd97244e33c37254531c148e4;

ADD ${baseDir}/services.js /var/www/sharelatex/config/services.js
ADD ${baseDir}/package.json /var/www/package.json
ADD ${baseDir}/git-revision.js /var/www/git-revision.js
ADD ${baseDir}/chownAll.sh /tmp/chownAll.sh
RUN cd /var/www && npm install


RUN cd /var/www/sharelatex; \
	npm install;
RUN cd /var/www/sharelatex; \
	grunt install;
RUN cd /var/www/sharelatex; \
	bash -c 'source ./bin/install-services';
RUN cd /var/www/sharelatex/web; \
	npm install;
RUN cd /var/www/sharelatex/web; \
	npm install bcrypt;
RUN cd /var/www/sharelatex/web/modules; \
	git clone https://github.com/sharelatex/launchpad-web-module.git launchpad; \
        cd launchpad; \
        git checkout fe6aaa63b4146271fc92a25ab9d22ef1099d4501;
RUN cd /var/www/sharelatex/web; \
	grunt compile;

RUN cd /var/www && node git-revision > revisions.txt

# Minify js assets
RUN cd /var/www/sharelatex/web; \
	grunt compile:minify;

RUN cd /var/www/sharelatex/clsi; \
	grunt compile:bin; \
        echo Will chown a lot of files now; \
        /tmp/chownAll.sh /var/www/sharelatex 'xargs -0 chown www-data:www-data';
#	chown -R www-data:www-data /var/www/sharelatex;

EXPOSE 80

WORKDIR /

ENTRYPOINT ["/sbin/my_init"]

