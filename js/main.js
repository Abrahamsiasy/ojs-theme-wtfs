/**
 * @file plugins/themes/custom/js/main.js
 *
 * Copyright (c) 2014-2021 Simon Fraser University
 * Copyright (c) 2000-2021 John Willinsky
 * Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
 *
 * @brief JAVS theme JavaScript — nav dropdowns, sticky header shrink, mobile toggle.
 */
(function($) {

	// ── Sticky navbar shrink (WTSF reference: .navbar.scrolled) ─────────────────
	var $navbar = $('.javs_navbar');
	if ($navbar.length) {
		function updateScrolled() {
			$navbar.toggleClass('scrolled', window.scrollY > 20);
		}
		window.addEventListener('scroll', updateScrolled, { passive: true });
		updateScrolled();
	}

	// ── Dropdown navigation (primary nav + topbar user menu) ─────────────────
	var $topbarUserNav = $('.javs_topbar_links #navigationUser');
	var $primaryNavMenu = $('#navigationPrimary');

	function markTopbarUserParents() {
		if (!$topbarUserNav.length) {
			return;
		}
		$topbarUserNav.children('li').each(function() {
			var $item = $(this);
			var hasMenu = $item.children('ul').length > 0;
			$item.toggleClass('javs_topbar_user_parent', hasMenu);
		});
	}

	function closeTopbarUserMenu() {
		$topbarUserNav.find('li').removeClass('javs_topbar_user_open');
	}

	function initTopbarUserDropdowns(isDesktop) {
		var $userSubmenus = $topbarUserNav.children('li').children('ul');

		$userSubmenus.each(function(index) {
			var $submenu = $(this);
			var $toggle = $submenu.siblings('a').first();

			if (!$toggle.data('javsOriginalHref')) {
				$toggle.data('javsOriginalHref', $toggle.attr('href'));
			}

			if (isDesktop) {
				$submenu
					.addClass('dropdown-menu')
					.attr('aria-labelledby', 'pkpUserDropdown' + index);
				$toggle
					.attr('data-toggle', 'dropdown')
					.attr('aria-haspopup', true)
					.attr('aria-expanded', false)
					.attr('id', 'pkpUserDropdown' + index)
					.attr('href', '#');
			} else {
				$submenu
					.removeClass('dropdown-menu show')
					.removeAttr('aria-labelledby');
				$toggle
					.removeAttr('data-toggle')
					.removeAttr('aria-haspopup')
					.removeAttr('aria-expanded')
					.removeAttr('id')
					.attr('href', '#');
			}
		});

		if (isDesktop && typeof $.fn.dropdown !== 'undefined') {
			$topbarUserNav.find('[data-toggle="dropdown"]').dropdown();
		} else if (typeof $.fn.dropdown !== 'undefined') {
			$topbarUserNav.find('[data-toggle="dropdown"]').dropdown('dispose');
		}
	}

	function initPrimaryDropdowns(isDesktop) {
		var $submenus = $('ul', $primaryNavMenu);

		$submenus.each(function(i) {
			var $submenu = $(this);
			var $toggle = $submenu.siblings('a');

			if (isDesktop) {
				var id = 'pkpDropdown' + i;
				$submenu
					.addClass('dropdown-menu')
					.attr('aria-labelledby', id);
				$toggle
					.attr('data-toggle', 'dropdown')
					.attr('aria-haspopup', true)
					.attr('aria-expanded', false)
					.attr('id', id)
					.attr('href', '#');
			} else {
				$submenu
					.removeClass('dropdown-menu show')
					.removeAttr('aria-labelledby');
				$toggle
					.removeAttr('data-toggle')
					.removeAttr('aria-haspopup')
					.removeAttr('aria-expanded')
					.removeAttr('id')
					.attr('href', '#');
			}
		});

		if (isDesktop && typeof $.fn.dropdown !== 'undefined') {
			$primaryNavMenu.find('[data-toggle="dropdown"]').dropdown();
		} else if (typeof $.fn.dropdown !== 'undefined') {
			$primaryNavMenu.find('[data-toggle="dropdown"]').dropdown('dispose');
		}
	}

	function toggleDropdowns() {
		var isDesktop = window.innerWidth >= 981;
		markTopbarUserParents();
		initPrimaryDropdowns(isDesktop);
		initTopbarUserDropdowns(isDesktop);
		if (!isDesktop) {
			closeTopbarUserMenu();
		}
	}

	markTopbarUserParents();

	$topbarUserNav.on('click', '> li.javs_topbar_user_parent > a', function(e) {
		if (window.innerWidth >= 981) {
			return;
		}
		var $item = $(this).parent('li');
		if (!$item.children('ul').length) {
			return;
		}
		e.preventDefault();
		e.stopPropagation();
		var isOpen = $item.hasClass('javs_topbar_user_open');
		closeTopbarUserMenu();
		if (!isOpen) {
			$item.addClass('javs_topbar_user_open');
		}
	});

	$(document).on('click', function(e) {
		if (!$topbarUserNav.length) {
			return;
		}
		if (!$topbarUserNav.is(e.target) && !$topbarUserNav.has(e.target).length) {
			closeTopbarUserMenu();
		}
	});

	if (typeof $.fn.dropdown !== 'undefined') {
		window.addEventListener('resize', toggleDropdowns);
		$().ready(toggleDropdowns);
	} else {
		window.addEventListener('resize', function() {
			markTopbarUserParents();
			if (window.innerWidth < 981) {
				closeTopbarUserMenu();
			}
		});
		$().ready(markTopbarUserParents);
	}

	// ── Mobile nav toggle (WTSF: .nav-links.open) ─────────────────────────────
	var $navToggle = $('.pkp_site_nav_toggle');
	var $navMenu = $('.pkp_site_nav_menu');
	var $navLinks = $('#navigationPrimary.javs_nav_links');
	var $primaryNav = $('#navigationPrimary.javs_nav_links');

	function resetMobileSubmenus() {
		$primaryNav.find('li').removeClass('javs_submenu_open');
	}

	function markSubmenuParents() {
		$primaryNav.find('li').each(function() {
			var $li = $(this);
			$li.toggleClass('javs_has_submenu', $li.children('ul').length > 0);
		});
	}

	function closeMobileNav() {
		$navMenu.removeClass('pkp_site_nav_menu--isOpen');
		$navLinks.removeClass('javs_nav_open');
		$navToggle.removeClass('pkp_site_nav_toggle--transform').attr('aria-expanded', 'false');
		resetMobileSubmenus();
	}

	function openMobileNav() {
		$navMenu.addClass('pkp_site_nav_menu--isOpen');
		$navLinks.addClass('javs_nav_open');
		$navToggle.addClass('pkp_site_nav_toggle--transform').attr('aria-expanded', 'true');
	}

	$navToggle.on('click', function(e) {
		e.preventDefault();
		e.stopPropagation();
		if ($navMenu.hasClass('pkp_site_nav_menu--isOpen')) {
			closeMobileNav();
		} else {
			openMobileNav();
		}
	});

	$(document).on('click', function(e) {
		if (window.innerWidth >= 981) {
			return;
		}
		if (!$navToggle.is(e.target) && !$navToggle.has(e.target).length &&
			!$navMenu.is(e.target) && !$navMenu.has(e.target).length) {
			closeMobileNav();
		}
	});

	$(window).on('resize', function() {
		if (window.innerWidth >= 981) {
			closeMobileNav();
			resetMobileSubmenus();
		}
	});

	// ── Mobile submenu accordion (tap to expand; hidden by default) ───────────
	markSubmenuParents();

	$primaryNav.on('click', 'li.javs_has_submenu > a', function(e) {
		if (window.innerWidth >= 981) {
			return;
		}
		var $link = $(this);
		var $item = $link.parent('li');
		if (!$item.children('ul').length) {
			return;
		}
		e.preventDefault();
		e.stopPropagation();
		var isOpen = $item.hasClass('javs_submenu_open');
		$item.siblings('.javs_submenu_open').removeClass('javs_submenu_open');
		$item.toggleClass('javs_submenu_open', !isOpen);
	});

	// Re-mark when dropdown shim mutates the menu (resize / ready)
	$(window).on('resize', markSubmenuParents);
	$().ready(markSubmenuParents);

	// Mark current page in primary nav; highlight parent when a submenu item matches
	function normalizeNavPath(path) {
		if (!path) {
			return '/';
		}
		path = path.replace(/\/+$/, '');
		return path || '/';
	}

	function markActiveNavLinks() {
		var currentPath = normalizeNavPath(window.location.pathname);
		var $nav = $('#navigationPrimary.javs_nav_links');
		var $bestLink = null;
		var bestLength = -1;
		var exactMatch = false;

		$nav.find('a').removeClass('active is_active');
		$nav.find('li').removeClass('active javs_nav_ancestor');

		$nav.find('a').each(function() {
			var href = $(this).attr('href');
			if (!href || href === '#') {
				return;
			}
			try {
				var linkPath = normalizeNavPath(new URL(href, window.location.origin).pathname);

				if (linkPath === currentPath) {
					$bestLink = $(this);
					bestLength = linkPath.length;
					exactMatch = true;
					return false;
				}

				// Section pages (e.g. /about/submissions) still activate /about parent
				if (!exactMatch && currentPath.indexOf(linkPath + '/') === 0 && linkPath.length > bestLength) {
					$bestLink = $(this);
					bestLength = linkPath.length;
				}
			} catch (err) {
				// ignore malformed URLs
			}
		});

		if (!$bestLink || !$bestLink.length) {
			return;
		}

		$bestLink.addClass('active');

		// Parent items (e.g. "About") when a child (e.g. "Contact") is current
		$bestLink.parents('#navigationPrimary.javs_nav_links li').each(function() {
			var $item = $(this);
			var $parentLink = $item.children('a').first();

			if ($parentLink.length && !$parentLink.is($bestLink)) {
				$parentLink.addClass('active');
			}
			$item.addClass('javs_nav_ancestor');
		});

		// Mobile: keep ancestor submenu open so the active child is visible
		if (window.innerWidth < 981) {
			$nav.find('li.javs_nav_ancestor.javs_has_submenu').addClass('javs_submenu_open');
		}
	}

	markActiveNavLinks();
	$(window).on('resize', markActiveNavLinks);

	// ── Issue cover: fall back to placeholder if cover image fails to load ─────
	$('.javs_home_issue_cover--photo .javs_home_issue_cover__img').each(function() {
		var $img = $(this);
		$img.on('error', function() {
			$img.closest('.javs_home_issue_cover')
				.removeClass('javs_home_issue_cover--photo')
				.addClass('javs_home_issue_cover--placeholder');
			$img.remove();
		});
	});

	// ── Chart.js options for UsageStats plugin ────────────────────────────────
	document.addEventListener('usageStatsChartOptions.pkp', function(e) {
		// Use theme base color for charts — falls back to JAVS green
		var accent = getComputedStyle(document.documentElement)
			.getPropertyValue('--pkp-bg-base').trim() || '#6d2d3d';
		e.chartOptions.elements.line.backgroundColor = accent;
		e.chartOptions.elements.bar.backgroundColor  = accent;
	});

	// ── Registration consent checkboxes ──────────────────────────────────────
	var $contextOptinGroup = $('#contextOptinGroup');
	if ($contextOptinGroup.length) {
		var $roles = $contextOptinGroup.find('.roles :checkbox');
		$roles.change(function() {
			var $thisRoles = $(this).closest('.roles');
			if ($thisRoles.find(':checked').length) {
				$thisRoles.siblings('.context_privacy').addClass('context_privacy_visible');
			} else {
				$thisRoles.siblings('.context_privacy').removeClass('context_privacy_visible');
			}
		});
	}

	// ── Reviewer interests toggle ─────────────────────────────────────────────
	function reviewerInterestsToggle() {
		var is_checked = false;
		$('#reviewerOptinGroup').find('input').each(function() {
			if ($(this).is(':checked')) {
				is_checked = true;
				return false;
			}
		});
		if (is_checked) {
			$('#reviewerInterests').addClass('is_visible');
		} else {
			$('#reviewerInterests').removeClass('is_visible');
		}
	}

	reviewerInterestsToggle();
	$('#reviewerOptinGroup input').on('click', reviewerInterestsToggle);

	// ── Swiper carousel ───────────────────────────────────────────────────────
	var swiper = new Swiper('.swiper', {
		a11y: {
			prevSlideMessage: pkpCustomThemeI18N.prevSlide,
			nextSlideMessage: pkpCustomThemeI18N.nextSlide,
		},
		autoHeight: true,
		navigation: {
			nextEl: '.swiper-button-next',
			prevEl: '.swiper-button-prev',
		},
		pagination: {
			el: '.swiper-pagination',
			type: 'bullets',
		}
	});

	// ── Fade-up on scroll (optional progressive enhancement) ─────────────────
	if ('IntersectionObserver' in window) {
		var fadeEls = document.querySelectorAll('.fade-up');
		if (fadeEls.length) {
			var fadeObserver = new IntersectionObserver(function(entries) {
				entries.forEach(function(entry) {
					if (entry.isIntersecting) {
						entry.target.style.opacity = '1';
						entry.target.style.transform = 'translateY(0)';
						fadeObserver.unobserve(entry.target);
					}
				});
			}, { threshold: 0.1 });

			fadeEls.forEach(function(el) {
				el.style.opacity = '0';
				el.style.transform = 'translateY(20px)';
				el.style.transition = 'opacity 600ms ease, transform 600ms ease';
				fadeObserver.observe(el);
			});
		}
	}

	// ── Copy DOI (article header) ───────────────────────────────────────────
	$(document).on('click', '[data-javs-copy-doi]', function() {
		var doi = $(this).attr('data-javs-copy-doi');
		if (!doi) {
			return;
		}

		if (navigator.clipboard && navigator.clipboard.writeText) {
			navigator.clipboard.writeText(doi);
		} else {
			var $temp = $('<textarea>').val(doi).appendTo('body').select();
			document.execCommand('copy');
			$temp.remove();
		}
	});

})(jQuery);
