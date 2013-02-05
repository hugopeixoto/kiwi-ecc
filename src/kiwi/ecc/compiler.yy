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

using kiwi::ecc::Compiler;

%}

%option reentrant
%option extra-type="Compiler*"
%x IN_CC CC_COMMENT CC_STRING
%%

<INITIAL>{
"<%="   yyextra->begin(Compiler::State::CC_RENDER); BEGIN(IN_CC);
"<%"    yyextra->begin(Compiler::State::CC_EXEC); BEGIN(IN_CC);
[^<]+   yyextra->add(yytext);
"<"     yyextra->add(yytext);
}

<CC_COMMENT>{
"*/"        BEGIN(IN_CC);
[^*]+
"*"
}

<CC_STRING>{
"\""        yyextra->add(yytext); BEGIN(IN_CC);
\\.         yyextra->add(yytext);
[^\\"]+     yyextra->add(yytext);
}

<IN_CC>{
"%>"        yyextra->begin(Compiler::State::HTML); BEGIN(INITIAL);
"\""        yyextra->add(yytext); BEGIN(CC_STRING);
"/*"        BEGIN(CC_COMMENT);
[^%"/]+     yyextra->add(yytext);
"%"         yyextra->add(yytext);
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
    writer = new FileWriter(a_out);
    begin(State::HTML);

    yyset_in(a_in, scanner);

    // compiler
    yylex_init_extra(this, &scanner);
    yylex(scanner);
    yylex_destroy(scanner);

    end();
}

std::string Compiler::compile (const std::string& a_input)
{
    yyscan_t scanner;

    // init
    writer = new StringWriter();
    begin(State::HTML);

    yylex_init_extra(this, &scanner);
    YY_BUFFER_STATE state = yy_scan_string(a_input.c_str(), scanner);
    yylex(scanner);
    yy_delete_buffer(state, scanner);
    yylex_destroy(scanner);

    end();

    return static_cast<StringWriter*>(writer)->buffer;
}

void Compiler::begin (State a_state)
{
  end();

  state = a_state;
}

void Compiler::end ()
{
  if (buffer.size()) {
    switch (state) {
      case State::HTML:
        puts("(output_buffer) << \"");
        for (size_t i = 0; i < buffer.size(); ++i) {
          putc(buffer[i]);
        }

        puts("\"");
        break;

      case State::CC_RENDER:
        puts("(output_buffer) << ");
        puts(buffer.c_str());
        break;

      case State::CC_EXEC:
        puts(buffer.c_str());
        break;
    }

    puts(";");
    buffer.resize(0);
  }
}

void Compiler::add (const char* a_buffer)
{
  buffer.append(a_buffer);
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

