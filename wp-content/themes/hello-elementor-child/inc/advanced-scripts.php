<?php
/**
 * Consolidated advanced scripts (migrated from wp-content/advanced-scripts plugin).
 */

defined('ABSPATH') || exit;

/**
 * Extend Public Post Preview nonce life to 90 days.
 */
add_filter('ppp_nonce_life', function () {
    return 90 * DAY_IN_SECONDS;
});

/**
 * Gravity Forms: disable notifications for LWT, maze.co, and test submissions.
 */
add_filter('gform_disable_notification', function ($is_disabled, $notification, $form, $entry) {
    $source_url = rgar($entry, 'source_url');
    $ref        = rgar($entry, '27');
    $c1         = rgar($entry, '29');
    $email      = rgar($entry, '5');

    if (str_contains($ref, 'lwt') || str_contains($source_url, 'lwt=') || str_contains($c1, 'maze.co')) {
        return true;
    }

    if ($email === 'mike@robotofthefuture.com') {
        return true;
    }

    return $is_disabled;
}, 99, 4);

/**
 * Shortcode: [amr-websurvey-link] -- outputs web survey URL with current query params appended.
 */
add_shortcode('amr-websurvey-link', function ($atts) {
    $atts = shortcode_atts([
        'link' => home_url('/web-survey/'),
    ], $atts, 'amr-websurvey-link');

    $link = $atts['link'];
    $query = isset($_SERVER['QUERY_STRING']) ? $_SERVER['QUERY_STRING'] : '';

    if ($query) {
        $link .= '?' . $query;
    }

    return esc_url($link);
});

/**
 * Register custom thumbnail sizes.
 */
add_image_size('Thumbnail Slider', 215, 215, true);
add_image_size('Thumbnail Slider 2x', 400, 400, true);

/**
 * Add Plausible analytics event class to Gravity Form 17 submit button.
 */
add_filter('gform_submit_button_17', function ($button, $form) {
    $dom = new DOMDocument();
    $dom->loadHTML('<?xml encoding="utf-8" ?>' . $button);
    $input   = $dom->getElementsByTagName('input')->item(0);
    $classes = $input->getAttribute('class');
    $classes .= ' plausible-event-name--signup';
    $input->setAttribute('class', $classes);
    return $dom->saveHtml($input);
}, 10, 2);

/**
 * Add meta description to date-based post archives.
 */
add_action('wp_head', function () {
    if (is_archive() && is_date()) {
        echo '<meta name="description" content="Explore the latest news, updates, and events at Allegany Mountain Resort at Rainbow Lake. Stay informed on what\'s happening at Rainbow Lake with our comprehensive news archive.">';
    }
});

/**
 * MailPoet + Zapier webhook: manage subscriber lists based on QAL status.
 */
add_filter('wp_zapier_custom_webhook', function ($user) {
    if (empty($_REQUEST['lists'])) {
        return $user;
    }

    if (!class_exists(\MailPoet\API\API::class)) {
        return $user;
    }

    $mailpoet_api = \MailPoet\API\API::MP('v1');

    $dealership = isset($_REQUEST['dealership']) ? sanitize_text_field($_REQUEST['dealership']) : '';
    $rep        = isset($_REQUEST['rep']) ? sanitize_text_field($_REQUEST['rep']) : '';

    $sub = [
        'email'      => sanitize_text_field($_REQUEST['email']),
        'first_name' => isset($_REQUEST['first_name']) ? sanitize_text_field($_REQUEST['first_name']) : '',
        'last_name'  => isset($_REQUEST['last_name']) ? sanitize_text_field($_REQUEST['last_name']) : '',
        'cf_1'       => $dealership,
        'cf_3'       => $rep,
    ];

    $qal = isset($_REQUEST['qal']) ? strtoupper(trim(sanitize_text_field($_REQUEST['qal']))) : '';

    $subscriber = null;
    try {
        $subscriber = $mailpoet_api->getSubscriber($sub['email']);
    } catch (\Throwable $th) {
        // Subscriber not found.
    }

    $lists = array_map('intval', explode(',', $_REQUEST['lists']));

    if ($qal === 'NR') {
        if (!$subscriber) {
            try {
                $mailpoet_api->addSubscriber($sub, $lists);
            } catch (\Throwable $th) {
                error_log('[MailPoet Zapier] Failed to create subscriber: ' . $th->getMessage());
            }
        } else {
            try {
                $mailpoet_api->subscribeToLists($subscriber['id'], $lists);
                $mailpoet_api->updateSubscriber($subscriber['id'], [
                    'cf_dealership' => $dealership,
                    'cf_rep'        => $rep,
                ]);
            } catch (\Throwable $th) {
                error_log('[MailPoet Zapier] Failed to update subscriber: ' . $th->getMessage());
            }
        }
    } else {
        if ($subscriber) {
            try {
                $mailpoet_api->unsubscribeFromLists($subscriber['id'], $lists);
            } catch (\Throwable $th) {
                error_log('[MailPoet Zapier] Failed to unsubscribe: ' . $th->getMessage());
            }
        }
    }

    return $user;
}, 10, 1);

/**
 * MailPoet unsubscribe handler: removes visitor from cert list (list 4) via ?amr_unsub=EMAIL.
 */
add_action('template_redirect', function () {
    if (empty($_GET['amr_unsub'])) {
        return;
    }

    $email   = sanitize_email($_GET['amr_unsub']);
    $list_id = 4;

    if (!is_email($email)) {
        wp_die('Invalid email address.');
    }

    if (!class_exists(\MailPoet\API\API::class)) {
        wp_die('MailPoet is not installed.');
    }

    try {
        $mailpoet_api = \MailPoet\API\API::MP('v1');
        $subscriber   = $mailpoet_api->getSubscriber($email);

        if ($subscriber) {
            $mailpoet_api->unsubscribeFromList($subscriber['id'], $list_id);
            wp_die('You have been unsubscribed successfully.', 'Unsubscribed', ['response' => 200]);
        } else {
            wp_die('Email address not found.', 'Not Found', ['response' => 404]);
        }
    } catch (\MailPoet\API\MP\v1\APIException $e) {
        wp_die('Error: ' . esc_html($e->getMessage()));
    }
});
