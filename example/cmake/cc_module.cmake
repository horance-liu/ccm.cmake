include(CMakeParseArguments)

function(target_do_force_link_libraries target visibility lib)
  if(MSVC)
    target_link_libraries(${target} ${visibility} "/WHOLEARCHIVE:${lib}")
  elseif(APPLE)
    target_link_libraries(${target} ${visibility} -Wl,-force_load ${lib})
  else()
    target_link_libraries(${target} ${visibility} -Wl,--whole-archive ${lib} -Wl,--no-whole-archive)
  endif()
endfunction()

function(target_force_link_libraries target)
  set(opts)
  set(single_args)
  set(multi_args
    PUBLIC
    PRIVATE
    INTERFACE
  )

  cmake_parse_arguments(CCM "${opts}" "${single_args}" "${multi_args}" ${ARGN})
  
  if(CCM_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "unknown keywords given to target_force_link_libraries(): \"${CCM_UNPARSED_ARGUMENTS}\"")
    return()
  endif()

  foreach(lib IN LISTS CCM_PUBLIC)
    target_do_force_link_libraries(${target} PUBLIC ${lib})
  endforeach()

  foreach(lib IN LISTS CCM_INTERFACE)
    target_do_force_link_libraries(${target} INTERFACE ${lib})
  endforeach()
  
  foreach(lib IN LISTS CCM_PRIVATE)
    target_do_force_link_libraries(${target} PRIVATE ${lib})
  endforeach()
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
    
    DEFINES
    PRIVATE_DEFINES 
    
    FETURES
    PRIVATE_FETURES

    COPTS
    PRIVATE_COPTS
  )

  cmake_parse_arguments(CCM "${opts}" "${single_args}" "${multi_args}" ${ARGN})

  if(CCM_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "unknown keywords given to cc_library(): \"${CCM_UNPARSED_ARGUMENTS}\"")
    return()
  endif()

  if(NOT CCM_NAME)
    message(FATAL_ERROR "required keyword NAME missing for cc_library() call")
    return()
  endif()

  if(CCM_NAMESPACE)
    string(REPLACE :: _ target ${CCM_NAMESPACE})
    string(APPEND target "_${CCM_NAME}")
  else()
    set(target ${CCM_NAME})
  endif()

  if(EXISTS include)
    file(GLOB_RECURSE public_hdrs CONFIGURE_DEPENDS
      include/*.h
      include/*.hpp
      include/*.hxx
      include/*.inc     
    )
  elseif(EXISTS src)
    file(GLOB_RECURSE srcs CONFIGURE_DEPENDS
      src/*.c
      src/*.cc
      src/*.cpp
      src/*.cxx
    )
    file(GLOB_RECURSE private_hdrs CONFIGURE_DEPENDS
      src/*.h
      src/*.hpp
      src/*.hxx
      src/*.inc
    )
  else()
    file(GLOB_RECURSE hdrs CONFIGURE_DEPENDS
      *.h
      *.hpp
      *.hxx
      *.inc
    )

    file(GLOB_RECURSE srcs CONFIGURE_DEPENDS
      *.c
      *.cc
      *.cpp
      *.cxx
    )

    if(NOT srcs)
      set(is_interface 1)
      set(public_hdrs  ${hdrs})
    else()
      set(is_interface 0)
      set(private_hdrs ${hdrs})
    endif()
  endif()

  if(is_interface)
    if(CCM_ALWAYS_LINK)
      message(FATAL_ERROR "ALWAYS_LINK should be empty for cc_library: interface ${target}")
      return()
    endif()

    if(CCM_PRIVATE_DEFINES)
      message(FATAL_ERROR "PRIVATE_DEFINES should be empty for cc_library: interface ${target}")
      return()
    endif()

    if(CCM_PRIVATE_COPTS)
      message(FATAL_ERROR "PRIVATE_COPTS should be empty for cc_library: interface ${target}")
      return()
    endif()

    if(CCM_PRIVATE_FETURES)
      message(FATAL_ERROR "PRIVATE_FETURES should be empty for cc_library: interface ${target}")
      return()
    endif()

    if(CCM_PRIVATE_DEPS)
      message(FATAL_ERROR "PRIVATE_DEPS should be empty for cc_library: interface ${target}")
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

    target_include_directories(${target}
      INTERFACE .
    )

    if(CCM_DEFINES)
      target_compile_definitions(${target}
        INTERFACE ${CCM_DEFINES}
      )
    endif()

    if(CCM_FETURES)
      target_compile_features(${target}
        INTERFACE ${CCM_FETURES}
      )
    endif()

    if(CCM_COPTS)
      target_compile_options(${target}
        INTERFACE ${CCM_COPTS}
      )
    endif()

    if(CCM_DEPS)
      target_link_libraries(${target}
        INTERFACE ${CCM_DEPS}
      )
    endif()
  else()
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

    target_include_directories(${target}
        PUBLIC  include
        PRIVATE src
    )

    if(CCM_DEFINES)
      target_compile_definitions(${target}
        PUBLIC ${CCM_DEFINES}
      )
    endif()

    if(CCM_PRIVATE_DEFINES)
      target_compile_definitions(${target}
        PRIVATE ${CCM_PRIVATE_DEFINES}
      )
    endif()

    if(CCM_FETURES)
      target_compile_features(${target}
        PUBLIC ${CCM_FETURES}
      )
    endif()

    if(CCM_PRIVATE_FETURES)
      target_compile_features(${target}
        PRIVATE ${CCM_PRIVATE_FETURES}
      )
    endif()    

    if(CCM_COPTS)
      target_compile_options(${target}
        PUBLIC ${CCM_COPTS}
      )
    endif()

    if(CCM_PRIVATE_COPTS)
      target_compile_options(${target}
        PRIVATE ${CCM_PRIVATE_COPTS}
      )
    endif()

    if(CCM_DEPS)
      target_link_libraries(${target}
        PUBLIC ${CCM_DEPS}
      )
    endif()

    if(CCM_PRIVATE_DEPS)
      target_link_libraries(${target}
        PRIVATE ${CCM_PRIVATE_DEPS}
      )
    endif()

    if(CCM_ALWAYS_LINK)
      set_target_properties(${target} 
        PROPERTIES ALWAYS_LINK 1
      )
    endif()    
  endif()

  if(CCM_NAMESPACE)
    add_library("${CCM_NAMESPACE}::${CCM_NAME}" ALIAS ${target})
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
    DEFINES
    FETURES
    COPTS
    LPATH
    LOPTS    
  )

  cmake_parse_arguments(CCM "${opts}" "${single_args}" "${multi_args}" ${ARGN})

  if(CCM_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "unknown keywords given to cc_binary(): \"${CCM_UNPARSED_ARGUMENTS}\"")
    return()
  endif()

  if(NOT CCM_NAME)
    message(FATAL_ERROR "required keyword NAME missing for cc_module() call")
    return()
  endif()

  if(CCM_ENABLE_TEST AND NOT BUILD_TESTING)
    return()
  endif()

  if(CCM_NAMESPACE)
    string(REPLACE :: _ target ${CCM_NAMESPACE})
    string(APPEND target "_${CCM_NAME}")
  else()
    set(target ${CCM_NAME})
  endif()  

  file(GLOB_RECURSE hdrs CONFIGURE_DEPENDS
    *.h
    *.hpp
    *.hxx
    *.inc
  )

  file(GLOB_RECURSE srcs CONFIGURE_DEPENDS
    *.c
    *.cc
    *.cpp
    *.cxx
  )

  if(NOT srcs)
    message(FATAL_ERROR "srcs are empty for cc_library: ${target}")
    return()
  endif()

  add_executable(${target})

  target_sources(${target}
    PRIVATE 
      ${hdrs}
      ${srcs}
  )

  if(CCM_DEFINES)
    target_compile_definitions(${target}
      PRIVATE ${CCM_DEFINES}
    )
  endif()

  if(CCM_FETURES)
    target_compile_features(${target}
      PRIVATE ${CCM_FETURES}
    )
  endif()

  if(CCM_COPTS)
    target_compile_options(${target}
      PRIVATE ${CCM_COPTS}
    )
  endif()

  if(CCM_DEPS)
    foreach(dep IN LISTS CCM_DEPS)
      get_target_property(force_link ${dep} ALWAYS_LINK)
      if (force_link)
        target_force_link_libraries(${target}
          PRIVATE ${dep}
        )
      else()
        target_link_libraries(${target}
          PRIVATE ${dep}
        )
      endif()
    endforeach()
  endif()

  if(CCM_NAMESPACE)
    add_executable("${CCM_NAMESPACE}::${CCM_NAME}" ALIAS ${target})
  endif()

  if(CCM_ENABLE_TEST AND BUILD_TESTING)
    add_test(NAME ${target} COMMAND ${target})
  endif()
endfunction()

function(cc_test)
  if(NOT BUILD_TESTING)
    return()
  endif()

  cc_binary(${ARGN} ENABLE_TEST)
endfunction()
