# frozen_string_literal: true

require "test_helper"
require "json"

module Simple
  module Json
    class TestParser < Minitest::Test
      def parse_and_assert(str)
        assert_equal JSON.parse(str), Parser.new(str).parse_json
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
      end
    end
  end
end
