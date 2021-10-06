#include "qux.h"
#include <stdlib.h>

int main(int argc, char **argv)
{
    expect_contains("foo");
    return EXIT_SUCCESS;
}