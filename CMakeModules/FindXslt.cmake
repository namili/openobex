# - Find XSLT processors.
# This module provides easy integration of XSLT processors.
# Currently xsltproc, Saxon 6.5.[345] and Xalan 2.x are supported.
#
# Typical usage is:
#   find_package(Xslt)
#   include_file(${Xslt_USE_FILE})
#   
#
# The following variables are created:
#   Xslt_FOUND     - true if at least one XSLT processor is found
#   Xslt_USE_FILE  - name of the USE_FILE
#   Xslt_CLASSPATH - the Java classpath to use for XSLT processing
#   XSLT_XSLTPROC_EXECUTABLE - executable for xltproc
#   XSLT_SAXON_COMMAND       - command for saxon-6.5.x
#   XSLT_XALAN2_COMMAND      - command for xalan-2.x
#
# The following environment variables are considered:
#   CLASSPATH - initial value of Xslt_CLASSPATH (if empty)
#
# The following functions are provided:
#   xsl_transform(xsl-file xml-file <output-file>...)
#     This uses the xsl file to transform the xml file input to one or
#     more output files. Several variables can be used to change the
#     behaviour of the transformation:
#       XSLT_PARAMS: cmake list of parameters for the XSL transformation
#                    in the form of param=value
#       XSLT_<processor>_OPTIONS: extra option for each of XSLTPROC,
#                    SAXON and XALAN2.

find_package ( Java )
if ( JAVA_RUNTIME )
  if ( NOT Xslt_CLASSPATH )
    set ( Xslt_CLASSPATH $ENV{CLASSPATH} CACHE STRING "java classpath" )
  endif ( NOT Xslt_CLASSPATH )
  if ( NOT CMAKE_SYSTEM_NAME STREQUAL "Windows" )
    # Non-Windows classpath may use : instead of ;
    # so make this a cmake list here by always using ;
    string ( REPLACE ":" ";" Xslt_CLASSPATH "${Xslt_CLASSPATH}" )
  endif ( NOT CMAKE_SYSTEM_NAME STREQUAL "Windows" )
  mark_as_advanced ( Xslt_CLASSPATH )

  find_file ( JAVA_RESOLVER_LIBRARY
    NAMES resolver.jar xml-commons-resolver-1.1.jar
    PATH_SUFFIXES share/java
    DOC "location of the XML commons resolver java library from the apache project"
    CMAKE_FIND_ROOT_PATH_BOTH
  )
  mark_as_advanced ( JAVA_RESOLVER_LIBRARY )
  if ( JAVA_RESOLVER_LIBRARY )
    list ( APPEND Xslt_CLASSPATH "${JAVA_RESOLVER_LIBRARY}" )
  endif ( JAVA_RESOLVER_LIBRARY )

  find_path ( JAVA_PROPERTIES_CATALOGMANAGER
    NAMES CatalogManager.properties
    PATHS /etc
    PATH_SUFFIXES xml/resolver share/java share/xml
    DOC "location of the catalog manager properties file from the XML commons resolver"
    CMAKE_FIND_ROOT_PATH_BOTH
  )
  mark_as_advanced ( JAVA_PROPERTIES_CATALOGMANAGER )
  if ( JAVA_PROPERTIES_CATALOGMANAGER )
    list ( APPEND Xslt_CLASSPATH "${JAVA_PROPERTIES_CATALOGMANAGER}" )
  endif ( JAVA_PROPERTIES_CATALOGMANAGER )

  #
  # Find Xalan 2
  #
  find_file ( XALAN2
    NAMES xalan2.jar
    PATH_SUFFIXES share/java
    DOC "location of Xalan2 JAR file"
    CMAKE_FIND_ROOT_PATH_BOTH
  )
  mark_as_advanced ( XALAN2 )
  find_file ( JAVA_XML_APIS_LIBRARY
    NAMES xml-apis.jar
    PATH_SUFFIXES share/java
    DOC "location of Xalan2 XML-API JAR file"
    CMAKE_FIND_ROOT_PATH_BOTH
  )
  mark_as_advanced ( JAVA_XML_APIS_LIBRARY )
  find_file ( JAVA_XERCES_IMPL_LIBRARY
    NAMES xercesImpl.jar
    PATH_SUFFIXES share/java
    DOC "location of Xalan2 Xerces Implementation JAR file"
    CMAKE_FIND_ROOT_PATH_BOTH
  )
  mark_as_advanced ( JAVA_XERCES_IMPL_LIBRARY )
  if ( XALAN2 AND JAVA_XML_APIS_LIBRARY AND JAVA_XERCES_IMPL_LIBRARY )
    set ( Xslt_XALAN2_CLASSPATH
      ${Xslt_CLASSPATH}
      "${XALAN2}"
      "${JAVA_XML_APIS_LIBRARY}"
      "${JAVA_XERCES_IMPL_LIBRARY}"
    )
    if ( Xslt_XALAN2_EXTENSIONS )
      list ( APPEND Xslt_XALAN2_CLASSPATH "${Xslt_XALAN2_EXTENSIONS}" )
    endif ( Xslt_XALAN2_EXTENSIONS )
    if ( NOT CMAKE_SYSTEM_NAME STREQUAL "Windows" )
      string ( REPLACE ";" ":" Xslt_XALAN2_CLASSPATH "${Xslt_XALAN2_CLASSPATH}" )
    endif ( NOT CMAKE_SYSTEM_NAME STREQUAL "Windows" )
    set ( XSLT_XALAN2_COMMAND
      org.apache.xalan.xslt.Process
    )
    if ( JAVA_RESOLVER_LIBRARY AND JAVA_PROPERTIES_CATALOGMANAGER )
      list ( APPEND XSLT_XALAN2_COMMAND
	-ENTITYRESOLVER  org.apache.xml.resolver.tools.CatalogResolver
	-URIRESOLVER  org.apache.xml.resolver.tools.CatalogResolver
      )
    endif ( JAVA_RESOLVER_LIBRARY AND JAVA_PROPERTIES_CATALOGMANAGER )
  endif ( XALAN2 AND JAVA_XML_APIS_LIBRARY AND JAVA_XERCES_IMPL_LIBRARY )

  #
  # Find Saxon 6.5.x
  #
  find_file ( SAXON
    NAMES saxon.jar saxon-6.5.5.jar saxon-6.5.4.jar saxon-6.5.3.jar
    PATH_SUFFIXES share/java
    DOC "location of saxon 6.5.x JAR file"
    CMAKE_FIND_ROOT_PATH_BOTH
  )
  mark_as_advanced ( SAXON )
  if ( SAXON )
    set ( Xslt_SAXON_CLASSPATH
      ${Xslt_CLASSPATH}
      "${SAXON}"
    )
    if ( Xslt_SAXON_EXTENSIONS )
      list ( APPEND Xslt_SAXON_CLASSPATH "${Xslt_SAXON_EXTENSIONS}" )
    endif ( Xslt_SAXON_EXTENSIONS )
    if ( NOT CMAKE_SYSTEM_NAME STREQUAL "Windows" )
      string ( REPLACE ";" ":" Xslt_SAXON_CLASSPATH "${Xslt_SAXON_CLASSPATH}" )
    endif ( NOT CMAKE_SYSTEM_NAME STREQUAL "Windows" )
    set ( XSLT_SAXON_COMMAND
      com.icl.saxon.StyleSheet
    )
    if ( JAVA_RESOLVER_LIBRARY )
      list ( APPEND XSLT_SAXON_COMMAND
	-x org.apache.xml.resolver.tools.ResolvingXMLReader
	-y org.apache.xml.resolver.tools.ResolvingXMLReader
	-u
      )
      if ( JAVA_PROPERTIES_CATALOGMANAGER )
	list ( APPEND XSLT_SAXON_COMMAND
	  -r org.apache.xml.resolver.tools.CatalogResolver
	)
      endif ( JAVA_PROPERTIES_CATALOGMANAGER )
    endif ( JAVA_RESOLVER_LIBRARY )
  endif ( SAXON )
endif ( JAVA_RUNTIME )

find_program ( XSLT_XSLTPROC_EXECUTABLE
  NAMES xsltproc
  DOC   "path to the libxslt XSLT processor xsltproc"
)
mark_as_advanced ( XSLT_XSLTPROC_EXECUTABLE )

set ( Xslt_USE_FILE UseXslt )

if ( XSLT_XSLTPROC_EXECUTABLE OR XSLT_SAXON_COMMAND OR XSLT_XALAN2_COMMAND )
  set ( Xslt_FOUND true )
endif ( XSLT_XSLTPROC_EXECUTABLE OR XSLT_SAXON_COMMAND OR XSLT_XALAN2_COMMAND )

if ( NOT Xslt_FOUND )
  if ( NOT Xslt_FIND_QUIETLY )
    message ( STATUS "No supported XSLT processor found. Supported XSLT processors are: xsltproc, saxon-6.5.x, xalan-2.x" )
  endif ( NOT Xslt_FIND_QUIETLY )
  if ( Xslt_FIND_REQUIRED )
    message ( FATAL_ERROR "No supported XSLT processor found but it is required." )
  endif ( Xslt_FIND_REQUIRED )
endif ( NOT Xslt_FOUND )
