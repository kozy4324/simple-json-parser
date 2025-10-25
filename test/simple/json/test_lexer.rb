# frozen_string_literal: true

require "test_helper"

module Simple
  module Json
    class TestLexer < Minitest::Test
      def test_tokenize # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
        lexer = Lexer.new(%([true,false]))
        # | [ true, false ]
        assert_equal [nil, :LBRACKET, false], [lexer.token, lexer.peek, lexer.done?]

        lexer.advance
        # [ | true, false ]
        assert_equal [:LBRACKET, :TRUE, false], [lexer.token, lexer.peek, lexer.done?]

        lexer.advance
        # [ true | , false ]
        assert_equal [:TRUE, :COMMA, false], [lexer.token, lexer.peek, lexer.done?]

        lexer.advance
        # [ true, | false ]
        assert_equal [:COMMA, :FALSE, false], [lexer.token, lexer.peek, lexer.done?]

        lexer.advance
        # [ true, false | ]
        assert_equal [:FALSE, :RBRACKET, false], [lexer.token, lexer.peek, lexer.done?]

        lexer.advance
        # [ true, false ] |
        assert_equal [:RBRACKET, nil, true], [lexer.token, lexer.peek, lexer.done?]

        lexer.advance
        # [ true, false ] |
        assert_equal [nil, nil, true], [lexer.token, lexer.peek, lexer.done?]
      end
    end
  end
end
