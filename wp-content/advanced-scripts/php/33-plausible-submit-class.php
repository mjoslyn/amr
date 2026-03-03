<?php defined('WPINC') or die ?><?php

add_filter( 'gform_submit_button_17', 'add_custom_css_classes', 10, 2 );
function add_custom_css_classes( $button, $form ) {
    $dom = new DOMDocument();
    $dom->loadHTML( '<?xml encoding="utf-8" ?>' . $button );
    $input = $dom->getElementsByTagName( 'input' )->item(0);
    $classes = $input->getAttribute( 'class' );
    $classes .= " plausible-event-name--signup";
    $input->setAttribute( 'class', $classes );
    return $dom->saveHtml( $input );
}