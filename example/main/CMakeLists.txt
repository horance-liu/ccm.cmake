# add_executable(main main.cc)

# target_link_libraries(main
#   PRIVATE qux
# )

# ERR: no effect
# target_link_libraries(main
#   PRIVATE foo
# )

# get_target_property(force_link foo ALWAYS_LINK)

# if (force_link)
#   target_force_link_libraries(main
#     PRIVATE foo
#   )
# endif()

cc_test(
  NAME 
    main
  DEPS
    :qux
)

cc_flink(
  NAME
    main
  PRIVATE
    :foo
)
