enum FolderSortOption: Hashable {
    case title(SortDirection)
    case createdAt(SortDirection)
    case updatedAt(SortDirection)
}
