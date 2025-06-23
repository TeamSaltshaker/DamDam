import Foundation
import ReactorKit

final class HomeReactor: Reactor {
    enum Action {
        case viewWillAppear
        case tapAddClip
        case tapAddFolder
        case tapCell(IndexPath)
        case tapDetail(IndexPath)
        case tapEdit(IndexPath)
        case tapDelete(IndexPath)
        case tapShowAllClips
    }

    enum Mutation {
        case setHomeDisplay([Clip], [Folder])
        case setPhase(State.Phase)
        case setRoute(State.Route?)
    }

    struct State {
        var homeDisplay: HomeDisplay?
        @Pulse var phase: Phase = .idle
        @Pulse var route: Route?

        enum Phase {
            case idle
            case loading
            case success
            case error(String)
        }

        enum Route {
            case showAddClip(Folder?)
            case showAddFolder
            case showWebView(URL)
            case showFolder(Folder)
            case showDetailClip(Clip)
            case showEditClip(Clip)
            case showEditFolder(Folder)
            case showUnvisitedClipList([Clip])
        }
    }

    enum SectionType {
        case unvisitedClip(Clip)
        case folder(Folder)
    }

    let initialState = State()

    private var unvisitedClips: [Clip] = []
    private var folders: [Folder] = []

    private let fetchUnvisitedClipsUseCase: FetchUnvisitedClipsUseCase
    private let fetchTopLevelFoldersUseCase: FetchTopLevelFoldersUseCase
    private let deleteClipUseCase: DeleteClipUseCase
    private let deleteFolderUseCase: DeleteFolderUseCase
    private let updateClipUseCase: UpdateClipUseCase

    init(
        fetchUnvisitedClipsUseCase: FetchUnvisitedClipsUseCase,
        fetchTopLevelFoldersUseCase: FetchTopLevelFoldersUseCase,
        deleteClipUseCase: DeleteClipUseCase,
        deleteFolderUseCase: DeleteFolderUseCase,
        updateClipUseCase: UpdateClipUseCase
    ) {
        self.fetchUnvisitedClipsUseCase = fetchUnvisitedClipsUseCase
        self.fetchTopLevelFoldersUseCase = fetchTopLevelFoldersUseCase
        self.deleteClipUseCase = deleteClipUseCase
        self.deleteFolderUseCase = deleteFolderUseCase
        self.updateClipUseCase = updateClipUseCase
    }

    func mutate(action: Action) -> Observable<Mutation> {
        print("\(Self.self): received action → \(action)")

        switch action {
        case .viewWillAppear:
            return .concat(
                .just(.setPhase(.loading)),
                .fromAsync { [weak self] in
                    guard let self else { throw DomainError.unknownError }

                    async let unvisitedClipsResult = fetchUnvisitedClipsUseCase.execute().get()
                    async let foldersResult = fetchTopLevelFoldersUseCase.execute().get()
                    let (unvisitedClips, folders) = try await (unvisitedClipsResult, foldersResult)

                    return .setHomeDisplay(unvisitedClips, folders)
                }
                .catch { .just(.setPhase(.error($0.localizedDescription))) },
                .just(.setPhase(.success))
            )

        case .tapDelete(let indexPath):
            return .concat(
                .just(.setPhase(.loading)),
                .fromAsync { [weak self] in
                    guard let self else { throw DomainError.unknownError }
                    guard let section = section(at: indexPath) else {
                        return .setPhase(.error("항목을 찾을 수 없습니다."))
                    }

                    switch section {
                    case .unvisitedClip(let clip):
                        try await deleteClipUseCase.execute(clip).get()
                    case .folder(let folder):
                        try await deleteFolderUseCase.execute(folder).get()
                    }

                    async let unvisitedClipsResult = fetchUnvisitedClipsUseCase.execute().get()
                    async let foldersResult = fetchTopLevelFoldersUseCase.execute().get()
                    let (unvisitedClips, folders) = try await (unvisitedClipsResult, foldersResult)

                    return .setHomeDisplay(unvisitedClips, folders)
                }
                .catch { .just(.setPhase(.error($0.localizedDescription))) },
                .just(.setPhase(.success))
            )

        case .tapCell(let indexPath):
            return .fromAsync { [weak self] in
                guard let self else { throw DomainError.unknownError }
                guard let section = section(at: indexPath) else {
                    return .setPhase(.error("항목을 찾을 수 없습니다."))
                }

                switch section {
                case .unvisitedClip(let clip):
                    let updatedClip = updateClipAsVisited(clip)
                    _ = await updateClipUseCase.execute(clip: updatedClip)
                    return .setRoute(.showWebView(clip.urlMetadata.url))
                case .folder(let folder):
                    return .setRoute(.showFolder(folder))
                }
            }
            .catch { .just(.setPhase(.error($0.localizedDescription))) }

        case .tapDetail(let indexPath):
            guard let section = section(at: indexPath) else {
                return .just(.setPhase(.error("항목을 찾을 수 없습니다.")))
            }

            switch section {
            case .unvisitedClip(let clip):
                return .just(.setRoute(.showDetailClip(clip)))
            case .folder:
                return .just(.setPhase(.error("폴더 상세보기는 지원하지 않습니다.")))
            }

        case .tapEdit(let indexPath):
            guard let section = section(at: indexPath) else {
                return .just(.setPhase(.error("항목을 찾을 수 없습니다.")))
            }

            switch section {
            case .unvisitedClip(let clip):
                return .just(.setRoute(.showEditClip(clip)))
            case .folder(let folder):
                return .just(.setRoute(.showEditFolder(folder)))
            }

        case .tapAddClip:
            return .just(.setRoute(.showAddClip(folders.max { $0.updatedAt < $1.updatedAt })))

        case .tapAddFolder:
            return .just(.setRoute(.showAddFolder))

        case .tapShowAllClips:
            return .just(.setRoute(.showUnvisitedClipList(unvisitedClips)))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setHomeDisplay(let unvisitedClips, let folders):
            self.unvisitedClips = unvisitedClips
            self.folders = folders

            let homeDisplay = HomeDisplay(
                unvisitedClips: unvisitedClips.map { ClipDisplayMapper.map($0) },
                folders: folders.map { FolderDisplayMapper.map($0) }
            )
            newState.homeDisplay = homeDisplay
        case .setRoute(let route):
            newState.route = route
        case .setPhase(let phase):
            newState.phase = phase
        }
        return newState
    }
}

private extension HomeReactor {
    func updateClipAsVisited(_ clip: Clip) -> Clip {
        Clip(
            id: clip.id,
            folderID: clip.folderID,
            urlMetadata: clip.urlMetadata,
            memo: clip.memo,
            lastVisitedAt: Date(),
            createdAt: clip.createdAt,
            updatedAt: Date(),
            deletedAt: clip.deletedAt
        )
    }
}

private extension HomeReactor {
    func section(at indexPath: IndexPath) -> SectionType? {
        switch indexPath.section {
        case 0:
            guard unvisitedClips.indices.contains(indexPath.item) else { return nil }
            return .unvisitedClip(unvisitedClips[indexPath.item])
        case 1:
            guard folders.indices.contains(indexPath.item) else { return nil }
            return .folder(folders[indexPath.item])
        default:
            return nil
        }
    }
}
