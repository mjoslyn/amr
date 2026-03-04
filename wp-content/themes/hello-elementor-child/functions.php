<?php
require get_stylesheet_directory() . '/inc/advanced-scripts.php';



add_action('after_setup_theme', function () {
  register_nav_menus(array(
    'primary' => 'Primary Navigation',
  ));
});

add_action('wp_enqueue_scripts', function ()
{
  wp_enqueue_style('amr-child-style', get_stylesheet_directory_uri() . '/dist/css/app.css', array('hello-elementor'));
  //wp_enqueue_script('amr-script', get_stylesheet_directory_uri() . '/dist/js/app.js');

  if (is_page_template('landing-camping-pass.php')) {
    wp_enqueue_style('amr-landing-fonts', 'https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;600;700&family=Source+Sans+3:wght@400;600;700;800&display=swap');
    wp_enqueue_style('amr-landing-camping-pass', get_stylesheet_directory_uri() . '/dist/css/landing-camping-pass.css', array('amr-child-style'));
  }

  if (is_page_template('homepage.php')) {
    wp_enqueue_style('amr-landing-fonts', 'https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;600;700&family=Source+Sans+3:wght@400;600;700;800&display=swap');
    wp_enqueue_style('amr-landing-camping-pass', get_stylesheet_directory_uri() . '/dist/css/landing-camping-pass.css', array('amr-child-style'));
    wp_enqueue_style('amr-homepage', get_stylesheet_directory_uri() . '/dist/css/homepage.css', array('amr-landing-camping-pass'));
  }
});



add_action('wp_head', function (){
?>
<!-- Google tag (gtag.js) -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-S98GJ3WT29"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());

  gtag('config', 'G-S98GJ3WT29');
</script>
<!-- VPIXEL --> 
<script type='text/javascript' src='https://pixel.jetmediacorp.com/vpixel.js?ver=1.1.0'></script>

<?php

});



add_action('wp_body_open', function()
{
?>
<script type="text/javascript" src="//tag.brandcdn.com/autoscript/alleghenymountainresort_vfhwuk1rmxfwvek9/Allegheny Mountain Resort.js"></script>
<script>vpixel.piximage('8092');</script>

<?php

});


add_shortcode( 'amr-show-bbb', function ( $atts ) {
	return '<a href="https://www.bbb.org/us/ny/east-otto/profile/campgrounds/allegany-mountain-resort-0041-235969684/#sealclick" target="_blank" rel="nofollow"><img src="https://seal-upstateny.bbb.org/seals/blue-seal-293-61-bbb-235969684.png" style="border: 0;" alt="Allegany Mountain Resort BBB Business Review" /></a>';
} );
