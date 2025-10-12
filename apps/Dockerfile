# Flutter Web Dockerfile
FROM ubuntu:22.04 as build-stage

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libgconf-2-4 \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter
ENV FLUTTER_VERSION=3.27.2
RUN git clone --depth 1 --branch ${FLUTTER_VERSION} https://github.com/flutter/flutter.git /flutter
ENV PATH="/flutter/bin:${PATH}"

# Set Flutter to use web platform
RUN flutter config --enable-web
RUN flutter doctor

WORKDIR /app

# Copy pubspec files
COPY apps/pubspec.yaml apps/pubspec.lock ./

# Get dependencies
RUN flutter pub get

# Copy source code
COPY apps/ ./

# Build web app
RUN flutter build web --release

# Production stage with nginx
FROM nginx:alpine as production-stage

# Copy built web app to nginx
COPY --from=build-stage /app/build/web /usr/share/nginx/html

# Copy nginx configuration
COPY docker/nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]