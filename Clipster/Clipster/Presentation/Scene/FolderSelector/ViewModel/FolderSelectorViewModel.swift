enum FolderSelectorMode {
    case clip
    case folder
}

enum FolderSelectorAction {
    case viewDidLoad
    case dataLoaded(folders: [Folder])
    case dataLoadFailed(Error)
    case openSubfolder(folder: Folder)
    case navigateUp
    case selectButtonTapped
    case addButtonTapped
    case folderAdded(folder: Folder)
}
