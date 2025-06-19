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
        case setHomeDisplay(HomeDisplay)
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
            return fetchHomeData()
        case .tapDelete(let indexPath):
            return handleDelete(at: indexPath)
        default:
            let route = makeRoute(for: action)
            return .just(.setRoute(route))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setHomeDisplay(let display):
            newState.homeDisplay = display
        case .setRoute(let route):
            newState.route = route
        case .setPhase(let phase):
            newState.phase = phase
        }
        return newState
    }
}

private extension HomeReactor {
    func fetchHomeData() -> Observable<Mutation> {
        Observable.concat([
            .just(.setPhase(.loading)),
            asyncMutate { try await self.makeHomeDisplayMutation() }
        ])
    }

    func makeHomeDisplayMutation() async throws -> Mutation {
        async let clips = self.makeClipDisplays()
        async let folders = self.makeFolderDisplays()
        let display = try await HomeDisplay(unvisitedClips: clips, folders: folders)
        return .setHomeDisplay(display)
    }

    func makeClipDisplays() async throws -> [ClipDisplay] {
        let clips = try await fetchUnvisitedClipsUseCase.execute().get()
        self.unvisitedClips = clips
        return clips.map(ClipDisplayMapper.map)
    }

    func makeFolderDisplays() async throws -> [FolderDisplay] {
        let folders = try await fetchTopLevelFoldersUseCase.execute().get()
        self.folders = folders
        return folders.map(FolderDisplayMapper.map)
    }

    func handleDelete(at indexPath: IndexPath) -> Observable<Mutation> {
        Observable.concat([
            .just(.setPhase(.loading)),
            asyncMutate {
                guard let section = self.section(at: indexPath) else {
                    return .setPhase(.error("삭제할 항목을 찾을 수 없습니다."))
                }

                switch section {
                case .unvisitedClip(let clip):
                    try await self.deleteClipUseCase.execute(clip).get()
                case .folder(let folder):
                    try await self.deleteFolderUseCase.execute(folder).get()
                }

                return try await self.makeHomeDisplayMutation()
            }
        ])
    }

    func makeRoute(for action: Action) -> State.Route? {
        switch action {
        case .tapCell(let indexPath):
            guard let section = section(at: indexPath) else { return nil }

            switch section {
            case .unvisitedClip(let clip):
                Task { await updateClipAsVisited(clip) }
                return .showWebView(clip.url)
            case .folder(let folder):
                return .showFolder(folder)
            }
        case .tapDetail(let indexPath):
            guard case let .unvisitedClip(clip)? = section(at: indexPath) else { return nil }
            return .showDetailClip(clip)
        case .tapEdit(let indexPath):
            guard let section = section(at: indexPath) else { return nil }

            switch section {
            case .unvisitedClip(let clip):
                return .showEditClip(clip)
            case .folder(let folder):
                return .showEditFolder(folder)
            }
        case .tapAddClip:
            let latestFolder = folders.max { $0.updatedAt < $1.updatedAt }
            return .showAddClip(latestFolder)
        case .tapAddFolder:
            return .showAddFolder
        case .tapShowAllClips:
            return .showUnvisitedClipList(unvisitedClips)
        default:
            return nil
        }
    }

    func updateClipAsVisited(_ clip: Clip) async {
        let visited = Clip(
            id: clip.id,
            folderID: clip.folderID,
            url: clip.url,
            title: clip.title,
            memo: clip.memo,
            thumbnailImageURL: clip.thumbnailImageURL,
            screenshotData: clip.screenshotData,
            lastVisitedAt: Date(),
            createdAt: clip.createdAt,
            updatedAt: Date(),
            deletedAt: clip.deletedAt,
        )
        _ = await updateClipUseCase.execute(clip: visited)
    }
}

private extension HomeReactor {
    func asyncMutate(_ task: @escaping () async throws -> Mutation) -> Observable<Mutation> {
        Observable.create { observer in
            Task {
                do {
                    let mutation = try await task()
                    observer.onNext(mutation)
                    observer.onNext(.setPhase(.success))
                } catch {
                    observer.onNext(.setPhase(.error(error.localizedDescription)))
                }
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }

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
