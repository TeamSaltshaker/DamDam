import Foundation
import ReactorKit

final class DDWebReactor: Reactor {
    enum Action {}

    enum Mutation {}

    struct State {}

    var initialState: State

    init() {
        self.initialState = State()
    }

    func mutate(action: Action) -> Observable<Mutation> {}

    func reduce(state: State, mutation: Mutation) -> State {}
}
