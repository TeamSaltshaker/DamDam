import Foundation
import ReactorKit

final class MyPageReactor: Reactor {
    enum Action {
        case viewWillAppear
        case tapCell(MyPageItem)
        case changeTheme(ThemeOption)
        case changeSavePathLayout(SavePathOption)
        case changeFolderSort(FolderSortOption)
        case changeClipSort(ClipSortOption)
        case changeNickName(String)
    }

    enum Mutation {
        case setAllPreferences(
            isLogin: Bool,
            nickname: String,
            theme: ThemeOption,
            folderSort: FolderSortOption,
            clipSort: ClipSortOption,
            savePath: SavePathOption
        )
        case setLogin(Bool)
        case setNickname(String)
        case setThemeOption(ThemeOption)
        case setFolderSortOption(FolderSortOption)
        case setClipSortOption(ClipSortOption)
        case setSavePathOption(SavePathOption)
        case setIsScrollToTop(Bool)
        case setPhase(State.Phase)
        case setRoute(State.Route?)
    }

    struct State {
        var isLogin: Bool = false
        var nickname: String = ""
        var themeOption: ThemeOption = .system
        var folderSortOption: FolderSortOption = .createdAt(.descending)
        var clipSortOption: ClipSortOption = .createdAt(.ascending)
        var savePathOption: SavePathOption = .expand

        @Pulse var isScrollToTop: Bool = false
        @Pulse var phase: Phase = .idle
        @Pulse var route: Route?

        var sectionModels: [MyPageSectionModel] {
            makeSectionModels(
                isLogin: isLogin,
                nickname: nickname,
                theme: themeOption,
                folderSort: folderSortOption,
                clipSort: clipSortOption,
                savePath: savePathOption
            )
        }

        enum Phase {
            case idle
            case loading
            case success
            case error(String)
        }

        enum Route {
            case showEditNickName(String)
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

    private let checkLoginStatusUseCase: CheckLoginStatusUseCase
    private let loginUseCase: LoginUseCase
    private let fetchCurrentUserUseCase: FetchCurrentUserUseCase
    private let fetchThemeOptionUseCase: FetchThemeOptionUseCase
    private let fetchFolderSortOptionUseCase: FetchFolderSortOptionUseCase
    private let fetchClipSortOptionUseCase: FetchClipSortOptionUseCase
    private let fetchSavePathLayoutOptionUseCase: FetchSavePathLayoutOptionUseCase
    private let logoutUseCase: LogoutUseCase
    private let withdrawUseCase: WithdrawUseCase
    private let saveThemeOptionUseCase: SaveThemeOptionUseCase
    private let saveSavePathLayoutOptionUseCase: SaveSavePathLayoutOptionUseCase
    private let saveFolderSortOptionUseCase: SaveFolderSortOptionUseCase
    private let saveClipSortOptionUseCase: SaveClipSortOptionUseCase
    private let updateNicknameUseCase: UpdateNicknameUseCase

    init(
        checkLoginStatusUseCase: CheckLoginStatusUseCase,
        loginUseCase: LoginUseCase,
        fetchCurrentUserUseCase: FetchCurrentUserUseCase,
        fetchThemeOptionUseCase: FetchThemeOptionUseCase,
        fetchFolderSortOptionUseCase: FetchFolderSortOptionUseCase,
        fetchClipSortOptionUseCase: FetchClipSortOptionUseCase,
        fetchSavePathLayoutOptionUseCase: FetchSavePathLayoutOptionUseCase,
        logoutUseCase: LogoutUseCase,
        withdrawUseCase: WithdrawUseCase,
        saveThemeOptionUseCase: SaveThemeOptionUseCase,
        saveSavePathLayoutOptionUseCase: SaveSavePathLayoutOptionUseCase,
        saveFolderSortOptionUseCase: SaveFolderSortOptionUseCase,
        saveClipSortOptionUseCase: SaveClipSortOptionUseCase,
        updateNicknameUseCase: UpdateNicknameUseCase
    ) {
        self.checkLoginStatusUseCase = checkLoginStatusUseCase
        self.loginUseCase = loginUseCase
        self.fetchCurrentUserUseCase = fetchCurrentUserUseCase
        self.fetchThemeOptionUseCase = fetchThemeOptionUseCase
        self.fetchFolderSortOptionUseCase = fetchFolderSortOptionUseCase
        self.fetchClipSortOptionUseCase = fetchClipSortOptionUseCase
        self.fetchSavePathLayoutOptionUseCase = fetchSavePathLayoutOptionUseCase
        self.logoutUseCase = logoutUseCase
        self.withdrawUseCase = withdrawUseCase
        self.saveThemeOptionUseCase = saveThemeOptionUseCase
        self.saveSavePathLayoutOptionUseCase = saveSavePathLayoutOptionUseCase
        self.saveFolderSortOptionUseCase = saveFolderSortOptionUseCase
        self.saveClipSortOptionUseCase = saveClipSortOptionUseCase
        self.updateNicknameUseCase = updateNicknameUseCase
    }

    func mutate(action: Action) -> Observable<Mutation> {
        print("\(Self.self): received action → \(action)")

        switch action {
        case .viewWillAppear:
            return .concat(
                .just(.setPhase(.loading)),
                .fromAsync { [weak self] in
                    guard let self else { throw DomainError.unknownError }
                    return try await makeAllPreferencesMutation()
                },
                .just(.setPhase(.success))
            )
            .catch {
                .just(.setPhase(.error($0.localizedDescription)))
            }
        case .tapCell(let item):
            switch item {
            case .login(let type):
                return .concat(
                    .just(.setPhase(.loading)),
                    .fromAsync { [weak self] in
                        guard let self else { throw DomainError.unknownError }
                        _ = try await loginUseCase.execute(type: type).get()
                        return try await makeAllPreferencesMutation()
                    }
                )
                .catch {
                    .just(.setPhase(.error($0.localizedDescription)))
                }
            case .account(let accountItem):
                return .concat(
                    .just(.setPhase(.loading)),
                    .fromAsync { [weak self] in
                        guard let self else { throw DomainError.unknownError }
                        switch accountItem {
                        case .logout:
                            _ = try await logoutUseCase.execute().get()
                        case .withdraw:
                            _ = try await withdrawUseCase.execute().get()
                        }
                        return try await makeAllPreferencesMutation()
                    },
                    .just(.setIsScrollToTop(true)),
                    .just(.setPhase(.success))
                )
                .catch {
                    .just(.setPhase(.error($0.localizedDescription)))
                }
            case .chevron, .detail, .dropdown:
                return .just(makeRouteMutation(for: item))
            default:
                return .empty()
            }
        case .changeTheme(let option):
            return .fromAsync { [weak self] in
                guard let self else { throw DomainError.unknownError }
                _ = try await saveThemeOptionUseCase.execute(option).get()
                return .setThemeOption(option)
            }
            .catch {
                .just(.setPhase(.error($0.localizedDescription)))
            }
        case .changeSavePathLayout(let option):
            return .fromAsync { [weak self] in
                guard let self else { throw DomainError.unknownError }
                _ = try await saveSavePathLayoutOptionUseCase.execute(option).get()
                return .setSavePathOption(option)
            }
            .catch {
                .just(.setPhase(.error($0.localizedDescription)))
            }
        case .changeFolderSort(let option):
            return .fromAsync { [weak self] in
                guard let self else { throw DomainError.unknownError }
                _ = try await saveFolderSortOptionUseCase.execute(option).get()
                return .setFolderSortOption(option)
            }
            .catch {
                .just(.setPhase(.error($0.localizedDescription)))
            }
        case .changeClipSort(let option):
            return .fromAsync { [weak self] in
                guard let self else { throw DomainError.unknownError }
                _ = try await saveClipSortOptionUseCase.execute(option).get()
                return .setClipSortOption(option)
            }
            .catch {
                .just(.setPhase(.error($0.localizedDescription)))
            }
        case .changeNickName(let nickname):
            return .fromAsync { [weak self] in
                guard let self else { throw DomainError.unknownError }
                _ = try await updateNicknameUseCase.execute(nickname: nickname).get()
                return .setNickname(nickname)
            }
            .catch {
                .just(.setPhase(.error($0.localizedDescription)))
            }
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setAllPreferences(isLogin, nickname, theme, folderSort, clipSort, savePath):
            newState.isLogin = isLogin
            newState.nickname = nickname
            newState.themeOption = theme
            newState.folderSortOption = folderSort
            newState.clipSortOption = clipSort
            newState.savePathOption = savePath
        case .setLogin(let value):
            newState.isLogin = value
        case .setNickname(let value):
            newState.nickname = value
        case .setThemeOption(let value):
            newState.themeOption = value
        case .setFolderSortOption(let value):
            newState.folderSortOption = value
        case .setClipSortOption(let value):
            newState.clipSortOption = value
        case .setSavePathOption(let value):
            newState.savePathOption = value
        case .setIsScrollToTop(let value):
            newState.isScrollToTop = value
        case .setPhase(let value):
            newState.phase = value
        case .setRoute(let route):
            newState.route = route
        }
        return newState
    }
}

private extension MyPageReactor {
    func makeAllPreferencesMutation() async throws -> Mutation {
        let isLogin = false
        async let themeOption = fetchThemeOptionUseCase.execute().get()
        async let folderSortOption = fetchFolderSortOptionUseCase.execute().get()
        async let clipSortOption = fetchClipSortOptionUseCase.execute().get()
        async let savePathOption = fetchSavePathLayoutOptionUseCase.execute().get()

        async let nickname = isLogin ?
        fetchCurrentUserUseCase.execute().get().nickname
        : ""

        return try await .setAllPreferences(
            isLogin: isLogin,
            nickname: nickname,
            theme: themeOption,
            folderSort: folderSortOption,
            clipSort: clipSortOption,
            savePath: savePathOption
        )
    }

    func makeRouteMutation(for item: MyPageItem) -> Mutation {
        switch item {
        case .chevron(let chevron):
            switch chevron {
            case .nicknameEdit:
                return .setRoute(.showEditNickName(currentState.nickname))
            case .support:
                return .setRoute(.showSupport)
            case .notificationSetting:
                return .setRoute(.showNotificationSetting)
            case .trash:
                return .setRoute(.showTrash)
            }
        case .detail(let detail):
            switch detail {
            case .theme(let option):
                return .setRoute(.showSelectTheme(
                    currentOption: option,
                    availableOptions: ThemeOption.allCases
                ))
            case .savePath(let option):
                return .setRoute(.showSelectSavePathLayout(
                    currentOption: option,
                    availableOptions: SavePathOption.allCases
                ))
            }
        case .dropdown(let dropdown):
            switch dropdown {
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
        default:
            return .setRoute(nil)
        }
    }
}

private extension MyPageReactor.State {
    func makeSectionModels(
        isLogin: Bool,
        nickname: String,
        theme: ThemeOption,
        folderSort: FolderSortOption,
        clipSort: ClipSortOption,
        savePath: SavePathOption
    ) -> [MyPageSectionModel] {
        let userSection = isLogin
        ? makeUserSpecificSections(nickname: nickname)
        : []

        let sharedSections = makeSharedSections(
            theme: theme,
            folderSort: folderSort,
            clipSort: clipSort,
            savePathLayout: savePath
        )

        let etcSection = makeEtcSection(isLogin: isLogin)

        return userSection + sharedSections + etcSection
    }

    func makeUserSpecificSections(nickname: String) -> [MyPageSectionModel] {
        [
            .init(section: .welcome(nickname), items: []),
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
                section: .login,
                items: [
                    .login(.apple),
                    .login(.google)
                ]
            )
        ]
    }

    func makeSharedSections(
        theme: ThemeOption,
        folderSort: FolderSortOption,
        clipSort: ClipSortOption,
        savePathLayout: SavePathOption
    ) -> [MyPageSectionModel] {
        [
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
            .init(section: .support, items: [.chevron(.support)])
        ]
    }

    func makeEtcSection(isLogin: Bool) -> [MyPageSectionModel] {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "알 수 없음"
        var items: [MyPageItem] = [.version(version)]
        if isLogin {
            items.insert(.account(.logout), at: 0)
            items.insert(.account(.withdraw), at: 1)
        }
        return [.init(section: .etc, items: items)]
    }
}
