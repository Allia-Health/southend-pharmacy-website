FROM wordpress:latest

# Install additional PHP extensions
RUN apt-get update && apt-get install -y \
    libzip-dev \
    zip \
    unzip \
    && docker-php-ext-install zip

# Copy custom theme
COPY southend-pharmacy-theme /var/www/html/wp-content/themes/southend-pharmacy

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html && \
    find /var/www/html -type d -exec chmod 755 {} \; && \
    find /var/www/html -type f -exec chmod 644 {} \;

# Expose port 80
EXPOSE 80

# Use the default WordPress entrypoint
CMD ["apache2-foreground"]

