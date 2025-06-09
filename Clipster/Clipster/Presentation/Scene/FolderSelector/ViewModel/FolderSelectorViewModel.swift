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

struct FolderSelectorState {
    let mode: FolderSelectorMode
    var folders: [Folder] = []
    var currentPath: [Folder] = []
    var isLoading = true
    var errorMessage: String?
    var didFinishSelection: Folder?

    var subfolders: [Folder] {
        currentPath.last?.folders ?? folders
    }

    var selectedFolder: Folder? {
        currentPath.last
    }

    var title: String {
        selectedFolder?.title ?? ""
    }

    var canNavigateUp: Bool {
        !currentPath.isEmpty
    }

    var isAddButtonHidden: Bool {
        mode == .folder
    }
}
