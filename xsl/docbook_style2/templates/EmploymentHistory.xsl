<?xml version="1.0" encoding="UTF-8"?>

<!--

   Copyright 2002 Charles Chan

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

	<xsl:template match="sep:EmploymentHistory">

		<!-- Section title -->
		<xsl:variable name="title">
			<xsl:call-template name="message">
				<xsl:with-param name="name">header.employmentHistory</xsl:with-param>
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
            
                <!-- Is this a functional or chronological list? -->
    		<xsl:choose>
    
    			<xsl:when test="sep:EmployerOrg/sep:PositionHistory/sep:OrgIndustry">
    
    				<!-- It's functional -->
    				<xsl:for-each-group
    					select="sep:EmployerOrg/sep:PositionHistory"
    					group-by="sep:OrgIndustry/sep:IndustryDescription">
    					
    					<section>
    						<xsl:variable name="subTitle">
    							<xsl:value-of select="current-grouping-key()"/>
    						</xsl:variable>
    
    						<!-- Generate a section ID from the title -->
    						<xsl:attribute name="id">
    							<!-- Remove spaces from the title because IDs can't have them -->
    							<xsl:value-of select="translate($subTitle, ' ', '')"/>
    						</xsl:attribute>
    
    						<title>
    							<xsl:value-of select="$subTitle"/>
    						</title>
    
    						<xsl:apply-templates select="current-group()"/>						
    					</section>
    					
    				</xsl:for-each-group>
    
    			</xsl:when>
    
    			<xsl:otherwise>
    
    				<!-- It's chronological -->
    				<xsl:apply-templates select="sep:EmployerOrg/sep:PositionHistory"/> 
    
    			</xsl:otherwise>
    
    		</xsl:choose>
        </section>
	</xsl:template>

	<xsl:template match="sep:EmployerOrg/sep:PositionHistory">

		<!-- Setting rowsep and colsep to 0 turns off the internal table borders in PDF output -->
		<informaltable frame="none" pgwide="1" rowsep="0" colsep="0">
			<tgroup cols="3">
			    <colspec colname="date" colsep="1" colwidth="50px" align="right"/>
				<colspec colname="description"/>
				<colspec colname="details"/>
				<tbody>
					<row>
					    <entry>
					        <emphasis>
					            <para>
					                <xsl:apply-templates select="sep:StartDate"/>
					            </para>
					            <para>
					                <xsl:apply-templates select="sep:EndDate"/>
					            </para>
					        </emphasis>
					    </entry>
						
						<entry namest="description" nameend="details">
						    <section renderas="sect3">
						        <title>
    								<xsl:value-of select="sep:Title"/>
						        </title>        
						        <subtitle>
						            <emphasis>
        								<!-- This field is required according to the spec, but we want it to be optional, -->
        								<!-- so we check for an empty string instead of testing for existence.            -->
        								<xsl:if test="string-length(sep:OrgName/sep:OrganizationName) != 0">
        									<xsl:value-of select="sep:OrgName/sep:OrganizationName"/>
        								</xsl:if>
        
        								<!-- This field is required according to the spec, but we want it to be optional, -->
        								<!-- so we check for an empty string instead of testing for existence.            -->
        								<xsl:if test="string-length(../sep:EmployerOrgName) != 0">
        									<xsl:if test="string-length(sep:OrgName/sep:OrganizationName) != 0">
        										<xsl:text>, </xsl:text>
        									</xsl:if>
        									<xsl:choose>
        										<!-- If WebSite is specified, put a link to it around the EmployerOrgName. -->
        										<xsl:when test="sep:OrgInfo/sep:WebSite">
        											<ulink>
        												<xsl:attribute name="url">
        													<xsl:value-of select="sep:OrgInfo/sep:WebSite"/>
        												</xsl:attribute>
        												<xsl:value-of select="../sep:EmployerOrgName"/>
        											</ulink>
        										</xsl:when>
        										<!-- Otherwise, just output the EmployerOrgName as-is. -->
        										<xsl:otherwise>
        											<xsl:value-of select="../sep:EmployerOrgName"/>
        										</xsl:otherwise>
        									</xsl:choose>
        
        									<xsl:if test="sep:OrgInfo/sep:LocationSummary">
        										<xsl:text> (</xsl:text>
        										<xsl:apply-templates select="sep:OrgInfo/sep:LocationSummary"/>
        										<xsl:text>)</xsl:text>
        									</xsl:if>
        								</xsl:if>
        							</emphasis>
						        </subtitle>
						        <!-- This field is required according to the spec, but we want it to be optional, -->
                        		<!-- so we check for an empty string instead of testing for existence.            -->
                        		<xsl:if test="string-length(sep:Description) != 0">
                        			<xsl:choose>
                        				<xsl:when test="false()">
                        					<!-- The description is on multiple lines; make each line a list item -->
                        					<itemizedlist mark="none">
                        				        <xsl:for-each select="tokenize(sep:Description, '[\r\n]+')">
                        				            <xsl:if test="normalize-space()">
                        				                <listitem>
                            			                    <xsl:value-of select="."/>
                            			                </listitem>
                        				            </xsl:if>
                        				        </xsl:for-each>
                        					</itemizedlist>
                        				</xsl:when>
                        				<xsl:otherwise>
                        					<!-- The description doesn't contain any newlines, so don't put it in a list -->
                						    <para>
                    							<xsl:value-of select="normalize-space(sep:Description)"/>
                    						</para>
                        				</xsl:otherwise>
                        			</xsl:choose>
                        		</xsl:if>
                        		
                        		<xsl:if test="sep:Competency">
                		            <itemizedlist>
                        				<xsl:apply-templates select="sep:Competency"/>
                        			</itemizedlist>
                        		</xsl:if>
						    </section>
						</entry>
					</row>
				</tbody>
			</tgroup>
		</informaltable>
	</xsl:template>
</xsl:stylesheet>