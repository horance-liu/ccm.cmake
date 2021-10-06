include(CMakeParseArguments)

function(ccm_get_real_dep_name dep namespace real_dep)
  string(FIND ${dep} ":" idx)

  if(idx EQUAL 0)
    if(namespace)
      string(PREPEND dep "${namespace}:")
    else()
      string(SUBSTRING ${dep} 1 -1 dep)
    endif()
  endif()
  
  set(${real_dep} ${dep} PARENT_SCOPE)
endfunction()

function(cc_flink_do target namespace visibility dep)
  ccm_get_real_dep_name(${dep} "${namespace}" real_dep)
  if(MSVC)
    target_link_libraries(${target} ${visibility} "/WHOLEARCHIVE:${real_dep}")
  elseif(APPLE)
    target_link_libraries(${target} ${visibility} -Wl,-force_load ${real_dep})
  else()
    target_link_libraries(${target} ${visibility} -Wl,--whole-archive ${real_dep} -Wl,--no-whole-archive)
  endif()
endfunction()

function(cc_flink)
  set(opts)
  
  set(single_args 
    NAME
    NAMESPACE
  )

  set(multi_args
    PUBLIC
    PRIVATE
    INTERFACE
  )

  cmake_parse_arguments(CC_FLINK "${opts}" "${single_args}" "${multi_args}" ${ARGN})
  
  if(CC_FLINK_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "unknown keywords given to cc_flink(): \"${CC_FLINK_UNPARSED_ARGUMENTS}\"")
    return()
  endif()

  if(NOT CC_FLINK_NAME)
    message(FATAL_ERROR "required keyword NAME missing for cc_library() call")
    return()
  endif()  

  if(CCM_NAMESPACE AND NOT CC_FLINK_NAMESPACE)
    set(CC_FLINK_NAMESPACE ${CCM_NAMESPACE})
  endif()

  if(CC_FLINK_NAMESPACE)
    string(REPLACE :: _ target ${CC_FLINK_NAMESPACE})
    string(APPEND target "_${CC_FLINK_NAME}")
  else()
    set(target ${CC_FLINK_NAME})
  endif()  

  foreach(dep IN LISTS CC_FLINK_PUBLIC)
    cc_flink_do(${target} ${CC_FLINK_NAMESPACE} PUBLIC ${dep})
  endforeach()

  foreach(dep IN LISTS CC_FLINK_INTERFACE)
    cc_flink_do(${target} ${CC_FLINK_NAMESPACE} INTERFACE ${dep})
  endforeach()
  
  foreach(dep IN LISTS CC_FLINK_PRIVATE)
    cc_flink_do(${target} "${CC_FLINK_NAMESPACE}" PRIVATE ${dep})
  endforeach()
endfunction()

function(target_force_link_libraries target)
  cc_flink(NAME ${target} ${ARGN})
endfunction()