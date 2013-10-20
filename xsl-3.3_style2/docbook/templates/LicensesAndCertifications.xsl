<?xml version="1.0" encoding="UTF-8"?>

<!--

   Copyright 2007 Trevor Harmon

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

-->

<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:sep="http://ns.hr-xml.org/2007-04-15"
	exclude-result-prefixes="sep">

	<xsl:template match="sep:LicensesAndCertifications">

		<xsl:variable name="title">
			<xsl:call-template name="message">
				<xsl:with-param name="name">header.licensesAndCertifications</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<section>

			<!-- Generate a section ID from the title -->
			<xsl:attribute name="id">
				<!-- Remove spaces from the title because IDs can't have them -->
				<xsl:value-of select="translate($title, ' ', '')"/>
			</xsl:attribute>

			<title>
				<xsl:value-of select="$title"/>
			</title>

			<xsl:apply-templates select="sep:LicenseOrCertification"/> 
			
		</section>

	</xsl:template>

	<xsl:template match="sep:LicenseOrCertification">
	    <informaltable frame="none" pgwide="1" rowsep="0" colsep="0">
			<tgroup cols="2">
				<colspec colname="description"/>
				<colspec colname="date"/>
				<tbody>
					<row>
						<entry>
					        <emphasis role="bold">
                		        <xsl:value-of select="sep:Name"/>
                				
                				<xsl:if test="sep:IssuingAuthority">
                					<xsl:text>, </xsl:text>
                					<xsl:value-of select="sep:IssuingAuthority"/>
                				</xsl:if>
                		    </emphasis>
                    	</entry>
                    	
                    	<xsl:if test="sep:EffectiveDate">
                            <entry align="right">
    						    <emphasis>
    						        <xsl:apply-templates select="sep:EffectiveDate/sep:FirstIssuedDate"/>
    						    </emphasis>
    						</entry>
				        </xsl:if>
					</row>
					
					<!-- Description -->
					<xsl:if test="sep:Description">
						<row>
						    <entry namest="description" nameend="date">
						        <xsl:value-of select="sep:Description"/>
						    </entry>
						</row>
					</xsl:if>
				</tbody>
			</tgroup>
		</informaltable>
	</xsl:template>

</xsl:stylesheet>
