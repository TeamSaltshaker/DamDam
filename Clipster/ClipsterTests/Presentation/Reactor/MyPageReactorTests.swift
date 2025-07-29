import XCTest
import RxSwift
@testable import Clipster

final class MyPageReactorTests: XCTestCase {
    typealias Phase = MyPageReactor.State.Phase
    typealias Route = MyPageReactor.State.Route

    private var disposeBag: DisposeBag!

    private var checkLoginStatusUseCase: MockCheckLoginStatusUseCase!
    private var loginUseCase: MockLoginUseCase!
    private var fetchCurrentUserUseCase: MockFetchCurrentUserUseCase!
    private var fetchThemeOptionUseCase: MockFetchThemeOptionUseCase!
    private var fetchFolderSortOptionUseCase: MockFetchFolderSortOptionUseCase!
    private var fetchClipSortOptionUseCase: MockFetchClipSortOptionUseCase!
    private var fetchSavePathLayoutOptionUseCase: MockFetchSavePathLayoutOptionUseCase!
    private var logoutUseCase: MockLogoutUseCase!
    private var withdrawUseCase: MockWithdrawUseCase!
    private var saveThemeOptionUseCase: MockSaveThemeOptionUseCase!
    private var saveSavePathLayoutOptionUseCase: MockSaveSavePathLayoutOptionUseCase!
    private var saveFolderSortOptionUseCase: MockSaveFolderSortOptionUseCase!
    private var saveClipSortOptionUseCase: MockSaveClipSortOptionUseCase!
    private var updateNicknameUseCase: MockUpdateNicknameUseCase!

    private var reactor: MyPageReactor!

    private var userSectionModels: [MyPageSectionModel] {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"

        return [
            .init(section: .welcome(MockUser.someUser.nickname), items: []),
            .init(
                section: .profile,
                items: [
                    .sectionTitle(MyPageSection.profile.title),
                    .chevron(.nicknameEdit)
                ]
            ),
            .init(
                section: .systemSettings,
                items: [
                    .sectionTitle(MyPageSection.systemSettings.title),
                    .detail(.theme(self.fetchThemeOptionUseCase.option)),
                    .dropdown(.folderSort(self.fetchFolderSortOptionUseCase.option)),
                    .dropdown(.clipSort(self.fetchClipSortOptionUseCase.option)),
                    .detail(.savePath(self.fetchSavePathLayoutOptionUseCase.option))
                ]
            ),
            .init(section: .support, items: [.chevron(.support)]),
            .init(
                section: .etc,
                items: [
                    .account(.logout),
                    .account(.withdraw),
                    .version(appVersion)
                ]
            )
        ]
    }

    private var guestSectionModels: [MyPageSectionModel] {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"

        return [
            .init(
                section: .systemSettings,
                items: [
                    .sectionTitle(MyPageSection.systemSettings.title),
                    .detail(.theme(self.fetchThemeOptionUseCase.option)),
                    .dropdown(.folderSort(self.fetchFolderSortOptionUseCase.option)),
                    .dropdown(.clipSort(self.fetchClipSortOptionUseCase.option)),
                    .detail(.savePath(self.fetchSavePathLayoutOptionUseCase.option))
                ]
            ),
            .init(section: .support, items: [.chevron(.support)]),
            .init(section: .etc, items: [.version(appVersion)])
        ]
    }

    override func setUp() {
        disposeBag = DisposeBag()

        checkLoginStatusUseCase = MockCheckLoginStatusUseCase()
        loginUseCase = MockLoginUseCase()
        fetchCurrentUserUseCase = MockFetchCurrentUserUseCase()
        fetchThemeOptionUseCase = MockFetchThemeOptionUseCase()
        fetchFolderSortOptionUseCase = MockFetchFolderSortOptionUseCase()
        fetchClipSortOptionUseCase = MockFetchClipSortOptionUseCase()
        fetchSavePathLayoutOptionUseCase = MockFetchSavePathLayoutOptionUseCase()
        logoutUseCase = MockLogoutUseCase()
        withdrawUseCase = MockWithdrawUseCase()
        saveThemeOptionUseCase = MockSaveThemeOptionUseCase()
        saveSavePathLayoutOptionUseCase = MockSaveSavePathLayoutOptionUseCase()
        saveFolderSortOptionUseCase = MockSaveFolderSortOptionUseCase()
        saveClipSortOptionUseCase = MockSaveClipSortOptionUseCase()
        updateNicknameUseCase = MockUpdateNicknameUseCase()

        reactor = MyPageReactor(
            checkLoginStatusUseCase: checkLoginStatusUseCase,
            loginUseCase: loginUseCase,
            fetchCurrentUserUseCase: fetchCurrentUserUseCase,
            fetchThemeOptionUseCase: fetchThemeOptionUseCase,
            fetchFolderSortOptionUseCase: fetchFolderSortOptionUseCase,
            fetchClipSortOptionUseCase: fetchClipSortOptionUseCase,
            fetchSavePathLayoutOptionUseCase: fetchSavePathLayoutOptionUseCase,
            logoutUseCase: logoutUseCase,
            withdrawUseCase: withdrawUseCase,
            saveThemeOptionUseCase: saveThemeOptionUseCase,
            saveSavePathLayoutOptionUseCase: saveSavePathLayoutOptionUseCase,
            saveFolderSortOptionUseCase: saveFolderSortOptionUseCase,
            saveClipSortOptionUseCase: saveClipSortOptionUseCase,
            updateNicknameUseCase: updateNicknameUseCase
        )
    }

    override func tearDown() {
        disposeBag = nil
        checkLoginStatusUseCase = nil
        loginUseCase = nil
        fetchCurrentUserUseCase = nil
        fetchThemeOptionUseCase = nil
        fetchFolderSortOptionUseCase = nil
        fetchClipSortOptionUseCase = nil
        fetchSavePathLayoutOptionUseCase = nil
        logoutUseCase = nil
        withdrawUseCase = nil
        saveThemeOptionUseCase = nil
        saveSavePathLayoutOptionUseCase = nil
        saveFolderSortOptionUseCase = nil
        saveClipSortOptionUseCase = nil
        updateNicknameUseCase = nil
        reactor = nil
    }

    func test_viewWillAppear() {
        // given
        let expectation = expectation(description: #function)
        var phaseResults: [Phase] = []

        reactor.pulse(\.$phase)
            .skip(1)
            .subscribe { phase in
                phaseResults.append(phase)
                if phase == .success {
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        // when
        reactor.action.onNext(.viewWillAppear)

        // then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(phaseResults, [.loading, .success])

        XCTAssertTrue(fetchThemeOptionUseCase.didCallExecute)
        XCTAssertTrue(fetchFolderSortOptionUseCase.didCallExecute)
        XCTAssertTrue(fetchClipSortOptionUseCase.didCallExecute)
        XCTAssertTrue(fetchSavePathLayoutOptionUseCase.didCallExecute)

        XCTAssertEqual(reactor.currentState.sectionModel, guestSectionModels)
    }

    func test_로그인_탭() {
        // given
        let expectation = expectation(description: #function)
        var phaseResults: [Phase] = []

        reactor.pulse(\.$phase)
            .skip(1)
            .subscribe { phase in
                phaseResults.append(phase)
                if phase == .success {
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        // when
        reactor.action.onNext(.tapCell(.login(.apple)))

        // then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(phaseResults, [.loading, .success])

        XCTAssertTrue(loginUseCase.didCallExecute)
        XCTAssertTrue(fetchThemeOptionUseCase.didCallExecute)
        XCTAssertTrue(fetchFolderSortOptionUseCase.didCallExecute)
        XCTAssertTrue(fetchClipSortOptionUseCase.didCallExecute)
        XCTAssertTrue(fetchSavePathLayoutOptionUseCase.didCallExecute)

        XCTAssertEqual(reactor.currentState.sectionModel, userSectionModels)
    }

    func test_닉네임_변경_탭() {
        // given
        reactor.action.onNext(.tapCell(.login(.apple)))

        let expectation = expectation(description: #function)
        var routeResult: Route?

        reactor.pulse(\.$route)
            .compactMap { $0 }
            .subscribe { route in
                routeResult = route
                expectation.fulfill()
            }
            .disposed(by: disposeBag)

        // when
        reactor.action.onNext(.tapCell(.chevron(.nicknameEdit)))

        // then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(routeResult, .showEditNickName(MockUser.someUser.nickname))
    }

    func test_알림설정__탭() {
        // given
        let expectation = expectation(description: #function)
        var routeResult: Route?

        reactor.pulse(\.$route)
            .compactMap { $0 }
            .subscribe { route in
                routeResult = route
                expectation.fulfill()
            }
            .disposed(by: disposeBag)

        // when
        reactor.action.onNext(.tapCell(.chevron(.notificationSetting)))

        // then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(routeResult, .showNotificationSetting)
    }

    func test_휴지통__탭() {
        // given
        let expectation = expectation(description: #function)
        var routeResult: Route?

        reactor.pulse(\.$route)
            .compactMap { $0 }
            .subscribe { route in
                routeResult = route
                expectation.fulfill()
            }
            .disposed(by: disposeBag)

        // when
        reactor.action.onNext(.tapCell(.chevron(.trash)))

        // then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(routeResult, .showTrash)
    }

    func test_문의하기__탭() {
        // given
        let expectation = expectation(description: #function)
        var routeResult: Route?

        reactor.pulse(\.$route)
            .compactMap { $0 }
            .subscribe { route in
                routeResult = route
                expectation.fulfill()
            }
            .disposed(by: disposeBag)

        // when
        reactor.action.onNext(.tapCell(.chevron(.support)))

        // then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(routeResult, .showSupport)
    }

    func test_테마_탭() {
        // given
        let expectation = expectation(description: #function)
        var routeResult: Route?

        reactor.pulse(\.$route)
            .compactMap { $0 }
            .subscribe { route in
                routeResult = route
                expectation.fulfill()
            }
            .disposed(by: disposeBag)

        // when
        reactor.action.onNext(.tapCell(.detail(.theme(.dark))))

        // then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(
            routeResult,
            .showSelectTheme(
                currentOption: .dark,
                availableOptions: ThemeOption.allCases
            )
        )
    }

    func test_저장_경로_보기_탭() {
        // given
        let expectation = expectation(description: #function)
        var routeResult: Route?

        reactor.pulse(\.$route)
            .compactMap { $0 }
            .subscribe { route in
                routeResult = route
                expectation.fulfill()
            }
            .disposed(by: disposeBag)

        // when
        reactor.action.onNext(.tapCell(.detail(.savePath(.expand))))

        // then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(
            routeResult,
            .showSelectSavePathLayout(
                currentOption: .expand,
                availableOptions: SavePathOption.allCases
            )
        )
    }

    func test_폴더_정렬_순서_탭() {
        // given
        let expectation = expectation(description: #function)
        var routeResult: Route?

        reactor.pulse(\.$route)
            .compactMap { $0 }
            .subscribe { route in
                routeResult = route
                expectation.fulfill()
            }
            .disposed(by: disposeBag)

        // when
        reactor.action.onNext(.tapCell(.dropdown(.folderSort(.createdAt(.ascending)))))

        // then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(
            routeResult,
            .showSelectFolderSort(
                currentOption: .createdAt(.ascending),
                availableOptions: FolderSortOption.allCases
            )
        )
    }

    func test_클립_정렬_순서_탭() {
        // given
        let expectation = expectation(description: #function)
        var routeResult: Route?

        reactor.pulse(\.$route)
            .compactMap { $0 }
            .subscribe { route in
                routeResult = route
                expectation.fulfill()
            }
            .disposed(by: disposeBag)

        // when
        reactor.action.onNext(.tapCell(.dropdown(.clipSort(.createdAt(.ascending)))))

        // then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(
            routeResult,
            .showSelectClipSort(
                currentOption: .createdAt(.ascending),
                availableOptions: ClipSortOption.allCases
            )
        )
    }

    func test_로그아웃_탭() {
        // given
        let expectation = expectation(description: #function)
        var phaseResults: [Phase] = []

        reactor.pulse(\.$phase)
            .skip(1)
            .subscribe { phase in
                phaseResults.append(phase)
                if phase == .success {
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        // when
        reactor.action.onNext(.tapCell(.account(.logout)))

        // then
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(phaseResults, [.loading, .success])
        XCTAssertTrue(logoutUseCase.didCallExecute)
        XCTAssertEqual(reactor.currentState.sectionModel, guestSectionModels)
    }

    func test_회원탈퇴_탭() {
        // given
        let expectation = expectation(description: #function)
        var phaseResults: [Phase] = []

        reactor.pulse(\.$phase)
            .skip(1)
            .subscribe { phase in
                phaseResults.append(phase)
                if phase == .success {
                    expectation.fulfill()
                }
            }
            .disposed(by: disposeBag)

        // when
        reactor.action.onNext(.tapCell(.account(.withdraw)))

        // then
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(phaseResults, [.loading, .success])
        XCTAssertTrue(withdrawUseCase.didCallExecute)
        XCTAssertEqual(reactor.currentState.sectionModel, guestSectionModels)
    }
}

extension MyPageSectionModel: @retroactive Equatable {
    public static func == (lhs: MyPageSectionModel, rhs: MyPageSectionModel) -> Bool {
        return lhs.section == rhs.section && lhs.items == rhs.items
    }
}

extension MyPageReactor.State.Phase: @retroactive Equatable {
    public static func == (
        lhs: MyPageReactor.State.Phase,
        rhs: MyPageReactor.State.Phase
    ) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.success, .success), (.error, .error):
            return true
        default:
            return false
        }
    }
}

extension MyPageReactor.State.Route: @retroactive Equatable {
    public static func == (
        lhs: MyPageReactor.State.Route,
        rhs: MyPageReactor.State.Route
    ) -> Bool {
        switch (lhs, rhs) {
        case (.showEditNickName(let a), .showEditNickName(let b)):
            return a == b
        case let (
            .showSelectTheme(currentOptionA, availableOptionsA),
            .showSelectTheme(currentOptionB, availableOptionsB)
        ):
            return currentOptionA == currentOptionB && availableOptionsA == availableOptionsB
        case let (
            .showSelectFolderSort(currentOptionA, availableOptionsA),
            .showSelectFolderSort(currentOptionB, availableOptionsB)
        ):
            return currentOptionA == currentOptionB && availableOptionsA == availableOptionsB
        case let (
            .showSelectClipSort(currentOptionA, availableOptionsA),
            .showSelectClipSort(currentOptionB, availableOptionsB)
        ):
            return currentOptionA == currentOptionB && availableOptionsA == availableOptionsB
        case let (
            .showSelectSavePathLayout(currentOptionA, availableOptionsA),
            .showSelectSavePathLayout(currentOptionB, availableOptionsB)
        ):
            return currentOptionA == currentOptionB && availableOptionsA == availableOptionsB
        case (.showNotificationSetting, .showNotificationSetting),
             (.showTrash, .showTrash),
             (.showSupport, .showSupport):
            return true
        default:
            return false
        }
    }
}
