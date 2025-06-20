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
        [#text(font: "Myriad Pro", size: 9pt)[POLS 1013 - American National Government]]
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
  )[POLS 1013 - American National Government]
]
#v(0.3em)

// Course info section

#align(center)[
  #text(
    font: "Myriad Pro",
    size: 14pt,
    style: "italic",
    fill: rgb("#4a6b56")
  )[Fall 2024]
]
#v(0.5em)

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
  )[12/15/2024]
]

#v(1.5em)

// Document body
= Course Overview
<course-overview>
This course provided students with a comprehensive introduction to American national government during the Fall 2024 semester. We covered the Constitution, federalism, civil liberties and rights, political institutions, and contemporary policy challenges.

= Final Enrollment
<final-enrollment>
#strong[Students:] 78 \
#strong[Meeting Time:] MWF 10:00-10:50 AM \
#strong[Location:] HSS 1001

= Course Highlights
<course-highlights>
== Major Topics Covered
<major-topics-covered>
- Constitutional foundations and federalism
- Civil liberties and civil rights
- Congress, presidency, and federal judiciary
- Political parties and interest groups
- Public opinion and political participation
- Domestic and foreign policy processes

== Student Projects
<student-projects>
- Research papers on contemporary policy issues
- Group presentations on Supreme Court cases
- Mock congressional hearings on current legislation

= Assessment Results
<assessment-results>
- #strong[Class Average:] B+ (87.3%)
- #strong[Research Paper Average:] 85.2%
- #strong[Exam Performance:] Strong understanding of institutional processes
- #strong[Participation:] High engagement in political discussions

= Course Improvements for Future
<course-improvements-for-future>
Based on student feedback and learning outcomes: - Add more current events integration - Include more diverse political perspectives - Expand Supreme Court case studies - Increase interactive learning activities

= Student Feedback Highlights
<student-feedback-highlights>
#emph["Professor Wimpy made complex political concepts easy to understand and always encouraged thoughtful discussion."]

#emph["The research paper really helped me understand how government affects daily life."]

#emph["Great balance of theory and real-world examples."]

#horizontalrule

= Course Materials
<course-materials>
- #strong[Textbook:] American Government: Stories of a Nation (Abernathy)
- #strong[Supplemental readings:] Congressional Quarterly articles
- #strong[Guest speakers:] Local elected officials
- #strong[Field trip:] Arkansas State Capitol (optional)
