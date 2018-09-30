#!/bin/sh
set -e

export VERSION=$(cat /version.txt)

echo "Now running nginx-cache $VERSION"

export LISTENPORT=${LISTENPORT:-8888}
export UPSTREAM=${UPSTREAM:-http://remote}
export WORKERS=${WORKERS:-4}
export MAX_EVENTS=${MAX_EVENTS:-1024}
export SENDFILE=${SENDFILE:-on}
export TCP_NOPUSH=${TCP_NOPUSH:-off}

export CACHE_SIZE=${CACHE_SIZE:-1G}
export CACHE_MEM=${CACHE_MEM:-10m}
export CACHE_AGE=${CACHE_AGE:-365d}

export USE_PERFLOG=${USE_PERFLOG:-0}
export PROXY_CACHE_LOCK=${PROXY_CACHE_LOCK:-on}

export SSL=${SSL:-off}
export CERTIFICATE=${CERTIFICATE:-/etc/certs.d/bad.pem}
export CERTIFICATE_KEY=${CERTIFICATE_KEY:-/etc/certs.d/bad.key}


if [ "$USE_PERFLOG" = "1" ]; then
	export ACCESS_LOG_STATEMENT='access_log  /log/access.log upstream_time;'
fi

envsubst '${SSL} ${CERTIFICATE} ${CERTIFICATE_KEY} ${LISTENPORT} ${UPSTREAM} ${WORKERS} ${MAX_EVENTS} ${SENDFILE} ${TCP_NOPUSH} ${CACHE_SIZE} ${CACHE_AGE} ${CACHE_MEM} ${ACCESS_LOG_STATEMENT} ${PROXY_CACHE_LOCK}' > /etc/nginx/nginx.conf < /etc/nginx/nginx.conf.tmpl

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
