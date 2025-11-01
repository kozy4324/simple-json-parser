# frozen_string_literal: true

require "test_helper"
require "json"

module Simple
  module Json
    class TestParser < Minitest::Test # rubocop:disable Metrics/ClassLength
      def parse_and_assert(str)
        assert_equal JSON.parse(str), Parser.new(str).parse_json
      end

      def parse_and_assert_raises(str)
        assert_raises { JSON.parse(str) }
        assert_raises { Parser.new(str).parse_json }
      end

      def test_parse_true
        parse_and_assert %(true)
      end

      def test_parse_false
        parse_and_assert %(false)
      end

      def test_parse_value_with_whitespaces
        parse_and_assert %( true)
        parse_and_assert %(true )
        parse_and_assert %(  true  )
      end

      def test_parse_empty_array
        parse_and_assert %([])
      end

      def test_parse_array_with_a_single_value
        parse_and_assert %([true])
      end

      def test_parse_array_with_multiple_values
        parse_and_assert %([true, false])
        parse_and_assert %([true, false, true])
      end

      def test_parse_nested_array
        parse_and_assert %([[]])
        parse_and_assert %([[[]]])
        parse_and_assert %([true, [true, [false, []]]])
      end

      def test_parse_null
        assert_nil JSON.parse(%(null))
      end

      def test_parse_string_value
        parse_and_assert %("string")
      end

      def test_parse_empty_object
        parse_and_assert %({})
      end

      def test_parse_object_with_a_single_value
        parse_and_assert %({"key1": "value1"})
      end

      def test_parse_object_with_multiple_values
        parse_and_assert %({"key1": "value1", "key2": "value2"})
      end

      def test_parse_nested_object
        parse_and_assert %({"key1": "value1", "key2": {"key3": [true, false]}})
      end

      def test_parse_number_value
        parse_and_assert %(123)
        parse_and_assert %(0)
        parse_and_assert %(-1)
        parse_and_assert %(-20)
      end

      def test_parse_number_with_fraction_value
        parse_and_assert %(123.0)
        parse_and_assert %(0.1)
        parse_and_assert %(10.23)
        parse_and_assert %(-4.560)
      end

      def test_parse_number_with_exponent_value
        parse_and_assert %(123E0)
        parse_and_assert %(123e1)
        parse_and_assert %(0E+1)
        parse_and_assert %(-2e+34)
        parse_and_assert %(56e-7)
        parse_and_assert %(-0e1000)
      end

      def test_parse_number_with_fraction_and_exponent_value
        parse_and_assert %(123.0E1)
        parse_and_assert %(0.1e+2)
        parse_and_assert %(10.23E-3)
        parse_and_assert %(-4.560E0)
      end

      def test_parse_invalid_integer_number_value
        parse_and_assert_raises %(+1)
        parse_and_assert_raises %(2+)
        parse_and_assert_raises %(--3)
        parse_and_assert_raises %(E4)
        parse_and_assert_raises %(e5)
        parse_and_assert_raises %(.6)
        parse_and_assert_raises %(07)
        parse_and_assert_raises %(-08)
      end

      def test_parse_invalid_fraction_number_value
        parse_and_assert_raises %(1.+)
        parse_and_assert_raises %(2.-)
        parse_and_assert_raises %(3..)
        parse_and_assert_raises %(1.)
        parse_and_assert_raises %(3.E)
      end

      def test_parse_invalid_exponent_number_value
        parse_and_assert_raises %(1Ee)
        parse_and_assert_raises %(2eE)
        parse_and_assert_raises %(3E.)
        parse_and_assert_raises %(4e1+)
        parse_and_assert_raises %(5E2-)
        parse_and_assert_raises %(6e+-)
        parse_and_assert_raises %(7E-+)
        parse_and_assert_raises %(2e)
        parse_and_assert_raises %(5.2E+)
        parse_and_assert_raises %(6.3e-)
      end

      def test_parse_plain_string
        parse_and_assert %("abc")
      end

      def test_parse_empty_string
        parse_and_assert %("")
      end

      def test_parse_string_includes_multibyte_chars
        parse_and_assert %("文字列")
      end

      def test_parse_string_includes_escape
        parse_and_assert %("abc\\"def")
        parse_and_assert %("abc\\\\def")
      end
    end
  end
end
