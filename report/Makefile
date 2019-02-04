all: report.docx report.odt

report.docx: report.tex
	pandoc -s $< -o $@

report.odt: report.tex
	pandoc -s $< -o $@

clean:
	rm report.docx report.odt
