/**
 * @file compiler.h
 * kiwi/ecc
 *
 * Copyright (c) 2013 Hugo Peixoto.
 * Distributed under the MIT License.
 */
#ifndef KIWI_HTTP_COMPILER_H_
#define KIWI_HTTP_COMPILER_H_

#include <string>

namespace kiwi {
  namespace ecc {
    class Compiler {
      public:
      Compiler ();
      ~Compiler ();

      void compile (FILE* a_in, FILE* a_out);

      std::string compile (const std::string& a_input);

      public:
      void begin_coder (bool a_printing);
      void end_coder ();

      void print_html (const char* a_html);
      void print_cc (const char* a_cc);

      void putc (char a_character);
      void puts (const char* a_string);

      protected:
      class Writer {
        public:
        virtual ~Writer ();
        virtual void printf (const char* a_format, ...) = 0;
      };

      class FileWriter : public Writer {
        public:
        FileWriter (FILE* a_fp);
        void printf (const char* a_format, ...);

        protected:
        FILE* fp;
      };

      class StringWriter : public Writer {
        public:
        void printf (const char* a_format, ...);
        std::string buffer;
      };

      Writer* writer;

      bool printing;
      bool string;
    };
  }
}

#endif // KIWI_HTTP_COMPILER_H_
