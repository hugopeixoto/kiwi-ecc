/**
 * @file compiler.yy
 * kiwi/ecc
 *
 * Copyright (c) 2013 Hugo Peixoto.
 * Distributed under the MIT License.
 */
%{
#include "kiwi/ecc/compiler.h"
#include <vector>
%}

%option reentrant
%option extra-type="kiwi::ecc::Compiler*"
%x IN_CC CC_COMMENT CC_STRING
%%

<INITIAL>{
"<%="   yyextra->begin_coder(true); BEGIN(IN_CC);
"<%"    BEGIN(IN_CC);
[^<]+   yyextra->print_html(yytext);
"<"     yyextra->print_html(yytext);
}

<CC_COMMENT>{
"*/"        BEGIN(IN_CC);
[^*]+
"*"
}

<CC_STRING>{
"\""        yyextra->print_cc(yytext); BEGIN(IN_CC);
\\.         yyextra->print_cc(yytext);
[^\\"]+     yyextra->print_cc(yytext);
}

<IN_CC>{
"%>"        yyextra->end_coder(); BEGIN(INITIAL);
"\""        yyextra->print_cc(yytext); BEGIN(CC_STRING);
"/*"        BEGIN(CC_COMMENT);
[^%"/]+     yyextra->print_cc(yytext);
"%"         yyextra->print_cc(yytext);
}

%%

using kiwi::ecc::Compiler;

Compiler::Compiler ()
{
  writer = nullptr;
}

Compiler::~Compiler ()
{
  if (writer != nullptr) {
    delete writer;
  }
}

void Compiler::compile (FILE* a_in, FILE* a_out)
{
    yyscan_t scanner;

    // init
    printing = false;
    writer = new FileWriter(a_out);

    yyset_in(a_in, scanner);

    // compiler
    yylex_init_extra(this, &scanner);
    yylex(scanner);
    yylex_destroy(scanner);
}

std::string Compiler::compile (const std::string& a_input)
{
    yyscan_t scanner;

    // init
    printing = false;
    writer = new StringWriter();

    yylex_init_extra(this, &scanner);
    YY_BUFFER_STATE state = yy_scan_string(a_input.c_str(), scanner);
    yylex(scanner);
    yy_delete_buffer(state, scanner);
    yylex_destroy(scanner);

    return static_cast<StringWriter*>(writer)->buffer;
}

void Compiler::begin_coder (bool a_printing)
{
  printing = a_printing;
  puts("(output_buffer) << ");
}

void Compiler::end_coder ()
{
  if (printing) {
    puts(";");
  }
}

void Compiler::print_html (const char* a_html)
{
  begin_coder(true);
  puts("\"");

  printf(">>%s\n", a_html);

  while (*a_html) {
    putc(*a_html++);
  }

  puts("\"");
  end_coder();
}

void Compiler::print_cc (const char* a_cc)
{
  puts(a_cc);
}

void Compiler::puts (const char* a_string)
{
    writer->printf("%s", a_string);
}

void Compiler::putc (char a_character)
{
  switch (a_character) {
    case '"':
    case '\\':
      writer->printf("\\%c", a_character);
      break;

    case '\n':
      writer->printf("\\n");
      break;

    default:
      writer->printf("%c", a_character);
      break;
  }
}

Compiler::FileWriter::FileWriter (FILE* a_fp)
{
  fp = a_fp;
}

Compiler::Writer::~Writer ()
{
}

void Compiler::FileWriter::printf (const char* a_format, ...)
{
  va_list args;
  va_start(args, a_format);
  vfprintf(fp, a_format, args);
  va_end(args);
}

void Compiler::StringWriter::printf (const char* a_format, ...)
{
  std::vector<char> current(100, '\0');
  va_list args;

  for (bool done = false; !done;) {
    va_start(args, a_format);
    auto n = vsnprintf(current.data(), current.size(), a_format, args);
    va_end(args);
    
    if (n < 0) {
      return;
    }

    done = (n < current.size());
  }

  buffer.append(current.data());
}

