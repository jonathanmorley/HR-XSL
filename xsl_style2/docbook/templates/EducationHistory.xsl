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

	<xsl:template match="sep:EducationHistory">

		<xsl:variable name="title">
			<xsl:call-template name="message">
				<xsl:with-param name="name">header.educationHistory</xsl:with-param>
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
            
            <xsl:for-each-group select="sep:SchoolOrInstitution/sep:Degree" group-by="sep:DegreeName">
                <xsl:for-each-group select="current-group()" group-by="sep:DatesOfAttendance">
                    <informaltable frame="none" pgwide="1" rowsep="0" colsep="0">
            	        <tgroup cols="3">
            	            <colspec colname="date" colsep="1" colwidth="50px" align="right"/>
            	            <colspec colname="description" align="left"/>
            	            <colspec colname="details" align="right"/>
            	            <tbody>
                        	    <row>
                                    <entry>
            					        <emphasis>
            					            <para>
            					                <xsl:apply-templates select="sep:DatesOfAttendance/sep:StartDate"/>
            					            </para>
            					            <para>
            					                <xsl:apply-templates select="sep:DatesOfAttendance/sep:EndDate"/>
            					            </para>
            					        </emphasis>
            					    </entry>
                                    
                                    <entry namest="description" nameend="details">
                                        <section renderas="sect3">
                            				<title>
                            					<!-- If the DegreeName element is specified, use it. Otherwise, generate the degree name -->
                            					<!-- automatically according to the degreeType attribute. -->
                            					<xsl:choose> 
                            						<xsl:when test="sep:DegreeName"> 
                            							<xsl:value-of select="sep:DegreeName"/> 
                            						</xsl:when> 
                            						<xsl:otherwise> 
                            							<xsl:apply-templates select="@degreeType"/>
                            						</xsl:otherwise>
                            					</xsl:choose>
                            					
                            					<xsl:choose>
                            					    <xsl:when test="count(current-group()) = 1">
                            					        <!-- Major -->
                                    					<xsl:if test="@degreeType and sep:DegreeMajor/sep:Name">
                                    						<xsl:text> </xsl:text>
                                    						<xsl:call-template name="message">
                                    							<xsl:with-param name="name">educationHistory.degreeIn</xsl:with-param>
                                    						</xsl:call-template>
                                    						<xsl:text> </xsl:text>
                                    						<xsl:value-of select="sep:DegreeMajor/sep:Name"/>
                                    					</xsl:if>
                            					    </xsl:when>
                            					    <xsl:otherwise>
                            					        <xsl:text>s</xsl:text>
                            					    </xsl:otherwise>
                            					</xsl:choose>
                            				
                                        						
                                				<!-- Academic honors -->
                                				<xsl:if test="sep:DegreeName/@academicHonors">
                                					<xsl:text> (</xsl:text>
                                					<xsl:value-of select="sep:DegreeName/@academicHonors"/>
                                					<xsl:text>)</xsl:text>
                                				</xsl:if>
                            				</title>
                            				
                            				<subtitle>
                            				    <emphasis>
                                					<xsl:value-of select="../sep:School/sep:SchoolName"/>
                                					<xsl:if test="../sep:LocationSummary">
                                						<xsl:text> (</xsl:text>
                                						<xsl:apply-templates select="../sep:LocationSummary"/>
                                						<xsl:text>)</xsl:text>
                                					</xsl:if>
                                				</emphasis>
                            				</subtitle>
                            				
                            				
                            				<xsl:choose>
                                				<xsl:when test="count(current-group()) = 1">
                                				
            				                		<!-- Grade -->
                                            		<xsl:if test="sep:DegreeMeasure/sep:MeasureValue">
                                            		    <para>
                                        				    <emphasis role="bold">
                                            					<xsl:call-template name="message">
                                            						<xsl:with-param name="name">educationHistory.grade</xsl:with-param>
                                            					</xsl:call-template>
                                            					<xsl:text>: </xsl:text>
                                        					</emphasis>
                                        					<xsl:value-of select="sep:DegreeMeasure/sep:MeasureValue"/>
                                            		    </para>
                                            		</xsl:if>
                                            
                                            		<!-- Concentration -->
                                            		<xsl:if test="sep:DegreeMajor/sep:DegreeConcentration">
                                            		    <para>
                                        					<xsl:call-template name="message">
                                        						<xsl:with-param name="name">educationHistory.concentrationIn</xsl:with-param>
                                        					</xsl:call-template>
                                        					<xsl:text> </xsl:text>
                                        					<xsl:value-of select="sep:DegreeMajor/sep:DegreeConcentration"/>
                                    					</para>
                                            		</xsl:if>
                                            
                                            		<!-- Honors -->
                                            		<xsl:if test="sep:OtherHonors">
                                    					<itemizedlist>
                                    						<xsl:for-each select="sep:OtherHonors">
                                    							<listitem>
                                    								<simpara>
                                    									<xsl:value-of select="."/>
                                    								</simpara>
                                    							</listitem>
                                    						</xsl:for-each>
                                    					</itemizedlist>
                                            		</xsl:if>
                                				
                                				    <!-- Comments -->
                                            		<xsl:if test="sep:Comments">
                                        			    <para>
                                        					<xsl:value-of select="sep:Comments"/>
                                        				</para>
                                            		</xsl:if>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <para>
                                                        <simplelist type='inline'>
                                                        <xsl:for-each-group select="current-group()" group-by="sep:DegreeMeasure">
                                                            <member>
                                                                <xsl:value-of select="count(current-group())" />
                                                                <xsl:text> </xsl:text>
                                                                <xsl:value-of select="sep:DegreeMeasure/sep:MeasureValue" />
                                                                <xsl:text> Grades (</xsl:text>
                                                                <xsl:value-of select="current-group()/sep:DegreeMajor/sep:Name" separator=", " />
                                                                <xsl:text>)</xsl:text>
                                                            </member>
                                                        </xsl:for-each-group>
                                                        </simplelist>
                                                    </para>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </section>
                        			</entry>
                                </row>
                            </tbody>
                        </tgroup>
                    </informaltable>
                </xsl:for-each-group>
            </xsl:for-each-group>
		</section>
	</xsl:template>

	<xsl:template match="@degreeType">
		<xsl:choose>
			<xsl:when test=". = 'high school or equivalent'">					 
				<xsl:call-template name="message"> 
					<xsl:with-param name="name">educationHistory.highschool</xsl:with-param> 
				</xsl:call-template> 
			</xsl:when> 
			<xsl:when test=". = 'associates'">					 
				<xsl:call-template name="message"> 
					<xsl:with-param name="name">educationHistory.associates</xsl:with-param> 
				</xsl:call-template> 
			</xsl:when> 
			<xsl:when test=". = 'bachelors'">					 
				<xsl:call-template name="message"> 
					<xsl:with-param name="name">educationHistory.bachelors</xsl:with-param> 
				</xsl:call-template> 
			</xsl:when> 
			<xsl:when test=". = 'masters'">					 
				<xsl:call-template name="message"> 
					<xsl:with-param name="name">educationHistory.masters</xsl:with-param> 
				</xsl:call-template> 
			</xsl:when> 
			<xsl:when test=". = 'doctorate'">					 
				<xsl:call-template name="message"> 
					<xsl:with-param name="name">educationHistory.doctorate</xsl:with-param> 
				</xsl:call-template> 
			</xsl:when> 
			<xsl:when test=". = 'international'">					 
				<xsl:call-template name="message"> 
					<xsl:with-param name="name">educationHistory.international</xsl:with-param> 
				</xsl:call-template> 
			</xsl:when> 
		</xsl:choose> 
	</xsl:template>

	<xsl:template match="sep:LocationSummary">

		<xsl:value-of select="sep:Municipality"/>
		
		<xsl:if test="sep:Region">
			<xsl:text>, </xsl:text>
			<xsl:value-of select="sep:Region"/>
		</xsl:if>
		
		<xsl:if test="sep:CountryCode">
			<xsl:text>, </xsl:text>
			<xsl:call-template name="message"> 
				<xsl:with-param name="name">countryCode.<xsl:value-of select="sep:CountryCode"/></xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		
	</xsl:template>

</xsl:stylesheet>
