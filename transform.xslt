<!--
This is an extremely simple XSLT transform which simply reads in a
`template.xml` and :—

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
<xslt:transform
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:exslt="http://exslt.org/common"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:xslt="http://www.w3.org/1999/XSL/Transform"
	version="1.0"
>
	<xslt:variable name="source" select="current()"/>
	<xslt:variable name="template" select="document('./template.xml')"/>

	<!--
		Instead of actually processing the root node, process the template in `template` mode.
	-->
	<xslt:template match="/">
		<xslt:apply-templates select="exslt:node-set($template)" mode="template"/>
	</xslt:template>

	<!--
		Process non‐template elements.
		By default, just copy the element, but remove any `@data-shrine-*` attribuets or `@slot` attributes with a value that begins with `shrine-`.
	-->
	<xslt:template match="*|text()" mode="content">
		<xslt:copy>
			<xslt:for-each select="@*[not(starts-with(name(), 'data-shrine-')) and not(name()='slot' and starts-with(., 'shrine-'))]">
				<xslt:copy/>
			</xslt:for-each>
			<xslt:for-each select="*|text()">
				<xslt:choose>
					<xslt:when test="@slot[starts-with(., 'shrine-')]">
						<xslt:comment>
							<text> placeholder for slotted element </text>
						</xslt:comment>
					</xslt:when>
					<xslt:otherwise>
						<xslt:apply-templates select="." mode="content"/>
					</xslt:otherwise>
				</xslt:choose>
			</xslt:for-each>
		</xslt:copy>
	</xslt:template>

	<!--
		Process template elements.
		By default, just copy the element.
		This behaviour will be overridden for certain elements to insert the page content.
	-->
	<xslt:template match="*|text()" mode="template">
		<xslt:copy>
			<xslt:for-each select="@*">
				<xslt:copy/>
			</xslt:for-each>
			<xslt:apply-templates mode="template"/>
		</xslt:copy>
	</xslt:template>

	<!--
		Process the template `<html>`.
		This copies over `@lang` and non‐shrine `@data-*` attributes from the root node.
	-->
	<xslt:template match="html:html" mode="template">
		<xslt:copy>
			<xslt:for-each select="@*">
				<xslt:copy/>
			</xslt:for-each>
			<xslt:for-each select="exslt:node-set($source)/*/@*[name()='lang' or name()='xml:lang' or starts-with(name(), 'data-') and not(starts-with(name(), 'data-shrine-'))]">
				<xslt:if test="not(exslt:node-set($template)/*/@*[name()=name(current())])">
					<xslt:copy/>
				</xslt:if>
			</xslt:for-each>
			<xslt:apply-templates mode="template"/>
		</xslt:copy>
	</xslt:template>

	<!--
		Process the template `<head>`.
		This inserts appropriate metadata based on the document.
	-->
	<xslt:template match="html:head" mode="template">
		<xslt:copy>
			<xslt:for-each select="@*">
				<xslt:copy/>
			</xslt:for-each>
			<xslt:for-each select="exslt:node-set($source)//*[@slot='shrine-head']">
				<xslt:text>&#x0A;</xslt:text>
				<xslt:apply-templates select="." mode="content"/>
			</xslt:for-each>
			<xslt:if test="not(exslt:node-set($source)//html:title[@slot='shrine-head'])">
				<xslt:text>&#x0A;</xslt:text>
				<title>
					<xslt:apply-templates select="exslt:node-set($source)//html:h1" mode="text"/>
				</title>
			</xslt:if>
			<xslt:apply-templates mode="template"/>
		</xslt:copy>
	</xslt:template>

	<!--
		Process the template header.
		Read the `@data-header` attribute of the root element, append `"-header.xml"` to the end of it, and process the resulting document.
		If no `@data-header` attribute is provided, no header is rendered.
	-->
	<xslt:template match="html:shrine-header" mode="template">
		<xslt:for-each select="exslt:node-set($source)/*/@data-shrine-header">
			<xslt:apply-templates select="document(concat('./', ., '-header.xml'), $template)/*" mode="content"/>
		</xslt:for-each>
	</xslt:template>

	<!--
		Process the template footer.
		Read the `@data-footer` attribute of the root element, append `"-footer.xml"` to the end of it, and process the resulting document.
		If no `@data-footer` attribute is provided, no footer is rendered.
	-->
	<xslt:template match="html:shrine-footer" mode="template">
		<xslt:for-each select="exslt:node-set($source)/*/@data-shrine-footer">
			<xslt:apply-templates select="document(concat('./', ., '-footer.xml'), $template)/*" mode="content"/>
		</xslt:for-each>
	</xslt:template>

	<!--
		Process the content.
	-->
	<xslt:template match="html:shrine-content" mode="template">
		<xslt:apply-templates select="exslt:node-set($source)/*" mode="content"/>
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
</xslt:transform>
