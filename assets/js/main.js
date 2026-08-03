/* Joaquina Salgado — portfolio interactions */
(function () {
	"use strict";

	/* ---- Mobile nav drawer ---- */
	var toggle = document.querySelector(".nav-toggle");
	var nav = document.querySelector(".nav-card");
	var backdrop = document.querySelector(".nav-backdrop");

	function closeNav() {
		if (nav) nav.classList.remove("open");
		if (backdrop) backdrop.classList.remove("open");
	}
	function openNav() {
		if (nav) nav.classList.add("open");
		if (backdrop) backdrop.classList.add("open");
	}
	if (toggle) {
		toggle.addEventListener("click", function () {
			if (nav && nav.classList.contains("open")) closeNav();
			else openNav();
		});
	}
	if (backdrop) backdrop.addEventListener("click", closeNav);
	// close drawer when a nav link is followed (same-page anchors / navigation)
	if (nav) {
		nav.addEventListener("click", function (e) {
			if (e.target.closest("a")) closeNav();
		});
	}

	/* ---- Image lightbox for .zoomable images ---- */
	var lb = document.createElement("div");
	lb.className = "lightbox";
	var lbImg = document.createElement("img");
	lb.appendChild(lbImg);
	document.body.appendChild(lb);

	function openLightbox(src, alt) {
		lbImg.src = src;
		lbImg.alt = alt || "";
		lb.classList.add("open");
		document.body.style.overflow = "hidden";
	}
	function closeLightbox() {
		lb.classList.remove("open");
		document.body.style.overflow = "";
		lbImg.src = "";
	}
	lb.addEventListener("click", closeLightbox);
	document.addEventListener("keydown", function (e) {
		if (e.key === "Escape") closeLightbox();
	});

	document.addEventListener(
		"click",
		function (e) {
			var img = e.target.closest("img.zoomable, .media-item.zoomable");
			if (img && img.tagName === "IMG") {
				e.preventDefault();
				openLightbox(img.currentSrc || img.src, img.alt);
			}
		},
		false
	);

	/* ---- Home: hover-triggered Hero <-> Projects reveal ----
	   Hovering the top 30% of the viewport smoothly scrolls up to reveal the
	   full-screen hero; hovering the bottom 30% scrolls down to the projects. */
	(function () {
		if (!document.body.classList.contains("home")) return;
		var hero = document.querySelector(".hero");
		var projects = document.querySelector(".projects");
		if (!hero || !projects) return;
		// hover-capable pointers only (skip touch / coarse)
		if (window.matchMedia && !window.matchMedia("(hover: hover)").matches) return;

		var TOP = 0.10; // reveal hero when pointer is in the top 10%
		var BOT = 0.90; // reveal projects when pointer is in the bottom 10%
		// Slow, smooth transition — ~2x a typical native smooth-scroll (doubled duration).
		var DURATION = 800;
		var reduce =
			window.matchMedia &&
			window.matchMedia("(prefers-reduced-motion: reduce)").matches;
		var locked = false;
		var animId = null;

		function atHero() {
			return window.scrollY < window.innerHeight * 0.5;
		}
		function easeInOutCubic(t) {
			return t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2;
		}
		function animateScrollTo(target) {
			if (reduce) { window.scrollTo(0, target); return; }
			if (animId) cancelAnimationFrame(animId);
			var start = window.scrollY;
			var dist = target - start;
			var t0 = null;
			function step(ts) {
				if (t0 === null) t0 = ts;
				var p = Math.min((ts - t0) / DURATION, 1);
				window.scrollTo(0, start + dist * easeInOutCubic(p));
				if (p < 1) animId = requestAnimationFrame(step);
			}
			animId = requestAnimationFrame(step);
		}
		function go(target) {
			locked = true;
			animateScrollTo(target);
			setTimeout(function () { locked = false; }, DURATION + 150);
		}

		window.addEventListener(
			"mousemove",
			function (e) {
				if (locked) return;
				if (window.innerWidth <= 680) return; // single-column flow on mobile
				var frac = e.clientY / window.innerHeight;
				if (frac <= TOP) {
					if (!atHero()) go(0); // reveal hero
				} else if (frac >= BOT) {
					if (atHero()) go(projects.offsetTop); // reveal projects
				}
			},
			{ passive: true }
		);
	})();

	/* ---- Mouse-reactive metallic border ----
	   Sets --active / --mx / --my / --start on each card & button so its
	   metallic gradient border lights up and a bright spotlight follows the
	   pointer. (Custom props are read by the ::before/::after border layers.) */
	(function () {
		var cards = Array.prototype.slice.call(document.querySelectorAll(".proj-card, .nav-proj-card, .metal-link-card"));
		var btns = Array.prototype.slice.call(document.querySelectorAll(".nav-toggle, .metal-btn"));
		var all = cards.concat(btns);
		if (!all.length) return;
		if (window.matchMedia && !window.matchMedia("(hover: hover)").matches) return;

		var entries = all.map(function (el) {
			return {
				el: el,
				isCard: el.classList.contains("proj-card") || el.classList.contains("nav-proj-card") || el.classList.contains("metal-link-card"),
				current: 0
			};
		});

		function moveOne(en, mx, my) {
			var r = en.el.getBoundingClientRect();
			if (r.width === 0) return;
			var cx = r.left + r.width / 2;
			var cy = r.top + r.height / 2;
			var inside = mx >= r.left && mx <= r.right && my >= r.top && my <= r.bottom;

			if (en.isCard) {
				en.el.style.setProperty("--active", inside ? "1" : "0");
				if (inside) {
					en.el.style.setProperty("--mx", (((mx - r.left) / r.width) * 100).toFixed(1) + "%");
					en.el.style.setProperty("--my", (((my - r.top) / r.height) * 100).toFixed(1) + "%");
				}
			}

			// rotate the metallic conic toward the pointer when it's over/near the element
			var near = mx > r.left - 60 && mx < r.right + 60 && my > r.top - 60 && my < r.bottom + 60;
			if (!near) return;
			var target = (180 * Math.atan2(my - cy, mx - cx)) / Math.PI + 90;
			var diff = ((target - en.current + 180) % 360) - 180;
			en.current += diff;
			en.el.style.setProperty("--start", String(en.current));
		}

		/* cylindrical "wheel/drum" deformation for the sidebar card list —
		   cards recede (tilt back + push into depth) the farther their centre is
		   from the middle of the visible sidebar; the focused card pops forward. */
		var navCard = document.querySelector(".nav-card");
		var sidebarCards = Array.prototype.slice.call(document.querySelectorAll(".nav-proj-card"));
		function updateWheel() {
			if (!navCard || !sidebarCards.length) return;
			if (window.innerWidth <= 980) {
				for (var i = 0; i < sidebarCards.length; i++) sidebarCards[i].style.transform = "";
				return;
			}
			var nr = navCard.getBoundingClientRect();
			var center = nr.top + nr.height / 2;
			var half = nr.height / 2 || 1;
			for (var j = 0; j < sidebarCards.length; j++) {
				var el = sidebarCards[j];
				if (el.classList.contains("active") || (el.matches && el.matches(":hover"))) {
					el.style.transform = "rotateX(0deg) translateZ(12px) scale(1)"; // focused card forward
					continue;
				}
				var r = el.getBoundingClientRect();
				var d = (r.top + r.height / 2 - center) / half;
				if (d < -1) d = -1; else if (d > 1) d = 1;
				var ad = d < 0 ? -d : d;
				var rx = (-d * 14).toFixed(2);
				var tz = (-ad * 50).toFixed(1);
				var sc = (1 - ad * 0.05).toFixed(3);
				el.style.transform = "rotateX(" + rx + "deg) translateZ(" + tz + "px) scale(" + sc + ")";
			}
		}

		var mx = 0, my = 0, raf = 0;
		function flush() {
			raf = 0;
			for (var i = 0; i < entries.length; i++) moveOne(entries[i], mx, my);
			updateWheel();
		}
		function schedule() { if (!raf) raf = requestAnimationFrame(flush); }

		document.addEventListener(
			"pointermove",
			function (e) { mx = e.clientX; my = e.clientY; schedule(); },
			{ passive: true }
		);
		window.addEventListener("scroll", schedule, { passive: true });
		window.addEventListener("resize", schedule, { passive: true });
		window.addEventListener("load", schedule);
		var scrollers = document.querySelectorAll(".proj-col, .nav-card");
		for (var i = 0; i < scrollers.length; i++) {
			scrollers[i].addEventListener("scroll", schedule, { passive: true });
		}
		schedule(); // initial paint (wheel + states)
	})();
})();

/* =========================================================================
   One More Sim hero — heat-reveal canvas (parameters kept exactly as given)
   ========================================================================= */
function buildHeatReveal(canvasSel, containerSel, opts) {
	opts = opts || {};
	var canvas = document.querySelector(canvasSel);
	var host = document.querySelector(containerSel);
	if (!canvas || !host) return;
	var ctx = canvas.getContext('2d');

	var CELL = opts.cell || 16;            // tamaño de cada celda de la grilla (px)
	var RADIUS = opts.radius || 1.7;       // alcance del kernel en cruz
	var HALF_LIFE = opts.halfLife || 2200; // ms para que el calor caiga a la mitad
	var IMPULSE = opts.impulse || 0.55;    // fuerza del pincel
	var MAX_A = opts.maxAlpha || 0.96;     // opacidad máx. del agujero (cuánto devela)
	var TRAIL_BOOST = 1.7;                 // el trail pinta más que el punto suelto
	var DIFFUSE = 0.07;                    // difusión a vecinos (suaviza los bloques)
	var EASE = 0.14;                       // lag del cursor (0-1); menos = más arrastre

	// respeto de "reduce motion": queda todo blanco (imagen oculta)
	if (matchMedia('(prefers-reduced-motion: reduce)').matches) {
		var r0 = host.getBoundingClientRect();
		canvas.width = Math.max(1, Math.round(r0.width));
		canvas.height = Math.max(1, Math.round(r0.height));
		ctx.fillStyle = '#fff';
		ctx.fillRect(0, 0, canvas.width, canvas.height);
		return;
	}

	var cols = 0, rows = 0, heat = null, next = null, jitter = null;

	function rebuild() {
		var r = host.getBoundingClientRect();
		var w = Math.max(1, Math.round(r.width));
		var h = Math.max(1, Math.round(r.height));
		if (w === canvas.width && h === canvas.height && heat) return; // conservar el trail
		canvas.width = w; canvas.height = h;
		cols = Math.ceil(w / CELL);
		rows = Math.ceil(h / CELL);
		heat = new Float32Array(cols * rows);
		next = new Float32Array(cols * rows);
		jitter = new Float32Array(cols * rows);
		for (var i = 0; i < jitter.length; i++) jitter[i] = 0.8 + Math.random() * 0.2;
	}
	rebuild();
	addEventListener('resize', rebuild, { passive: true });
	if (typeof ResizeObserver !== 'undefined') new ResizeObserver(rebuild).observe(host);

	// kernel en cruz / chaflán alrededor de una celda (el smear con forma de estrella)
	function inject(cr, cc, amount) {
		var reach = Math.ceil(RADIUS / 0.06);
		var r0 = Math.max(0, cr - reach), r1 = Math.min(rows - 1, cr + reach);
		for (var rr = r0; rr <= r1; rr++) {
			var c0 = Math.max(0, cc - reach), c1 = Math.min(cols - 1, cc + reach);
			for (var c = c0; c <= c1; c++) {
				var dr = Math.abs(rr - cr), dc = Math.abs(c - cc);
				var d = Math.min(dr, dc) + 0.06 * Math.max(dr, dc);
				if (d <= RADIUS) {
					var kk = 1 - d / (RADIUS + 1e-6);
					var idx = rr * cols + c;
					heat[idx] = Math.min(1.6, heat[idx] + amount * kk);
				}
			}
		}
	}

	// inyectar a lo largo del trail entre dos celdas (Bresenham)
	function injectLine(r0, c0, r1, c1, amount) {
		var dr = Math.abs(r1 - r0), dc = Math.abs(c1 - c0);
		var sr = r0 < r1 ? 1 : -1, sc = c0 < c1 ? 1 : -1;
		var err = (dc > dr ? dc : -dr) / 2, r = r0, c = c0, guard = 0;
		for (;;) {
			inject(r, c, amount);
			if ((r === r1 && c === c1) || ++guard > 400) break;
			var e = err;
			if (e > -dc) { err -= dr; c += sc; }
			if (e < dr) { err += dc; r += sr; }
		}
	}

	// cursor en coords locales; la fuente de calor sigue al puntero con lag (eso dibuja el smear)
	var tx = -1e4, ty = -1e4, cx = -1e4, cy = -1e4, prevCell = null, seen = false;
	addEventListener('mousemove', function (e) {
		var r = host.getBoundingClientRect();
		tx = e.clientX - r.left; ty = e.clientY - r.top;
		if (!seen) { cx = tx; cy = ty; seen = true; }
	}, { passive: true });

	var last = performance.now();
	function step(now) {
		var dt = Math.min(100, now - last); last = now;
		if (!heat) { requestAnimationFrame(step); return; }

		// decaimiento con half-life
		var k = Math.pow(0.5, dt / HALF_LIFE);
		for (var i = 0; i < heat.length; i++) heat[i] *= k;

		// cursor con easing → inyecta en su celda + a lo largo del trail
		if (seen) {
			cx += (tx - cx) * EASE; cy += (ty - cy) * EASE;
			var cc = Math.floor(cx / CELL), cr = Math.floor(cy / CELL);
			if (cr >= 0 && cr < rows && cc >= 0 && cc < cols) {
				var dtn = dt / 16.7;
				inject(cr, cc, IMPULSE * 0.06 * dtn);
				if (prevCell && (prevCell.r !== cr || prevCell.c !== cc)) {
					injectLine(prevCell.r, prevCell.c, cr, cc, IMPULSE * 0.06 * TRAIL_BOOST * dtn);
				}
				prevCell = { r: cr, c: cc };
			} else prevCell = null;
		}

		// difusión leve a vecinos — ablanda los bloques hacia un smear
		for (var r = 0; r < rows; r++) {
			for (var c = 0; c < cols; c++) {
				var ii = r * cols + c;
				var up = r > 0 ? heat[ii - cols] : 0;
				var dn = r < rows - 1 ? heat[ii + cols] : 0;
				var lf = c > 0 ? heat[ii - 1] : 0;
				var rt = c < cols - 1 ? heat[ii + 1] : 0;
				next[ii] = heat[ii] + DIFFUSE * ((up + dn + lf + rt) / 4 - heat[ii]);
			}
		}
		var tmp = heat; heat = next; next = tmp;

		// render: tapar de blanco y perforar donde hay calor → se ve la imagen
		ctx.globalCompositeOperation = 'source-over';
		ctx.fillStyle = '#fff';
		ctx.fillRect(0, 0, canvas.width, canvas.height);
		ctx.globalCompositeOperation = 'destination-out';
		for (var r2 = 0; r2 < rows; r2++) {
			for (var c2 = 0; c2 < cols; c2++) {
				var hh = heat[r2 * cols + c2];
				if (hh < 0.012) continue;
				var a = Math.min(1, Math.pow(hh, 0.9)) * MAX_A * jitter[r2 * cols + c2];
				ctx.fillStyle = 'rgba(0,0,0,' + a.toFixed(3) + ')';
				ctx.fillRect(c2 * CELL, r2 * CELL, CELL - 1, CELL - 1);
			}
		}
		ctx.globalCompositeOperation = 'source-over';

		requestAnimationFrame(step);
	}
	requestAnimationFrame(step);
}

(function () {
	function init() { buildHeatReveal('#mw-heat', '#oms-home'); }
	if (document.readyState === 'loading') {
		document.addEventListener('DOMContentLoaded', init);
	} else {
		init();
	}
})();

/* Full-bleed the One More Sim banner precisely (uses real client width,
   so the scrollbar doesn't leave a gap the way a 100vw calc would). */
(function () {
	var hero = document.querySelector('.oms-home');
	if (!hero || !hero.parentElement) return;
	var inner = hero.querySelector('.mw-inner');
	function layout() {
		// reset before measuring the (unshifted) article column
		hero.style.marginLeft = '0px';
		hero.style.marginTop = '0px';
		hero.style.width = '';
		var pr = hero.parentElement.getBoundingClientRect();
		var parentLeft = pr.left;
		var parentWidth = pr.width;
		var cw = document.documentElement.clientWidth;
		var page = hero.closest('.page');
		var padTop = page ? parseFloat(getComputedStyle(page).paddingTop) || 0 : 0;
		// full-bleed + flush to the very top of the page
		hero.style.width = cw + 'px';
		hero.style.marginLeft = (-parentLeft) + 'px';
		hero.style.marginTop = (-padTop) + 'px';
		// keep the title + tags aligned to the article column width/position
		if (inner) {
			inner.style.marginLeft = parentLeft + 'px';
			inner.style.width = parentWidth + 'px';
			// shrink the (nowrap) title to fit the column when it's too long
			var t = inner.querySelector('.mw-title');
			if (t) {
				t.style.fontSize = '';
				var avail = inner.clientWidth;
				var natural = t.scrollWidth;
				if (avail > 0 && natural > avail) {
					var fs = parseFloat(getComputedStyle(t).fontSize) || 0;
					if (fs) t.style.fontSize = (fs * avail / natural * 0.97).toFixed(2) + 'px';
				}
			}
		}
	}
	function run() {
		if (document.readyState === 'loading') {
			document.addEventListener('DOMContentLoaded', layout);
		} else {
			layout();
		}
	}
	run();
	window.addEventListener('resize', layout, { passive: true });
	window.addEventListener('load', layout);
})();

/* One More Sim — side-rail cards slide in with overall scroll progress */
function watchSideRail() {
	var rail = document.querySelector('.side-rail');
	var cards = Array.prototype.slice.call(document.querySelectorAll('.side-card'));
	if (!cards.length) return;

	var thresholds = [0.07, 0.2, 0.34];   // all > 0 so cards stay hidden until scrolling into the article
	var fadeAnchor = document.querySelector('#bay');   // optional fade-out anchor

	var update = function () {
		var max = document.documentElement.scrollHeight - window.innerHeight;
		var p = max > 0 ? window.scrollY / max : 1;
		cards.forEach(function (c, i) {
			var th = thresholds[i] != null ? thresholds[i] : 1;
			c.classList.toggle('on', p >= th);
		});
		if (rail && fadeAnchor) {
			rail.classList.toggle('hush', fadeAnchor.getBoundingClientRect().top < window.innerHeight * 0.5);
		}
	};

	window.addEventListener('scroll', update, { passive: true });
	window.addEventListener('resize', update, { passive: true });
	update();
}
if (document.readyState === 'loading') {
	document.addEventListener('DOMContentLoaded', watchSideRail);
} else {
	watchSideRail();
}
