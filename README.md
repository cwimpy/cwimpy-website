# Cameron Wimpy — Personal Website

I have tried to create a modern, responsive academic website built with [Quarto](https://quarto.org) featuring automated content management and (Typst) PDF generation. Given the challenges and unique preferences I may have, I have done my best to make the rest of this README useful for others (and me when I forget how I did this!).

🌐 **Live Site:** [cwimpy.com](https://cwimpy.com)

## 🏗️ Architecture

### Content Organization
```
├── _quarto.yml                 # Main configuration
|—— _publish.yml                # Deploy to Netlify
├── index.qmd                   # Homepage
├── research.qmd                # Research & publications
├── cv.qmd                      # Curriculum vitae
├── contact.qmd                 # Contact form
|—— 
├── 404.qmd                     # Custom error page
├── posts/                      # Blog posts
│   ├── _metadata.yml           # Posts configuration
│   ├── index.qmd               # Posts listing
│   └── [post-folders]/         # Individual posts
├── teaching/                   # Teaching materials
│   ├── _metadata.yml           # Teaching configuration
│   ├── current/                # Current courses
│   ├── materials/              # Course resources
│   └── past/                   # Course archive
|── styles/                     # Custom styling
|   ├── styles.scss             # Main styles
|   └── custom-dark.scss        # Dark mode styles
|—— templates/                  # Typst templates
    ├── post-template.typ       # Typst template for PDF posts
    └── teaching-template.typ   # Typst template for teaching documents
```

### PDF Templates
- **`templates/post-template.typ`** - Blog post PDF generation
- **`templatesteaching-template.typ`** - Academic document formatting

## 🚀 Getting Started

### Prerequisites
- [Quarto](https://quarto.org/docs/get-started/) (latest version)
- [Typst](https://typst.app/) for PDF generation
- **Fonts:** Minion Pro and Myriad Pro (or substitute with something like Times and Helvetica)

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
The site uses a professional green color palette defined in `styles.scss`:
- Primary: `#1e5f3e` (dark green)
- Secondary: `#2d8a47` (medium green)
- Accent colors for different text weights

### Fonts
- **Body text:** Minion Pro (serif) - excellent readability
- **Headings:** Myriad Pro (sans-serif) - clean, modern
- **Code:** SF Mono - consistent monospace

### Dark Mode
Automatic dark mode with custom color palette defined in `custom-dark.scss`:
- Background: `#0f172a` (dark blue)
- Text: Light grays and blues
- Accent: `#4ade80` (bright green)

## 🚢 Deployment

### Netlify (my suggestion)
1. Connect your GitHub repository to Netlify
2. Set build command: `quarto render`
3. Set publish directory: `_site`
4. Enable form handling for contact form
5. Configure Giscus for comments (see setup below)

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
