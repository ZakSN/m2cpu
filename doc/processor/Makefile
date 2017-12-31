TEX=latex
PDF=pdflatex
PDFVIEWER=qpdfview
SPELLCHECK=hunspell
SPELLFLAGS=-t
DOCUMENT=m2cpu_architecture

.PHONY: clean all spelling view

all: $(DOCUMENT).pdf

$(DOCUMENT).pdf: $(DOCUMENT).tex
	$(PDF) $(DOCUMENT).tex
	$(PDF) $(DOCUMENT).tex

spelling:
	$(SPELLCHECK) -t $(DOCUMENT).tex

view: $(DOCUMENT).pdf
	$(PDFVIEWER) $(DOCUMENT).pdf

clean:
	rm -f *.dvi
	rm -f *.out
	rm -f *.toc
	rm -f *.aux
	rm -f *.log
	rm -f *.pdf
	rm -f *.lof
	rm -f *.lot
