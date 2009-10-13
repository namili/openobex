
include ( ${Xslt_USE_FILE} )

if ( NOT DOCBOOK_XSL_VERSION )
  set ( DOCBOOK_XSL_VERSION current )
endif ( NOT DOCBOOK_XSL_VERSION )
set ( DOCBOOK_XSL_PREFIX "http://docbook.sourceforge.net/release/xsl/${DOCBOOK_XSL_VERSION}"
      CACHE STRING "prefix to locate the docbook-XSL release files" )
mark_as_advanced ( DOCBOOK_XSL_PREFIX )

function ( _DOCBOOK_GET_HTML_FILES inFile outFileList )
  # This assumes that every refentry has an unique id attribute
  file ( READ "${inFile}" XML_FILE_CONTENTS )
  string ( REPLACE ";" "" XML_FILE_CONTENTS "${XML_FILE_CONTENTS}" )
  string ( REGEX MATCHALL "<refentry[ ]+[^>]*" XML_REFENTRYTITLE "${XML_FILE_CONTENTS}" )
  foreach ( id ${XML_REFENTRYTITLE} )
    string ( REGEX REPLACE ".*id=\"([^\"]*)\".*" "\\1" id "${id}" )
    if ( "${id}" STREQUAL "" )
      message ( FATAL_ERROR "At least one refentry in file ${infile} has no or an empty id attribute." )
    endif ( "${id}" STREQUAL "" )
    list ( APPEND FILES ${id}.html )
  endforeach ( id )
  string ( REGEX MATCH "<!DOCTYPE[ ]+[^ >]*" XML_ENTRY_ELEMENT "${XML_FILE_CONTENTS}" )
  string ( REGEX REPLACE "<!DOCTYPE[ ]+(.*)" "\\1" XML_ENTRY_ELEMENT "${XML_ENTRY_ELEMENT}" )
  if ( "${XML_ENTRY_ELEMENT}" STREQUAL "reference" )
    list ( APPEND FILES index.html )
  endif ( "${XML_ENTRY_ELEMENT}" STREQUAL "reference" )
  set ( ${outFileList} ${FILES} PARENT_SCOPE )
endfunction ( )

function ( _DOCBOOK_GET_MANPAGE_FILES inFile outFileList )
  file ( READ "${inFile}" XML_FILE_CONTENTS )
  string ( REPLACE ";" "" XML_FILE_CONTENTS "${XML_FILE_CONTENTS}" )
  string ( REGEX MATCHALL "<refentry[ ]+.*</refentry>" ENTRIES "${XML_FILE_CONTENTS}" )
  string ( REPLACE "</refentry>" ";" ENTRIES "${ENTRIES}" )
  list ( REMOVE_ITEM ENTRIES "" )
  list ( LENGTH ENTRIES COUNT )
  math ( EXPR COUNT "${COUNT} - 1" )
  foreach ( index RANGE ${COUNT} )
    list ( GET ENTRIES ${index} entry )
    string ( REGEX MATCH "<refname>[^<]*" MANPAGE_NAME "${entry}" )
    string ( REGEX REPLACE "^<refname>" "" MANPAGE_NAME "${MANPAGE_NAME}" )
    string ( REGEX REPLACE "[[:space:]]" "" MANPAGE_NAME "${MANPAGE_NAME}" )
    if ( "${MANPAGE_NAME}" STREQUAL "" )
      message ( FATAL_ERROR "At least one refentry in file ${infile} has no or an empty refname element." )
    endif ( "${MANPAGE_NAME}" STREQUAL "" )

    string ( REGEX MATCH "<manvolnum>[^<]*" MANPAGE_VOLUME "${entry}" )
    string ( REGEX REPLACE "^<manvolnum>" "" MANPAGE_VOLUME "${MANPAGE_VOLUME}" )
    string ( REGEX REPLACE "[[:space:]]" "" MANPAGE_VOLUME "${MANPAGE_VOLUME}" )
    if ( "${MANPAGE_VOLUME}" STREQUAL "" )
      message ( FATAL_ERROR "At least one refentry in file ${infile} has no or an empty manvolnum element." )
    endif ( "${MANPAGE_VOLUME}" STREQUAL "" )

    list ( APPEND FILES "${MANPAGE_NAME}.${MANPAGE_VOLUME}" )
  endforeach ( index )
  set ( ${outFileList} ${FILES} PARENT_SCOPE )
endfunction ( )

function ( _DOCBOOK_MANPAGE inFile outList )
  _docbook_get_manpage_files ( "${inFile}" FILES )

  xsl_transform (
    "${DOCBOOK_XSL_PREFIX}/manpages/docbook.xsl"
    "${inFile}"
    ${FILES}
  )

  set ( ${outList} ${FILES} PARENT_SCOPE )
endfunction ( )

function ( _DOCBOOK_HTML inFile outList )
  _docbook_get_html_files ( "${inFile}" FILES )
  list ( APPEND XSLT_PARAMS
    "use.id.as.filename=1"
  )

  xsl_transform (
    "${DOCBOOK_XSL_PREFIX}/xhtml/chunk.xsl"
    "${inFile}"
    ${FILES}
  )

  set ( ${outList} ${FILES} PARENT_SCOPE )
endfunction ( )

function ( DOCBOOK_GENERATE format inFile outList )
  if ( format STREQUAL "manpage" )
    _docbook_manpage ( "${inFile}" ${outList} )

  elseif ( format STREQUAL "html" )
    _docbook_html ( "${inFile}" ${outList} )

  else ( )
    message ( FATAL_ERROR "Unsupported docbook output format." )

  endif ( )
  set ( ${outList} ${${outList}} PARENT_SCOPE )
endfunction ( )
