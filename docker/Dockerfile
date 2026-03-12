# Builder - Download and verify Wordpress

FROM debian:bookworm-slim AS builder

ARG WORDPRESS_VERSION=6.5.3

RUN apt-get update && apt-get install -y --no-install-recommends \
	curl \
	ca-certificates \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Download Wordpress and verify checksum

RUN curl --fsSL "https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz" \
	-o wordpress.tar.gz \
	&& curl -fsSL "https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz.md5" \
    -o wordpress.tar.gz.md5 \
	&& echo "$(cat wordpress.tar.gz.md5)  wordpress.tar.gz" | md5sum -c - \
    && tar -xzf wordpress.tar.gz \
    && rm wordpress.tar.gz wordpress.tar.gz.md5

# minimal production image

FROM php:8.2-fpm-alpine AS final

# Install required PHP extensions and tools
RUN apk add --no-cache \
    nginx \
    supervisor \
    mysql-client \
    libpng-dev \
    libjpeg-turbo-dev \
    libwebp-dev \
    freetype-dev \
    && docker-php-ext-configure gd \
        --with-freetype \
        --with-jpeg \
        --with-webp \
    && docker-php-ext-install -j$(nproc) \
        gd \
        mysqli \
        pdo_mysql \
        opcache \
        exif \
    && rm -rf /var/cache/apk/*

# Copy WordPress from builder stage

COPY --from=builder /build/wordpress /var/www/html

# Copy nginx and supervisor configs 

COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/supervisord.conf /etc/supervisord.conf
COPY config/php-opcache.ini /usr/local/etc/php/conf.d/opcache.ini

# Harden: run as non-root

RUN addgroup -g 1001 wordpress \
    && adduser -u 1001 -G wordpress -s /bin/sh -D wordpress \
    && chown -R wordpress:wordpress /var/www/html \
    && chown -R wordpress:wordpress /var/log/nginx \
    && chown -R wordpress:wordpress /var/lib/nginx

WORKDIR /var/www/html

EXPOSE 8080

USER wordpress

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
