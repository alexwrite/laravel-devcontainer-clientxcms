# From official nginx image
FROM nginx:1.27-alpine

# Copy nginx configuration
COPY default.conf /etc/nginx/conf.d/default.conf

# Set working directory
WORKDIR /workspaces/laravel

# Expose port 80
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
