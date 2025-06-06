import Foundation
import RxRelay
import RxSwift

final class EditClipViewModel: ViewModel {
    enum Action {
        case editURLInputTextField(String)
    }

    enum Mutation {
        case updateURLInputText(String)
    }

    struct State {
        var urlInputText: String = ""
        var isEmptyURLInput: Bool = false
        var isHiddenURLMetadataStackView = false
        var isHiddenURLValidationStackView = false
    }

    var state: BehaviorRelay<State>
    var action = PublishRelay<Action>()
    var disposeBag = DisposeBag()

    init() {
        state = BehaviorRelay(value: State())
        bind()
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .editURLInputTextField(let urlText):
            return .just(.updateURLInputText(urlText))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .updateURLInputText(let urlText):
            newState.urlInputText = urlText
            newState.isEmptyURLInput = newState.urlInputText.isEmpty
            newState.isHiddenURLMetadataStackView = newState.urlInputText.isEmpty
            newState.isHiddenURLValidationStackView = newState.urlInputText.isEmpty
        }
        return newState
    }
}
