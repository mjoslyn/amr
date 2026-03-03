<?php defined('WPINC') or die ?><?php
add_filter( 'ppp_nonce_life', 'amr_nonce_life' );
function amr_nonce_life() {
    return 90 * DAY_IN_SECONDS;
}
// Your PHP code goes here!