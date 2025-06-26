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
        case setClips([Clip])
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
    private let visitClipUseCase: VisitClipUseCase

    init(
        clips: [Clip],
        fetchUnvisitedClipsUseCase: FetchUnvisitedClipsUseCase,
        deleteClipUseCase: DeleteClipUseCase,
        visitClipUseCase: VisitClipUseCase
    ) {
        self.clips = clips
        self.fetchUnvisitedClipsUseCase = fetchUnvisitedClipsUseCase
        self.deleteClipUseCase = deleteClipUseCase
        self.visitClipUseCase = visitClipUseCase
    }

    func mutate(action: Action) -> Observable<Mutation> {
        print("\(Self.self): received action → \(action)")
        switch action {
        case .viewWillAppear:
            return .concat(
                .just(.setPhase(.loading)),
                .fromAsync { [weak self] in
                    guard let self else { throw DomainError.unknownError }

                    let clips: [Clip]
                    if shouldFetchOnAppear {
                        clips = try await fetchUnvisitedClipsUseCase.execute().get()
                    } else {
                        shouldFetchOnAppear = true
                        clips = self.clips
                    }
                    return .setClips(clips)
                },
                .just(.setPhase(.success))
            )
            .catch { .just(.setPhase(.error($0.localizedDescription))) }

        case .tapBack:
            return .just(.setRoute(.back))

        case .tapCell(let index):
            return .fromAsync { [weak self] in
                guard let self else { throw DomainError.unknownError }
                guard clips.indices.contains(index) else {
                    return .setPhase(.error("항목을 찾을 수 없습니다."))
                }

                _ = try await visitClipUseCase.execute(clip: clips[index]).get()
                return .setRoute(.showWebView(clips[index].url))
            }

        case .tapDetail(let index):
            guard clips.indices.contains(index) else {
                return .just(.setPhase(.error("항목을 찾을 수 없습니다.")))
            }

            return .just(.setRoute(.showDetailClip(clips[index])))

        case .tapEdit(let index):
            guard clips.indices.contains(index) else {
                return .just(.setPhase(.error("항목을 찾을 수 없습니다.")))
            }

            return .just(.setRoute(.showDetailClip(clips[index])))

        case .tapDelete(let index):
            return .concat(
                .just(.setPhase(.loading)),
                .fromAsync { [weak self] in
                    guard let self else { throw DomainError.unknownError }
                    guard clips.indices.contains(index) else {
                        return .setPhase(.error("항목을 찾을 수 없습니다."))
                    }

                    try await deleteClipUseCase.execute(clips[index]).get()

                    let clips = try await fetchUnvisitedClipsUseCase.execute().get()
                    return .setClips(clips)
                },
                .just(.setPhase(.success))
            )
            .catch { .just(.setPhase(.error($0.localizedDescription))) }
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setClips(let clips):
            self.clips = clips

            let display = clips.map(ClipDisplayMapper.map)
            newState.clips = display
        case .setRoute(let route):
            newState.route = route
        case .setPhase(let phase):
            newState.phase = phase
        }
        return newState
    }
}
