FROM nginx:alpine

# The build/web directory is built in GitHub Actions
# Since the Docker context is set to the project root, we use the subdirectory prefix
COPY BwVrFrontend/build/web /usr/share/nginx/html

# Copy custom nginx config for Flutter routing support
COPY BwVrFrontend/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
