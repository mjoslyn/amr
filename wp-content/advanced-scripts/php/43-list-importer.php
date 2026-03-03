<?php defined('WPINC') or die ?><?php

function add_subscribers_to_mailpoet_zapier( $user ) {

    error_log( '[MailPoet Zapier] Function triggered' );

    // If lists aren't passed through just bail.
    if ( empty( $_REQUEST['lists'] ) ) {
        error_log( '[MailPoet Zapier] No lists provided, bailing' );
        return $user;
    }

    if (class_exists(\MailPoet\API\API::class)) {
        $mailpoet_api = \MailPoet\API\API::MP('v1');

        // Get custom field values
        $dealership = isset( $_REQUEST['dealership'] ) ? sanitize_text_field( $_REQUEST['dealership'] ) : '';
        $rep = isset( $_REQUEST['rep'] ) ? sanitize_text_field( $_REQUEST['rep'] ) : '';

        $sub = array(
            'email' => sanitize_text_field( $_REQUEST['email'] ),
            'first_name' => isset( $_REQUEST['first_name'] ) ? sanitize_text_field( $_REQUEST['first_name'] ) : '',
            'last_name' => isset( $_REQUEST['last_name'] ) ? sanitize_text_field( $_REQUEST['last_name'] ) : '',
            'cf_1' => $dealership,
            'cf_3' => $rep,
        );

        error_log( '[MailPoet Zapier] Processing subscriber: ' . $sub['email'] . ' (' . $sub['first_name'] . ' ' . $sub['last_name'] . ')' );
        error_log( '[MailPoet Zapier] Dealership: ' . ( $dealership ? $dealership : '(empty)' ) );
        error_log( '[MailPoet Zapier] Rep: ' . ( $rep ? $rep : '(empty)' ) );

        // Get QAL value
        $qal = isset( $_REQUEST['qal'] ) ? strtoupper( trim( sanitize_text_field( $_REQUEST['qal'] ) ) ) : '';
        error_log( '[MailPoet Zapier] QAL value: ' . ( $qal ? $qal : '(empty)' ) );

        // See if the user exists first.
        $subscriber = null;
        try {
            $subscriber = $mailpoet_api->getSubscriber( $sub['email'] );
            error_log( '[MailPoet Zapier] Existing subscriber found, ID: ' . $subscriber['id'] );
        } catch ( \Throwable $th ) {
            error_log( '[MailPoet Zapier] Subscriber not found: ' . $th->getMessage() );
        }

        // Parse lists
        $lists_id = explode( ',', $_REQUEST['lists'] );
        $lists = array();
        foreach( $lists_id as $key => $list_id ) {
            $lists[] = intval( $list_id );
        }
        error_log( '[MailPoet Zapier] Target lists: ' . implode( ', ', $lists ) );

        // Only add user if QAL is "NR"
        if ( $qal === 'NR' ) {
            error_log( '[MailPoet Zapier] QAL is NR - adding/subscribing user' );

            // If the subscriber doesn't exist, add them.
            if ( ! $subscriber ) {
                try {
                    $subscriber = $mailpoet_api->addSubscriber( $sub, $lists );
                    error_log( '[MailPoet Zapier] New subscriber created, ID: ' . $subscriber['id'] );
                } catch (\Throwable $th) {
                    error_log( '[MailPoet Zapier] Failed to create subscriber: ' . $th->getMessage() );
                }
            } else {
                // Update existing subscriber with custom fields
                try {
                    $mailpoet_api->subscribeToLists( $subscriber['id'], $lists );
                    // Update custom fields for existing subscriber
                    $update_data = array(
                        'cf_dealership' => $dealership,
                        'cf_rep' => $rep,
                    );
                    $mailpoet_api->updateSubscriber( $subscriber['id'], $update_data );
                    error_log( '[MailPoet Zapier] Updated subscriber ' . $subscriber['id'] . ' with custom fields' );
                } catch ( \Throwable $th ) {
                    error_log( '[MailPoet Zapier] Failed to update subscriber: ' . $th->getMessage() );
                }
            }

        } else {
            error_log( '[MailPoet Zapier] QAL is not NR - removing user from lists' );

            // QAL is not "NR" - remove user from lists if they exist
            if ( $subscriber ) {
                $user_id = $subscriber['id'];
                try {
                    $mailpoet_api->unsubscribeFromLists( $user_id, $lists );
                    error_log( '[MailPoet Zapier] Unsubscribed user ' . $user_id . ' from lists' );
                } catch ( \Throwable $th ) {
                    error_log( '[MailPoet Zapier] Failed to unsubscribe from lists: ' . $th->getMessage() );
                }
            } else {
                error_log( '[MailPoet Zapier] No existing subscriber to remove' );
            }
        }
    } else {
        error_log( '[MailPoet Zapier] MailPoet API class not found' );
    }

    error_log( '[MailPoet Zapier] Function complete' );
    return $user;
}
add_filter( 'wp_zapier_custom_webhook', 'add_subscribers_to_mailpoet_zapier', 10, 1 );
