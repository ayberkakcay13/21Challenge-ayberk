module challenge::main {
    use std::string;
    use std::string::String;

    public struct Habit has drop, store {
        id: u64,
        name: String,
        done: bool,
    }

    public struct HabitList has drop, store {
        habits: vector<Habit>,
    }

    public fun empty_list(): HabitList {
        HabitList { habits: vector::empty<Habit>() }
    }

    public fun add_habit(list: &mut HabitList, habit: Habit) {
        vector::push_back(&mut list.habits, habit);
    }

    public fun length(list: &HabitList): u64 {
        vector::length(&list.habits)
    }

    #[test]
    fun test_add_habit() {
        let mut list = empty_list();

        let h1 = Habit { id: 1, name: string::utf8(b"Gym"), done: false };
        let h2 = Habit { id: 2, name: string::utf8(b"Read"), done: true };

        add_habit(&mut list, h1);
        add_habit(&mut list, h2);

        assert!(length(&list) == 2, 0);
    }
}

