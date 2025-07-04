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
        case setHomeDisplay([Clip], [Folder], [Clip])
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
        case clip(Clip)
    }

    let initialState = State()

    private var unvisitedClips: [Clip] = []
    private var folders: [Folder] = []
    private var clips: [Clip] = []

    private let fetchUnvisitedClipsUseCase: FetchUnvisitedClipsUseCase
    private let fetchTopLevelFoldersUseCase: FetchTopLevelFoldersUseCase
    private let fetchTopLevelClipsUseCase: FetchTopLevelClipsUseCase
    private let deleteClipUseCase: DeleteClipUseCase
    private let deleteFolderUseCase: DeleteFolderUseCase
    private let visitClipUseCase: VisitClipUseCase
    private let fetchClipSortOptionUseCase: FetchClipSortOptionUseCase
    private let fetchFolderSortOptionUseCase: FetchFolderSortOptionUseCase
    private let sortClipsUseCase: SortClipsUseCase
    private let sortFoldersUseCase: SortFoldersUseCase

    init(
        fetchUnvisitedClipsUseCase: FetchUnvisitedClipsUseCase,
        fetchTopLevelFoldersUseCase: FetchTopLevelFoldersUseCase,
        fetchTopLevelClipsUseCase: FetchTopLevelClipsUseCase,
        deleteClipUseCase: DeleteClipUseCase,
        deleteFolderUseCase: DeleteFolderUseCase,
        visitClipUseCase: VisitClipUseCase,
        fetchClipSortOptionUseCase: FetchClipSortOptionUseCase,
        fetchFolderSortOptionUseCase: FetchFolderSortOptionUseCase,
        sortClipsUseCase: SortClipsUseCase,
        sortFoldersUseCase: SortFoldersUseCase
    ) {
        self.fetchUnvisitedClipsUseCase = fetchUnvisitedClipsUseCase
        self.fetchTopLevelFoldersUseCase = fetchTopLevelFoldersUseCase
        self.fetchTopLevelClipsUseCase = fetchTopLevelClipsUseCase
        self.deleteClipUseCase = deleteClipUseCase
        self.deleteFolderUseCase = deleteFolderUseCase
        self.visitClipUseCase = visitClipUseCase
        self.fetchClipSortOptionUseCase = fetchClipSortOptionUseCase
        self.fetchFolderSortOptionUseCase = fetchFolderSortOptionUseCase
        self.sortClipsUseCase = sortClipsUseCase
        self.sortFoldersUseCase = sortFoldersUseCase
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
                    async let clipsResult = fetchTopLevelClipsUseCase.execute().get()
                    async let clipSortOption = fetchClipSortOptionUseCase.execute().get()
                    async let folderSortOption = fetchFolderSortOptionUseCase.execute().get()

                    let (
                        unvisitedClips,
                        folders,
                        clips,
                        clipSort,
                        folderSort
                    ) = try await (
                        unvisitedClipsResult,
                        foldersResult,
                        clipsResult,
                        clipSortOption,
                        folderSortOption
                    )

                    let sortedFolders = sortFoldersUseCase.execute(folders, by: folderSort)
                    let sortedClips = sortClipsUseCase.execute(clips, by: clipSort)

                    return .setHomeDisplay(unvisitedClips, sortedFolders, sortedClips)
                },
                .just(.setPhase(.success))
            )
            .catch { .just(.setPhase(.error($0.localizedDescription))) }

        case .tapDelete(let indexPath):
            return .concat(
                .just(.setPhase(.loading)),
                .fromAsync { [weak self] in
                    guard let self else { throw DomainError.unknownError }
                    guard let section = section(at: indexPath) else {
                        return .setPhase(.error("항목을 찾을 수 없습니다."))
                    }

                    switch section {
                    case .unvisitedClip(let clip), .clip(let clip):
                        try await deleteClipUseCase.execute(clip).get()
                    case .folder(let folder):
                        try await deleteFolderUseCase.execute(folder).get()
                    }

                    async let unvisitedClipsResult = fetchUnvisitedClipsUseCase.execute().get()
                    async let foldersResult = fetchTopLevelFoldersUseCase.execute().get()
                    async let clipsResult = fetchTopLevelClipsUseCase.execute().get()
                    let (unvisitedClips, folders, clips) = try await (
                        unvisitedClipsResult,
                        foldersResult,
                        clipsResult
                    )

                    return .setHomeDisplay(unvisitedClips, folders, clips)
                },
                .just(.setPhase(.success))
            )
            .catch { .just(.setPhase(.error($0.localizedDescription))) }

        case .tapCell(let indexPath):
            return .fromAsync { [weak self] in
                guard let self else { throw DomainError.unknownError }
                guard let section = section(at: indexPath) else {
                    return .setPhase(.error("항목을 찾을 수 없습니다."))
                }

                switch section {
                case .unvisitedClip(let clip), .clip(let clip):
                    _ = try await visitClipUseCase.execute(clip: clip).get()
                    return .setRoute(.showWebView(clip.url))
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
            case .unvisitedClip(let clip), .clip(let clip):
                return .just(.setRoute(.showDetailClip(clip)))
            case .folder:
                return .just(.setPhase(.error("폴더 상세보기는 지원하지 않습니다.")))
            }

        case .tapEdit(let indexPath):
            guard let section = section(at: indexPath) else {
                return .just(.setPhase(.error("항목을 찾을 수 없습니다.")))
            }

            switch section {
            case .unvisitedClip(let clip), .clip(let clip):
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
        case .setHomeDisplay(let unvisitedClips, let folders, let clips):
            self.unvisitedClips = unvisitedClips
            self.folders = folders
            self.clips = clips

            let homeDisplay = HomeDisplay(
                unvisitedClips: unvisitedClips.map { ClipDisplayMapper.map($0) },
                folders: folders.map { FolderDisplayMapper.map($0) },
                clips: clips.map { ClipDisplayMapper.map($0) }
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
    func section(at indexPath: IndexPath) -> SectionType? {
        switch indexPath.section {
        case 0:
            guard unvisitedClips.indices.contains(indexPath.item) else { return nil }
            return .unvisitedClip(unvisitedClips[indexPath.item])
        case 1:
            guard folders.indices.contains(indexPath.item) else { return nil }
            return .folder(folders[indexPath.item])
        case 2:
            guard clips.indices.contains(indexPath.item) else { return nil }
            return .clip(clips[indexPath.item])
        default:
            return nil
        }
    }
}
