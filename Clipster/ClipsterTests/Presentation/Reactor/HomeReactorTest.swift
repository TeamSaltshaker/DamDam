import XCTest
import RxSwift
@testable import Clipster

final class HomeReactorTests: XCTestCase {
    private var disposeBag: DisposeBag!

    private var deleteClipUseCase: MockDeleteClipUseCase!
    private var deleteFolderUseCase: MockDeleteFolderUseCase!
    private var visitClipUseCase: MockVisitClipUseCase!

    private var reactor: HomeReactor!

    private let clipIndexPath = IndexPath(item: 0, section: 0)
    private let folderIndexPath = IndexPath(item: 0, section: 1)

    override func setUpWithError() throws {
        disposeBag = DisposeBag()
        deleteClipUseCase = MockDeleteClipUseCase()
        deleteFolderUseCase = MockDeleteFolderUseCase()
        visitClipUseCase = MockVisitClipUseCase()
        reactor = HomeReactor(
            fetchUnvisitedClipsUseCase: MockFetchUnvisitedClipsUseCase(),
            fetchTopLevelFoldersUseCase: MockFetchTopLevelFoldersUseCase(),
            deleteClipUseCase: deleteClipUseCase,
            deleteFolderUseCase: deleteFolderUseCase,
            visitClipUseCase: visitClipUseCase
        )
    }

    override func tearDownWithError() throws {
        disposeBag = nil
        deleteClipUseCase = nil
        deleteFolderUseCase = nil
        visitClipUseCase = nil
        reactor = nil
    }

    func test_홈_화면_나타날_때_홈_데이터_로드() {
        // given
        var phaseHistory: [HomeReactor.State.Phase] = []

        reactor.pulse(\.$phase)
            .skip(1)
            .subscribe(onNext: { phase in
                phaseHistory.append(phase)
            })
            .disposed(by: disposeBag)

        // when
        waitUntilHomeDataLoaded()

        // then
        assertPhaseStartAndEnd(phaseHistory)
        XCTAssertEqual(
            reactor.currentState.homeDisplay?.unvisitedClips.count,
            MockClip.unvisitedClips.count
        )
        XCTAssertEqual(
            reactor.currentState.homeDisplay?.folders.count,
            MockFolder.rootFolders.count
        )
    }

    func test_클립_추가_탭_시_클립_추가_화면으로_이동() {
        // given
        waitUntilHomeDataLoaded()

        // when
        reactor.action.onNext(.tapAddClip)

        // then
        guard let route = reactor.currentState.route,
              case let .showAddClip(folder) = route else {
            return XCTFail("tapAddClip → showAddClip 화면 이동 실패")
        }
        XCTAssertEqual(folder?.id, MockFolder.rootFolders[0].id)
    }

    func test_폴더_추가_탭_시_폴더_추가_화면으로_이동() {
        // when
        reactor.action.onNext(.tapAddFolder)

        // then
        guard let route = reactor.currentState.route,
              case .showAddFolder = route else {
            return XCTFail("tapAddFolder → showAddFolder 화면 이동 실패")
        }
    }

    func test_클립_셀_탭_시_웹뷰로_이동_및_방문_처리_호출() {
        // given
        var routedURL: URL?

        waitUntilHomeDataLoaded()

        let routeExpectation = expectation(description: "웹뷰 화면 이동 감지")
        reactor.pulse(\.$route)
            .compactMap { route -> URL? in
                guard case let .showWebView(url) = route else { return nil }
                return url
            }
            .take(1)
            .subscribe(onNext: { url in
                routedURL = url
                routeExpectation.fulfill()
            })
            .disposed(by: disposeBag)

        // when
        let indexPath = IndexPath(item: 0, section: 0)
        reactor.action.onNext(.tapCell(indexPath))

        // then
        wait(for: [routeExpectation], timeout: 1.0)
        XCTAssertEqual(routedURL, MockClip.unvisitedClips[0].urlMetadata.url)
        XCTAssertTrue(visitClipUseCase.didCallExecute, "클립 방문 처리 유스케이스가 호출되어야 합니다.")
    }

    func test_클립_상세_탭_시_클립_상세_화면으로_이동() {
        // given
        waitUntilHomeDataLoaded()

        // when
        let indexPath = IndexPath(item: 0, section: 0)
        reactor.action.onNext(.tapDetail(indexPath))

        // then
        guard let route = reactor.currentState.route,
              case let .showDetailClip(clip) = route else {
            return XCTFail("tapDetail → showDetailClip 화면 이동 실패")
        }
        XCTAssertEqual(clip.id, MockClip.unvisitedClips[0].id)
    }

    func test_클립_수정_탭_시_클립_수정_화면으로_이동() {
        // given
        waitUntilHomeDataLoaded()

        // when
        let indexPath = IndexPath(item: 0, section: 0)
        reactor.action.onNext(.tapEdit(indexPath))

        // then
        guard let route = reactor.currentState.route,
              case let .showEditClip(clip) = route else {
            return XCTFail("tapEdit → showEditClip 화면 이동 실패")
        }
        XCTAssertEqual(clip.id, MockClip.unvisitedClips[0].id)
    }

    func test_클립_삭제_성공시_phase_변경되고_유스케이스_호출됨() {
        // given
        waitUntilHomeDataLoaded()

        let deleteExpectation = expectation(description: "클립 삭제 완료")
        var phaseHistory: [HomeReactor.State.Phase] = []

        reactor.pulse(\.$phase)
            .skip(1)
            .subscribe(onNext: { phase in
                phaseHistory.append(phase)
                if case .success = phase {
                    deleteExpectation.fulfill()
                }
            })
            .disposed(by: disposeBag)

        // when
        let indexPath = IndexPath(item: 0, section: 0)
        reactor.action.onNext(.tapDelete(indexPath))

        // then
        wait(for: [deleteExpectation], timeout: 1.0)
        assertPhaseStartAndEnd(phaseHistory)
        XCTAssertTrue(deleteClipUseCase.didCallExecute)
        XCTAssertEqual(
            reactor.currentState.homeDisplay?.folders.count,
            MockFolder.rootFolders.count
        )
    }

    func test_폴더_셀_탭_시_폴더_화면으로_이동() {
        // given
        waitUntilHomeDataLoaded()

        let routeExpectation = expectation(description: "폴더 화면 이동 감지")
        var routedFolder: Folder?

        reactor.pulse(\.$route)
            .compactMap { route -> Folder? in
                guard case let .showFolder(folder) = route else { return nil }
                return folder
            }
            .take(1)
            .subscribe(onNext: { folder in
                routedFolder = folder
                routeExpectation.fulfill()
            })
            .disposed(by: disposeBag)

        // when
        let indexPath = IndexPath(item: 0, section: 1)
        reactor.action.onNext(.tapCell(indexPath))

        // then
        wait(for: [routeExpectation], timeout: 1.0)
        XCTAssertEqual(routedFolder?.id, MockFolder.rootFolders[0].id)
    }

    func test_폴더_수정_탭_시_폴더_수정_화면으로_이동() {
        // given
        waitUntilHomeDataLoaded()

        // when
        let indexPath = IndexPath(item: 0, section: 1)
        reactor.action.onNext(.tapEdit(indexPath))

        // then
        guard let route = reactor.currentState.route,
              case let .showEditFolder(folder) = route else {
            return XCTFail("tapEdit → showEditFolder 화면 이동 실패")
        }

        XCTAssertEqual(folder.id, MockFolder.rootFolders[0].id)
    }

    func test_폴더_삭제_성공시_phase_변경되고_유스케이스_호출됨() {
        // given
        waitUntilHomeDataLoaded()

        let deleteExpectation = expectation(description: "폴더 삭제 완료")
        var phaseHistory: [HomeReactor.State.Phase] = []

        reactor.pulse(\.$phase)
            .skip(1)
            .subscribe(onNext: { phase in
                phaseHistory.append(phase)
                if case .success = phase {
                    deleteExpectation.fulfill()
                }
            })
            .disposed(by: disposeBag)

        // when
        let indexPath = IndexPath(item: 0, section: 1)
        reactor.action.onNext(.tapDelete(indexPath))

        // then
        wait(for: [deleteExpectation], timeout: 1.0)
        assertPhaseStartAndEnd(phaseHistory)
        XCTAssertTrue(deleteFolderUseCase.didCallExecute)
        XCTAssertEqual(
            reactor.currentState.homeDisplay?.folders.count,
            MockFolder.rootFolders.count
        )
    }

    func test_모든_클립_보기를_누르면_클립_리스트로_이동() {
        // given
        waitUntilHomeDataLoaded()

        // when
        reactor.action.onNext(.tapShowAllClips)

        // then
        guard let route = reactor.currentState.route,
              case let .showUnvisitedClipList(clips) = route else {
            return XCTFail("tapShowAllClips → showUnvisitedClipList 화면 이동 실패")
        }

        XCTAssertEqual(clips.map { $0.id }, MockClip.unvisitedClips.map { $0.id })
    }
}

private extension HomeReactorTests {
    func waitUntilHomeDataLoaded() {
        let expectation = expectation(description: "홈 데이터 로딩 완료")
        reactor.pulse(\.$phase)
            .filter { if case .success = $0 { true } else { false } }
            .take(1)
            .subscribe(onNext: { _ in expectation.fulfill() })
            .disposed(by: disposeBag)
        reactor.action.onNext(.viewWillAppear)
        wait(for: [expectation], timeout: 1.0)
    }

    func assertPhaseStartAndEnd(_ history: [HomeReactor.State.Phase]) {
        XCTAssertTrue(
            history.first.map { if case .loading = $0 { true } else { false } } ?? false,
            "첫 번째 phase는 .loading이어야 합니다."
        )
        XCTAssertTrue(
            history.last.map { if case .success = $0 { true } else { false } } ?? false,
            "마지막 phase는 .success이어야 합니다."
        )
    }
}
