<?php
/**
 * Southend Pharmacy Theme Functions
 */

// Enqueue styles
function southend_pharmacy_enqueue_styles() {
    wp_enqueue_style( 'southend-pharmacy-style', get_stylesheet_uri(), array(), '1.0.0' );
}
add_action( 'wp_enqueue_scripts', 'southend_pharmacy_enqueue_styles' );

// Theme setup
function southend_pharmacy_setup() {
    // Add theme support
    add_theme_support( 'title-tag' );
    add_theme_support( 'custom-logo' );
    add_theme_support( 'html5', array( 'search-form', 'comment-form', 'comment-list', 'gallery', 'caption' ) );
}
add_action( 'after_setup_theme', 'southend_pharmacy_setup' );

