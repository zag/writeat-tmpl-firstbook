<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>
<xsl:variable name="title"> <xsl:value-of select="book/bookinfo/title" /></xsl:variable>
<xsl:variable name="subtitle"> <xsl:value-of select="book/bookinfo/subtitle" /></xsl:variable>
<xsl:variable name="abstract"> <xsl:value-of select="book/bookinfo/abstract" /></xsl:variable>

<xsl:template match="/">
<html>
	<head>

	     <title><xsl:copy-of select="$title" /></title>
             <meta name="description" content="{$abstract}"/>
           <!-- CSS : implied media="all" -->
         <link rel="stylesheet" href="data/l1.css"/>
        </head>
	<body>
<div id="content">        
          <div id="header">
           <h1><xsl:copy-of select="$title" /></h1>
           <h2><xsl:copy-of select="$subtitle" /></h2>
          </div><!-- #header -->


        <div id="description">
<!--            <xsl:copy-of select="book/preface/*" />-->
             <xsl:apply-templates select="book/preface"/> 
        </div><!-- #description -->
     <div id="cover">
      <div id="get">
        <a href="html/{$name}.html">
          <span>Open</span>
          HTML version 
          <span>(single-page)</span>
        </a>
        <a href="html-chunk/index.html">
          <span>Open</span>

          HTML version
          <span>(multiple-page)</span>
        </a>
       </div><!-- #get -->
        <div>
         <a href="data/bookcover.jpg" target="_blank">
          <img src="data/bookcover.jpg" alt="{$title}"/>
         </a>
        </div>
   </div> <!-- #cover -->
  <div id="footer">
      <div id="license">
        <p><a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/3.0/" target="_blank"><img alt="Creative Commons License" style="border-width: 0pt;" src="http://i.creativecommons.org/l/by-nc-sa/3.0/88x31.png"/></a>
This work is licensed under a <a href="http://creativecommons.org/licenses/by-nc-sa/3.0/" rel="license" target="_blank">Creative Commons Attribution-Noncommercial-Share Alike 3.0 Unported License</a> </p>
      </div>
    </div>
</div> <!-- #content-->
</body>

</html>
</xsl:template>

<xsl:template match="para">
  <p><xsl:apply-templates /></p>
</xsl:template>

</xsl:stylesheet>
