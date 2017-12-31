## Documentation For the M2CPU Project
This directory contains the documentation for the processor and some 
documentation for other parts of the project.

The loose markdown files in this directory contain implementation notes that
largely exist so that I don't forget how stuff works. The Libre Office Calc
spreadsheet (`m2cpu_ISA.ods`) contains a colour coded table of the processor's
75 instruction codes (useful programming reference).

The directory `processor` contains extensive LaTeX documentation for the 
processor and its instruction set. To build a PDF from the LaTeX source in

```
$ cd "${CHECKOUT_ROOT}"/doc/processor
$ make
```

You may need to install some additional TeX libraries dependanding on what
distribution of LaTeX you're using. The makke file assumes that the program
`pdflatex` is in your $PATH and knows how to make PDFs from .tex files. If this
is not true you'll need to take a hack at the makefile. Two other targets are 
provided in the makefile in case you feel like edititng my documentation; they
are:

```
$ make view
```
and
```
$ make spelling
```

`view` compiles the document and opens a pdf viewer. The pdf viewer to use is
set by the `PDFVIEWER` variable in the makefile. It defaults to my favourite
pdf viewer `qpdfview`.

`spelling` runs a simple spell check on the document. It assumes that 
`hunspell` exists in your $PATH and knows where to find its dictionaries.

The LaTeX docs are the authoritative source of documentation for the M2CPU.
