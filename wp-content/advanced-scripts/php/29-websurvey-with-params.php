<?php defined('WPINC') or die ?><?php
$atts = shortcode_atts([
    'link' => 'https://www.alleganymountainresort.local:8443/web-survey/',
], $atts, $tag);
$link = $atts['link'];
$url = $base_url . $_SERVER["REQUEST_URI"];
$q =parse_url($url, PHP_URL_QUERY);
if($q) {
    $link .= '?'.$q;
}
echo $link;