# frozen_string_literal: true

require_relative "parser/version"
require_relative "lexer"

module Simple
  module Json
    #
    # Parser: 構文解析器
    #
    # - 基本は1文法ルールに1パースメソッドが対応する
    # - 読み込み位置はパースメソッド開始時点でその文法の先頭にあり、終了時点で末尾まで進むものとする
    #   - e.g. parse_object の開始時点で開始位置「|」は「|{...}」となり、終了時点で「{...}|」となる
    # - トークン列で考えるとメソッド開始時点でその文法の直前トークン、終了時点でその文法の最終トークンが token から取得できる
    #   - e.g.
    #       トークン列 => [ :LCURLY, :STRING, :COLON, :LBRACKET, :TRUE, :COMMA, :FALSE, :RBRACKET, :RCURLY ]
    #       該当文字列 =>   "{"      "key"    ":"     "["        "true" ","     "false" "]"        "}"
    #
    #       "[true,false]" を処理する parse_array 開始時点では (token = :COLON, peek = :LBRACKET)
    #       トークン列 => [ :LCURLY, :STRING, :COLON, :LBRACKET, :TRUE, :COMMA, :FALSE, :RBRACKET, :RCURLY ]
    #       該当文字列 =>   "{"      "key"    ":"     "["        "true" ","     "false" "]"        "}"
    #                                       ^^^^^^^
    #       parse_array 終了時点では (token = :RBRACKET, peek = :RCURLY)
    #       トークン列 => [ :LCURLY, :STRING, :COLON, :LBRACKET, :TRUE, :COMMA, :FALSE, :RBRACKET, :RCURLY ]
    #       該当文字列 =>   "{"      "key"    ":"     "["        "true" ","     "false" "]"        "}"
    #                                                                                 ^^^^^^^^^^
    #
    class Parser
      def initialize(string)
        @lexer = Lexer.new string
      end

      # json ::= element
      def parse_json
        v = parse_element
        @lexer.advance
        raise "invalid input." unless @lexer.done?

        v
      end

      private

      # value ::= object | array | string | number | "true" | "false" | "null"
      def parse_value # rubocop:disable Metrics/MethodLength,Metrics/CyclomaticComplexity
        case @lexer.peek
        when :LCURLY
          parse_object
        when :LBRACKET
          parse_array
        when :QUOTE
          parse_string
        when :NUMBER
          parse_number
        when :TRUE
          @lexer.advance # 'true'
          true
        when :FALSE
          @lexer.advance # 'false'
          false
        when :NULL
          @lexer.advance # 'null'
          nil
        end
      end

      # object ::= '{' ws '}' | '{' members '}'
      def parse_object
        @lexer.advance # '{'
        parse_ws
        object = case @lexer.peek
                 when :RCURLY
                   {}
                 else
                   parse_members
                 end
        @lexer.advance # '}'
        object
      end

      # members ::= member | member ',' members
      def parse_members
        members = {}
        members.merge! parse_member
        if @lexer.peek == :COMMA
          @lexer.advance
          members.merge! parse_members
        end
        members
      end

      # member ::= ws string ws ':' element
      def parse_member
        parse_ws
        key = parse_string
        parse_ws
        @lexer.advance # ':'
        value = parse_element
        { key => value }
      end

      # array ::= '[' ws ']' | '[' elements ']'
      def parse_array
        @lexer.advance # '['
        parse_ws
        array = case @lexer.peek
                when :RBRACKET
                  []
                else
                  parse_elements
                end
        @lexer.advance # ']'
        array
      end

      # elements ::= element | element ',' elements
      def parse_elements
        elements = []
        elements << parse_element
        if @lexer.peek == :COMMA
          @lexer.advance # ','
          elements.concat parse_elements
        end
        elements
      end

      # element ::= ws value ws
      def parse_element
        parse_ws
        value = parse_value
        parse_ws
        value
      end

      # string ::= '"' characters '"'
      # characters ::= "" | character characters
      # character ::= '0020' . '10FFFF' - '"' - '\' | '\' escape
      # escape ::= '"' | '\' | '/' | 'b' | 'f' | 'n' | 'r' | 't' | 'u' hex hex hex hex
      # hex ::= digit | 'A' . 'F' | 'a' . 'f'
      def parse_string
        @lexer.string_value
      end

      # number ::= integer fraction exponent
      # integer ::= digit | onenine digits | '-' digit | '-' onenine digits
      # digits ::= digit | digit digits
      # digit ::= '0' | onenine
      # onenine ::= '1' . '9'
      # fraction ::= "" | '.' digits
      # exponent ::= "" | 'E' sign digits | 'e' sign digits
      # sign ::= "" | '+' | '-'
      def parse_number
        @lexer.number_value
      end

      # ws ::= "" | '0020' ws | '000A' ws | '000D' ws | '0009' ws
      def parse_ws
        @lexer.ignore_ws
      end
    end
  end
end
