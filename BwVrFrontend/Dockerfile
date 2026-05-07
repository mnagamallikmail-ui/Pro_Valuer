<<<<<<< HEAD
FROM nginx:alpine

# The build/web directory is built in GitHub Actions
COPY build/web /usr/share/nginx/html

# Copy custom nginx config for Flutter routing support
COPY nginx.conf /etc/nginx/conf.d/default.conf

=======
FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app
COPY pubspec.yaml ./
RUN flutter pub get
COPY . .
RUN flutter build web --release --pwa-strategy=none

FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
>>>>>>> 84141aa47c8b58ff717d8d2c62f72a0cee589238
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
