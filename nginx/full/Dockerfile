ARG ALPINE_RELEASE
FROM wener/base:${ALPINE_RELEASE}

# https://pkgs.alpinelinux.org/packages?name=nginx-mod-*&branch=v3.11&arch=x86_64
RUN apk --no-cache add \
        nginx \
        # nginx-mod-http
        # copy($$('.package a').map(v=>v.innerText).filter(v=>v.startsWith('nginx-mod-http')).map(v=>v.replace(/^nginx-mod-http-/,'')).sort().join(','))
        nginx-mod-http-{accounting,acme,array-var,auth-jwt,brotli,cache-purge,cookie-flag,dav-ext,echo,encrypted-session,fancyindex,geoip,geoip2,headers-more,image-filter,js,keyval,log-zmq,lua,lua-upstream,naxsi,nchan,perl,redis2,set-misc,shibboleth,slowfs-cache,untar,upload,upload-progress,upstream-fair,vod,vts,xslt-filter,zip,zstd} \
        # copy($$('.package a').map(v=>v.innerText).filter(v=>v.startsWith('nginx-mod-stream-')).map(v=>v.replace(/^nginx-mod-stream-/,'')).sort().join(','))
        nginx-mod-stream nginx-mod-stream-{geoip,geoip2,js,keyval} \
        # copy($$('.package a').map(v=>v.innerText).filter(v=>!(v.startsWith('nginx-mod-http') || v.startsWith('nginx-mod-stream'))).map(v=>v.replace(/^nginx-mod-/,'')).sort().join(','))
        nginx-mod-{dev,devel-kit,dynamic-healthcheck,dynamic-upstream,mail,rtmp}

RUN chown -R nginx:www-data /var/lib/nginx && \
    mkdir -p /run/nginx/

EXPOSE 80 443
ENTRYPOINT ["dumb-init", "--"]
CMD ["nginx", "-g", "daemon off;"]
