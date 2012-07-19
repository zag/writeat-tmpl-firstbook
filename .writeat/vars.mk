WORKDIR = work

WORKDIR_GIT = $(WORKDIR)/git
WORKDIR_XML = $(WORKDIR)/xml
WORKDIR_HTML-CHUNK = $(WORKDIR)/html-chunk
WORKDIR_HTML = $(WORKDIR)/html
WORKDIR_IMAGES = $(WORKDIR)/img

NAME =  $(basename $(notdir $(SRC_POD)))
SRC_POD_PATH = $(dir $(SRC_POD))
POD_NAME=$(WORKDIR_XML)/$(NAME).pod
DOCBOOK_NAME = $(WORKDIR_XML)/$(NAME).xml
HTML_NAME = $(WORKDIR_HTML)/$(NAME).html
CSS_FILE = .writeat/docstyles.css
INDEX_XSLT_FILE = $(WORKDIR_XML)/$(NAME).xsl
INDEX_HTML_FILE = $(WORKDIR)/index.html

#DETECT OS = [Linux, FreeBSD]
ifeq ($(shell uname),FreeBSD)
	OS ?="FreeBSD"
endif
OS ?=Linux

XSLTPROC= /usr/bin/xsltproc
HTML_STYLESHEET=.writeat/html-stylesheet.xsl
CHUNK_STYLESHEET=.writeat/chunk-stylesheet.xsl
POD2BOOK=writeat
DOCSCHEME=file:///usr/share/xml/docbook/schema/dtd/4.5/docbookx.dtd
#SETUP VARIABLES
ifeq ($(OS),"FreeBSD")
XSLTPROC= /usr/local/bin/xsltproc
HTML_STYLESHEET=.writeat/html-stylesheet.bsd.xsl
CHUNK_STYLESHEET=.writeat/chunk-stylesheet.bsd.xsl
DOCSCHEME=file:///usr/local/share/xml/docbook/4.5/docbookx.dtd
endif
