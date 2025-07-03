enum ClipSortOption: Hashable {
    case title(SortDirection)
    case lastVisitedAt(SortDirection)
    case createdAt(SortDirection)
    case updatedAt(SortDirection)
}
