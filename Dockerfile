# checkov:skip=CKV_DOCKER_3: Current implementation uses off-the-shelf
# OpenResty image which does not provide a non-root variant.

# -------------------------------
# Base Image – OpenResty NGINX on Alpine
# -------------------------------
FROM docker.io/openresty/openresty:1.27.1.2-1-alpine-fat

# -------------------------------
# Image metadata (rebranded for CATS)
# -------------------------------
LABEL org.opencontainers.image.vendor="CATS" \
      org.opencontainers.image.authors="CATS Platform Team" \
      org.opencontainers.image.title="CATS Cloud Development Environment NGINX Proxy" \
      org.opencontainers.image.description="NGINX / OpenResty reverse proxy for the CATS analytical platform" \
      org.opencontainers.image.url="https://github.com/catsgroup/cats-nginx-proxy"

# -------------------------------
# NOTE: lua-resty-openidc NOT installed here
# -------------------------------
# In this environment:
#  - apk update fails due to TLS interception (Zscaler),
#  - luarocks cannot fetch manifests for Lua 5.1 reliably.
#
# To guarantee a clean, reproducible build with no external
# network dependencies, we skip lua-resty-openidc installation.
#
# If you later require OIDC at the NGINX layer, we can:
#  - pre-download the lua-resty-openidc rock,
#  - ADD it into the build context, and
#  - install it via `luarocks install /path/to/lua-resty-openidc-X.Y.Z.rock`.

# -------------------------------
# NGINX / Lua configuration
# -------------------------------
# These paths must exist in your repo:
#   src/etc/nginx
#   src/opt/lua-scripts
#   src/srv/www
#   src/usr/local/bin/entrypoint.sh
#   src/usr/local/bin/healthcheck.sh

COPY src/etc/nginx          /etc/nginx
COPY src/opt/lua-scripts    /opt/lua-scripts
COPY src/srv/www            /srv/www

# Helper scripts (entrypoint, healthcheck)
COPY --chown=nobody:nobody --chmod=0755 \
  src/usr/local/bin/entrypoint.sh   /usr/local/bin/entrypoint.sh
COPY --chown=nobody:nobody --chmod=0755 \
  src/usr/local/bin/healthcheck.sh  /usr/local/bin/healthcheck.sh

EXPOSE 3000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
  CMD ["/usr/local/bin/healthcheck.sh"]
