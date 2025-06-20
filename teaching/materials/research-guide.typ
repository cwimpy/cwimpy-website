// Academic document template for teaching materials
// Place this file as: teaching-template.typ in your project root

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
        [#text(font: "Myriad Pro", size: 9pt)[Political Science Research Guide]]
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
      [date]
    )
    #line(length: 100%, stroke: 0.4pt + gray)
  ]
)

#set par(justify: true, leading: 0.65em, first-line-indent: 0pt)

// Define horizontal rule function for compatibility
#let horizontalrule = line(length: 100%, stroke: 1pt + gray)

// Course/document title styling
#show heading.where(level: 1): it => [
  #set text(font: "Myriad Pro", size: 20pt, weight: "bold", fill: rgb("#1e5f3e"))
  #align(center)[#it]
  #v(0.8em)
]

// Major section headings
#show heading.where(level: 2): it => [
  #set text(font: "Myriad Pro", size: 16pt, weight: "bold", fill: rgb("#1e5f3e"))
  #v(1.2em)
  #it
  #v(0.5em)
]

// Subsection headings
#show heading.where(level: 3): it => [
  #set text(font: "Myriad Pro", size: 14pt, weight: "bold", fill: rgb("#2d8a47"))
  #v(1em)
  #it
  #v(0.3em)
]

// Sub-subsection headings
#show heading.where(level: 4): it => [
  #set text(font: "Myriad Pro", size: 12pt, weight: "bold")
  #v(0.8em)
  #it
  #v(0.2em)
]

// Code styling
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

// Link styling
#show link: it => [
  #set text(fill: rgb("#2d8a47"))
  #it
]

// Table styling
#show table: it => [
  #set text(size: 10pt)
  #block(
    width: 100%,
    stroke: rgb("#d1d9e0"),
    radius: 3pt,
    inset: 0pt
  )[#it]
]

// List styling with better spacing
#set list(indent: 1em, body-indent: 0.5em)
#set enum(indent: 1em, body-indent: 0.5em)

// Document header info
#align(center)[
  #text(
    font: "Myriad Pro",
    size: 24pt,
    weight: "bold", 
    fill: rgb("#1e5f3e")
  )[Political Science Research Guide]
]
#v(0.3em)

// Course info section


// Department and contact info
#align(center)[
  #text(
    font: "Myriad Pro",
    size: 11pt,
    fill: rgb("#4a6b56")
  )[
    Department of Government, Law & Policy \
    Arkansas State University \
    #link("mailto:cwimpy@astate.edu")[cwimpy@astate.edu]
  ]
]

#align(center)[
  #text(
    font: "Myriad Pro",
    size: 10pt,
    style: "italic",
    fill: rgb("#7a9b87")
  )[8/20/2024]
]

#v(1.5em)

// Document body
= Getting Started with Political Science Research
<getting-started-with-political-science-research>
Research is at the heart of political science. This guide will help you navigate the research process from topic selection to final paper submission.

= Finding Quality Sources
<finding-quality-sources>
== Academic Databases
<academic-databases>
- #strong[JSTOR] - Academic articles and books
- #strong[Political Science Complete] - Discipline-specific database
- #strong[LexisNexis Academic] - News and legal documents
- #strong[CQ Researcher] - Policy analysis and reports

== Government Sources
<government-sources>
- #strong[Congressional Research Service] - #link("https://crsreports.congress.gov")[crsreports.congress.gov]
- #strong[Government Accountability Office] - #link("https://www.gao.gov")[gao.gov]
- #strong[Census Bureau] - #link("https://www.census.gov")[census.gov]
- #strong[Bureau of Labor Statistics] - #link("https://www.bls.gov")[bls.gov]

== Think Tanks & Research Organizations
<think-tanks-research-organizations>
- #strong[Brookings Institution] - Centrist policy research
- #strong[American Enterprise Institute] - Conservative perspectives
- #strong[Center for American Progress] - Progressive viewpoints
- #strong[Pew Research Center] - Public opinion polling

= Citation Guidelines
<citation-guidelines>
All papers must use #strong[APSA (American Political Science Association)] citation style.

== Book Example
<book-example>
Putnam, Robert D. 2000. #emph[Bowling Alone: The Collapse and Revival of American Community];. New York: Simon & Schuster.

== Journal Article Example
<journal-article-example>
Bartels, Larry M. 2008. "Unequal Democracy: The Political Economy of the New Gilded Age." #emph[American Political Science Review] 102(1): 1-18.

== Online Source Example
<online-source-example>
Pew Research Center. 2024. "Public Trust in Government Remains Low." Retrieved August 15, 2024 (https:\/\/www.pewresearch.org/politics/).

= Writing Tips
<writing-tips>
== Structure Your Argument
<structure-your-argument>
+ #strong[Introduction] - State your thesis clearly
+ #strong[Literature Review] - What do we already know?
+ #strong[Analysis] - Present your evidence
+ #strong[Conclusion] - Summarize findings and implications

== Common Mistakes to Avoid
<common-mistakes-to-avoid>
- Using Wikipedia as a source
- Failing to cite properly
- Making claims without evidence
- Ignoring counterarguments
- Poor grammar and spelling

= Getting Help
<getting-help>
- #strong[Writing Center:] Free tutoring and feedback
- #strong[Library Research Desk:] Help finding sources
- #strong[Professor Office Hours:] Discuss ideas and get feedback
- #strong[Study Groups:] Collaborate with classmates

Remember: Start early, cite everything, and don't hesitate to ask for help!
