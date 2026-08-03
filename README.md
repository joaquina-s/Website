# Joaquina Salgado — Portfolio (standalone)

A self-contained static rebuild of the portfolio originally hosted on Cargo.site
(<https://joaquinasalgado.com>). All texts, structure and layout were reproduced
as plain **HTML + CSS + JavaScript** that you fully own — there is no Cargo runtime
and no build framework required to view it.

## What's inside

```
.
├── index.html              Home (eye image + navigation card)
├── about.html              About / bio / exhibitions / press
├── <project>.html          One page per project (avispish, deriva, nitef, …)
├── assets/
│   ├── css/style.css       All styling (layout, nav card, typography, responsive)
│   ├── js/main.js          Mobile nav drawer + image lightbox
│   ├── fonts/              Space Grotesk (web font, see note below)
│   └── media/              Every image & video, downloaded locally (~430 MB)
└── build/
    ├── source/*.json       Snapshot of the original Cargo page data
    └── generate.ps1        Regenerates all .html + re-downloads media from source
```

## Viewing it locally

Any static file server works. Two easy options:

```powershell
# Node (recommended)
npx -y serve -l 4321 .

# or Python 3
python -m http.server 4321
```

Then open <http://localhost:4321>.

> Opening the files directly with `file://` mostly works, but some browsers block
> local web-fonts over `file://`, so a tiny local server is recommended.

## Deploying

It's a plain static site — drop the whole folder onto any static host:

- **Netlify / Vercel / Cloudflare Pages** — drag-and-drop the folder, no config.
- **GitHub Pages** — push to a repo and enable Pages on the root.

No server-side code, no environment variables.

## Notes & decisions

- **Fonts.** The original used *Monument Grotesk* and *Diatype* (commercial Dinamo
  fonts served by Cargo). Those licenses don't transfer off Cargo, so this rebuild
  uses **Space Grotesk** (SIL Open Font License) — a free grotesque that's visually
  close. To switch fonts, edit the `--font-main` variable and the `<link>` to
  `assets/fonts/space-grotesk.css` in each page.
- **Images & video** are downloaded into `assets/media/` so the site is fully
  self-contained.
- **YouTube / Vimeo** clips can't be downloaded as files, so they remain `<iframe>`
  embeds pointing at YouTube/Vimeo (deriva, fluido-obj, hidrontes, water-nodes).
- A few outbound links were already broken in the original site (e.g. a "Refresh
  magazine" link whose URL contains spaces). They were copied verbatim and can be
  fixed in the HTML when you have the correct URLs.

## Regenerating from source

If you change anything in `build/source/*.json` (or want to re-pull media), run:

```powershell
powershell -ExecutionPolicy Bypass -File build\generate.ps1
```

This rewrites every `.html` file and downloads any missing assets into
`assets/media/`. Editing the page `.html` files directly is also perfectly fine for
day-to-day tweaks.
