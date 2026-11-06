# Cameron Wimpy — Personal Website

I have tried to create a modern, responsive academic website built with [Quarto](https://quarto.org) featuring automated content management and (Typst) PDF generation. Given the challenges and unique preferences I may have, I have done my best to make the rest of this README useful for others (and me when I forget how I did this!).

🌐 **Live Site:** [cwimpy.com](https://cwimpy.com)

## 🏗️ Architecture

### Content Organization
```
├── _quarto.yml                 # Main configuration (navbar, footer, theme, render list)
├── _publish.yml                # Netlify publish target
├── _variables.yml              # Email, ORCID, links used via {{< var ... >}}
├── index.qmd                   # Homepage
├── research.qmd                # Publications (built from publications.bib)
├── rural.qmd                   # Rural Notes series landing page
├── software.qmd / templates.qmd
├── teaching.qmd                # Teaching overview
├── cv.qmd / now.qmd / contact.qmd / thank-you.qmd / 404.qmd
├── styles.qmd                  # Style guide (component reference, not linked)
├── posts/                      # Blog posts
│   ├── _metadata.yml           # Settings shared by every post (comments, dates)
│   ├── index.qmd               # Posts listing
│   └── [post-folders]/         # One folder per post: index.qmd + figures/data
├── teaching/courses/           # Course sites (kept in git, not rendered yet)
├── styles.scss                 # Light theme: colors + imports
├── custom-dark.scss            # Dark theme: colors + imports
├── _tokens.scss                # Spacing, type scale, radius, font stacks
├── _components.scss            # Index that imports the partials below, in order
├── scss/                       # Component styles, one file per area of the site
├── _includes/                  # HTML includes (fonts, cite dialog, schema.org)
├── scripts/                    # Build helpers (see "Building and publishing")
├── images/ , uploads/          # Site images; PDFs of papers and the CV
├── publications.bib            # Source for the research page
└── templates/                  # Typst templates for PDF versions of posts
```

### PDF Templates
- **`templates/post-template.typ`** - Blog post PDF generation
- **`templates/teaching-template.typ`** - Academic document formatting

## 🚀 Getting Started

### Prerequisites
- [Quarto](https://quarto.org/docs/get-started/) (latest version)
- R with `bib2df`, `dplyr`, and `readr` (the research page and homepage run small R chunks)
- [Typst](https://typst.app/) for PDF versions of posts
- **Fonts for the Typst PDFs only:** Minion Pro and Myriad Pro (or substitute with something like Times and Helvetica)

### Local Development
```bash
# Clone the repository
git clone https://github.com/cwimpy/cwimpy-website.git
cd cwimpy-website

# Preview the site
quarto preview

# Build the site
quarto render
```

### Adding Content

#### Blog Posts
Create a new folder in `posts/` with an `index.qmd` file:
```yaml
---
title: "Your Post Title"
date: "2024-01-15"
categories: [research, methodology]
format:
  html: default
  typst:
    output-file: "your-post-title.pdf"
---

Your content here...

::: {.content-visible when-format="html"}
[{{< fa file-pdf >}} Download PDF](your-post-title.pdf){.pdf-download}
:::
```

#### Teaching Materials
Add course files to appropriate folders in `teaching/`:
```yaml
---
title: "Course Name"
course-number: "POSC 2013"
semester: "Fall 2024"
date: "8/15/2024"
categories: [undergraduate, political science]
format:
  html: default
  typst:
    output-file: "posc-2013-syllabus.pdf"
---
```

## 🎨 Customization

### Color Scheme
Colors are CSS custom properties, defined once per theme: `styles.scss` (light) and `custom-dark.scss` (dark). Components only ever refer to the variables, so a color changes in one place.
- Primary: `#1e5f3e` (dark green) for headings
- Accent: `#287d40` (medium green) for links and buttons
- Background: `#fdfcf8` (warm off-white); dark mode uses `#111814` (green-black)

### Fonts
Loaded from Google Fonts in `_includes/fonts.html`; the stacks are set in `_tokens.scss`.
- **Headings:** Fraunces
- **Body text:** Source Serif 4
- **Navigation, buttons, small labels:** Inter
- **Code:** JetBrains Mono

(The Typst PDF templates are separate and still ask for Minion Pro and Myriad Pro.)

### Styles
`_components.scss` is only a list of imports. The rules live in `scss/`, one file per area (`_navbar.scss`, `_footer.scss`, `_home-features.scss`, and so on). The import order matters, so add new files to the list rather than reordering it.

## 🚢 Building and publishing

The site is rendered on my machine and uploaded to Netlify; Netlify does not build it. That means **what is live is whatever was last published from the local `_site` folder, not what is in git.**

```bash
scripts/build.sh --no-publish   # rebuild the map and OG cards, render locally
scripts/build.sh                # the same, then publish to Netlify
```

Flags: `--skip-data` skips the map rebuild, `--skip-og` skips the OG cards.

What the pieces do:
- `scripts/rucc-map.R` builds the homepage map and writes the counts the homepage quotes (`scripts/rucc-map-stats.csv`).
- `scripts/generate-og.py` builds the link-preview cards in `images/og/` (needs `pip install -r scripts/requirements.txt`). Add a page to its `PAGES` list to give it a card.
- `scripts/post-render.sh` runs automatically after every render, including the one `quarto publish` does. It removes iCloud/Dropbox duplicate files ("index 2.html") from `_site` and drops utility pages from the sitemap.

Two things to remember:
- A post without `draft: true` goes live on the next publish, along with every file its folder links to.
- Commit a post when you publish it, so git and the live site agree.

## 💬 Comments Setup (Giscus)

1. Enable Discussions in your GitHub repository settings
2. Visit [giscus.app](https://giscus.app)
3. Configure for your repository: `cwimpy/cwimpy-website`
4. Copy the generated `repo-id` and `category-id`
5. Update `posts/_metadata.yml` with your IDs

## 📧 Contact Form Setup

The contact form uses Netlify Forms. Once deployed to Netlify:
1. Forms are automatically detected and enabled
2. Submissions appear in your Netlify dashboard
3. Configure email notifications in Netlify settings
4. Spam protection is included via honeypot field

## 📚 Dependencies

### Core
- **Quarto** - Static site generator
- **Typst** - PDF generation engine
- **SCSS** - Styling and theming

### External Services
- **Netlify** - Hosting and form handling
- **Giscus** - GitHub-based commenting
- **Font Awesome** - Icon library

## 🛠️ Development Notes

### PDF Generation
- Uses Typst for fast compilation (vs. LaTeX)
- Custom templates for different content types
- Automatic font fallbacks if premium fonts unavailable
- Format-specific content blocks prevent PDF download links in PDFs

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🤝 Contributing

While this is a personal academic website, suggestions and improvements are welcome! Please feel free to:
- Report bugs via GitHub Issues
- Suggest features or improvements
- Submit pull requests for fixes

## 📞 Contact

**Cameron Wimpy**  
Department of Government, Law & Policy  
Arkansas State University  
Email: [cwimpy@astate.edu](mailto:cwimpy@astate.edu)  
Website: [cwimpy.com](https://cwimpy.com)

---

*Built with ❤️ using [Quarto](https://quarto.org) and deployed on [Netlify](https://netlify.com)*
