<!--
This is a⸠n extremely simple⸡ progressively‐less‐simple X·S·L·T
transform which simply reads in a `template.xml` and :—

• Replaces the `<html:shrine-content>` element with the content of the document it is being applied to,

• If the root element of the document it is being applied to has a `@data-shrine-header` attribute, replaces the `<html:shrine-header>` with the contents of the corresponding header file (`⸺-header.xml`), and

• If the root element of the document it is being applied to has a `@data-shrine-footer` attribute, replaces the `<html:shrine-footer>` with the contents of the corresponding footer file (`⸺-footer.xml`), and

• Copies any remaining `@lang` or `@data-*` attributes from the root element of the document it is being applied to over to the root element of the template.

The intent is that this file is used in conjunction with a Makefile to quickly automate inserting header and footer content into documents.
The exact feature·set might be somewhat more expansive than the description above; for a lengthier overview of what this file does, see `README.markdown`.

Feel free to add additional templates and features to suit your needs!

___

© 2022 Margaret KIBI

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.
-->
<!DOCTYPE xslt:transform [
	<!ENTITY Atom "http://www.w3.org/2005/Atom">
	<!ENTITY xhtml "http://www.w3.org/1999/xhtml">
]>
<xslt:transform
	xmlns:atom="&Atom;"
	xmlns:html="&xhtml;"
	xmlns:xslt="http://www.w3.org/1999/XSL/Transform"
	version="1.0"
>
	<xslt:param name="BASEIRI" select="'http://example.com'"/>
	<xslt:param name="DATETIME" select="'1972-12-31T00:00:00Z'"/>
	<xslt:param name="OUTPUTPATH" select="'/unknown'"/>
	<xslt:variable name="baseiri">
		<xslt:choose>
			<xslt:when test="contains($BASEIRI, '://')"> <!-- there is an authority -->
				<xslt:variable name="noscheme" select="substring-after($BASEIRI, '://')"/>
				<xslt:value-of select="substring-before($BASEIRI, '://')"/>
				<xslt:text>://</xslt:text>
				<xslt:choose>
					<xslt:when test="contains($noscheme, '/')">
						<xslt:value-of select="substring-before($noscheme, '/')"/>
					</xslt:when>
					<xslt:otherwise>
						<xslt:value-of select="$noscheme"/>
					</xslt:otherwise>
				</xslt:choose>
			</xslt:when>
			<xslt:otherwise>
				<xslt:value-of select="substring-before($BASEIRI, ':')"/>
			</xslt:otherwise>
		</xslt:choose>
	</xslt:variable>
	<xslt:variable name="datetime" select="string($DATETIME)"/>
	<xslt:variable name="outputpath">
		<xslt:if test="not(starts-with($OUTPUTPATH, '/'))">
			<xslt:text>/</xslt:text>
		</xslt:if>
		<xslt:value-of select="$OUTPUTPATH"/>
	</xslt:variable>
	<xslt:variable name="source" select="current()"/>
	<xslt:variable name="template" select="document('./template.xml')"/>

	<!--
		Instead of actually processing the root node, process the template in `template` mode.
	-->
	<xslt:template match="/">
		<xslt:choose>
			<xslt:when test="atom:feed">
				<xslt:apply-templates mode="feed"/>
			</xslt:when>
			<xslt:otherwise>
				<xslt:apply-templates select="$template" mode="template"/>
			</xslt:otherwise>
		</xslt:choose>
	</xslt:template>

	<!--
		Process non‐template elements.
		By default, just copy the element, but remove any `@data-shrine-*` attribuets or `@slot` attributes with a value that begins with `shrine-`.
		Some elements may have special treatment.
	-->
	<xslt:template match="*" mode="content">
		<xslt:element name="{local-name()}">
			<xslt:for-each select="@*[not(starts-with(name(), 'data-shrine-')) and not((name()='slot' or name()='itemprop') and starts-with(., 'shrine-'))]">
				<xslt:copy/>
			</xslt:for-each>
			<xslt:for-each select="*|text()">
				<xslt:choose>
					<xslt:when test="@slot[starts-with(., 'shrine-')]">
						<xslt:comment>
							<xslt:text> placeholder for slotted element </xslt:text>
						</xslt:comment>
					</xslt:when>
					<xslt:otherwise>
						<xslt:apply-templates select="." mode="content"/>
					</xslt:otherwise>
				</xslt:choose>
			</xslt:for-each>
		</xslt:element>
	</xslt:template>

	<!--
		Drop `<meta>` elements which only provide shrine microdata.
	-->
	<xslt:template match="html:meta[not(@name)][starts-with(@itemprop, 'shrine-')]" mode="content">
		<xslt:comment>
			<xslt:text> placeholder for metadata element </xslt:text>
		</xslt:comment>
	</xslt:template>

	<!--
		Process text content; just make a copy.
	-->
	<xslt:template match="text()" mode="content">
		<xslt:copy/>
	</xslt:template>

	<!--
		Process template elements.
		By default, just copy the element.
		This behaviour will be overridden for certain elements to insert the page content.
	-->
	<xslt:template match="*" mode="template">
		<xslt:element name="{local-name()}">
			<xslt:for-each select="@*">
				<xslt:copy/>
			</xslt:for-each>
			<xslt:apply-templates mode="template"/>
		</xslt:element>
	</xslt:template>

	<!--
		Process template text; just make a copy.
	-->
	<xslt:template match="text()" mode="template">
		<xslt:copy/>
	</xslt:template>

	<!--
		Process the template `<html>` elements.
		This copies over `@lang` and non‐shrine `@data-*` attributes from the root node.
	-->
	<xslt:template match="html:html" mode="template">
		<html>
			<xslt:for-each select="@*[not(starts-with(name(), 'xmlns'))]">
				<xslt:copy/>
			</xslt:for-each>
			<xslt:for-each select="$source/*/@*[name()='lang' or starts-with(name(), 'data-') and not(starts-with(name(), 'data-shrine-'))]">
				<xslt:if test="not($template/*/@*[name()=name(current())])">
					<xslt:copy/>
				</xslt:if>
			</xslt:for-each>
			<xslt:apply-templates mode="template"/>
		</html>
	</xslt:template>

	<!--
		Process the template `<head>` elements.
		This inserts appropriate metadata based on the document.
	-->
	<xslt:template match="html:head" mode="template">
		<head>
			<xslt:for-each select="@*">
				<xslt:copy/>
			</xslt:for-each>
			<xslt:if test="not(html:title) and not($source//html:title[@slot='shrine-head'])">
				<xslt:choose>
					<xslt:when test="$source//*[@itemprop='shrine-title']">
						<xslt:apply-templates select="$source//*[@itemprop='shrine-title'][1]" mode="microdata">
							<xslt:with-param name="tagname" select="'title'"/>
							<xslt:with-param name="plaintext" select="true()"/>
						</xslt:apply-templates>
					</xslt:when>
					<xslt:when test="$source//html:h1">
						<title>
							<xslt:apply-templates select="$source//html:h1[1]" mode="text"/>
						</title>
					</xslt:when>
				</xslt:choose>
			</xslt:if>
			<meta name="generator" content="https://github.com/marrus-sh/shrine-xslt"/>
			<xslt:apply-templates mode="template"/>
			<xslt:for-each select="$source//*[@slot='shrine-head']">
				<xslt:apply-templates select="." mode="content"/>
			</xslt:for-each>
		</head>
	</xslt:template>

	<!--
		Process the template header and footer.
		Read the corresponding `@data-header` or `@data-footer` attribute of the root element, append `"-header.xml"` or `"-footer.xml"` to the end of it, and process the resulting document.
		If no `@data-header` or `@data-footer` attribute is provided, nothing is rendered.
	-->
	<xslt:template match="html:shrine-header|html:shrine-footer" mode="template">
		<xslt:param name="context" select="'shrine-template'"/>
		<xslt:variable name="kind" select="substring-after(local-name(), 'shrine-')"/>
		<xslt:choose>
			<xslt:when test="$context='shrine-template'">
				<xslt:for-each select="$source/*/@*[name()=concat('data-shrine-', $kind)]">
					<xslt:for-each select="document(concat('./', ., '-', $kind, '.xml'), $template)/*">
						<xslt:element name="{local-name()}">
							<xslt:for-each select="@*">
								<xslt:copy/>
							</xslt:for-each>
							<xslt:for-each select="$source//*[@slot=concat('shrine-', $kind, '-before')]">
								<xslt:apply-templates select="." mode="content"/>
							</xslt:for-each>
							<xslt:apply-templates mode="template">
								<xslt:with-param name="context" select="concat('shrine-', $kind)"/>
							</xslt:apply-templates>
							<xslt:for-each select="$source//*[@slot=concat('shrine-', $kind, '-after')]">
								<xslt:apply-templates select="." mode="content"/>
							</xslt:for-each>
						</xslt:element>
					</xslt:for-each>
				</xslt:for-each>
			</xslt:when>
			<xslt:otherwise>
				<xslt:element name="{local-name()}">
					<xslt:for-each select="@*">
						<xslt:copy/>
					</xslt:for-each>
					<xslt:apply-templates mode="template"/>
				</xslt:element>
			</xslt:otherwise>
		</xslt:choose>
	</xslt:template>

	<!--
		Process the content.
	-->
	<xslt:template match="html:shrine-content" mode="template">
		<xslt:apply-templates select="$source/*" mode="content"/>
	</xslt:template>

	<!--
		Process miscellaneous template slots.
	-->
	<xslt:template match="html:slot[not(ancestor::html:template)]" mode="template">
		<xslt:param name="context" select="'shrine-template'"/>
		<xslt:variable name="name" select="string(@name)"/>
		<xslt:for-each select="$source//*[@slot=concat($context, '-slot-', $name)]">
			<xslt:apply-templates select="." mode="content"/>
		</xslt:for-each>
	</xslt:template>

	<!--
		Process feed elements and text.
		By default, just make a copy.
		This behaviour will be overridden for certain elements to generate feed metadata.
	-->
	<xslt:template match="*|text()" mode="feed">
		<xslt:copy>
			<xslt:for-each select="@*">
				<xslt:copy/>
			</xslt:for-each>
			<xslt:apply-templates mode="feed"/>
		</xslt:copy>
	</xslt:template>

	<!--
		Process the root feed element.
		This adds required metadata when it has not been provided in the source X·M·L.
	-->
	<xslt:template match="atom:feed" mode="feed">
		<xslt:text>&#x0A;</xslt:text> <!-- ensure a newline between the doctype and the feed element -->
		<feed xmlns="&Atom;">
			<xslt:for-each select="@*">
				<xslt:copy/>
			</xslt:for-each>
			<xslt:apply-templates select="text()[following-sibling::*[not(self::atom:entry)]]|*[not(self::atom:entry)]" mode="feed"/>
			<xslt:if test="not(atom:id)">
				<xslt:text>&#x0A;&#x09;</xslt:text>
				<id>
					<xslt:choose>
						<xslt:when test="contains($baseiri, '://')">
							<xslt:text>oai:</xslt:text>
							<xslt:value-of select="substring-after($baseiri, '://')"/>
							<xslt:text>:</xslt:text>
						</xslt:when>
						<xslt:otherwise>
							<xslt:value-of select="$baseiri"/>
							<xslt:text>/</xslt:text>
						</xslt:otherwise>
					</xslt:choose>
					<xslt:value-of select="$outputpath"/>
				</id>
			</xslt:if>
			<xslt:if test="not(atom:title)">
				<xslt:text>&#x0A;&#x09;</xslt:text>
				<title xml:lang="en">Untitled</title>
			</xslt:if>
			<xslt:if test="not(atom:author)">
				<xslt:text>&#x0A;&#x09;</xslt:text>
				<author>
					<name xml:lang="en">Anonymous</name>
				</author>
			</xslt:if>
			<xslt:if test="not(atom:link[@rel='alternate'][@type='text/html'])">
				<xslt:text>&#x0A;&#x09;</xslt:text>
				<link rel="alternate" type="text/html" href="{$baseiri}/"/>
			</xslt:if>
			<xslt:if test="not(atom:link[@rel='self'])">
				<xslt:text>&#x0A;&#x09;</xslt:text>
				<link rel="self" type="application/atom+xml" href="{$baseiri}{$outputpath}"/>
			</xslt:if>
			<xslt:if test="not(atom:updated)">
				<xslt:text>&#x0A;&#x09;</xslt:text>
				<updated>
					<xslt:value-of select="$datetime"/>
				</updated>
			</xslt:if>
			<xslt:if test="not(atom:generator)">
				<xslt:text>&#x0A;&#x09;</xslt:text>
				<generator uri="https://github.com/marrus-sh/shrine-xslt">shrine-xslt</generator>
			</xslt:if>
			<xslt:apply-templates select="atom:entry" mode="feed"/>
			<xslt:text>&#x0A;</xslt:text> <!-- newline before close tag -->
		</feed>
	</xslt:template>

	<!--
		Process feed entry elements.
	-->
	<xslt:template match="atom:entry[atom:link[@rel='alternate'][starts-with(@href, '/')][@type='text/html']]" mode="feed">
		<xslt:variable name="entryhref" select="atom:link[@rel='alternate'][starts-with(@href, '/')][@type='text/html'][1]/@href"/>
		<xslt:variable name="srchref">
			<xslt:text>./sources</xslt:text>
			<xslt:choose>
				<xslt:when test="substring($entryhref, string-length($entryhref))='/'">
					<xslt:value-of select="substring($entryhref, 1, string-length($entryhref) - 1)"/>
					<xslt:text>.xml</xslt:text>
				</xslt:when>
				<xslt:when test="substring($entryhref, string-length($entryhref) - 4)='.html'">
					<xslt:value-of select="substring($entryhref, 1, string-length($entryhref) - 4)"/>
					<xslt:text>xml</xslt:text>
				</xslt:when>
				<xslt:otherwise>
					<xslt:value-of select="$entryhref"/>
				</xslt:otherwise>
			</xslt:choose>
		</xslt:variable>
		<xslt:variable name="srcdoc" select="document($srchref)"/>
		<xslt:text>&#x0A;&#x09;</xslt:text>
		<entry xmlns="&Atom;">
			<xslt:for-each select="@*">
				<xslt:copy/>
			</xslt:for-each>
			<xslt:apply-templates select="text()[following-sibling::*]|*" mode="feed"/>
			<xslt:if test="not(atom:id)">
				<xslt:text>&#x0A;&#x09;&#x09;</xslt:text>
				<xslt:choose>
					<xslt:when test="$srcdoc//*[@itemprop='shrine-id']">
						<xslt:apply-templates select="$srcdoc//*[@itemprop='shrine-id'][1]" mode="microdata">
							<xslt:with-param name="tagname" select="'id'"/>
							<xslt:with-param name="namespace" select="'&Atom;'"/>
							<xslt:with-param name="plaintext" select="true()"/>
						</xslt:apply-templates>
					</xslt:when>
					<xslt:otherwise>
						<id>
							<xslt:choose>
								<xslt:when test="contains($baseiri, '://')">
									<xslt:text>oai:</xslt:text>
									<xslt:value-of select="substring-after($baseiri, '://')"/>
									<xslt:text>:</xslt:text>
								</xslt:when>
								<xslt:otherwise>
									<xslt:value-of select="$baseiri"/>
									<xslt:text>/</xslt:text>
								</xslt:otherwise>
							</xslt:choose>
							<xslt:value-of select="$entryhref"/>
						</id>
					</xslt:otherwise>
				</xslt:choose>
			</xslt:if>
			<xslt:if test="not(atom:title)">
				<xslt:text>&#x0A;&#x09;&#x09;</xslt:text>
				<xslt:choose>
					<xslt:when test="$srcdoc//*[@itemprop='shrine-title']">
						<xslt:apply-templates select="$srcdoc//*[@itemprop='shrine-title'][1]" mode="microdata">
							<xslt:with-param name="tagname" select="'title'"/>
							<xslt:with-param name="namespace" select="'&Atom;'"/>
						</xslt:apply-templates>
					</xslt:when>
					<xslt:when test="$srcdoc//html:h1">
						<xslt:apply-templates select="$srcdoc//html:h1[1]" mode="microdata">
							<xslt:with-param name="tagname" select="'title'"/>
							<xslt:with-param name="namespace" select="'&Atom;'"/>
						</xslt:apply-templates>
					</xslt:when>
					<xslt:when test="$srcdoc//html:title">
						<xslt:apply-templates select="$srcdoc//html:title[1]" mode="microdata">
							<xslt:with-param name="tagname" select="'title'"/>
							<xslt:with-param name="namespace" select="'&Atom;'"/>
						</xslt:apply-templates>
					</xslt:when>
					<xslt:otherwise>
						<title xml:lang="en">Untitled</title>
					</xslt:otherwise>
				</xslt:choose>
			</xslt:if>
			<xslt:if test="not(atom:updated)">
				<xslt:text>&#x0A;&#x09;&#x09;</xslt:text>
				<xslt:choose>
					<xslt:when test="$srcdoc//*[@itemprop='shrine-updated']">
						<xslt:apply-templates select="$srcdoc//*[@itemprop='shrine-updated'][1]" mode="microdata">
							<xslt:with-param name="tagname" select="'updated'"/>
							<xslt:with-param name="namespace" select="'&Atom;'"/>
							<xslt:with-param name="plaintext" select="true()"/>
						</xslt:apply-templates>
					</xslt:when>
					<xslt:otherwise>
						<xslt:value-of select="$datetime"/>
					</xslt:otherwise>
				</xslt:choose>
			</xslt:if>
			<xslt:text>&#x0A;&#x09;</xslt:text> <!-- newline before close tag -->
		</entry>
	</xslt:template>

	<!--
		Process feed link elements.
		This simply rewrites relative links to be absolute.
	-->
	<xslt:template match="atom:link[starts-with(@href, '/')]" mode="feed">
		<link xmlns="&Atom;" rel="{@rel}" href="{$baseiri}{@href}">
			<xslt:for-each select="@*[local-name()!='rel' and local-name()!='href']">
				<xslt:copy/>
			</xslt:for-each>
		</link>
	</xslt:template>

	<!--
		Provide the complete text content of the provided element.
	-->
	<xslt:template match="*|text()" mode="text">
		<xslt:choose>
			<xslt:when test="self::*">
				<xslt:apply-templates mode="text"/>
			</xslt:when>
			<xslt:when test="self::text()">
				<xslt:copy/>
			</xslt:when>
		</xslt:choose>
	</xslt:template>

	<!--
		Provide the appropriate microdata for the provided element.
	-->
	<xslt:template match="*|text()" mode="microdata">
		<xslt:param name="tagname"/>
		<xslt:param name="namespace"/>
		<xslt:param name="plaintext" select="false()"/>
		<xslt:element name="{$tagname}" namespace="{$namespace}">
			<xslt:if test="@lang">
				<xslt:attribute name="xml:lang">
					<xslt:value-of select="@lang"/>
				</xslt:attribute>
			</xslt:if>
			<xslt:choose>
				<xslt:when test="self::text()|self::html:title|self::html:time[not(@datetime)]">
					<xslt:apply-templates select="." mode="text"/>
				</xslt:when>
				<xslt:when test="self::html:meta[@content]">
					<xslt:value-of select="@content"/>
				</xslt:when>
				<xslt:when test="self::html:audio|self::html:embed|self::html:iframe|self::html:img|self::html:source|self::html:track|self::html:video">
					<xslt:value-of select="@src"/>
				</xslt:when>
				<xslt:when test="self::html:a|self::html:area|self::html:link">
					<xslt:value-of select="@href"/>
				</xslt:when>
				<xslt:when test="self::html:object">
					<xslt:value-of select="@data"/>
				</xslt:when>
				<xslt:when test="self::html:data|self::html:meter">
					<xslt:value-of select="@value"/>
				</xslt:when>
				<xslt:when test="self::html:time[@datetime]">
					<xslt:value-of select="@datetime"/>
				</xslt:when>
				<xslt:otherwise>
					<xslt:choose>
						<xslt:when test="$plaintext">
							<xslt:apply-templates mode="text"/>
						</xslt:when>
						<xslt:otherwise>
							<xslt:if test="$namespace='&Atom;'">
								<xslt:attribute name="type">xhtml</xslt:attribute>
							</xslt:if>
							<div xmlns="&xhtml;">
								<xslt:apply-templates mode="content"/>
							</div>
						</xslt:otherwise>
					</xslt:choose>
				</xslt:otherwise>
			</xslt:choose>
		</xslt:element>
	</xslt:template>

	<!--
		Set up output.
		Note that this relies on “default” output method detection specified in X·S·L·T in order to work.
		The `about:legacy-compat` system doctype is for H·T·M·L compatibility but is harmless in X·M·L.
	-->
	<xslt:output charset="UTF-8" doctype-system="about:legacy-compat" indent="no"/>
</xslt:transform>
