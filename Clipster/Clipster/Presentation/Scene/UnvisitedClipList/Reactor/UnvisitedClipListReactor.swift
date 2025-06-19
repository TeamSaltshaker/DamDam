import Foundation
import ReactorKit

final class UnvisitedClipListReactor: Reactor {
    enum Action {
        case viewWillAppear
        case tapBack
        case tapCell(Int)
        case tapDetail(Int)
        case tapEdit(Int)
        case tapDelete(Int)
    }

    enum Mutation {
        case setClips([ClipDisplay])
        case setPhase(State.Phase)
        case setRoute(State.Route?)
    }

    struct State {
        var clips: [ClipDisplay] = []
        @Pulse var phase: Phase = .idle
        @Pulse var route: Route?

        enum Phase {
            case idle
            case loading
            case success
            case error(String)
        }

        enum Route {
            case back
            case showWebView(URL)
            case showDetailClip(Clip)
            case showEditClip(Clip)
        }
    }

    let initialState = State()

    private var clips: [Clip]
    private var shouldFetchOnAppear: Bool = false

    private let fetchUnvisitedClipsUseCase: FetchUnvisitedClipsUseCase
    private let deleteClipUseCase: DeleteClipUseCase
    private let updateClipUseCase: UpdateClipUseCase

    init(
        clips: [Clip],
        fetchUnvisitedClipsUseCase: FetchUnvisitedClipsUseCase,
        deleteClipUseCase: DeleteClipUseCase,
        updateClipUseCase: UpdateClipUseCase
    ) {
        self.clips = clips
        self.fetchUnvisitedClipsUseCase = fetchUnvisitedClipsUseCase
        self.deleteClipUseCase = deleteClipUseCase
        self.updateClipUseCase = updateClipUseCase
    }

    func mutate(action: Action) -> Observable<Mutation> {
        print("\(Self.self): received action → \(action)")
        switch action {
        case .viewWillAppear:
            return fetchClipData()
        case .tapDelete(let index):
            guard clips.indices.contains(index) else { return .empty() }
            return deleteClip(clips[index])
        default:
            let route = makeRoute(for: action)
            return .just(.setRoute(route))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setClips(let display):
            newState.clips = display
        case .setRoute(let route):
            newState.route = route
        case .setPhase(let phase):
            newState.phase = phase
        }
        return newState
    }
}

private extension UnvisitedClipListReactor {
    func fetchClipData() -> Observable<Mutation> {
        Observable.concat([
            .just(.setPhase(.loading)),
            asyncMutate { try await self.makeClipsMutation() }
        ])
    }

    func makeClipsMutation() async throws -> Mutation {
        if self.shouldFetchOnAppear {
            let result = try await self.fetchUnvisitedClipsUseCase.execute().get()
            self.clips = result
        } else {
            self.shouldFetchOnAppear = true
        }
        let display = self.clips.map(ClipDisplayMapper.map)
        return .setClips(display)
    }

    func deleteClip(_ clip: Clip) -> Observable<Mutation> {
        Observable.concat([
            .just(.setPhase(.loading)),
            asyncMutate {
                try await self.deleteClipUseCase.execute(clip).get()
                return try await self.makeClipsMutation()
            }
        ])
    }

    func makeRoute(for action: Action) -> State.Route? {
        switch action {
        case .tapBack:
            return .back
        case .tapCell(let index):
            guard clips.indices.contains(index) else { return nil }
            Task { await updateClipAsVisited(clips[index]) }
            return .showWebView(clips[index].url)
        case .tapDetail(let index):
            guard clips.indices.contains(index) else { return nil }
            return .showDetailClip(clips[index])
        case .tapEdit(let index):
            guard clips.indices.contains(index) else { return nil }
            return .showEditClip(clips[index])
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

private extension UnvisitedClipListReactor {
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
}
