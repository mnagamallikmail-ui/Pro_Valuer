FROM nginx:alpine

# The build/web directory is built in GitHub Actions
COPY build/web /usr/share/nginx/html

# Copy custom nginx config for Flutter routing support
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
