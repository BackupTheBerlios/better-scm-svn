all: comparison.html 

db: scm-comparison.pdf
	
comparison.dtd: gen-dtd.pl
	perl gen-dtd.pl > $@

comparison.html: render.pl scm-comparison.xml comparison.dtd ScmCompare.pm
	perl render.pl

FILES = comparison.html render.pl render-docbook.pl scm-comparison.xml bk-license.html Makefile comparison.dtd gen-dtd.pl ScmCompare.pm

docbook/scm-comparison.xml: scm-comparison.xml render-docbook.pl ScmCompare.pm
	perl render-docbook.pl

scm-comparison.pdf: docbook/scm-comparison.xml
	db2pdf -c /etc/sgml/catalog -d './mystyle.dsl#print' $<

upload: all $(FILES)
	rsync --progress -v --rsh=ssh $(FILES) shlomif@shell.berlios.de:/home/groups/better-scm/htdocs/comparison


	
