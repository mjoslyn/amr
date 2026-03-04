<?php
/**
 * Template Name: Homepage
 */
?>
<!DOCTYPE html>
<html <?php language_attributes(); ?>>
<head>
<meta charset="<?php bloginfo('charset'); ?>">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<?php wp_head(); ?>
</head>
<body <?php body_class('amr-homepage'); ?>>
<?php wp_body_open(); ?>

<?php get_template_part('template-parts/site-header'); ?>

<!-- HERO (split layout) -->
<section class="hp-hero">
  <div class="hp-hero-inner">
    <div class="hp-hero-content">
      <span class="section-label">Welcome to Rainbow Lake</span>
      <h1>Western New York's Premier RV Campground &amp; Family Resort</h1>
      <p>310 private acres, a 70-acre lake, three pools, and more amenities than you can fit into a long weekend. This is camping done differently.</p>
      <div class="hp-hero-actions">
        <a href="/landing-camping-pass/" class="hero-cta">Claim Your Camping Pass</a>
      </div>
    </div>
    <div class="hp-hero-media">
      <img src="https://alleganymountainresort.com/wp-content/uploads/2022/12/Hero-c-Pools-Dock-Lake-2023-1.jpg" alt="Aerial view of Rainbow Lake pools, dock, and lake at Allegany Mountain Resort">
    </div>
  </div>
</section>

<!-- STATS BAR -->
<section class="stats-bar">
  <div class="stats-bar-inner">
    <div class="stat-item">
      <span class="stat-number">50+</span>
      <span class="stat-label">Years of Family Camping</span>
    </div>
    <div class="stat-divider"></div>
    <div class="stat-item">
      <span class="stat-number">310</span>
      <span class="stat-label">Private Acres</span>
    </div>
    <div class="stat-divider"></div>
    <div class="stat-item">
      <span class="stat-number">70</span>
      <span class="stat-label">Acre Private Lake</span>
    </div>
    <div class="stat-divider"></div>
    <div class="stat-item">
      <span class="stat-number">3</span>
      <span class="stat-label">Swimming Pools</span>
    </div>
  </div>
</section>

<!-- FEATURES (alternating zigzag) -->
<section class="hp-features" id="explore">
  <div class="hp-feature reveal">
    <div class="hp-feature-image">
      <img src="https://alleganymountainresort.com/wp-content/uploads/2023/11/299532098_10158616345076771_7526863914145550404_n-1536x1152.jpg.avif" alt="Kayaking on Rainbow Lake">
    </div>
    <div class="hp-feature-content">
      <span class="section-label">The Lake</span>
      <h2>Your Own 70-Acre Private Lake</h2>
      <p>Rainbow Lake is the heart of the resort. Paddle out in a kayak at sunrise, cast a line from the dock, or float the afternoon away on a pedal boat. The lake is exclusively for resort guests -- no public access, no crowds, just calm water and open sky.</p>
      <ul class="hp-feature-list">
        <li>Kayaks and canoes included</li>
        <li>Pedal boat rentals</li>
        <li>Catch-and-release fishing</li>
        <li>Waterfront picnic areas</li>
      </ul>
    </div>
  </div>

  <div class="hp-feature reverse reveal">
    <div class="hp-feature-image">
      <img src="https://alleganymountainresort.com/wp-content/uploads/2023/08/allegany-mountain-resort-outdoor-pools-400x400.jpg" alt="Outdoor swimming pools">
    </div>
    <div class="hp-feature-content">
      <span class="section-label">Pools &amp; Recreation</span>
      <h2>Three Pools. Endless Summer Days.</h2>
      <p>Cool off in our two outdoor pools or swim year-round in the heated indoor pool and spa. The pool deck is the social hub of the resort, with lounge chairs, a poolside cafe, and plenty of room to spread out.</p>
      <ul class="hp-feature-list">
        <li>2 outdoor pools with sun deck</li>
        <li>Heated indoor pool and spa</li>
        <li>Poolside cafe with food and drinks</li>
        <li>Open to all guests and members</li>
      </ul>
    </div>
  </div>

  <div class="hp-feature reveal">
    <div class="hp-feature-image">
      <img src="https://alleganymountainresort.com/wp-content/uploads/2023/08/allegany-mountain-resort-bounce-house-activity-400x400.jpg" alt="Family activities and events">
    </div>
    <div class="hp-feature-content">
      <span class="section-label">Family Activities</span>
      <h2>Something for Every Age</h2>
      <p>From mini golf and shuffleboard to organized craft nights and holiday-themed weekends, there's never a dull moment at Rainbow Lake. Kids make summer-long friendships while parents relax knowing everyone's having a great time.</p>
      <ul class="hp-feature-list">
        <li>Mini golf course</li>
        <li>Organized weekend events</li>
        <li>Arts, crafts, and game nights</li>
        <li>Dog park for four-legged family</li>
      </ul>
    </div>
  </div>
</section>

<!-- AMENITIES -->
<section class="amenities">
  <div class="reveal">
    <span class="section-label">All Included</span>
    <h2>Everything Your Family Needs</h2>
    <p class="section-intro">Every amenity is included with your stay. No add-ons, no surprise fees.</p>
  </div>
  <div class="amenity-cards reveal">
    <div class="amenity-card">
      <img src="https://alleganymountainresort.com/wp-content/uploads/2023/08/allegany-mountain-resort-outdoor-pools-400x400.jpg" alt="Swimming pools">
      <span>3 Swimming Pools</span>
    </div>
    <div class="amenity-card">
      <img src="https://alleganymountainresort.com/wp-content/uploads/2023/11/299532098_10158616345076771_7526863914145550404_n-1536x1152.jpg.avif" alt="Kayaks and canoes on Rainbow Lake">
      <span>Kayaks &amp; Canoes</span>
    </div>
    <div class="amenity-card">
      <img src="https://alleganymountainresort.com/wp-content/uploads/2023/08/allegany-mountain-resort-kids-fishing-on-rainbow-lake-with-adult-400x400.jpg" alt="Pedal boats on Rainbow Lake">
      <span>Pedal Boats</span>
    </div>
    <div class="amenity-card">
      <img src="https://alleganymountainresort.com/wp-content/uploads/2023/11/mini-golf-allegany-mountain-resort-400x400.jpg" alt="Mini golf course">
      <span>Mini Golf</span>
    </div>
    <div class="amenity-card">
      <img src="https://alleganymountainresort.com/wp-content/uploads/2023/08/allegany-mountain-resort-kids-fishing-on-rainbow-lake-with-adult-400x400.jpg" alt="Fishing on Rainbow Lake">
      <span>Fishing</span>
    </div>
    <div class="amenity-card">
      <img src="https://alleganymountainresort.com/wp-content/uploads/2023/08/allegany-mountain-resort-bounce-house-activity-400x400.jpg" alt="Organized events">
      <span>Organized Events</span>
    </div>
    <div class="amenity-card">
      <img src="https://alleganymountainresort.com/wp-content/uploads/2023/11/Jeff-Poolside-Cafepct_-400x400.png" alt="Poolside cafe">
      <span>Poolside Cafe</span>
    </div>
    <div class="amenity-card">
      <img src="https://alleganymountainresort.com/wp-content/uploads/2023/11/Jeff-Playing-With-Dogpct_-400x400.png" alt="Dog park">
      <span>Dog Park</span>
    </div>
  </div>
</section>

<!-- YOUR AVERAGE DAY -->
<section class="avg-day">
  <div class="reveal">
    <span class="section-label">A Day at the Resort</span>
    <h2>Your Average Day at Rainbow Lake</h2>
    <p class="section-intro">When's the last time your whole family did something together that didn't involve a screen? Picture this instead:</p>
  </div>
  <div class="avg-day-timeline reveal">
    <div class="avg-day-item">
      <span class="avg-day-badge">Morning</span>
      <p>Wake up to birds instead of alarms. Coffee by the campfire while the kids sleep in.</p>
    </div>
    <div class="avg-day-item">
      <span class="avg-day-badge">Afternoon</span>
      <p>Everyone's in the pool. Or on kayaks. Or racing through mini golf while you pretend to let them win.</p>
    </div>
    <div class="avg-day-item">
      <span class="avg-day-badge">Evening</span>
      <p>S'mores. Ghost stories. Stars you forgot existed. Kids so tired they pass out by 9.</p>
    </div>
    <div class="avg-day-item">
      <span class="avg-day-badge">Next AM</span>
      <p><em>"Can we stay longer?"</em></p>
    </div>
  </div>
  <div class="avg-day-footer reveal">
    <p>That's a typical day at Allegany Mountain Resort. And your first visit? <strong>It starts at just $10/day.</strong></p>
    <a href="/landing-camping-pass/" class="hero-cta">Claim Your Camping Pass</a>
  </div>
</section>

<!-- HERITAGE -->
<section class="heritage">
  <div class="heritage-inner reveal">
    <div class="heritage-content">
      <span class="section-label">Our Story</span>
      <h2>More Than 50 Years of Family Tradition</h2>
      <p>Allegany Mountain Resort has been welcoming families to the hills of Western New York since the early 1970s. What started as a small campground on the shores of Rainbow Lake has grown into a 310-acre gated resort with world-class amenities -- but the spirit hasn't changed. This is still a place where kids ride bikes until dark, where families gather around campfires, and where summer memories are made that last a lifetime.</p>
      <p>We're a family membership park, not a timeshare. No high-pressure sales, no gimmicks. Just a beautiful place for families who love the outdoors.</p>
    </div>
    <div class="heritage-badge">
      <span class="heritage-years">50+</span>
      <span class="heritage-years-label">Years of<br>Family Camping</span>
    </div>
  </div>
</section>

<!-- TESTIMONIALS -->
<section class="testimonials">
  <div class="reveal">
    <span class="section-label">Member Stories</span>
    <h2>Why Families Choose Rainbow Lake</h2>
  </div>
  <div class="testimonials-grid reveal">
    <div class="testimonial-card">
      <div class="testimonial-stars">&#9733;&#9733;&#9733;&#9733;&#9733;</div>
      <blockquote>
        <p>"We came for a weekend preview and never looked back. The lake, the pools, the campfires -- our kids already ask when we're going back before we've even left. This is our family's happy place."</p>
      </blockquote>
      <div class="testimonial-footer">
        <div class="testimonial-author">The Martinez Family</div>
        <div class="testimonial-detail">Members since 2019</div>
      </div>
    </div>
    <div class="testimonial-card featured">
      <div class="testimonial-stars">&#9733;&#9733;&#9733;&#9733;&#9733;</div>
      <blockquote>
        <p>"We've camped all over the Northeast and nothing comes close. Three pools, mini golf, kayaking, a cafe -- and it's all included. The grounds are immaculate and the staff treats you like family. Worth every penny."</p>
      </blockquote>
      <div class="testimonial-footer">
        <div class="testimonial-author">Sarah &amp; Tom W.</div>
        <div class="testimonial-detail">Members since 2017</div>
      </div>
    </div>
    <div class="testimonial-card">
      <div class="testimonial-stars">&#9733;&#9733;&#9733;&#9733;&#9733;</div>
      <blockquote>
        <p>"Our kids have made lifelong friends here. The organized activities keep them busy all day, and in the evening we all come together around the fire. It's the only vacation where we all actually unplug."</p>
      </blockquote>
      <div class="testimonial-footer">
        <div class="testimonial-author">The Johnson Family</div>
        <div class="testimonial-detail">Members since 2021</div>
      </div>
    </div>
  </div>
</section>

<!-- CTA BANNER (split layout) -->
<section class="hp-cta-banner">
  <div class="hp-cta-inner">
    <div class="hp-cta-image">
      <img src="https://alleganymountainresort.com/wp-content/uploads/2023/08/allegany-mountain-resort-indoor-pool-and-spa-400x400.jpg" alt="Indoor pool and spa at Allegany Mountain Resort">
    </div>
    <div class="hp-cta-content reveal">
      <h2>Ready to See It for Yourself?</h2>
      <p>Schedule a personal park preview and tour the resort with one of our guides. Afterward, camp for up to 4 days at just $10/day with full access to every amenity.</p>
      <div class="hp-cta-perks">
        <span><span class="check">&#10003;</span> No obligation</span>
        <span><span class="check">&#10003;</span> Not a timeshare</span>
        <span><span class="check">&#10003;</span> Full resort access</span>
      </div>
      <a href="/landing-camping-pass/" class="hero-cta">Claim Your Camping Pass</a>
    </div>
  </div>
</section>

<?php get_template_part('template-parts/site-footer'); ?>

<script>
  // Mobile nav toggle
  document.querySelector('.nav-toggle').addEventListener('click', function() {
    var nav = document.getElementById('site-nav');
    var expanded = this.getAttribute('aria-expanded') === 'true';
    this.setAttribute('aria-expanded', !expanded);
    nav.classList.toggle('open');
    this.classList.toggle('open');
  });

  // Mobile dropdown toggle -- tap parent items to expand submenus
  document.querySelectorAll('.nav-menu > .menu-item-has-children > a').forEach(function(link) {
    link.addEventListener('click', function(e) {
      if (window.innerWidth <= 900) {
        e.preventDefault();
        var parent = this.parentElement;
        var wasOpen = parent.classList.contains('mobile-submenu-open');
        // Close all other open submenus
        document.querySelectorAll('.menu-item-has-children.mobile-submenu-open').forEach(function(item) {
          item.classList.remove('mobile-submenu-open');
        });
        if (!wasOpen) parent.classList.add('mobile-submenu-open');
      }
    });
  });

  // Reveal on scroll
  var observer = new IntersectionObserver(function(entries) {
    entries.forEach(function(e) { if (e.isIntersecting) e.target.classList.add('visible'); });
  }, { threshold: 0.12 });
  document.querySelectorAll('.reveal').forEach(function(el) { observer.observe(el); });

  // Smooth scroll for anchor links
  document.querySelectorAll('a[href^="#"]').forEach(function(link) {
    link.addEventListener('click', function(e) {
      var target = document.querySelector(this.getAttribute('href'));
      if (target) {
        e.preventDefault();
        target.scrollIntoView({ behavior: 'smooth', block: 'start' });
      }
    });
  });
</script>

<?php wp_footer(); ?>
</body>
</html>
