# Stage 1: Build Flutter Web
FROM ghcr.io/cirruslabs/flutter:stable AS build

# Build arguments for configuration
ARG BACKEND_URL
ARG SWAGGER_URL
ARG HEALTH_URL

WORKDIR /app

# Copy files and get dependencies
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy the rest of the code
COPY . .

# Build Flutter web with defines
RUN flutter build web --release \
    --dart-define=BACKEND_URL=$BACKEND_URL \
    --dart-define=SWAGGER_URL=$SWAGGER_URL \
    --dart-define=HEALTH_URL=$HEALTH_URL

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Remove default nginx contents
RUN rm -rf /usr/share/nginx/html/*

# Copy build output from stage 1
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port (Nginx default is 80, but Railway uses $PORT)
EXPOSE 80

# Script to inject PORT variable into nginx config and start nginx
CMD /bin/sh -c "sed -i 's/listen 80;/listen '\"$PORT\"';/g' /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"
