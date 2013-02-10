/**
 * @file compiler.cc
 * tests
 *
 * Copyright (c) 2013 Hugo Peixoto.
 * Distributed under the MIT License.
 */
#include "gtest/gtest.h"
#include "kiwi/ecc/compiler.h"

using kiwi::ecc::Compiler;

TEST(KiwiEccCompiler, ShouldCompileEmptyFile)
{
  EXPECT_EQ("", Compiler().compile(""));
}

TEST(KiwiEccCompiler, ShouldCompileSimpleHTML)
{
  EXPECT_EQ(
    "output_buffer() << \"<h1>Hello</h1>\";",
    Compiler().compile("<h1>Hello</h1>"));
}

TEST(KiwiEccCompiler, ShouldCompilePrintTag)
{
  EXPECT_EQ(
    "output_buffer() <<  1 ;",
    Compiler().compile("<%= 1 %>"));
}

TEST(KiwiEccCompiler, ShouldCompileExecuteTag)
{
  EXPECT_EQ(
    " debug_trace() ;",
    Compiler().compile("<% debug_trace() %>"));
}

TEST(KiwiEccCompiler, ShouldCompilePrintAndExecuteTag)
{
  EXPECT_EQ(
    " int i = 2 ;output_buffer() <<  i ;",
    Compiler().compile("<% int i = 2 %><%= i %>"));
}

