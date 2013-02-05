/**
 * @file ecc.cc
 * kiwi/ecc
 *
 * Copyright (c) 2013 Hugo Peixoto.
 * Distributed under the MIT License.
 */
#include "kiwi/ecc/compiler.h"

int main ()
{
    kiwi::ecc::Compiler c;
    c.compile(stdin, stdout);
    return 0;
}
