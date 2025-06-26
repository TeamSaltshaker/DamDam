enum SortHelper {
    static func compare<T: Comparable>(_ lhs: T, _ rhs: T, _ direction: SortDirection) -> Bool {
        direction == .ascending ? lhs < rhs : lhs > rhs
    }
}
