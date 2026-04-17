# Dockerfile (copy-paste this entire file)

FROM ghcr.io/cirruslabs/flutter:stable AS build

ARG BACKEND_URL
ARG SWAGGER_URL
ARG HEALTH_URL

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .

RUN flutter build web --release \
  --dart-define=BACKEND_URL=${BACKEND_URL} \
  --dart-define=SWAGGER_URL=${SWAGGER_URL} \
  --dart-define=HEALTH_URL=${HEALTH_URL}

FROM nginx:alpine

RUN rm -rf /usr/share/nginx/html/*

COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["/bin/sh","-c","sed -i \"s/listen 80;/listen ${PORT:-80};/g\" /etc/nginx/conf.d/default.conf && nginx -g 'daemon