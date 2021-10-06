#include "qux.h"
#include "bar.h"

#include <iostream>
#include <stdlib.h>

#define ASSERT_TRUE(exp) \
do { \
    if (!(exp)) { \
        std::cerr << "expect " #exp " be true, but got false" << std::endl; \
        exit( EXIT_FAILURE ); \
    } \
} while(0)

void expect_contains(const std::string& val)
{
    ASSERT_TRUE(bar_exist(val));
}