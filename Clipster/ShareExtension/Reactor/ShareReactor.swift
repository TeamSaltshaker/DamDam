import Foundation
import ReactorKit

final class ShareReactor: Reactor {
    enum Action {
        case viewWillAppear
        case extractedURL(URL)
    }

    enum Mutation {
        case updateIsReadyExtractURL(Bool)
        case updateURLString(String)
    }

    struct State {
        var isReadyToExtractURL = false
        var urlString: String = ""
    }

    var initialState: State

    init() {
        self.initialState = State()
    }

    func mutate(action: Action) -> Observable<Mutation> {
        print("\(Self.self) action: \(action)")
        switch action {
        case .viewWillAppear:
            return .just(.updateIsReadyExtractURL(true))
        case .extractedURL(let url):
            return .just(.updateURLString(url.absoluteString))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case .updateIsReadyExtractURL(let value):
            newState.isReadyToExtractURL = value
        case .updateURLString(let urlString):
            newState.urlString = urlString
        }

        return newState
    }
}
