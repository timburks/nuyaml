(load "yaml/YAML")

(class TestExtensions is NuTestCase
     (- (id) testStringIndent is
        (assert_equal 0 ("foo" indentLevel))
        (assert_equal 1 (" bar" indentLevel))
        (assert_equal 5 ("     baz" indentLevel))))

(class TestExporting is NuTestCase
     (- (id) testSimpleArrays is
        (set wanted "\n- apple\n- banana\n- carrot")
        (set s01 (array "apple" "banana" "carrot"))
        (assert_equal wanted (s01 yamlDescription)))
     
     (- (id) testNestedArrays is
          (set wanted "\n- \n  - foo\n  - bar\n  - baz")
          (set s02 (array (array "foo" "bar" "baz")))
          (assert_equal wanted (s02 yamlDescription))))
