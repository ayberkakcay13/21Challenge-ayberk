module challenge::day_02 {

    #[test_only]
    use std::unit_test::assert_eq;

    /// İki u64 sayıyı toplar
    public fun sum(a: u64, b: u64): u64 {
        a + b
    }

    #[test]
    fun test_sum() {
        let result = sum(1, 2);
        assert_eq!(result, 3);
    }
}
