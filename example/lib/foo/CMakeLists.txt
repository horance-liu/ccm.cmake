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

# add_library(foo)

# target_sources(foo
#   PRIVATE
#     ${internal_hdrs}
#     ${srcs}
# )

# target_link_libraries(foo
#   PRIVATE bar
# )

# target_compile_features(foo
#   PRIVATE cxx_std_11
# )

cc_library(
  NAME 
    foo
  NAMESPACE
    ccm::demo
  PRIVATE_DEPS
    ccm::demo::bar
  PRIVATE_FETURES 
    cxx_std_11
  ALWAYS_LINK
)