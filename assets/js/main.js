/*
 * ESSENCE — Minimal JavaScript
 * Only what's necessary, nothing more.
 */

(function() {
  'use strict';

  // ─────────────────────────────────────────────────────────
  // Reading Progress (articles only)
  // ─────────────────────────────────────────────────────────

  const article = document.querySelector('.article__content');

  if (article) {
    const progress = document.createElement('div');
    progress.className = 'reading-progress';
    progress.setAttribute('aria-hidden', 'true');
    document.body.appendChild(progress);

    // Add styles dynamically
    const style = document.createElement('style');
    style.textContent = `
      .reading-progress {
        position: fixed;
        top: 0;
        left: 0;
        width: 0%;
        height: 2px;
        background-color: var(--color-black);
        z-index: 1000;
        transition: width 100ms ease-out;
      }
    `;
    document.head.appendChild(style);

    function updateProgress() {
      const articleRect = article.getBoundingClientRect();
      const articleTop = articleRect.top + window.scrollY;
      const articleHeight = articleRect.height;
      const windowHeight = window.innerHeight;
      const scrollY = window.scrollY;

      // Calculate progress through the article
      const start = articleTop - windowHeight * 0.2;
      const end = articleTop + articleHeight - windowHeight * 0.8;
      const current = scrollY;

      let percentage = ((current - start) / (end - start)) * 100;
      percentage = Math.max(0, Math.min(100, percentage));

      progress.style.width = percentage + '%';
    }

    // Throttle scroll events
    let ticking = false;
    window.addEventListener('scroll', function() {
      if (!ticking) {
        window.requestAnimationFrame(function() {
          updateProgress();
          ticking = false;
        });
        ticking = true;
      }
    }, { passive: true });

    updateProgress();
  }


  // ─────────────────────────────────────────────────────────
  // External Links — Open in new tab
  // ─────────────────────────────────────────────────────────

  document.querySelectorAll('a[href^="http"]').forEach(function(link) {
    if (link.hostname !== window.location.hostname) {
      link.setAttribute('target', '_blank');
      link.setAttribute('rel', 'noopener noreferrer');
    }
  });


  // ─────────────────────────────────────────────────────────
  // Smooth reveal on scroll (subtle)
  // ─────────────────────────────────────────────────────────

  if ('IntersectionObserver' in window) {
    const revealStyle = document.createElement('style');
    revealStyle.textContent = `
      .post-item {
        opacity: 0;
        transform: translateY(8px);
        transition: opacity 400ms ease-out, transform 400ms ease-out;
      }
      .post-item.is-visible {
        opacity: 1;
        transform: translateY(0);
      }
    `;
    document.head.appendChild(revealStyle);

    const observer = new IntersectionObserver(function(entries) {
      entries.forEach(function(entry) {
        if (entry.isIntersecting) {
          entry.target.classList.add('is-visible');
          observer.unobserve(entry.target);
        }
      });
    }, {
      threshold: 0.1,
      rootMargin: '0px 0px -50px 0px'
    });

    document.querySelectorAll('.post-item').forEach(function(item, index) {
      item.style.transitionDelay = (index * 50) + 'ms';
      observer.observe(item);
    });
  }

})();
