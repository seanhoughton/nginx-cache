#!/bin/sh
set -e

export VERSION=$(cat /version.txt)

echo "Now running nginx-cache $VERSION"

export LISTENPORT=${LISTENPORT:-8888}
export UPSTREAM=${UPSTREAM:-http://remote}
export UPSTREAM_PROTOCOL=${UPSTREAM_PROTOCOL:-http}
export UPSTREAM_OPTS=${UPSTREAM_OPTS:-max_fails=5 fail_timeout=15s}
export WORKERS=${WORKERS:-4}
export MAX_EVENTS=${MAX_EVENTS:-1024}
export SENDFILE=${SENDFILE:-on}
export TCP_NOPUSH=${TCP_NOPUSH:-off}
export CUSTOM_CONFIGURATION=${CUSTOM_CONFIGURATION}

export BODY_BUFFER_SIZE=${BODY_BUFFER_SIZE:-64k}
export CACHE_SIZE=${CACHE_SIZE:-1G}
export CACHE_MEM=${CACHE_MEM:-10m}
export CACHE_AGE=${CACHE_AGE:-365d}

export STDERR_ERR_LOG=${STDERR_ERR_LOG:-0}
export PROXY_CACHE_LOCK=${PROXY_CACHE_LOCK:-on}

export SSL=${SSL:-off}
export CERTIFICATE=${CERTIFICATE:-/etc/certs.d/bad.pem}
export CERTIFICATE_KEY=${CERTIFICATE_KEY:-/etc/certs.d/bad.key}


if [ "$STDERR_ERR_LOG" = "1" ]; then
	export ERR_LOG='stderr warn'
else
	export ERR_LOG='/var/log/nginx/error.log warn'
fi


export UPSTREAM_SERVERS=$(echo $UPSTREAM | tr ";" "\n" | sed -e "s/^\(.*\)$/        server \1 ${UPSTREAM_OPTS};/")

echo -e "Servers:\n${UPSTREAM_SERVERS}"

SUBSTVARS='${SSL} ${CERTIFICATE} ${CERTIFICATE_KEY} ${LISTENPORT} ${UPSTREAM_SERVERS} ${WORKERS} ${MAX_EVENTS} ${SENDFILE} ${TCP_NOPUSH} ${BODY_BUFFER_SIZE} ${CACHE_SIZE} ${CACHE_AGE} ${CACHE_MEM} ${ERR_LOG} ${PROXY_CACHE_LOCK} ${CUSTOM_CONFIGURATION}'
envsubst "${SUBSTVARS}" > /etc/nginx/nginx.conf < /etc/nginx/nginx.conf.tmpl

if [ "$1" = "cache" ]; then
	shift

	# Nginx will interanlly switch user. Make sure that if we mount the volume, we also gain ownership of it.
	# This can be very expensive and has been disabled, only the folder is changed for now
	# chown -R nginx /cache
	chown nginx /cache

	if [ "$VERBOSE" = "1" ]; then
		cat /etc/nginx/nginx.conf
		#cat /etc/nginx/conf.d/*.conf
	fi

	exec /usr/sbin/nginx -g "daemon off;"
fi

exec "$@"
