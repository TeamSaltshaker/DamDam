enum ClipDetailAction {
    case viewDidLoad
    case viewWillAppear
    case editButtonTapped
    case deleteButtonTapped
    case deleteConfirmed
    case dataLoadSucceeded(clip: Clip, folder: Folder)
    case dataLoadFailed(Error)
    case deleteSucceeded
    case deleteFailed(Error)
}

struct ClipDetailState {
    var clip: Clip
    var clipDisplay: ClipDisplay
    var folder: Folder?
    let navigationTitle: String
    var isLoading = true
    var isProcessingDelete = false
    var shouldDismiss = false
    var shouldNavigateToEdit = false
    var showDeleteConfirmation = false
    var errorMessage: String?

    init(clip: Clip, navigationTitle: String) {
        self.clip = clip
        self.clipDisplay = ClipDisplayMapper.map(clip)
        self.navigationTitle = navigationTitle
    }
}
