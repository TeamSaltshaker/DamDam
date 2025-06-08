import Foundation
import RxSwift
import RxRelay

final class FolderViewModel {
    enum Action {
        case didTapAddClipButton
        case didTapAddFolderButton
        case didTapCell(IndexPath)
        case didTapEditButton(IndexPath)
        case didTapDeleteButton(IndexPath)
    }

    struct State {
        let currentFolderTitle: String
        let folders: [FolderCellDisplay]
        let clips: [ClipCellDisplay]
    }

    enum Navigation {
        case editClipView(Clip?)
        case editFolderView(Folder?)
        case folderView(Folder)
        case clipDetailView(Clip)
        case webView(URL)
    }

    var action = PublishRelay<Action>()
    var state: BehaviorRelay<State>
    var navigation = PublishRelay<Navigation>()
    var disposeBag = DisposeBag()

    private let folder: Folder
    private let mapper: CellDisplayMapper

    init(
        folder: Folder,
        mapper: CellDisplayMapper,
    ) {
        self.folder = folder
        self.mapper = mapper
        state = BehaviorRelay(value: State(
            currentFolderTitle: folder.title,
            folders: folder.folders.map { mapper.folderCellDisplay(from: $0) },
            clips: folder.clips.map { mapper.clipCellDisplay(from: $0) },
        ))
        setBindings()
    }
}

private extension FolderViewModel {
    func setBindings() {

    }
}
