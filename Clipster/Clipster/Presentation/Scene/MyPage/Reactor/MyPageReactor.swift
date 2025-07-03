import Foundation
import ReactorKit

final class MyPageReactor: Reactor {
    enum Action {
        case viewWillAppear
        case tapCell(MyPageItem)
        case changeTheme(ThemeOption)
    }

    enum Mutation {
        case setSectionModel([MyPageSectionModel])
        case setPhase(State.Phase)
        case setRoute(State.Route?)
    }

    struct State {
        var sectionModel: [MyPageSectionModel] = []
        @Pulse var phase: Phase = .idle
        @Pulse var route: Route?

        enum Phase {
            case idle
            case loading
            case success
            case error(String)
        }

        enum Route {
            case showEditNickName
            case showSelectTheme(
                currentOption: ThemeOption,
                availableOptions: [ThemeOption]
            )
            case showSelectFolderSort(
                currentOption: FolderSortOption,
                availableOptions: [FolderSortOption]
            )
            case showSelectClipSort(
                currentOption: ClipSortOption,
                availableOptions: [ClipSortOption]
            )
            case showSelectSavePathLayout(
                currentOption: SavePathOption,
                availableOptions: [SavePathOption]
            )
            case showNotificationSetting
            case showTrash
            case showSupport
        }
    }

    let initialState = State()

    private let loginUseCase: LoginUseCase
    private let fetchThemeUseCase: FetchThemeOptionUseCase
    private let fetchFolderSortUseCase: FetchFolderSortOptionUseCase
    private let fetchClipSortUseCase: FetchClipSortOptionUseCase
    private let fetchSavePathLayoutUseCase: FetchSavePathLayoutOptionUseCase
    private let logoutUseCase: LogoutUseCase
    private let withdrawUseCase: WithdrawUseCase
    private let saveThemeOptionUseCase: SaveThemeOptionUseCase

    init(
        loginUseCase: LoginUseCase,
        fetchThemeUseCase: FetchThemeOptionUseCase,
        fetchFolderSortUseCase: FetchFolderSortOptionUseCase,
        fetchClipSortUseCase: FetchClipSortOptionUseCase,
        fetchSavePathLayoutUseCase: FetchSavePathLayoutOptionUseCase,
        logoutUseCase: LogoutUseCase,
        withdrawUseCase: WithdrawUseCase,
        saveThemeOptionUseCase: SaveThemeOptionUseCase
    ) {
        self.loginUseCase = loginUseCase
        self.fetchThemeUseCase = fetchThemeUseCase
        self.fetchFolderSortUseCase = fetchFolderSortUseCase
        self.fetchClipSortUseCase = fetchClipSortUseCase
        self.fetchSavePathLayoutUseCase = fetchSavePathLayoutUseCase
        self.logoutUseCase = logoutUseCase
        self.withdrawUseCase = withdrawUseCase
        self.saveThemeOptionUseCase = saveThemeOptionUseCase
    }

    func mutate(action: Action) -> Observable<Mutation> {
        print("\(Self.self): received action → \(action)")

        switch action {
        case .viewWillAppear:
            return .concat(
                .just(.setPhase(.loading)),
                .fromAsync { [weak self] in
                    guard let self else { throw DomainError.unknownError }

                    let sectionModels = try await makeSectionModels(isLogin: true)
                    return .setSectionModel(sectionModels)
                },
                .just(.setPhase(.success))
            )
            .catch {
                .just(.setPhase(.error($0.localizedDescription)))
            }
        case .tapCell(let item):
            switch item {
            case .login:
                return .empty()
            case .chevron(let chevronItem):
                return .just(makeChevronItemMutation(item: chevronItem))
            case .detail(let detailItem):
                return .just(makeDetailItemMutation(item: detailItem))
            case .dropdown(let dropdownItem):
                return .just(makeDropdownItemMutation(item: dropdownItem))
            case .account(let accountItem):
                return .concat(
                    .just(.setPhase(.loading)),
                    .fromAsync { [weak self] in
                        guard let self else { throw DomainError.unknownError }
                        return try await makeAccountItemMutation(item: accountItem)
                    },
                    .just(.setPhase(.success))
                )
                .catch {
                    .just(.setPhase(.error($0.localizedDescription)))
                }
            default:
                return .empty()
            }
        case .changeTheme(let option):
            return .fromAsync { [weak self] in
                guard let self else { throw DomainError.unknownError }

                let sectionModels = replacingThemeItem(with: option, in: currentState.sectionModel)
                print(sectionModels)
                return .setSectionModel(sectionModels)
            }
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setSectionModel(let model):
            newState.sectionModel = model
        case .setPhase(let phase):
            newState.phase = phase
        case .setRoute(let route):
            newState.route = route
        }
        return newState
    }
}

private extension MyPageReactor {
    func makeSectionModels(isLogin: Bool) async throws -> [MyPageSectionModel] {
        async let specificSections = isLogin
            ? makeUserSpecificSections()
            : makeGuestSpecificSections()

        async let sharedSections = makeSharedSections()
        let etcSection = makeEtcSection(isLogin: isLogin)

        return try await specificSections + sharedSections + etcSection
    }

    func makeUserSpecificSections() async throws -> [MyPageSectionModel] {
        let nickName = "김담담"

        return [
            .init(section: .login("\(nickName) 님 환영합니다."), items: []),
            .init(
                section: .profile,
                items: [
                    .sectionTitle(MyPageSection.profile.title),
                    .chevron(.nicknameEdit)
                ]
            )
        ]
    }

    func makeGuestSpecificSections() -> [MyPageSectionModel] {
        [
            .init(
                section: .login("로그인"),
                items: [
                    .login(.apple),
                    .login(.google)
                ]
            )
        ]
    }

    func makeSharedSections() async throws -> [MyPageSectionModel] {
        async let theme = fetchThemeUseCase.execute().get()
        async let folderSort = fetchFolderSortUseCase.execute().get()
        async let clipSort = fetchClipSortUseCase.execute().get()
        async let savePathLayout = fetchSavePathLayoutUseCase.execute().get()

        return try await [
            .init(
                section: .systemSettings,
                items: [
                    .sectionTitle(MyPageSection.systemSettings.title),
                    .detail(.theme(theme)),
                    .dropdown(.folderSort(folderSort)),
                    .dropdown(.clipSort(clipSort)),
                    .detail(.savePath(savePathLayout))
                ]
            ),
            .init(section: .notificationSettings, items: [.chevron(.notificationSetting)]),
            .init(section: .trash, items: [.chevron(.trash)]),
            .init(section: .support, items: [.chevron(.support)])
        ]
    }

    func makeEtcSection(isLogin: Bool) -> [MyPageSectionModel] {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        let items: [MyPageItem] = isLogin
            ? [.account(.logout), .account(.withdraw), .version(appVersion)]
            : [.version(appVersion)]

        return [.init(section: .etc, items: items)]
    }
}

private extension MyPageReactor {
    func makeChevronItemMutation(item: ChevronItem) -> Mutation {
        switch item {
        case .nicknameEdit:
            return .setRoute(.showEditNickName)
        case .notificationSetting:
            return .setRoute(.showNotificationSetting)
        case .trash:
            return .setRoute(.showTrash)
        case .support:
            return .setRoute(.showSupport)
        }
    }

    func makeDetailItemMutation(item: DetailItem) -> Mutation {
        switch item {
        case .theme(let option):
            return .setRoute(
                .showSelectTheme(
                currentOption: option,
                availableOptions: ThemeOption.allCases
                )
            )
        case .savePath(let option):
            return .setRoute(
                .showSelectSavePathLayout(
                currentOption: option,
                availableOptions: SavePathOption.allCases
                )
            )
        }
    }

    func makeDropdownItemMutation(item: DropdownItem) -> Mutation {
        switch item {
        case .folderSort(let option):
            return .setRoute(.showSelectFolderSort(
                currentOption: option,
                availableOptions: FolderSortOption.allCases
            ))
        case .clipSort(let option):
            return .setRoute(.showSelectClipSort(
                currentOption: option,
                availableOptions: ClipSortOption.allCases
            ))
        }
    }

    func makeAccountItemMutation(item: AccountItem) async throws -> Mutation {
        switch item {
        case .logout:
            _ = try await logoutUseCase.execute().get()
            let sectionModetls = try await makeSectionModels(isLogin: false)
            return .setSectionModel(sectionModetls)
        case .withdraw:
            _ = try await withdrawUseCase.execute().get()
            let sectionModetls = try await makeSectionModels(isLogin: false)
            return .setSectionModel(sectionModetls)
        }
    }
}

private extension MyPageReactor {
    func replacingThemeItem(
        with newOption: ThemeOption,
        in models: [MyPageSectionModel]
    ) -> [MyPageSectionModel] {
        models.map { section in
            if let index = section.items.firstIndex(where: {
                if case .detail(.theme) = $0 {
                    return true
                }
                return false
            }) {
                var newItems = section.items
                newItems[index] = .detail(.theme(newOption))
                return MyPageSectionModel(section: section.section, items: newItems)
            } else {
                return section
            }
        }
    }
}
