TEX=latex
PDF=pdflatex
PDFVIEWER=qpdfview
SPELLCHECK=hunspell
SPELLFLAGS=-t
DOCUMENT=m2cpu_architecture

.PHONY: clean all spelling view

all: spelling $(DOCUMENT).pdf view

$(DOCUMENT).pdf: $(DOCUMENT).tex
	$(PDF) $(DOCUMENT).tex
	$(PDF) $(DOCUMENT).tex

spelling:
	$(SPELLCHECK) -t $(DOCUMENT).tex

view: $(DOCUMENT).pdf
	$(PDFVIEWER) $(DOCUMENT).pdf

clean:
	rm *.dvi
	rm *.out
	rm *.toc
	rm *.aux
	rm *.log
	rm *.pdf
