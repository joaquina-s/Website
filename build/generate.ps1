<#
  generate.ps1
  Rebuilds the static portfolio from the Cargo page JSONs in build/source/.
  - Transforms Cargo custom elements into standard HTML.
  - Collects every referenced image/video and downloads it into assets/media/.
  - Writes index.html, about.html and one HTML file per project.

  Run:  powershell -ExecutionPolicy Bypass -File build\generate.ps1
#>

$ErrorActionPreference = "Stop"
$base      = Split-Path -Parent $PSScriptRoot      # project root
$srcDir    = Join-Path $PSScriptRoot "source"
$mediaDir  = Join-Path $base "assets\media"
New-Item -ItemType Directory -Force -Path $mediaDir | Out-Null

$utf8 = New-Object System.Text.UTF8Encoding($false)
function Write-File($path, $text) { [System.IO.File]::WriteAllText($path, $text, $utf8) }

# --------------------------------------------------------------------------
# Navigation data (Selected / Recent projects) — drives the nav card on every page
# --------------------------------------------------------------------------
$selected = @(
	@{ t = "N.i.t.E.F";                    m = "Video game";  y = "2025";      h = "nitef" },
	@{ t = "Avispish";                     m = "Installation"; y = "2023";      h = "avispish" },
	@{ t = "Deriva";                       m = "Performance";  y = "2023";      h = "deriva" },
	@{ t = "To the best of Our knowledge"; m = "Video game";  y = "2025";       h = "to-the-best-of-our-knowledge" },
	@{ t = "Hidrontes";                    m = "Installation"; y = "2022";      h = "hidrontes" }
)
$recent = @(
	@{ t = "Diver:Unidad-" + [char]0x0394; m = "Interface";              y = "2024";      h = "diver" },
	@{ t = "God Milk";                     m = "Performance";            y = "2024";      h = "god-milk" },
	@{ t = "Simulacion de lo esencial";    m = "Video game Installation"; y = "2021/2023"; h = "sdle" },
	@{ t = "Fluido.obj";                   m = "VR Installation";        y = "2019";      h = "fluido-obj" },
	@{ t = "Water Nodes";                  m = "Performance";            y = "2022";      h = "water-nodes" },
	@{ t = "Fin De Fiesta";                m = "Image Series";           y = "2022";      h = "fin-de-fiesta" },
	@{ t = "Caja Negra";                   m = "Book Covers";            y = "2020-2024"; h = "caja-negra" }
)

# --------------------------------------------------------------------------
# Home page: projects grouped into 4 categories (Games / Installation /
# Interface / Video). Each item: title, href, medium, year, img, desc.
# This drives the antikythera-style 4-column layout on the home page.
# --------------------------------------------------------------------------
$titSim   = "Simulaci" + [char]0x00F3 + "n de lo esencial"
$titDiver = "Diver:Unidad-" + [char]0x0394

$homeCategories = @(
	@{ name = "Games"; items = @(
		@{ title = "Nostalgia is the Extended Feedback"; href = "nitef"; medium = "Video game"; year = "2025"; img = "assets/media/A2735789747829222329589952003931.png"; desc = "A slow, atmospheric videogame suspended between dream and digital residue, a flooded world of luminous eggs and half-remembered interfaces." },
		@{ title = "One More Sim"; href = "one-more-sim"; medium = "Web Videogame"; year = "2026"; img = "assets/media/U3000570250880500013001455812443.png"; desc = "A web-based memory simulator of nine porous worlds where memories become simulations, commissioned for Vienna Digital Cultures 2026." },
		@{ title = "Artist Rejector"; href = "artist-rejector"; medium = "Email Sim"; year = "2026"; img = "assets/img/ss.png"; desc = "A little catharsis email simulator fed from real rejection letters, on open calls and institutional silence." },
		@{ title = "To the Best of Our Knowledge"; href = "to-the-best-of-our-knowledge"; medium = "Video game"; year = "2025"; img = "assets/media/G2293209650152453056179497189211.png"; desc = "An artistic exploration of video games in conjunction with quantum computing theories." },
		@{ title = $titSim; href = "sdle"; medium = "Video game / Installation"; year = "2021/2023"; img = "assets/media/e396d7c76748c76b7f69bf68a310e94c95c744cfd372dff6063dcb67068c3626.jpg"; desc = "An aquatic being hatches from an egg and explores a synthetic world that gestures toward nature but can never fully become it." }
	)},
	@{ name = "Installations"; items = @(
		@{ title = "Avispish"; href = "avispish"; medium = "Installation"; year = "2023/2025"; img = "assets/media/fa455474f99d9a7fc8fd10c50c883a3f2d51361e7bc58f3cea6392dba974273d.jpg"; desc = "A multi-screen artwork of animated facial captures, a narrative of fragmented conversations on surveillance and power." },
		@{ title = "Hidrontes"; href = "hidrontes"; medium = "Installation"; year = "2022"; img = "assets/media/f228c0f645199df532a4c2d251b019df70a945fc0ab5a974bbb9ff2fab5de699.jpg"; desc = "Speculative fiction where aquatic beings arrive on dry land to rehearse composting and care in potential futures." },
		@{ title = "Fluido.obj"; href = "fluido-obj"; medium = "VR Installation"; year = "2019/2023"; img = "assets/media/F2293533828824032594223013936987.jpeg"; desc = "A VR installation centred on perception; nostalgia as a vibe, exploring futuristic landscapes of memory." }
	)},
	@{ name = "A/V Performance"; items = @(
		@{ title = "Deriva"; href = "deriva"; medium = "Performance"; year = "2023"; img = "assets/media/6274af2b2992db5bc7cef5059800ce4d7d03409b24810aa4862ea4efaa55179b.jpg"; desc = "An audiovisual performance exploring the forms within a virtual organism, modulated in real time through motion capture." },
		@{ title = "God Milk"; href = "god-milk"; medium = "Performance"; year = "2024"; img = "assets/media/C2293443625555230983748989861723.jpg"; desc = "A performance and audio-visual installation set in a milk factory, on the care economy and the gamification of female bodies." },
		@{ title = "Water Nodes"; href = "water-nodes"; medium = "Motion Capture Performance"; year = "2022"; img = "assets/media/Y2293547360636062048675406921563.png"; desc = "A motion-capture performance built on the idea that water is memory, streaming live mocap across remote locations." }
	)},
	@{ name = "Interface"; items = @(
		@{ title = $titDiver; href = "diver"; medium = "Interface"; year = "2024"; img = "assets/img/diver1.jpg"; desc = "A bio-mechanical wanderer, an interface-sculpture designed to connect with its environment." }
	); subgroups = @(
		@{ name = "IMG"; items = @(
			@{ title = "Caja Negra"; href = "caja-negra"; medium = "Book Covers"; year = "2020-2024"; img = "assets/media/f9aac46d345291061c89cd613112688b85eeef52fce50c36500478dbc8037177.png"; desc = "Cover artworks for Caja Negra, an independent publishing house between Buenos Aires and Madrid." },
			@{ title = "Fin de Fiesta"; href = "fin-de-fiesta"; medium = "Image Series"; year = "2022"; img = "assets/media/1c3d4fdd453dedb05ba8d5738d32e9dcc048aa5a73e36318cdbfc0120b516036.jpg"; desc = "A landscape out of time, a depository of nightmares aestheticized through memory." }
		)}
	)}
)

# flatten every project item (including category subgroups) once
$script:allProjects = @()
foreach ($cat in $homeCategories) {
	foreach ($it in $cat.items) { $script:allProjects += ,@{ item = $it; category = $cat.name } }
	if ($cat.subgroups) { foreach ($sg in $cat.subgroups) { foreach ($it in $sg.items) { $script:allProjects += ,@{ item = $it; category = $sg.name } } } }
}

# href -> cover image  /  href -> hero metadata
$script:projImg = @{}
$script:projLookup = @{}
foreach ($e in $script:allProjects) {
	$it = $e.item
	$script:projImg[$it.href] = $it.img
	$script:projLookup[$it.href] = @{ title = $it.title; category = $e.category; medium = $it.medium; year = $it.year }
}

function Build-ProjectHero($info) {
	$med = "$($info.medium)".Trim()
	$yr = "$($info.year)".Trim()
	$tags = ""
	if ($med) { $tags += "<span>$med</span>" }
	if ($yr) { $tags += "<span>$yr</span>" }
	return "<section class=""oms-home"" id=""oms-home""><div class=""mw-photo"" aria-hidden=""true""></div><canvas class=""mw-heat"" id=""mw-heat"" aria-hidden=""true""></canvas><div class=""mw-inner""><h1 class=""mw-title"">$($info.title)</h1><div class=""mw-tags"">$tags</div></div></section>"
}

# purl -> output filename
$outName = @{ "home-1" = "index.html"; "about-1" = "about.html" }

# --------------------------------------------------------------------------
# Build a global media map: hash -> { name, file_type, is_url, url }
# --------------------------------------------------------------------------
$script:mediaMap = @{}
Get-ChildItem "$srcDir\*.json" | ForEach-Object {
	$data = Get-Content $_.FullName -Raw | ConvertFrom-Json
	foreach ($prop in $data.pages.byId.PSObject.Properties) {
		$pg = $prop.Value
		if ($pg.media) {
			foreach ($mm in $pg.media) {
				if ($mm.hash -and -not $script:mediaMap.ContainsKey($mm.hash)) {
					$script:mediaMap[$mm.hash] = $mm
				}
			}
		}
	}
}
Write-Host "Media map: $($script:mediaMap.Count) entries"

# url -> local filename (download queue, de-duplicated)
$script:assets = [ordered]@{}

function Register-Asset($downloadUrl, $localName) {
	if (-not $script:assets.Contains($downloadUrl)) {
		$script:assets[$downloadUrl] = $localName
	}
	return $localName
}

function Get-Attr($tag, $name) {
	$m = [regex]::Match($tag, $name + '\s*=\s*"([^"]*)"')
	if ($m.Success) { return $m.Groups[1].Value }
	return $null
}

function Local-From-Url($url) {
	$u = $url.Split('?')[0].TrimEnd('/')
	$parts = $u.Split('/')
	$idx = [array]::IndexOf($parts, 'i')
	$fname = $parts[$parts.Length - 1]
	if ($idx -ge 0 -and $idx + 1 -lt $parts.Length) {
		# freight hash-based URL: use the unique hash segment + original extension
		$seg = $parts[$idx + 1]
		$ext = [System.IO.Path]::GetExtension($fname)
		return "$seg$ext"
	}
	# otherwise keep the (sanitized) original filename
	return ($fname -replace '[^A-Za-z0-9._-]', '_')
}

$script:localHosts = 'freight\.cargo\.site|files\.cargocollective\.com'

$videoExt = @('.mp4', '.mov', '.webm', '.m4v', '.ogv')

# --------------------------------------------------------------------------
# Content transformer
# --------------------------------------------------------------------------
function Convert-Content($html) {
	if ([string]::IsNullOrEmpty($html)) { return "" }

	# strip leftover Cargo gallery placeholders
	$html = [regex]::Replace($html, '\{(image|video)\s+\d+\}', '')

	# duplicate id="fullscreen_embed" -> safe class
	$html = $html.Replace('id="fullscreen_embed"', 'class="embed-video"')

	# ---- media-item -> img / video / iframe (callback preserves inner content) ----
	$evalMedia = [System.Text.RegularExpressions.MatchEvaluator] {
		param($m)
		$tag = $m.Groups[1].Value
		$inner = $m.Groups[2].Value
		$src = Get-Attr $tag 'src'
		$hash = Get-Attr $tag 'hash'
		$zoom = if ($tag -match 'zoomable') { ' zoomable' } else { '' }

		$url = $null; $ext = $null; $isUrl = $false; $embedUrl = $null
		if ($src) {
			$url = $src
			$ext = [System.IO.Path]::GetExtension($src.Split('?')[0]).ToLower()
		}
		elseif ($hash -and $script:mediaMap.ContainsKey($hash)) {
			$mi = $script:mediaMap[$hash]
			if ($mi.is_url) { $isUrl = $true; $embedUrl = $mi.url }
			else {
				$name = $mi.name
				$ext = [System.IO.Path]::GetExtension($name)
				if (-not $ext) { $ext = "." + $mi.file_type }
				$ext = $ext.ToLower()
				$encName = [uri]::EscapeDataString($name)
				$url = "https://freight.cargo.site/t/original/i/$hash/$encName"
			}
		}

		$innerHtml = Convert-Content $inner

		if ($isUrl) {
			# youtube / vimeo embed
			$em = $embedUrl
			return "<div class=""video-embed""><iframe src=""$em"" loading=""lazy"" allow=""autoplay; fullscreen; picture-in-picture"" allowfullscreen></iframe></div>$innerHtml"
		}
		if (-not $url) { return $innerHtml }

		$local = Local-From-Url $url
		if (-not ([System.IO.Path]::GetExtension($local))) { $local = $local + $ext }
		Register-Asset $url $local | Out-Null
		$localPath = "assets/media/$local"

		if ($videoExt -contains $ext) {
			return "<video class=""media-item embed-video"" autoplay muted loop playsinline><source src=""$localPath"" type=""video/mp4""></video>$innerHtml"
		}
		else {
			return "<img class=""media-item$zoom"" src=""$localPath"" alt="""" loading=""lazy"">$innerHtml"
		}
	}
	$html = [regex]::Replace($html, '<media-item([^>]*)>(.*?)</media-item>', $evalMedia,
		([System.Text.RegularExpressions.RegexOptions]::Singleline -bor [System.Text.RegularExpressions.RegexOptions]::IgnoreCase))

	# ---- plain <img src="freight..."> -> local ----
	$evalImg = [System.Text.RegularExpressions.MatchEvaluator] {
		param($m)
		$tag = $m.Value
		$src = Get-Attr $tag 'src'
		if ($src -and $src -match $script:localHosts) {
			$local = Local-From-Url $src
			Register-Asset $src $local | Out-Null
			$tag = $tag.Replace($src, "assets/media/$local")
		}
		# add lazy + zoomable
		if ($tag -notmatch 'loading=') { $tag = $tag -replace '^<img', '<img loading="lazy"' }
		if ($tag -notmatch 'class=') { $tag = $tag -replace '^<img', '<img class="zoomable"' }
		elseif ($tag -notmatch 'zoomable') { $tag = [regex]::Replace($tag, 'class="([^"]*)"', 'class="$1 zoomable"') }
		return $tag
	}
	$html = [regex]::Replace($html, '<img\b[^>]*>', $evalImg, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

	# ---- <video ... src> and <source src> -> local ----
	$evalSrc = [System.Text.RegularExpressions.MatchEvaluator] {
		param($m)
		$url = $m.Groups[2].Value
		if ($url -match $script:localHosts) {
			$local = Local-From-Url $url
			Register-Asset $url $local | Out-Null
			return $m.Groups[1].Value + "assets/media/$local" + '"'
		}
		return $m.Value
	}
	$html = [regex]::Replace($html, '(\ssrc=")(https?://[^"]+)"', $evalSrc, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

	# ---- column-set / column-unit ----
	$evalColset = [System.Text.RegularExpressions.MatchEvaluator] {
		param($m)
		$tag = $m.Value
		$g = Get-Attr $tag 'gutter'
		$mg = Get-Attr $tag 'mobile-gutter'
		$style = ""
		if ($g) { if ($g -match '^[\d.]+$') { $g = "$g" + "rem" }; $style += "--gutter:$g;" }
		if ($mg) { if ($mg -match '^[\d.]+$') { $mg = "$mg" + "rem" }; $style += "--mobile-gutter:$mg;" }
		if ($style) { return "<div class=""column-set"" style=""$style"">" }
		return "<div class=""column-set"">"
	}
	$html = [regex]::Replace($html, '<column-set[^>]*>', $evalColset, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

	$evalColunit = [System.Text.RegularExpressions.MatchEvaluator] {
		param($m)
		$tag = $m.Value
		$span = Get-Attr $tag 'span'
		if ($span) { return "<div class=""column-unit"" style=""--span:$span"">" }
		return "<div class=""column-unit"">"
	}
	$html = [regex]::Replace($html, '<column-unit[^>]*>', $evalColunit, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
	$html = $html -replace '</column-unit>', '</div>'
	$html = $html -replace '</column-set>', '</div>'

	# ---- gallery-grid ----
	$evalGallery = [System.Text.RegularExpressions.MatchEvaluator] {
		param($m)
		$tag = $m.Value
		$cols = Get-Attr $tag 'columns'; if (-not $cols) { $cols = "2" }
		$g = Get-Attr $tag 'gutter'; if (-not $g) { $g = "1rem" }
		if ($g -match '^[\d.]+$') { $g = "$g" + "rem" }
		return "<div class=""gallery-grid"" style=""--cols:$cols;--gutter:$g"">"
	}
	$html = [regex]::Replace($html, '<gallery-grid[^>]*>', $evalGallery, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
	$html = $html -replace '</gallery-grid>', '</div>'

	# ---- text-icon ----
	$html = [regex]::Replace($html, '<text-icon[^>]*icon="downwards-arrow"[^>]*>\s*</text-icon>', '<span class="text-icon">&#8595;</span>', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
	$html = [regex]::Replace($html, '<text-icon[^>]*icon="north-east-arrow"[^>]*>\s*</text-icon>', '<span class="text-icon">&#8599;</span>', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
	$html = [regex]::Replace($html, '<text-icon[^>]*>\s*</text-icon>', '', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

	return $html
}

# --------------------------------------------------------------------------
# Nav card markup (shared) — $active is the current purl
# --------------------------------------------------------------------------
function Build-Nav($active) {
	$sb = New-Object System.Text.StringBuilder
	[void]$sb.Append('<nav class="nav-card" id="siteNav">')
	[void]$sb.Append('<a class="nav-title" href="index.html">Joaquina Salgado</a>')
	$aboutCls = if ($active -eq "about-1") { ' active' } else { '' }
	[void]$sb.Append("<a class=""nav-about$aboutCls"" href=""about.html"">About &#8594;</a>")

	# grouped by the same categories (and IMG subgroup) as the Home page
	function navSection($secName, $items) {
		$s = "<p class=""nav-section"">$secName</p><div class=""nav-card-list"">"
		foreach ($it in $items) {
			$cls = if ($it.href -eq $active) { "nav-proj-card active" } else { "nav-proj-card" }
			$s += "<a class=""$cls"" href=""$($it.href).html"">"
			if ($it.img) { $s += "<img class=""npc-img"" src=""$($it.img)"" alt="""" loading=""lazy"">" }
			$s += '<span class="npc-overlay"></span>'
			$s += "<span class=""npc-body""><span class=""npc-title"">$($it.title)</span><span class=""npc-sub"">$($it.medium)</span><span class=""npc-desc"">$($it.desc)</span></span></a>"
		}
		return $s + "</div>"
	}
	foreach ($cat in $homeCategories) {
		[void]$sb.Append((navSection $cat.name $cat.items))
		if ($cat.subgroups) { foreach ($sg in $cat.subgroups) { [void]$sb.Append((navSection $sg.name $sg.items)) } }
	}

	[void]$sb.Append('<div class="nav-links"><a href="mailto:hola@joaquinasalgado.com">Email</a><br><a href="https://www.instagram.com/joaquina.s/" target="_blank" rel="noopener">Instagram <span class="text-icon">&#8599;</span></a></div>')
	[void]$sb.Append('</nav>')
	return $sb.ToString()
}

# --------------------------------------------------------------------------
# Page templates
# --------------------------------------------------------------------------
function Page-Head($title) {
	return @"
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>$title</title>
	<link rel="icon" type="image/png" href="assets/img/h.png">
	<link rel="stylesheet" href="assets/fonts/space-grotesk.css">
	<link rel="stylesheet" href="assets/css/style.css">
</head>
"@
}

function Build-ContentPage($title, $active, $contentHtml) {
	$head = Page-Head $title
	$nav = Build-Nav $active
	return @"
$head
<body class="content-page page-$active">
<button class="nav-toggle" aria-label="Open menu">&#9776;</button>
<div class="nav-backdrop"></div>
$nav
<main class="page">
	<div class="page-content"><bodycopy>
$contentHtml
	</bodycopy></div>
</main>
<div class="crt-scanlines"></div>
<div class="crt-rollbar"></div>
<div class="crt-vignette"></div>
<script src="assets/js/main.js"></script>
</body>
</html>
"@
}

function Build-HomePage() {
	$head = Page-Head "Joaquina Salgado"
	# home hero image (h1.png / eye-egg)
	Register-Asset "https://freight.cargo.site/t/original/i/X2735720508418063518556990586715/h1.png" "h1.png" | Out-Null

	# build the 4 category columns
	function Home-Cards($items) {
		$c = ""
		foreach ($it in $items) {
			$c += "<a class=""proj-card"" href=""$($it.href).html""><span class=""pc-thumb""><img src=""$($it.img)"" alt=""$($it.title)"" loading=""lazy""></span><span class=""pc-title"">$($it.title)</span><span class=""pc-meta"">$($it.medium) &middot; $($it.year)</span><span class=""pc-desc"">$($it.desc)</span></a>"
		}
		return $c
	}
	$colsHtml = ""
	foreach ($cat in $homeCategories) {
		$inner = "<div class=""col-head""><span class=""col-name"">$($cat.name)</span><span class=""col-count"">$('{0:00}' -f $cat.items.Count)</span></div><div class=""col-cards"">$(Home-Cards $cat.items)</div>"
		if ($cat.subgroups) {
			foreach ($sg in $cat.subgroups) {
				$inner += "<div class=""col-head col-sub""><span class=""col-name"">$($sg.name)</span><span class=""col-count"">$('{0:00}' -f $sg.items.Count)</span></div><div class=""col-cards"">$(Home-Cards $sg.items)</div>"
			}
		}
		$colsHtml += "<div class=""proj-col"" data-col>$inner</div>"
	}

	# upcoming-presentations ticker (marquee group is duplicated for a seamless loop)
	$tkGroup = @'
<span class="tk-item"><span class="tk-date">March 2027</span> <a class="tk-link" href="https://ntcart.museum/en/index.aspx" target="_blank" rel="noopener">New Taipei City Art Museum <span class="text-icon">&#8599;</span></a> <span class="tk-loc">Taipei, Taiwan</span></span><span class="tk-dot">&#9670;</span>
'@
	$ticker = '<section class="ticker" aria-label="Upcoming presentations"><div class="ticker-head"><span>Upcoming Presentations 2027</span></div><div class="ticker-viewport"><div class="ticker-track">' + $tkGroup + $tkGroup + '</div></div></section>'

	return @"
$head
<body class="home">
<header class="site-header">
	<a class="brand" href="index.html">Joaquina Salgado</a>
	<nav class="header-nav">
		<a href="#work">Work</a>
		<a href="about.html">About</a>
		<a href="https://www.instagram.com/joaquina.s/" target="_blank" rel="noopener">Instagram &#8599;</a>
	</nav>
</header>

<section class="hero">
	<img class="hero-img" src="assets/media/h1.png" alt="Joaquina Salgado">
	<a class="scroll-cue" href="#work" aria-label="Scroll to work">&#8595;</a>
</section>

$ticker

<section class="projects" id="work">
	<div class="projects-inner">
		<div class="section-label"><span>Selected Work</span></div>
		<div class="proj-columns">
$colsHtml
		</div>
	</div>
</section>

<div class="crt-scanlines"></div>
<div class="crt-rollbar"></div>
<div class="crt-vignette"></div>
<script src="assets/js/main.js"></script>
</body>
</html>
"@
}

# --------------------------------------------------------------------------
# About page — project-detail layout (hero + bio) + 4 metallic accordions
$aboutContent = @'
<section class="oms-home" id="oms-home"><div class="mw-photo" aria-hidden="true"></div><canvas class="mw-heat" id="mw-heat" aria-hidden="true"></canvas><div class="mw-inner"><h1 class="mw-title">Joaquina Salgado</h1><div class="mw-tags"></div></div></section>
<div class="about-body">
<div class="about-bio">
<p>Joaquina Salgado is a Berlin-based media artist from Argentina whose work examines the intersections of technology, philosophy, and more-than-human worlds. With a background in Media Arts at the Universidad Nacional de La Plata, she creates interactive installations, animations, and video games shaped by internet culture that probe how perception, agency, and collective experience are constructed through algorithmic systems.</p>
<p>Through motion capture, game engines, and custom interfaces, Salgado develops speculative ecosystems that illuminate hidden entanglements between humans, machines, and living systems. Her practice explores technology as both a tool of control and a medium for intimacy and interconnection, seeking to explore how technology might enable more equitable and interconnected futures.</p>
<p>Recent projects include DERIVA (Pro Helvetia, Zurich), avispish (CCK, Buenos Aires), and Vienna Digital Cultures (2026). Her solo exhibition Nostalgia is the Extended Feedback opened at SOMA Berlin in December 2025. She has presented work at MUTEK (Buenos Aires/Montreal), Berlin Art Week, and the APAP7 Triennial in Korea.</p>
</div>
<p class="about-contact">mandame un email (&#728;&#840; &#7509; &#728;&#840;&#9825;)&#730;&#3664;*&#735;&#9825; <a href="mailto:hola@joaquinasalgado.com">hola@joaquinasalgado.com</a> &#8333;&#758; &#8226;. &#8226; &#9285;&#8334;&#4304; &#9825;</p>
<div class="acc-list">
<details class="accordion"><summary class="acc-head"><span class="acc-title">Exhibitions</span><span class="chev">&#9662;</span></summary><div class="acc-body">
<h4 class="acc-group">Solo Shows</h4>
<ul>
<li><b>2026</b> &mdash; Nostalgia es Feedback expandido. Artlab, Buenos Aires, Argentina.</li>
<li><b>2025</b> &mdash; Nostalgia Is The Extended Feedback. SOMA Berlin.</li>
<li><b>2023</b> &mdash; "SIMULACI&Oacute;N DE LO ESENCIAL", "AVISPISH", "LA INFINITA" &mdash; "DESBORDE" Individual Exhibition, Centro NAVE, Santiago de Chile, Chile.</li>
</ul>
<h4 class="acc-group">Group Shows</h4>
<ul>
<li><b>2026</b> &mdash; <a href="https://kunsttagebasel.ch/ausstellungen/lust-art-space-eggs" target="_blank" rel="noopener">Lust*Art: Space Eggs</a>. Kasko, Kunsttage Basel, Switzerland.</li>
<li><b>2026</b> &mdash; <a href="https://culture.hu/de/berlin/veranstaltungen/ausstellungseroffnung:-brave-new" target="_blank" rel="noopener">Diver</a>. Collegium Hungaricum Berlin, Germany.</li>
<li><b>2026</b> &mdash; Cyber Eternity. Nite Lite, Buenos Aires, Argentina.</li>
<li><b>2026</b> &mdash; Niebla Intramundos. MUTEK.AR, Planetario de la Ciudad de Buenos Aires, Argentina.</li>
<li><b>2026</b> &mdash; <a href="https://www.mediales.art/articulos/performa-2026" target="_blank" rel="noopener">PERFORMA 2026: Festival Internacional de Artes Mediales</a>, Valpara&iacute;so, Chile.</li>
<li><b>2026</b> &mdash; <a href="https://uchile.cl/agenda/244703/visionado-latitudes-inmersivas-en-planetario-huechuraba" target="_blank" rel="noopener">Latitudes Inmersivas</a>. Planetario, Santiago, Chile.</li>
<li><b>2026</b> &mdash; <a href="https://www.killscreen.com/joaquina-salgado-shows-memory-simulator-one-more-sim/" target="_blank" rel="noopener">One More Sim</a>. Clutch, Berlin, Germany.</li>
<li><b>2026</b> &mdash; "N.I.T.E.F" shortfilm at Azur Gallery, Berlinale. Berlin, Germany.</li>
<li><b>2026</b> &mdash; One More Sim. Vienna Digital Cultures. Vienna, Austria.</li>
<li><b>2026</b> &mdash; Diver &mdash; Exhibition at Azur Gallery. Berlin, Germany.</li>
<li><b>2026</b> &mdash; One More Sim. Sybil. Berlin, Germany.</li>
<li><b>2025</b> &mdash; Avispish, Metonom, Modena, Italy.</li>
<li><b>2025</b> &mdash; Avispish. CCK. Buenos Aires, Argentina.</li>
<li><b>2025</b> &mdash; To the Best of Our Knowledge, Immaterial festival, San Sebastian.</li>
<li><b>2025</b> &mdash; Ghosts in the Feedback Loop. New Art City. NY/Online.</li>
<li><b>2025</b> &mdash; ME777AXXXY. Artwings. Berlin, Germany.</li>
<li><b>2025</b> &mdash; Open Sailing: Algorithmic Mythology. Seoul, Korea.</li>
<li><b>2024</b> &mdash; "RETORNO" shortfilm &mdash; Centro Cultural Kirchner. Buenos Aires, Argentina.</li>
<li><b>2024</b> &mdash; "GodMilk" Interactive performance at Berlin ArtWeek.</li>
<li><b>2024</b> &mdash; Projection on Water. Feed The River. Chemnitz, Germany.</li>
<li><b>2023</b> &mdash; "LA INFINITA" &mdash; "Not built in a Day" Exhibition &mdash; Rome, Italy.</li>
<li><b>2023</b> &mdash; "SIMULACI&Oacute;N DE LO ESENCIAL" &mdash; "Zero Uno" Exhibition &mdash; Buenos Aires, Argentina.</li>
<li><b>2023</b> &mdash; "DERIVA" Live motion capture performance &mdash; ZHDK Zurich University of the Arts.</li>
<li><b>2023</b> &mdash; "AVISPISH" A/V Installation &mdash; INHERITED Exhibition &mdash; Atelier Mondial &mdash; Basel, Switzerland.</li>
<li><b>2023</b> &mdash; "MITO DEL AGUA MURIENTE" &mdash; NFC and Interwined Exhibition &mdash; Lisboa, Portugal.</li>
<li><b>2023</b> &mdash; "FLUIDO.OBJ" VR Installation &mdash; APAP7 &mdash; Anyang, Korea.</li>
<li><b>2022</b> &mdash; "HIDRONTES" A/V Installation &mdash; "DESAF&Iacute;OS" Exhibition &mdash; Fundacion Andreani &mdash; Buenos Aires, Argentina.</li>
<li><b>2022</b> &mdash; "NIVEL V: Crisis de las coordenadas" &mdash; FullDome experience &mdash; MUTEK &mdash; Buenos Aires, Argentina.</li>
<li><b>2022</b> &mdash; "MITO DEL AGUA MURIENTE" &mdash; RIESGO PA&Iacute;S Exhibition by CRYPTOARG &mdash; New York, USA.</li>
<li><b>2021</b> &mdash; "SIMULACI&Oacute;N DE LO ESENCIAL" VideoGame Installation &mdash; CRYPTOARG Collective Exhibition.</li>
<li><b>2021</b> &mdash; "MI AURA ES LA NET" 3d sculpture &mdash; Virtual Exhibition. Ergo Proxy.</li>
<li><b>2021</b> &mdash; "RETORNO" shortfilm &mdash; Virtual Exhibition &mdash; Fundaci&oacute;n PROA.</li>
<li><b>2021</b> &mdash; "CRYPTOARG x MoCa" &mdash; Virtual Space in Decentraland.</li>
<li><b>2020</b> &mdash; "FLUIDO.OBJ.VR" &mdash; VR Installation &mdash; Mirage Festival &mdash; Lyon, France.</li>
<li><b>2020</b> &mdash; "CAOS by CRYPTOARG" &mdash; CryptoVoxels.</li>
<li><b>2019</b> &mdash; "FLUIDO.OBJ.VR" &mdash; A/V Performance &mdash; MUTEK Montreal and MUTEK Argentina.</li>
</ul></div></details>
<details class="accordion"><summary class="acc-head"><span class="acc-title">Curation</span><span class="chev">&#9662;</span></summary><div class="acc-body"><ul>
<li><b>2026&ndash;</b> Aegean Film Festival VR and Immersive programmer. Patmos. Greece.</li>
</ul></div></details>
<details class="accordion"><summary class="acc-head"><span class="acc-title">Press</span><span class="chev">&#9662;</span></summary><div class="acc-body"><ul>
<li><b>Kill Screen</b> &mdash; <a href="https://www.killscreen.com/joaquina-salgado-hides-a-score-inside-luminous-eggs/" target="_blank" rel="noopener">Joaquina Salgado hides a score inside luminous eggs</a>.</li>
<li><b>Refresh Art Magazine</b> &mdash; <a href="https://www.refresh.art/reviews/joaquina-salgado/" target="_blank" rel="noopener">Digital Specters Against Homogenization</a>.</li>
<li><b>AntiMateria</b> &mdash; <a href="https://anti-materia.org/eyecandy-1/2025/12/8/semana-4871-nostalgia-is-the-extended-feedback" target="_blank" rel="noopener">Nostalgia is the Extended Feedback</a>.</li>
<li><b>MOCA</b>, by Maxwell Cohen &mdash; <a href="https://medium.com/@museumofcryptoart/joaquina-salgado-searches-for-sincerity-and-so-do-you-4696fdaae9c0" target="_blank" rel="noopener">Joaquina Salgado Searches for Sincerity, And So Do You!</a></li>
<li><b>MOCA</b>, by Julian Brangold &mdash; <a href="https://medium.com/@museumofcryptoart/joaquina-salgado-the-backend-of-culture-58af5b6af7c2" target="_blank" rel="noopener">Joaquina Salgado: The Backend of Culture</a>.</li>
<li><b>G7</b>, by Vero Flores &mdash; <a href="https://revistag7.com/joaquina-salgado-hija-de-internet/" target="_blank" rel="noopener">Joaquina Salgado. Hija de Internet</a>.</li>
</ul></div></details>
</div>
</div>
'@

# Generate all pages
# --------------------------------------------------------------------------
Get-ChildItem "$srcDir\*.json" | ForEach-Object {
	$purl = $_.BaseName
	$data = Get-Content $_.FullName -Raw | ConvertFrom-Json
	# find the page object whose purl matches the filename
	$pg = $null
	foreach ($prop in $data.pages.byId.PSObject.Properties) {
		if ($prop.Value.purl -eq $purl) { $pg = $prop.Value; break }
	}
	$file = if ($outName.ContainsKey($purl)) { $outName[$purl] } else { "$purl.html" }

	if ($purl -eq "home-1") {
		Write-File (Join-Path $base $file) (Build-HomePage)
		Write-Host "  $file (home)"
		return
	}

	if ($null -eq $pg) { Write-Host "  SKIP $purl (no page match)"; return }

	$title = "$($pg.title) " + [char]0x2014 + " Joaquina Salgado"

	$raw = $pg.content
	if ($purl -eq "about-1") { $raw = $aboutContent }
	if ($purl -eq "nitef") {
		# stretched / deformed treatment for this line
		$raw = $raw -replace '<h2>Where is the sea in this cybernetic world\?', '<h2 class="deformed">Where is the sea in this cybernetic world?'
	}
	if ($purl -eq "avispish") {
		$raw = $raw -replace '<h2>What does it mean to exist in a world where every gesture can be turned into data\?', '<h2 class="deformed">What does it mean to exist in a world where every gesture can be turned into data?'
	}
	if ($purl -eq "diver") {
		# new top image = diver1; body images = diver2/3/4; old top image moves to the bottom
		$rep = @{
			'H2742196830453005648276294844251' = '<img src="assets/img/diver1.jpg" alt="Diver">'
			'Z2293380227932772411351672405851' = '<img src="assets/img/diver2.jpg" alt="Diver">'
			'S2293390445307613677966669234011' = '<img src="assets/img/diver3.jpg" alt="Diver">'
			'V2293391378473056134711756832603' = '<img src="assets/img/diver4.jpg" alt="Diver">'
			'K2293391504482764902221703921499' = '<media-item class="zoomable" hash="H2742196830453005648276294844251"></media-item>'
		}
		foreach ($h in $rep.Keys) {
			$raw = [regex]::Replace($raw, '<media-item[^>]*hash="' + $h + '"[^>]*>.*?</media-item>', $rep[$h], [System.Text.RegularExpressions.RegexOptions]::Singleline)
		}
	}
	if ($purl -eq "one-more-sim") {
		# remove the trailing 3 media (video + 2 images) at the very end
		$vidIdx = $raw.IndexOf("gameplay_1.mp4")
		if ($vidIdx -ge 0) {
			$hrIdx = $raw.Substring(0, $vidIdx).LastIndexOf("<hr")
			if ($hrIdx -ge 0) { $raw = $raw.Substring(0, $hrIdx) }
		}
		# turn the top external link into an animated metal-border card
		$card = '<div style="text-align: center"><a class="metal-link-card" href="https://onemoresim.viennadigitalcultures.at/" target="_blank" rel="noopener noreferrer"><span class="mlc-body"><span class="mlc-title">Play videogame</span><span class="mlc-url">onemoresim.viennadigitalcultures.at &#8599;</span></span></a></div>'
		$raw = [regex]::Replace($raw, '<div style="text-align: center"><h2><a href="https://onemoresim\.viennadigitalcultures\.at/"[^>]*>.*?</a>\s*</h2></div>', $card, [System.Text.RegularExpressions.RegexOptions]::Singleline)
		# right-pinned rail of cards that slide in on scroll
		$raw += '<aside class="side-rail" id="side-rail"><article class="side-card side-card--img"><img class="side-img" src="assets/img/oms1.png" alt=""></article><article class="side-card side-card--img"><img class="side-img" src="assets/img/oms2.png" alt=""></article><article class="side-card side-card--img"><img class="side-img" src="assets/img/oms3.png" alt=""></article></aside>'
	}

	# every catalogued project gets the heat-reveal hero: strip the original
	# title/metadata header (up to & including the first <hr>) and prepend the hero.
	$info = $script:projLookup[$purl]
	if ($info) {
		$hrIdx2 = $raw.IndexOf("<hr")
		if ($hrIdx2 -ge 0) {
			$tagEnd = $raw.IndexOf(">", $hrIdx2)
			if ($tagEnd -ge 0) { $raw = $raw.Substring($tagEnd + 1) }
		}
		$raw = (Build-ProjectHero $info) + $raw
	}

	$content = Convert-Content $raw
	Write-File (Join-Path $base $file) (Build-ContentPage $title $purl $content)
	Write-Host "  $file"
}

# --------------------------------------------------------------------------
# Artist Rejector — hand-authored page (same heat-reveal hero style as OMS)
# --------------------------------------------------------------------------
$arContent = @'
<section class="oms-home" id="oms-home"><div class="mw-photo" aria-hidden="true"></div><canvas class="mw-heat" id="mw-heat" aria-hidden="true"></canvas><div class="mw-inner"><h1 class="mw-title">Artist Rejector</h1><div class="mw-tags"><span>Games</span><span>Email Sim</span><span>2026</span></div></div></section>
<div class="ar-body">
<img class="zoomable ar-shot" loading="lazy" src="assets/img/ss.png" alt="Artist Rejector">
<div class="ar-text">
<p>I don't feel anything anymore when I receive a rejection from an open call.<br />
Got so used to institutional AI responses, but I'm still wondering if there are real people behind them?<br />
I put a lot of time and effort into these applications.<br />
Are open calls real? Or is it just a myth?<br />
When I put a lot of time and effort into these applications and get these soulless responses, I think sometimes about reasons:</p>
<ul>
<li>My art is just bad</li>
<li>The open call was already arranged</li>
<li>People reviewing the applications might also be exploited cultural workers and they don't have time to see everything.</li>
</ul>
<p>Made this lil catharsis email sim fed from real rejection letters.</p>
</div>
<a class="metal-link-card" href="https://joaquina-s.github.io/artist-rejector/" target="_blank" rel="noopener noreferrer"><span class="mlc-body"><span class="mlc-title">Play Artist Rejector</span><span class="mlc-url">joaquina-s.github.io/artist-rejector &#8599;</span></span></a>
</div>
<aside class="side-rail" id="side-rail"><article class="side-card side-card--img"><img class="side-img" src="assets/img/AR1.png" alt=""></article><article class="side-card side-card--img"><img class="side-img" src="assets/img/AR2.png" alt=""></article><article class="side-card side-card--img"><img class="side-img" src="assets/img/AR3.png" alt=""></article></aside>
'@
$arTitle = "Artist Rejector " + [char]0x2014 + " Joaquina Salgado"
Write-File (Join-Path $base "artist-rejector.html") (Build-ContentPage $arTitle "artist-rejector" $arContent)
Write-Host "  artist-rejector.html"

# favicon
Register-Asset "https://freight.cargo.site/t/original/i/H2297683048899553283417558335323/eyealpha.ico" "favicon.ico" | Out-Null

# --------------------------------------------------------------------------
# Download all collected assets
# --------------------------------------------------------------------------
Write-Host ""
Write-Host "Downloading $($script:assets.Count) assets ..."
$ok = 0; $fail = 0
foreach ($entry in $script:assets.GetEnumerator()) {
	$url = $entry.Key
	$local = $entry.Value
	$dest = Join-Path $mediaDir $local
	if (Test-Path $dest) { $ok++; continue }
	try {
		Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing -TimeoutSec 120
		$ok++
	}
	catch {
		$fail++
		Write-Host "  FAIL $local  <- $url"
		Write-Host "       $($_.Exception.Message)"
	}
}
Write-Host "Assets done. OK=$ok  FAIL=$fail"
Write-Host "Generation complete."
