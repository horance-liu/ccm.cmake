# file(GLOB_RECURSE internal_hdrs CONFIGURE_DEPENDS
#   include/*.h
#   include/*.hpp
#   include/*.hxx
#   include/*.inc
# )

# file(GLOB_RECURSE srcs CONFIGURE_DEPENDS
#   src/*.c
#   src/*.cc
#   src/*.cpp
#   src/*.cxx
# )

# add_library(qux)

# target_sources(qux
#   PRIVATE 
#     ${internal_hdrs} 
#     ${srcs}
# )

# target_include_directories(qux
#   PUBLIC  include
#   PRIVATE src
# )

# target_link_libraries(qux
#   PUBLIC bar
# )

cc_library(
  NAME 
    qux
  NAMESPACE 
    ccm::demo
  DEPS 
    ccm::demo::bar
)