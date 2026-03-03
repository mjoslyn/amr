<?php defined('WPINC') or die ?><?php

add_filter( 'gform_disable_notification', 'disable_notification', 99, 4 );
function disable_notification( $is_disabled, $notification, $form, $entry ) {
    $source_url = rgar($entry, 'source_url');
    $ref = rgar($entry,'27');
    $c1 = rgar($entry,'29');
    $email = rgar($entry,'5');
    if(str_contains($ref,"lwt") || str_contains($source_url, "lwt=") || str_contains($c1, 'maze.co')){
        return true;
    }
    if($email == "mike@robotofthefuture.com"){
        return true;
    }
    return $is_disabled;
}
/*
add_filter( 'gform_notification', 'my_gform_notification_signature', 10, 3 );
function my_gform_notification_signature( $notification, $form, $entry ) {
    if($form['id'] == 17) {
        $source_url = rgar($entry, 'source_url');
        $ref = rgar($entry,'27');
        if(str_contains($ref,"gclid=") || str_contains($source_url, "gclid=")  || str_contains($source_url, "gad_source=")){
            $notification['message'] .= "Source: Google Ads";
        }
        if(str_contains($ref,"fbclid=") || str_contains($source_url, "fbclid=")){
            $notification['message'] .= "Source: Facebook Ads";
        }
      }
    return $notification;
}
*/
