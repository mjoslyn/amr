<?php defined('WPINC') or die ?><?php
  /**
   * MailPoet Unsubscribe Handler
   * Place in your WordPress theme or as a custom page template
   */

  // Ensure WordPress is loaded
  if (!defined('ABSPATH')) {
      require_once($_SERVER['DOCUMENT_ROOT'] . '/wp-load.php');
  }

  $email = isset($_GET['email']) ? sanitize_email($_GET['email']) : '';
  $list_id = 4;

  if (empty($email) || !is_email($email)) {
      wp_die('Invalid email address.');
  }

  // Check if MailPoet is active
  if (!class_exists(\MailPoet\API\API::class)) {
      wp_die('MailPoet is not installed.');
  }

  try {
      $mailpoet_api = \MailPoet\API\API::MP('v1');

      // Get subscriber by email
      $subscriber = $mailpoet_api->getSubscriber($email);

      if ($subscriber) {
          // Unsubscribe from list 4
          $mailpoet_api->unsubscribeFromList($subscriber['id'], $list_id);
          echo 'You have been unsubscribed successfully.';
      } else {
          echo 'Email address not found.';
      }

  } catch (\MailPoet\API\MP\v1\APIException $e) {
      wp_die('Error: ' . esc_html($e->getMessage()));
  }