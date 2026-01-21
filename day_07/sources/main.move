module challenge::main {
    use std::string::{Self, String};
    use sui::object::UID;
    use sui::tx_context::TxContext;
    use sui::transfer;

    /// --------------------
    /// Core structs
    /// --------------------

    /// Bir habit
    public struct Habit has store, drop {
        name: String,
        completed: bool,
    }

    /// Habit listesi tutan on-chain object
    public struct HabitBook has key, store {
        id: UID,
        habits: vector<Habit>,
    }

    /// --------------------
    /// Core logic
    /// --------------------

    public fun new_book(ctx: &mut TxContext): HabitBook {
        HabitBook {
            id: sui::object::new(ctx),
            habits: vector[],
        }
    }

    public fun new_habit(name: String): Habit {
        Habit {
            name,
            completed: false,
        }
    }

    /// Day 6’dan: bytes -> String helper
    public fun make_habit(name_bytes: vector<u8>): Habit {
        let s = string::utf8(name_bytes);
        new_habit(s)
    }

    public fun add_habit(book: &mut HabitBook, habit: Habit) {
        vector::push_back(&mut book.habits, habit);
    }

    public fun add_habit_bytes(book: &mut HabitBook, name_bytes: vector<u8>) {
        let h = make_habit(name_bytes);
        add_habit(book, h);
    }

    /// Bir habit’i tamamla
    public fun complete_habit(book: &mut HabitBook, index: u64) {
        let h = vector::borrow_mut(&mut book.habits, index);
        h.completed = true;
    }

    public fun habit_count(book: &HabitBook): u64 {
        vector::length(&book.habits)
    }

    public fun habit_completed(book: &HabitBook, index: u64): bool {
        let h = vector::borrow(&book.habits, index);
        h.completed
    }

    public fun habit_name(book: &HabitBook, index: u64): &String {
        let h = vector::borrow(&book.habits, index);
        &h.name
    }

    /// Entry (prod için)
    public entry fun create_book(ctx: &mut TxContext) {
        let book = new_book(ctx);
        transfer::public_transfer(book, sui::tx_context::sender(ctx));
    }

    /// --------------------
    /// Tests (Day 7)
    /// --------------------

    #[test_only]
    const ALICE: address = @0xA;

    /// Test 1: Habit ekleme
    #[test]
    fun test_add_habits() {
        use sui::test_scenario as ts;

        let mut scenario = ts::begin(@0x0);
        scenario.next_tx(ALICE);

        let mut book = new_book(scenario.ctx());

        add_habit_bytes(&mut book, b"run");
        add_habit_bytes(&mut book, b"read");

        // habit sayısı doğru mu?
        assert!(habit_count(&book) == 2, 0);

        // isimler doğru mu?
        assert!(*string::as_bytes(habit_name(&book, 0)) == b"run", 1);
        assert!(*string::as_bytes(habit_name(&book, 1)) == b"read", 2);

        transfer::public_transfer(book, ALICE);
        ts::end(scenario);
    }

    /// Test 2: Habit tamamlama
    #[test]
    fun test_complete_habit() {
        use sui::test_scenario as ts;

        let mut scenario = ts::begin(@0x0);
        scenario.next_tx(ALICE);

        let mut book = new_book(scenario.ctx());

        add_habit_bytes(&mut book, b"gym");

        // başta tamamlanmamış olmalı
        assert!(!habit_completed(&book, 0), 10);

        // tamamla
        complete_habit(&mut book, 0);

        // artık tamamlanmış olmalı
        assert!(habit_completed(&book, 0), 11);

        transfer::public_transfer(book, ALICE);
        ts::end(scenario);
    }
}
