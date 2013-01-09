all: work.done $(POD_NAME) $(DOCBOOK_NAME) $(HTML_NAME) html-chunk.done $(INDEX_HTML_FILE)

install:  $(HTML_NAME) html-chunk.done  $(INDEX_HTML_FILE)
	if [ -e ${PREFIX} ]; then \
	    RESULT_PATH=${PREFIX} && \
	    echo MAKE INSTALL TO $$RESULT_PATH ; \
	    mkdir -p $$RESULT_PATH && \
	    ( cd $(WORKDIR) &&  \
	      cp -Rp  ../$(WORKDIR_HTML) ../$(WORKDIR_HTML-CHUNK) ../$(WORKDIR_IMAGES) ../$(INDEX_HTML_FILE) ../$(WORKDIR)/data $$RESULT_PATH \
	     ) \
	fi

work.done: $(WORKDIR)

$(WORKDIR) $(WORKDIR_XML) $(WORKDIR_HTML) $(WORKDIR_HTML-CHUNK) $(WORKDIR_IMAGES):
	-@mkdir -p $@ > /dev/null 2>&1

img.done:$(WORKDIR_IMAGES) $(DOCBOOK_NAME)
	perl .writeat/relocate.pl -d $(SRC_POD_PATH)  -p ../img/ -todir $(WORKDIR_IMAGES)/< $(DOCBOOK_NAME) > $(DOCBOOK_NAME).text && \
	cp $(DOCBOOK_NAME).text $(DOCBOOK_NAME) && touch $@

$(POD_NAME): $(WORKDIR_XML)
	perl -e  'print "=begin pod\n=Include $(SRC_POD)\n=end pod"' > $@

$(DOCBOOK_NAME): $(WORKDIR_XML) $(POD_NAME)
	$(POD2BOOK) -lang en < $(POD_NAME)  >> $@

$(INDEX_XSLT_FILE): $(DOCBOOK_NAME)
	echo '<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">'\
	'<xsl:variable name="name">$(NAME)</xsl:variable>' \
	'<xsl:include href="../../.writeat/index.html-stylesheet.xsl"/>' \
	'</xsl:stylesheet>' > $@

#create index.html for book
$(INDEX_HTML_FILE): $(INDEX_XSLT_FILE)
	$(XSLTPROC) -o $@ $(INDEX_XSLT_FILE) $(DOCBOOK_NAME); \
	cp -Rp .writeat/data work

$(HTML_NAME): $(WORKDIR_HTML)  $(DOCBOOK_NAME) img.done
	$(XSLTPROC) -o $(HTML_NAME) $(HTML_STYLESHEET) $(DOCBOOK_NAME)  && cp $(CSS_FILE) $(WORKDIR_HTML)/docstyles.css

html-chunk.done: $(WORKDIR_HTML-CHUNK) $(DOCBOOK_NAME) img.done
	$(XSLTPROC)  \
	--output $(WORKDIR_HTML-CHUNK)/ \
	$(CHUNK_STYLESHEET) $(DOCBOOK_NAME) &&  cp $(CSS_FILE) $(WORKDIR_HTML-CHUNK)/docstyles.css && touch $@

clean:
	-@rm -Rf *.done work book img
