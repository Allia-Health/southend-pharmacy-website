FROM wordpress:latest

# Install additional PHP extensions
RUN apt-get update && apt-get install -y \
    libzip-dev \
    zip \
    unzip \
    && docker-php-ext-install zip

# Create mu-plugins directory (persistent across WordPress copy)
RUN mkdir -p /usr/src/wordpress/wp-content/mu-plugins

# Copy custom theme
COPY southend-pharmacy-theme /usr/src/wordpress/wp-content/themes/southend-pharmacy

# Copy SMTP configuration plugin to WordPress source (will be copied to /var/www/html on startup)
COPY wp-content/mu-plugins/smtp-config.php /usr/src/wordpress/wp-content/mu-plugins/smtp-config.php

# Also copy to /var/www/html to ensure it's available immediately
RUN mkdir -p /var/www/html/wp-content/mu-plugins && \
    cp /usr/src/wordpress/wp-content/mu-plugins/smtp-config.php /var/www/html/wp-content/mu-plugins/smtp-config.php

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html && \
    find /var/www/html -type d -exec chmod 755 {} \; && \
    find /var/www/html -type f -exec chmod 644 {} \;

# Expose port 80
EXPOSE 80

# Use the default WordPress entrypoint
CMD ["apache2-foreground"]

