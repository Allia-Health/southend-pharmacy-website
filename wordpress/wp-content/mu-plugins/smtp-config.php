<?php
/**
 * Plugin Name: SMTP Configuration
 * Description: Configures WordPress to use SMTP for email delivery
 * Version: 1.0.0
 * Author: Allia Health
 */

// Configure PHPMailer to use SMTP
add_action('phpmailer_init', function($phpmailer) {
    // Get SMTP settings from environment variables
    $smtp_host = getenv('SMTP_HOST') ?: 'smtp.gmail.com';
    $smtp_port = getenv('SMTP_PORT') ?: '587';
    $smtp_user = getenv('SMTP_USER');
    $smtp_pass = getenv('SMTP_PASSWORD');
    $smtp_from = getenv('SMTP_FROM') ?: get_option('admin_email');
    $smtp_from_name = getenv('SMTP_FROM_NAME') ?: get_bloginfo('name');
    $smtp_secure = getenv('SMTP_SECURE') ?: 'tls'; // 'tls' or 'ssl'
    
    // Log SMTP configuration attempt
    error_log('SMTP Config Plugin: Attempting to configure SMTP');
    error_log('SMTP Config Plugin: SMTP_USER=' . (!empty($smtp_user) ? 'SET' : 'EMPTY'));
    error_log('SMTP Config Plugin: SMTP_PASSWORD=' . (!empty($smtp_pass) ? 'SET' : 'EMPTY'));
    
    // Only configure if SMTP credentials are provided
    if (empty($smtp_user) || empty($smtp_pass)) {
        error_log('SMTP Config Plugin: Skipping SMTP config - missing credentials');
        return;
    }
    
    try {
        $phpmailer->isSMTP();
        $phpmailer->Host = $smtp_host;
        $phpmailer->SMTPAuth = true;
        $phpmailer->Port = (int)$smtp_port;
        $phpmailer->Username = $smtp_user;
        $phpmailer->Password = $smtp_pass;
        $phpmailer->SMTPSecure = $smtp_secure;
        $phpmailer->From = $smtp_from;
        $phpmailer->FromName = $smtp_from_name;
        
        // Enable verbose debug output
        $phpmailer->SMTPDebug = 2;
        $phpmailer->Debugoutput = function($str, $level) {
            error_log("PHPMailer Debug ($level): $str");
        };
        
        // Set additional SMTP options for better compatibility
        $phpmailer->SMTPOptions = array(
            'ssl' => array(
                'verify_peer' => true,
                'verify_peer_name' => true,
                'allow_self_signed' => false
            )
        );
        
        error_log('SMTP Config Plugin: SMTP configured successfully');
        error_log('SMTP Config Plugin: Host=' . $smtp_host . ', Port=' . $smtp_port . ', Secure=' . $smtp_secure);
    } catch (Exception $e) {
        error_log('SMTP Config Plugin Error: ' . $e->getMessage());
    }
});

// Override WordPress default from email
add_filter('wp_mail_from', function($from_email) {
    $smtp_from = getenv('SMTP_FROM');
    return $smtp_from ?: $from_email;
});

add_filter('wp_mail_from_name', function($from_name) {
    $smtp_from_name = getenv('SMTP_FROM_NAME');
    return $smtp_from_name ?: $from_name;
});

// Log email sending attempts
add_action('wp_mail_failed', function($wp_error) {
    error_log('WordPress Email Failed: ' . $wp_error->get_error_message());
    if (isset($wp_error->error_data['phpmailer_exception_code'])) {
        error_log('PHPMailer Exception Code: ' . $wp_error->error_data['phpmailer_exception_code']);
    }
});

add_action('wp_mail_succeeded', function($mail_data) {
    error_log('WordPress Email Succeeded: ' . print_r($mail_data, true));
});

