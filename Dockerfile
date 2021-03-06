FROM python:2-alpine

# maybe we can remove gcc and musl-dev
RUN apk update && \
	apk --no-cache add tini gcc musl-dev

RUN set -x \
	&& addgroup -g 82 -S www-data \
	&& adduser -u 82 -D -S -G www-data www-data

COPY . /app

# Pdfsizeopt
RUN tar xzvf /app/pdfsizeopt.tar.gz -C /tmp/ && \
	cp /tmp/pdfsizeopt/* /bin/ && \
	rm -rf /app/pdfsizeopt.tar.gz  /tmp/*

# PhantomJs
RUN tar xzvf /app/phantomjs.tar.gz -C /tmp/ && \
	cp -R /tmp/etc/fonts /etc/ && \
	cp -R /tmp/lib/* /lib/ && \
	cp -R /tmp/lib64 / && \
	cp -R /tmp/usr/lib/* /usr/lib/ && \
	cp -R /tmp/usr/lib/x86_64-linux-gnu /usr/ && \
	cp -R /tmp/usr/share/* /usr/share/ && \
	cp /tmp/usr/local/bin/phantomjs /usr/bin/ && \
	rm -rf /app/phantomjs.tar.gz  /tmp/*

RUN mkdir -p /storage

RUN chown -R www-data:www-data /usr/local/ /app /storage

USER www-data

RUN pip install -r /app/requirements.txt && \
   cd /app && \
   pip install .

EXPOSE 8080
WORKDIR /app
VOLUME /storage
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["pdfy"]
