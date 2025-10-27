# frozen_string_literal: true

require "strscan"

module Simple
  module Json
    #
    # Lexer: 字句解析器
    #
    # 以下のJSON文字列を扱うとする
    # { "key": [ true, false ] }
    #
    # 以下のトークン列が取得できる
    # トークン列 => [ :LCURLY, :STRING, :COLON, :LBRACKET, :TRUE, :COMMA, :FALSE, :RBRACKET, :RCURLY ]
    # 該当文字列 =>   "{"      "key"    ":"     "["        "true" ","     "false" "]"        "}"
    #
    # 読み込み位置を「|」と表現する、初期状態は以下となる
    # | { "key": [ true, false ] }
    # ^ (token => nil, peek => :LCURLY, done? => false)
    #
    # advance によって読み込み位置が1トークン分進み、現在のトークンが更新される
    # { | "key": [ true, false ] }
    # ^^^ (token => :LCURLY, peek => :STRING, done? => false)
    # ↓
    # { "key" | : [ true, false ] }
    #   ^^^^^^^ (token => :STRING, peek => :COLON, done? => false)
    # ↓
    # { "key" : | [ true, false ] }
    #         ^^^ (token => :COLON, peek => :LBRACKET, done? => false)
    #
    # 最後の読み込み位置から advance を呼び出すと done? が true となる
    # { "key" : [ true, false ] | }
    #                         ^^^ (token => :RBRACKET, peek => :RCURLY, done? => false)
    # ↓
    # { "key" : [ true, false ] } |
    #                           ^^^ (token => :RCURLY, peek => nil, done? => false)
    # ↓
    # { "key" : [ true, false ] } |
    #                             ^ (token => nil, peek => nil, done? => true)
    class Lexer
      # number ::= integer fraction exponent
      # integer ::= digit | onenine digits | '-' digit | '-' onenine digits
      # digits ::= digit | digit digits
      # digit ::= '0' | onenine
      # onenine ::= '1' . '9'
      # fraction ::= "" | '.' digits
      # exponent ::= "" | 'E' sign digits | 'e' sign digits
      # sign ::= "" | '+' | '-'
      NUMBER_REGEXP = /[1-9]+/

      def initialize(string)
        @scan = StringScanner.new string
        @token = nil
      end

      # 現在のトークンを取得する
      attr_reader :token

      # 読み込み位置を1トークン分進める
      def advance = scan(true)

      # 読み込み位置を進めずに次のトークンを取得する
      def peek = scan(false)

      # 現在読み込み位置以降の連続するホワイトスペースを読み飛ばす
      def ignore_ws = @scan.skip(/\s+/)

      # 全てのトークンが処理済みかどうか
      def done? = @scan.eos? && @token.nil?

      # 現在読み込み位置以降の文字列値を取得して読み込み位置を進める、エスケープはまだ考慮できていない
      def string_value = @scan.scan(/[^"]+/)

      # 現在読み込み位置以降の数値を取得して読み込み位置を進める
      def number_value = @scan.scan(NUMBER_REGEXP).to_i

      def to_s = @scan.inspect

      private

      def scan(with_advance) # rubocop:disable Metrics/MethodLength,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
        t = if @scan.scan_full("true", with_advance, true)
              :TRUE
            elsif @scan.scan_full("false", with_advance, true)
              :FALSE
            elsif @scan.scan_full("null", with_advance, true)
              :NULL
            elsif @scan.scan_full("{", with_advance, true)
              :LCURLY
            elsif @scan.scan_full("}", with_advance, true)
              :RCURLY
            elsif @scan.scan_full("[", with_advance, true)
              :LBRACKET
            elsif @scan.scan_full("]", with_advance, true)
              :RBRACKET
            elsif @scan.scan_full(":", with_advance, true)
              :COLON
            elsif @scan.scan_full(",", with_advance, true)
              :COMMA
            elsif @scan.scan_full('"', with_advance, true)
              :QUOTE
            elsif @scan.scan_full(NUMBER_REGEXP, with_advance, true)
              :NUMBER
            end
        @token = t if with_advance
        t
      end
    end
  end
end
