// Clean academic document template for teaching materials
// Replace your existing teaching-template.typ with this content

#set text(font: "Minion Pro", size: 11pt)

#set page(
  paper: "us-letter",
  margin: 1in,
  header: context [
    #if counter(page).get().first() > 1 [
      #grid(
        columns: (1fr, 1fr),
        align: (left, right),
        [#text(font: "Myriad Pro", size: 9pt)[Dr. Cameron Wimpy]],
        [#text(font: "Myriad Pro", size: 9pt)[$title$]]
      )
      #line(length: 100%, stroke: 0.4pt + gray)
    ]
  ],
  footer: context [
    #set text(font: "Myriad Pro", size: 9pt)
    #grid(
      columns: (1fr, auto, 1fr),
      align: (left, center, right),
      [Arkansas State University],
      counter(page).display(),
      [$if(date)$date$else$[]$endif$]
    )
    #line(length: 100%, stroke: 0.4pt + gray)
  ]
)

#set par(justify: true, leading: 0.65em, first-line-indent: 0pt)

#let horizontalrule = line(length: 100%, stroke: 1pt + gray)

#show heading.where(level: 1): it => [
  #set text(font: "Myriad Pro", size: 20pt, weight: "bold")
  #align(center)[#it]
  #v(0.8em)
]

#show heading.where(level: 2): it => [
  #set text(font: "Myriad Pro", size: 16pt, weight: "bold")
  #v(1.2em)
  #it
  #v(0.5em)
]

#show heading.where(level: 3): it => [
  #set text(font: "Myriad Pro", size: 14pt, weight: "bold")
  #v(1em)
  #it
  #v(0.3em)
]

#show heading.where(level: 4): it => [
  #set text(font: "Myriad Pro", size: 12pt, weight: "bold")
  #v(0.8em)
  #it
  #v(0.2em)
]

#show raw.where(block: true): it => [
  #set text(font: "SF Mono", size: 9pt)
  #block(
    width: 100%,
    fill: rgb("#f6f8fa"),
    stroke: rgb("#d1d9e0"), 
    radius: 3pt,
    inset: 8pt
  )[#it]
]

#show raw.where(block: false): it => [
  #set text(font: "SF Mono", size: 9pt)
  #box(
    fill: rgb("#f6f8fa"),
    stroke: rgb("#d1d9e0"),
    radius: 2pt, 
    inset: (x: 3pt, y: 1pt)
  )[#it]
]

#show link: it => [
  #set text(fill: rgb("#2d8a47"))
  #it
]

#show table: it => [
  #set text(size: 10pt)
  #block(
    width: 100%,
    stroke: rgb("#d1d9e0"),
    radius: 3pt,
    inset: 0pt
  )[#it]
]

#set list(indent: 1em, body-indent: 0.5em)
#set enum(indent: 1em, body-indent: 0.5em)

$if(title)$
#align(center)[
  #text(
    font: "Myriad Pro",
    size: 24pt,
    weight: "bold", 
    fill: rgb("#1e5f3e")
  )[$title$]
]
#v(0.3em)
$endif$

$if(course-number)$
#align(center)[
  #text(
    font: "Myriad Pro",
    size: 16pt,
    weight: "semibold",
    fill: rgb("#2d8a47")
  )[$course-number$]
]
#v(0.2em)
$endif$

$if(semester)$
#align(center)[
  #text(
    font: "Myriad Pro",
    size: 14pt,
    style: "italic",
    fill: rgb("#4a6b56")
  )[$semester$]
]
#v(0.5em)
$endif$

#align(center)[
  #text(
    font: "Myriad Pro",
    size: 11pt,
    fill: rgb("#4a6b56")
  )[
    Department of Government, Law & Policy \
    Arkansas State University
  ]
]

$if(date)$
#align(center)[
  #text(
    font: "Myriad Pro",
    size: 10pt,
    style: "italic",
    fill: rgb("#7a9b87")
  )[$date$]
]
$endif$

#v(1.5em)

$body$