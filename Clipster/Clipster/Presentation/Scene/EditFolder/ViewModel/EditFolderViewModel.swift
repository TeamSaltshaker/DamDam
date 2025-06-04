import Foundation

enum EditFolderMode {
    case add(parentFolderID: UUID?, parentFolderTitle: String)
    case edit(folderToEdit: Folder, parentFolderTitle: String)
}

enum EditFolderAction {
    case folderTitleChanged(String)
    case saveButtonTapped
    case saveSucceeded
    case saveFailed(Error)
}

struct EditFolderState {
    let mode: EditFolderMode
    var folderTitle: String
    let initialFolderTitle: String
    let navigationTitle: String

    var isSavable: Bool {
        let trimmed = folderTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return false
        }

        switch mode {
        case .add:
            return true
        case .edit:
            return trimmed != initialFolderTitle
        }
    }

    var isProcessing: Bool = false
    var shouldDismiss: Bool = false
    var alertMessage: String?

    init(mode: EditFolderMode) {
        self.mode = mode
        switch mode {
        case .add(_, let parentFolderTitle):
            self.folderTitle = ""
            self.initialFolderTitle = ""
            self.navigationTitle = parentFolderTitle
        case .edit(let folder, let parentFolderTitle):
            self.folderTitle = folder.title
            self.initialFolderTitle = folder.title
            self.navigationTitle = parentFolderTitle
        }
    }
}
