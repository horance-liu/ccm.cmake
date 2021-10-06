# file(GLOB_RECURSE srcs CONFIGURE_DEPENDS
#   *.c
#   *.cc
#   *.cpp
#   *.cxx
# )

# add_library(foo)

# target_sources(foo
#   PRIVATE ${srcs}
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
  DEPS
    :bar
  CFETURES 
    cxx_std_11
)