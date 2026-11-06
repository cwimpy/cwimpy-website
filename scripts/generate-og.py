#!/usr/bin/env python3
"""
Generate per-page Open Graph / Twitter Card images for cwimpy.com.

Output: 1200x630 PNG cards in images/og/, one per page in the PAGES list.
Uses the site's typography (Fraunces + Inter + JetBrains Mono) via Google Fonts
and matches the brand cream/green palette.

Run:    python3 scripts/generate-og.py            (all cards)
        python3 scripts/generate-og.py rural cv   (only the named cards)
Add a new page: append to PAGES below and re-run.
Needs: pip install -r scripts/requirements.txt && playwright install chromium
"""

import asyncio
import logging
import sys
import urllib.parse
from pathlib import Path
from typing import List, Tuple

from playwright.async_api import Error as PlaywrightError
from playwright.async_api import Page, async_playwright

logger = logging.getLogger(__name__)

ROOT = Path(__file__).resolve().parent.parent
TEMPLATE = ROOT / "scripts" / "og-template.html"
OUT_DIR  = ROOT / "images" / "og"
OUT_DIR.mkdir(parents=True, exist_ok=True)

# (slug, eyebrow, title, subtitle)
# Use "|" in title for an explicit line break.
PAGES: List[Tuple[str, str, str, str]] = [
    ("index", "Cameron Wimpy",
     "Political science|from rural America",
     "Associate Professor & Chair · Arkansas State University"),

    ("research", "Research",
     "Publications &|working papers",
     "Election administration · methodology · rural public policy"),

    ("teaching", "Teaching",
     "Courses & course|materials",
     "Graduate methods, comparative politics, and public policy"),

    ("software", "Software",
     "Open-source|research tools",
     "R packages, replication code, and analysis scripts"),

    ("cv", "Curriculum Vitae",
     "Cameron Wimpy",
     "Associate Professor & Chair, Government, Law & Policy"),

    ("now", "Now",
     "What I'm working|on right now",
     "A snapshot of current research, teaching, and reading"),

    ("contact", "Contact",
     "Get in touch",
     "Email, office, social, and meeting links"),

    ("posts", "Posts",
     "Writing on teaching,|research, & academic life",
     "Field notes from a working political scientist"),

    ("rural", "Rural Notes",
     "Working notes on|rural measurement",
     "Research in progress on rural attitudes and policy"),

    ("plsc-66003-fall2026", "PLSC 66003 · Fall 2026",
     "Advanced|Political Analysis",
     "Graduate quantitative methods in R"),

    ("plsc-4489v-fall2026", "PLSC 4489V / 6680V · Fall 2026",
     "Election Administration|and Voting",
     "How American elections actually get run"),

    ("404", "Not Found",
     "Page not found",
     "Looks like you wandered off the Ridge."),
]


async def render_card(page: Page, slug: str, eyebrow: str, title: str, subtitle: str) -> None:
    """Render one 1200x630 card to images/og/<slug>.png."""
    template_url = "file://" + str(TEMPLATE)
    params = urllib.parse.urlencode({
        "eyebrow":  eyebrow,
        "title":    title,
        "subtitle": subtitle,
    }, quote_via=urllib.parse.quote)
    # Cache-bust with the slug as a query param so each navigation is a real reload
    url = f"{template_url}?slug={slug}#{params}"

    await page.goto("about:blank")
    await page.goto(url, wait_until="networkidle", timeout=15000)
    # Wait for fonts to actually settle
    await page.evaluate("document.fonts.ready")
    await page.wait_for_timeout(200)

    out_path = OUT_DIR / f"{slug}.png"
    await page.screenshot(
        path=str(out_path),
        clip={"x": 0, "y": 0, "width": 1200, "height": 630},
        omit_background=False,
    )
    logger.info("wrote %s", out_path.relative_to(ROOT))


async def main(only: List[str]) -> None:
    """Render every card in PAGES, or only the slugs named on the command line."""
    pages = [entry for entry in PAGES if not only or entry[0] in only]
    unknown = set(only) - {entry[0] for entry in PAGES}
    if unknown:
        raise ValueError(f"Unknown card slug(s): {sorted(unknown)}")
    async with async_playwright() as p:
        try:
            browser = await p.chromium.launch()
        except PlaywrightError:
            # Playwright's own Chromium is not installed; use the Google Chrome
            # already on this machine instead of failing.
            logger.warning("Bundled Chromium not found; using installed Google Chrome.")
            browser = await p.chromium.launch(channel="chrome")
        ctx = await browser.new_context(
            viewport={"width": 1200, "height": 630},
            device_scale_factor=1,
        )
        page = await ctx.new_page()
        for entry in pages:
            await render_card(page, *entry)
        await ctx.close()
        await browser.close()
    logger.info("Generated %d OG card(s) in images/og/", len(pages))


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO, format="%(message)s")
    asyncio.run(main(sys.argv[1:]))
