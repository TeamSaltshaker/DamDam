import Foundation
import ReactorKit
import RxRelay

final class FolderReactor: Reactor {
    enum Action {
        case viewWillAppear
        case didTapCell(IndexPath)
        case didTapAddFolderButton
        case didTapAddClipButton
        case didTapDetailButton(IndexPath)
        case didTapEditButton(IndexPath)
        case didTapDeleteButton(IndexPath)
    }

    enum Mutation {
        case reloadFolder(Folder)
        case updateClipLastVisitedDate(Clip)
        case route(Route)
    }

    struct State {
        var currentFolderTitle: String
        var folders: [FolderDisplay]
        var clips: [ClipDisplay]
        var isEmptyViewHidden: Bool
    }

    enum Route {
        case editClipViewForAdd(Folder)
        case editClipViewForEdit(Clip)
        case editFolderView(Folder, Folder?)
        case folderView(Folder)
        case clipDetailView(Clip)
        case webView(URL)
    }

    let initialState: State
    let route = PublishRelay<Route>()
    private var folder: Folder

    private let fetchFolderUseCase: FetchFolderUseCase
    private let deleteFolderUseCase: DeleteFolderUseCase
    private let updateClipUseCase: UpdateClipUseCase
    private let deleteClipUseCase: DeleteClipUseCase

    init(
        folder: Folder,
        fetchFolderUseCase: FetchFolderUseCase,
        deleteFolderUseCase: DeleteFolderUseCase,
        updateClipUseCase: UpdateClipUseCase,
        deleteClipUseCase: DeleteClipUseCase,
    ) {
        self.folder = folder
        self.fetchFolderUseCase = fetchFolderUseCase
        self.deleteFolderUseCase = deleteFolderUseCase
        self.updateClipUseCase = updateClipUseCase
        self.deleteClipUseCase = deleteClipUseCase

        initialState = State(
            currentFolderTitle: folder.title,
            folders: folder.folders.map { FolderDisplayMapper.map($0) },
            clips: folder.clips.map { ClipDisplayMapper.map($0) },
            isEmptyViewHidden: !folder.folders.isEmpty || !folder.clips.isEmpty,
        )
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return reloadFolder()
        case .didTapCell(let indexPath):
            switch indexPath.section {
            case 0:
                return routeToFolderView(at: indexPath.item)
            case 1:
                return Observable.concat(
                    updateLastVisitedDate(at: indexPath.item),
                    routeToWebView(at: indexPath.item),
                )
            default:
                return .empty()
            }
        case .didTapAddFolderButton:
            return routeToAddFolderView()
        case .didTapAddClipButton:
            return routeToAddClipView()
        case .didTapDetailButton(let indexPath):
            switch indexPath.section {
            case 1:
                return routeToClipDetailView(at: indexPath.item)
            default:
                return .empty()
            }
        case .didTapEditButton(let indexPath):
            switch indexPath.section {
            case 0:
                return routeToEditFolderView(at: indexPath.item)
            case 1:
                return routeToEditClipView(at: indexPath.item)
            default:
                return .empty()
            }
        case .didTapDeleteButton(let indexPath):
            return Observable.concat(
                delete(at: indexPath),
                reloadFolder(),
            )
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case .reloadFolder(let folder):
            newState.currentFolderTitle = folder.title
            newState.folders = folder.folders.map(FolderDisplayMapper.map)
            newState.clips = folder.clips.map(ClipDisplayMapper.map)
            newState.isEmptyViewHidden = !folder.folders.isEmpty || !folder.clips.isEmpty
        case .updateClipLastVisitedDate(let updatedClip):
            if let index = newState.clips.firstIndex(where: { $0.id == updatedClip.id }) {
                newState.clips[index] = ClipDisplayMapper.map(updatedClip)
            }
        case .route(let route):
            self.route.accept(route)
        }

        return newState
    }
}

private extension FolderReactor {
    func reloadFolder() -> Observable<Mutation> {
        Observable.create { [weak self] observer in
            guard let self else {
                observer.onCompleted()
                return Disposables.create()
            }

            Task {
                guard case let .success(folder) = await self.fetchFolderUseCase.execute(id: self.folder.id) else {
                    print("\(Self.self): Failed to reload")
                    observer.onCompleted()
                    return
                }
                self.folder = folder
                observer.onNext(.reloadFolder(folder))
                observer.onCompleted()
            }

            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
        .asObservable()
    }

    func updateLastVisitedDate(at index: Int) -> Observable<Mutation> {
        Observable.create { [weak self] observer in
            guard let self else {
                observer.onCompleted()
                return Disposables.create()
            }

            Task {
                let clip = self.folder.clips[index]
                let updatedClip = Clip(
                    id: clip.id,
                    folderID: clip.folderID,
                    urlMetadata: clip.urlMetadata,
                    memo: clip.memo,
                    lastVisitedAt: Date.now,
                    createdAt: clip.createdAt,
                    updatedAt: Date.now,
                    deletedAt: clip.deletedAt,
                )
                _ = await self.updateClipUseCase.execute(clip: updatedClip)
                observer.onNext(.updateClipLastVisitedDate(updatedClip))
                observer.onCompleted()
            }

            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
        .asObservable()
    }

    func routeToWebView(at index: Int) -> Observable<Mutation> {
        let url = folder.clips[index].urlMetadata.url
        return Observable.just(.route(.webView(url)))
    }

    func routeToFolderView(at index: Int) -> Observable<Mutation> {
        let folder = folder.folders[index]
        return Observable.just(.route(.folderView(folder)))
    }

    func routeToAddFolderView() -> Observable<Mutation> {
        Observable.just(.route(.editFolderView(folder, nil)))
    }

    func routeToAddClipView() -> Observable<Mutation> {
        Observable.just(.route(.editClipViewForAdd(folder)))
    }

    func routeToClipDetailView(at index: Int) -> Observable<Mutation> {
        let clip = folder.clips[index]
        return Observable.just(.route(.clipDetailView(clip)))
    }

    func routeToEditFolderView(at index: Int) -> Observable<Mutation> {
        let selectedFolder = folder.folders[index]
        return Observable.just(.route(.editFolderView(folder, selectedFolder)))
    }

    func routeToEditClipView(at index: Int) -> Observable<Mutation> {
        let clip = folder.clips[index]
        return Observable.just(.route(.editClipViewForEdit(clip)))
    }

    func delete(at indexPath: IndexPath) -> Observable<Mutation> {
        Observable.create { [weak self] observer in
            guard let self else {
                observer.onCompleted()
                return Disposables.create()
            }

            Task {
                switch indexPath.section {
                case 0:
                    let folder = self.folder.folders[indexPath.item]
                    _ = await self.deleteFolderUseCase.execute(folder)
                case 1:
                    let clip = self.folder.clips[indexPath.item]
                    _ = await self.deleteClipUseCase.execute(clip)
                default:
                    break
                }
                observer.onCompleted()
            }

            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
        .asObservable()
    }
}
