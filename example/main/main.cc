#include "qux.h"
#include <stdlib.h>
#include <stdio.h>

int main(int argc, char **argv)
{
    expect_contains("foo");
    printf("succ\n");
    return EXIT_SUCCESS;
}