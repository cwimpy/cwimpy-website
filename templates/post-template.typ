// Custom Typst template for blog posts
// Place this file as: post-template.typ in your project root

// Set up the document with fonts and basic styling
#set text(
  font: "Minion Pro",
  size: 11pt,
  lang: "en"
)

// Page setup with headers and footers
#set page(
  paper: "us-letter",
  margin: 1in,
  
  // Header - title on right (skip first page)
  header: locate(loc => {
    if counter(page).at(loc).first() > 1 {
      align(right, text(
        font: "Myriad Pro",
        size: 9pt,
        [$title$]
      ))
    }
  }),
  
  // Footer - date left, page center, Dr. Wimpy right
  footer: locate(loc => [
    #set text(font: "Myriad Pro", size: 9pt)
    #grid(
      columns: (1fr, auto, 1fr),
      align: (left, center, right),
      [$if(date)$date$endif$],
      counter(page).display(),
      [Dr. Wimpy]
    )
    #line(length: 100%, stroke: 0.4pt + gray)
  ])
)

// Paragraph settings
#set par(
  justify: true,
  leading: 0.65em,
  first-line-indent: 0pt
)

// Heading styles - all use Myriad Pro
#show heading.where(level: 1): it => {
  set text(font: "Myriad Pro", size: 18pt, weight: "bold")
  it
  v(0.5em)
}

#show heading.where(level: 2): it => {
  set text(font: "Myriad Pro", size: 14pt, weight: "bold")
  v(1em)
  it
  v(0.3em)
}

#show heading.where(level: 3): it => {
  set text(font: "Myriad Pro", size: 12pt, weight: "bold")
  v(0.8em)
  it
  v(0.2em)
}

// Code styling
#show raw.where(block: true): it => {
  set text(font: "SF Mono", size: 9pt)
  block(
    width: 100%,
    fill: rgb("#f6f8fa"),
    stroke: rgb("#d1d9e0"),
    radius: 3pt,
    inset: 8pt,
    it
  )
}

#show raw.where(block: false): it => {
  set text(font: "SF Mono", size: 9pt)
  box(
    fill: rgb("#f6f8fa"),
    stroke: rgb("#d1d9e0"),
    radius: 2pt,
    inset: (x: 3pt, y: 1pt),
    it
  )
}

// Link styling
#show link: it => {
  set text(fill: rgb("#2d8a47"))
  it
}

// Title styling
$if(title)$
#align(center)[
  #text(
    font: "Myriad Pro",
    size: 24pt,
    weight: "bold",
    fill: rgb("#1e5f3e"),
    [$title$]
  )
]
#v(0.5em)
$endif$

// Date styling
$if(date)$
#align(center)[
  #text(
    font: "Myriad Pro",
    size: 11pt,
    style: "italic",
    fill: rgb("#4a6b56"),
    [$date$]
  )
]
#v(1.5em)
$endif$

// Document body
$body$