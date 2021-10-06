include(CMakeParseArguments)

function(ccm_target_name target namespace real_target)
  string(FIND ${target} ":" idx)
  
  if(idx EQUAL 0)
    if(namespace)
      string(PREPEND target "${namespace}:")
    else()
      string(SUBSTRING ${target} 1 -1 dep)
    endif()
  endif()

  set(${real_target} ${target} PARENT_SCOPE)
endfunction()

function(ccm_deps target namespace visibility deps)
  foreach(dep IN LISTS deps)
    ccm_target_name(${dep} ${namespace} real_dep)
    target_link_libraries(${target}
      ${visibility} ${real_dep}
    )
  endforeach()
endfunction()

function(collect_hdrs hdrs dir)
  if(dir)
    set(hdrs_exts ${dir}/*.h ${dir}/*.hpp ${dir}/*.hxx ${dir}/*.inc)
  else()
    set(hdrs_exts *.h *.hpp *.hxx *.inc)
  endif()

  file(GLOB_RECURSE all_hdrs CONFIGURE_DEPENDS
    ${hdrs_exts}
  )

  set(${hdrs} ${all_hdrs} PARENT_SCOPE)
endfunction()

function(collect_srcs srcs dir)
  if(dir)
    set(srcs_exts ${dir}/*.c ${dir}/*.cc  ${dir}/*.cpp ${dir}/*.cxx)  
  else()
    set(srcs_exts *.c *.cc  *.cpp *.cxx)   
  endif()

  file(GLOB_RECURSE all_srcs CONFIGURE_DEPENDS
    ${srcs_exts}
  )

  set(${srcs} ${all_srcs} PARENT_SCOPE)
endfunction()

function(cc_library)
  set(opts 
    ENABLE_INSTALL
    ALWAYS_LINK
  )
  
  set(single_args 
    NAME
    NAMESPACE
  )
  
  set(multi_args
    DEPS
    PRIVATE_DEPS
    PUBLIC_DEPS
    INTERFACE_DEPS
    
    INCLS
    PRIVATE_INCLS
    PUBLIC_INCLS
    INTERFACE_INCLS

    DEFINES
    PRIVATE_DEFINES
    PUBLIC_DEFINES
    INTERFACE_DEFINES 
    
    CFETURES
    PRIVATE_CFETURES
    PUBLIC_CFETURES
    INTERFACE_CFETURES

    COPTS
    PRIVATE_COPTS
    PUBLIC_COPTS
    INTERFACE_COPTS

    LOPTS
    PRIVATE_LOPTS
    PUBLIC_LOPTS
    INTERFACE_LOPTS

    LPATHS
    PRIVATE_LPATHS
    PUBLIC_LPATHS
    INTERFACE_LPATHS
  )

  cmake_parse_arguments(CC_LIBRARY "${opts}" "${single_args}" "${multi_args}" ${ARGN})

  if(CC_LIBRARY_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "unknown keywords given to cc_library(): \"${CC_LIBRARY_UNPARSED_ARGUMENTS}\"")
    return()
  endif()

  if(NOT CC_LIBRARY_PRIVATE_DEPS)
    set(CC_LIBRARY_PRIVATE_DEPS ${CC_LIBRARY_DEPS})
  endif()

  if(NOT CC_LIBRARY_PRIVATE_INCLS)
    set(CC_LIBRARY_PRIVATE_INCLS ${CC_LIBRARY_INCLS})
  endif()

  if(NOT CC_LIBRARY_PRIVATE_DEFINES)
    set(CC_LIBRARY_PRIVATE_DEFINES ${CC_LIBRARY_DEFINES})
  endif()
  
  if(NOT CC_LIBRARY_PRIVATE_COPTS)
    set(CC_LIBRARY_PRIVATE_COPTS ${CC_LIBRARY_COPTS})
  endif()
  
  if(NOT CC_LIBRARY_PRIVATE_CFETURES)
    set(CC_LIBRARY_PRIVATE_CFETURES ${CC_LIBRARY_CFETURES})
  endif()
  
  if(NOT CC_LIBRARY_PRIVATE_LOPTS)
    set(CC_LIBRARY_PRIVATE_LOPTS ${CC_LIBRARY_LOPTS})
  endif()
  
  if(NOT CC_LIBRARY_PRIVATE_LPATHS)
    set(CC_LIBRARY_PRIVATE_LPATHS ${CC_LIBRARY_LPATHS})
  endif()

  if(NOT CC_LIBRARY_NAME)
    message(FATAL_ERROR "required keyword NAME missing for cc_library() call")
    return()
  endif()

  if(CCM_NAMESPACE AND NOT CC_LIBRARY_NAMESPACE)
    set(CC_LIBRARY_NAMESPACE ${CCM_NAMESPACE})
  endif()

  if(CC_LIBRARY_NAMESPACE)
    string(REPLACE :: _ target ${CC_LIBRARY_NAMESPACE})
    string(APPEND target "_${CC_LIBRARY_NAME}")
  else()
    set(target ${CC_LIBRARY_NAME})
  endif()

  set(local_include ${CMAKE_CURRENT_LIST_DIR}/include)
  set(local_src ${CMAKE_CURRENT_LIST_DIR}/src)  

  if(EXISTS ${local_include})
    collect_hdrs(public_hdrs include)
  endif()

  if(EXISTS ${CMAKE_CURRENT_LIST_DIR}/src)
    collect_srcs(srcs src)
    collect_hdrs(private_hdrs src)
  endif()

  if(NOT (EXISTS ${local_include} AND EXISTS ${local_src}))
    collect_hdrs(hdrs "")
    collect_srcs(srcs "")
    if(NOT srcs)
      set(is_interface 1)
      set(public_hdrs  ${hdrs})
    else()
      set(is_interface 0)
      set(private_hdrs ${hdrs})
    endif()
  endif()

  if(is_interface)
    set(intf_err "should only set INTERFACE properties for cc_library: interface ${target}")

    if(CC_LIBRARY_PRIVATE_INCLS OR CC_LIBRARY_PUBLIC_INCLS)
      message(FATAL_ERROR ${intf_err})
      return()
    endif()
  
    if(CC_LIBRARY_PRIVATE_DEFINES OR CC_LIBRARY_PUBLIC_DEFINES)
      message(FATAL_ERROR ${intf_err})
      return()
    endif()

    if(CC_LIBRARY_PRIVATE_COPTS OR CC_LIBRARY_PUBLIC_COPTS)
      message(FATAL_ERROR ${intf_err})
      return()
    endif()

    if(CC_LIBRARY_PRIVATE_CFETURES OR CC_LIBRARY_PUBLIC_CFETURES)
      message(FATAL_ERROR ${intf_err})
      return()
    endif()

    if(CC_LIBRARY_PRIVATE_DEPS OR CC_LIBRARY_PUBLIC_DEPS)
      message(FATAL_ERROR ${intf_err})
      return()
    endif()

    if(CC_LIBRARY_PRIVATE_LOPTS OR CC_LIBRARY_PUBLIC_LOPTS)
      message(FATAL_ERROR ${intf_err})
      return()
    endif()
    
    if(CC_LIBRARY_PRIVATE_LPATHS OR CC_LIBRARY_PUBLIC_LPATHS)
      message(FATAL_ERROR ${intf_err})
      return()
    endif()

    if(NOT public_hdrs)
      message(FATAL_ERROR "public hdrs are empty for cc_library: interface ${target}")
      return()
    endif()

    add_library(${target} INTERFACE)

    target_sources(${target}
      INTERFACE ${public_hdrs}
    )

    if(EXISTS include)
      target_include_directories(${target}
        INTERFACE include
      )
    else()
      target_include_directories(${target}
        INTERFACE .
      )
    endif()

    if(CC_LIBRARY_INTERFACE_INCLS)
      target_include_directories(${target}
        INTERFACE ${CC_LIBRARY_INTERFACE_INCLS}
      )
    endif()

    if(CC_LIBRARY_INTERFACE_DEFINES)
      target_compile_definitions(${target}
        INTERFACE ${CC_LIBRARY_INTERFACE_DEFINES}
      )
    endif()

    if(CC_LIBRARY_INTERFACE_CFETURES)
      target_compile_features(${target}
        INTERFACE ${CC_LIBRARY_INTERFACE_CFETURES}
      )
    endif()    

    if(CC_LIBRARY_INTERFACE_COPTS)
      target_compile_options(${target}
        INTERFACE ${CC_LIBRARY_INTERFACE_COPTS}
      )
    endif()

    if(CC_LIBRARY_INTERFACE_LOPTS)
      target_link_options(${target}
        INTERFACE ${CC_LIBRARY_INTERFACE_LOPTS}
      )
    endif()    

    if(CC_LIBRARY_INTERFACE_CPATHS)
      target_link_directories(${target}
        INTERFACE ${CC_LIBRARY_INTERFACE_CPATHS}
      )
    endif()

    if(CC_LIBRARY_INTERFACE_DEPS)
      target_link_libraries(${target}
        INTERFACE ${CC_LIBRARY_DEPS}
      )
    endif()
  else(is_interface)
    if(NOT srcs)
      message(FATAL_ERROR "srcs are empty for cc_library: ${target}")
      return()
    endif()

    add_library(${target})

    target_sources(${target}
      PUBLIC  
        ${public_hdrs}
      PRIVATE 
        ${private_hdrs}
        ${srcs}
    )

    if(EXISTS ${local_include} AND EXISTS ${local_src})
      target_include_directories(${target}
          PUBLIC  include
          PRIVATE src
      )
    else()
      target_include_directories(${target}
        PRIVATE .
      )
    endif()

    if(CC_LIBRARY_PUBLIC_INCLS)
      target_include_directories(${target}
        PUBLIC ${CC_LIBRARY_PUBLIC_INCLS}
      )
    endif()

    if(CC_LIBRARY_INTERFACE_INCLS)
      target_include_directories(${target}
        INTERFACE ${CC_LIBRARY_INTERFACE_INCLS}
      )
    endif()

    if(CC_LIBRARY_PRIVATE_INCLS)
      target_include_directories(${target}
        PRIVATE ${CC_LIBRARY_PRIVATE_INCLS}
      )
    endif()

    if(CC_LIBRARY_PRIVATE_DEFINES)
      target_compile_definitions(${target}
        PRIVATE ${CC_LIBRARY_PRIVATE_DEFINES}
      )
    endif()

    if(CC_LIBRARY_PUBLIC_DEFINES)
      target_compile_definitions(${target}
        PUBLIC ${CC_LIBRARY_PUBLIC_DEFINES}
      )
    endif()

    if(CC_LIBRARY_INTERFACE_DEFINES)
      target_compile_definitions(${target}
        INTERFACE ${CC_LIBRARY_INTERFACE_DEFINES}
      )
    endif()

    if(CC_LIBRARY_PRIVATE_CFETURES)
      target_compile_features(${target}
        PRIVATE ${CC_LIBRARY_PRIVATE_CFETURES}
      )
    endif()

    if(CC_LIBRARY_PUBLIC_CFETURES)
      target_compile_features(${target}
        PUBLIC ${CC_LIBRARY_PUBLIC_CFETURES}
      )
    endif()

    if(CC_LIBRARY_INTERFACE_CFETURES)
      target_compile_features(${target}
        INTERFACE ${CC_LIBRARY_INTERFACE_CFETURES}
      )
    endif()    

    if(CC_LIBRARY_PUBLIC_COPTS)
      target_compile_options(${target}
        PUBLIC ${CC_LIBRARY_PUBLIC_COPTS}
      )
    endif()

    if(CC_LIBRARY_PRIVATE_COPTS)
      target_compile_options(${target}
        PRIVATE ${CC_LIBRARY_PRIVATE_COPTS}
      )
    endif()
    
    if(CC_LIBRARY_INTERFACE_COPTS)
      target_compile_options(${target}
        INTERFACE ${CC_LIBRARY_INTERFACE_COPTS}
      )
    endif()

    if(CC_LIBRARY_PUBLIC_LOPTS)
      target_link_options(${target}
        PUBLIC ${CC_LIBRARY_PUBLIC_LOPTS}
      )
    endif()

    if(CC_LIBRARY_PRIVATE_LOPTS)
      target_link_options(${target}
        PRIVATE ${CC_LIBRARY_PRIVATE_LOPTS}
      )
    endif()
    
    if(CC_LIBRARY_INTERFACE_LOPTS)
      target_link_options(${target}
        INTERFACE ${CC_LIBRARY_INTERFACE_LOPTS}
      )
    endif()

    if(CC_LIBRARY_PUBLIC_LPATHS)
      target_link_directories(${target}
        PUBLIC ${CC_LIBRARY_PUBLIC_LPATHS}
      )
    endif()

    if(CC_LIBRARY_PRIVATE_LPATHS)
      target_link_directories(${target}
        PRIVATE ${CC_LIBRARY_PRIVATE_LPATHS}
      )
    endif()
    
    if(CC_LIBRARY_INTERFACE_LPATHS)
      target_link_directories(${target}
        INTERFACE ${CC_LIBRARY_INTERFACE_LPATHS}
      )
    endif()

    if(CC_LIBRARY_PUBLIC_DEPS)
      ccm_deps(${target} ${CC_LIBRARY_NAMESPACE} PUBLIC ${CC_LIBRARY_PUBLIC_DEPS})
    endif()

    if(CC_LIBRARY_PRIVATE_DEPS)
      ccm_deps(${target} ${CC_LIBRARY_NAMESPACE} PRIVATE ${CC_LIBRARY_PRIVATE_DEPS})
    endif()    

    if(CC_LIBRARY_INTERFACE_DEPS)
      ccm_deps(${target} ${CC_LIBRARY_NAMESPACE} INTERFACE ${CC_LIBRARY_INTERFACE_DEPS})
    endif()

    if(CC_LIBRARY_ALWAYS_LINK)
      set_target_properties(${target} 
        PROPERTIES ALWAYS_LINK 1
      )
    endif()
  endif()

  if(CC_LIBRARY_NAMESPACE)
    add_library(${CC_LIBRARY_NAMESPACE}::${CC_LIBRARY_NAME} ALIAS ${target})
    set_target_properties(${target}
      PROPERTIES NAMESPACE ${CC_LIBRARY_NAMESPACE}
    )
  endif()
endfunction()

function(cc_binary)
  set(opts
    ENABLE_INSTALL
    ENABLE_TEST
  )

  set(single_args 
    NAME
    NAMESPACE
  )

  set(multi_args
    DEPS
    PRIVATE_DEPS

    INCLS
    PRIVATE_INCLS

    DEFINES
    PRIVATE_DEFINES

    CFETURES
    PRIVATE_CFETURES

    COPTS
    PRIVATE_COPTS

    LPATHS
    PRIVATE_LPATHS

    LOPTS
    PRIVATE_LOPTS   
  )

  cmake_parse_arguments(CC_BINARY "${opts}" "${single_args}" "${multi_args}" ${ARGN})

  if(CC_BINARY_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "unknown keywords given to cc_binary(): \"${CC_BINARY_UNPARSED_ARGUMENTS}\"")
    return()
  endif()

  if(NOT CC_BINARY_PRIVATE_DEPS)
    set(CC_BINARY_PRIVATE_DEPS ${CC_BINARY_DEPS})
  endif()

  if(NOT CC_BINARY_PRIVATE_INCLS)
    set(CC_BINARY_PRIVATE_INCLS ${CC_BINARY_INCLS})
  endif()

  if(NOT CC_BINARY_PRIVATE_DEFINES)
    set(CC_BINARY_PRIVATE_DEFINES ${CC_BINARY_DEFINES})
  endif()
  
  if(NOT CC_BINARY_PRIVATE_COPTS)
    set(CC_BINARY_PRIVATE_COPTS ${CC_BINARY_COPTS})
  endif()
  
  if(NOT CC_BINARY_PRIVATE_CFETURES)
    set(CC_BINARY_PRIVATE_CFETURES ${CC_BINARY_CFETURES})
  endif()
  
  if(NOT CC_BINARY_PRIVATE_LOPTS)
    set(CC_BINARY_PRIVATE_LOPTS ${CC_BINARY_LOPTS})
  endif()
  
  if(NOT CC_BINARY_PRIVATE_LPATHS)
    set(CC_BINARY_PRIVATE_LPATHS ${CC_BINARY_LPATHS})
  endif()  

  if(NOT CC_BINARY_NAME)
    message(FATAL_ERROR "required keyword NAME missing for cc_binary() call")
    return()
  endif()

  if(CC_BINARY_ENABLE_TEST AND NOT BUILD_TESTING)
    return()
  endif()

  if(CCM_NAMESPACE AND NOT CC_BINARY_NAMESPACE)
    set(CC_BINARY_NAMESPACE ${CCM_NAMESPACE})
  endif()

  if(CC_BINARY_NAMESPACE)
    string(REPLACE :: _ target ${CC_BINARY_NAMESPACE})
    string(APPEND target "_${CC_BINARY_NAME}")
  else()
    set(target ${CC_BINARY_NAME})
  endif()  

  collect_hdrs(hdrs "")
  collect_srcs(srcs "")

  if(NOT srcs)
    message(FATAL_ERROR "srcs are empty for cc_binary: ${target}")
    return()
  endif()

  add_executable(${target})

  target_sources(${target}
    PRIVATE 
      ${hdrs}
      ${srcs}
  )

  if(CC_BINARY_PRIVATE_DEFINES)
    target_compile_definitions(${target}
      PRIVATE ${CC_BINARY_PRIVATE_DEFINES}
    )
  endif()

  if(CC_BINARY_PRIVATE_FETURES)
    target_compile_features(${target}
      PRIVATE ${CC_BINARY_PRIVATE_FETURES}
    )
  endif()

  if(CC_BINARY_PRIVATE_COPTS)
    target_compile_options(${target}
      PRIVATE ${CC_BINARY_PRIVATE_COPTS}
    )
  endif()

  if(CC_BINARY_PRIVATE_LOPTS)
    target_link_options(${target}
      PRIVATE ${CC_BINARY_PRIVATE_LOPTS}
    )
  endif()  

  if(CC_BINARY_PRIVATE_LPATHS)
    target_link_directories(${target}
      PRIVATE ${CC_BINARY_PRIVATE_LPATHS}
    )
  endif()    

  if(CC_BINARY_PRIVATE_DEPS)
    ccm_deps(${target} ${CC_BINARY_NAMESPACE} PRIVATE ${CC_BINARY_PRIVATE_DEPS})
  endif()

  if(CC_BINARY_NAMESPACE)
    add_executable("${CC_BINARY_NAMESPACE}::${CC_BINARY_NAME}" ALIAS ${target})
    set_target_properties(${target}
      PROPERTIES NAMESPACE ${CC_BINARY_NAMESPACE}
    )    
  endif()

  if(CC_BINARY_ENABLE_TEST AND BUILD_TESTING)
    add_test(NAME ${target} COMMAND ${target})
  endif()
endfunction()

function(cc_test)
  if(BUILD_TESTING)
    cc_binary(${ARGN} ENABLE_TEST)
  endif()
endfunction()
