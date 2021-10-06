# add_executable(main main.cc)

# target_link_libraries(main
#   PRIVATE qux
# )

# target_force_link_libraries(main
#   PRIVATE foo
# )

# add_test(NAME main COMMAND main)

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
