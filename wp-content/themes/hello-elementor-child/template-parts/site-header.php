<?php
/**
 * Reusable site header: announcement bar + main navigation
 *
 * Usage: get_template_part('template-parts/site-header');
 */
?>

<!-- ANNOUNCEMENT BAR -->
<div class="announcement-bar">
  <div class="announcement-bar-inner">
    <span class="announcement-text">
      <strong>Attention RV Owners:</strong> Win a Free Week on Rainbow Lake!
      <a href="/monthly-drawing/">Click here to enter our monthly drawing.</a>
    </span>
  </div>
</div>

<!-- SITE HEADER / NAV -->
<header class="site-header">
  <div class="site-header-inner">
    <a href="<?php echo esc_url(home_url('/')); ?>" class="site-logo">
      <img src="https://alleganymountainresort.com/wp-content/uploads/2023/02/AMR-logo-300x200.png" alt="<?php bloginfo('name'); ?>">
    </a>

    <button class="nav-toggle" aria-label="Toggle navigation" aria-expanded="false">
      <span class="nav-toggle-bar"></span>
      <span class="nav-toggle-bar"></span>
      <span class="nav-toggle-bar"></span>
    </button>

    <nav class="site-nav" id="site-nav">
      <?php
        wp_nav_menu(array(
          'theme_location' => 'primary',
          'container'      => false,
          'menu_class'     => 'nav-menu',
          'fallback_cb'    => false,
          'depth'          => 2,
        ));
      ?>
      <a href="/landing-camping-pass/" class="nav-cta">Claim Your Camping Pass</a>
    </nav>
  </div>
</header>
