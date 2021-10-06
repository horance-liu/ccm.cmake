# file(GLOB_RECURSE public_hdrs CONFIGURE_DEPENDS
#   include/*.h
#   include/*.hpp
#   include/*.hxx
#   include/*.inc
# )

# file(GLOB_RECURSE private_hdrs CONFIGURE_DEPENDS
#   src/*.h
#   src/*.hpp
#   src/*.hxx
#   src/*.inc
# )

# file(GLOB_RECURSE srcs CONFIGURE_DEPENDS
#   src/*.c
#   src/*.cc
#   src/*.cpp
#   src/*.cxx
# )

# add_library(bar)

# target_sources(bar
#   PUBLIC
#     ${public_hdrs}
#   PRIVATE 
#     ${private_hdrs} 
#     ${srcs}
# )

# target_include_directories(bar
#   PUBLIC  include
#   PRIVATE src
# )

# target_link_libraries(bar
#   PRIVATE baz
# )

# target_compile_features(bar
#   PRIVATE cxx_std_11
# )

cc_library(
  NAME 
    bar
  DEPS 
    :baz
  CFETURES 
    cxx_std_11
)