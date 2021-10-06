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

# add_library(qux)

# target_sources(qux
#   PUBLIC
#     ${public_hdrs}
#   PRIVATE 
#     ${private_hdrs} 
#     ${srcs}
# )

# target_include_directories(qux
#   PUBLIC  include
#   PRIVATE src
# )

# target_link_libraries(qux
#   PRIVATE bar
# )

cc_library(
  NAME 
    qux
  DEPS
    :bar
)