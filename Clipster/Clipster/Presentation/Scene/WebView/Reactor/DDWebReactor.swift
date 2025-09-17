import Foundation
import ReactorKit

final class DDWebReactor: Reactor {
    enum Action {
        case viewDidLoad
    }

    enum Mutation {
        case updateViewDidLoad
    }

    struct State {
        let url: URL
        var isViewDidLoad = false
    }

    var initialState: State

    init(url: URL) {
        initialState = State(url: url)
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
                .just(.updateViewDidLoad)
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case .updateViewDidLoad:
            newState.isViewDidLoad = true
        }

        return newState
    }
}
