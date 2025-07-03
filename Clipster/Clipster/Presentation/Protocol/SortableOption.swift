protocol SortableOption: Hashable {
    var displayText: String { get }
    var isAscending: Bool { get }

    func toggled() -> Self
    func isSameSortBasis(as other: Self) -> Bool
}
