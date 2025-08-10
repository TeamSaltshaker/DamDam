import XCTest
@testable import Clipster

final class ParseURLUseCaseTests: XCTestCase {
    private var useCase: DefaultParseURLUseCase!

    override func setUp() {
        super.setUp()
        useCase = DefaultParseURLUseCase(
            urlMetaRepository: StubURLRepository(
                resolveRedirectURL: URL(string: "www.google.com")!,
                htmlResult: """
                <!DOCTYPE html>
                <html lang="en">
                <head>
                    <meta charset="UTF-8">
                    <meta property="og:title" content="담담 소개 페이지">
                    <meta property="og:description" content="링크와 이미지를 손쉽게 저장하고 관리하세요.">
                </head>
                </html>
                """,
                captureScreenshot: "image".data(using: .utf8)!
            )
        )
    }

    override func tearDown() {
        useCase = nil
        super.tearDown()
    }

    func test_ogTitle_파싱_성공() {
        let mockHTML = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta property="og:title" content="담담 소개 페이지">
            <meta property="og:description" content="링크와 이미지를 손쉽게 저장하고 관리하세요.">
        </head>
        </html>
        """
        let result = useCase.extractOGContent(html: mockHTML, property: "og:title")

        XCTAssertEqual(result, "담담 소개 페이지")
    }

    func test_ogDescription_파싱_성공() {
        let mockHTML = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta property="og:title" content="담담 소개 페이지">
            <meta property="og:description" content="링크와 이미지를 손쉽게 저장하고 관리하세요.">
        </head>
        </html>
        """
        let result = useCase.extractOGContent(html: mockHTML, property: "og:description")
        XCTAssertEqual(result, "링크와 이미지를 손쉽게 저장하고 관리하세요.")
    }

    func test_ogTitle_파싱_실패() {
        let result = useCase.extractOGContent(html: "", property: "og:title")
        XCTAssertNil(result)
    }

    func test_ogTitle_없을_때_HTML_title_파싱_성공() {
        let htmlWithoutOGTags = """
        <!DOCTYPE html>
        <html lang="ko">
        <head>
            <meta charset="UTF-8">
            <title>기본 제목 테스트</title>
            <meta name="description" content="이것은 메타 description입니다.">
        </head>
        </html>
        """
        let result = useCase.extractHTMLTagContent(html: htmlWithoutOGTags, property: "title")
        XCTAssertEqual(result, "기본 제목 테스트")
    }

    func test_ogDescription_없을_때_HTML_description_파싱_성공() {
        let htmlWithoutOGTags = """
        <!DOCTYPE html>
        <html lang="ko">
        <head>
            <meta charset="UTF-8">
            <title>기본 제목 테스트</title>
            <meta name="description" content="이것은 메타 description입니다.">
        </head>
        </html>
        """
        let result = useCase.extractOGContent(html: htmlWithoutOGTags, property: "description")
        XCTAssertEqual(result, "이것은 메타 description입니다.")
    }

    func test_일반적인_유튜브_링크일_때_videoID_추출_성공() {
        let url = URL(string: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")!
        let result = useCase.extractYouTubeVideoID(from: url)
        XCTAssertEqual(result, "dQw4w9WgXcQ")
    }

    func test_모바일_유튜브_링크일_때_videoID_추출_성공() {
        let url = URL(string: "https://m.youtube.com/watch?v=dQw4w9WgXcQ")!
        let result = useCase.extractYouTubeVideoID(from: url)
        XCTAssertEqual(result, "dQw4w9WgXcQ")
    }

    func test_공유된_유튜브_링크일_때_videoID_추출_성공() {
        let url = URL(string: "https://youtu.be/dQw4w9WgXcQ")!
        let result = useCase.extractYouTubeVideoID(from: url)
        XCTAssertEqual(result, "dQw4w9WgXcQ")
    }

    func test_유튜브_videoID가_없을_때_실패() {
        let url = URL(string: "https://www.youtube.com/watch")!
        let result = useCase.extractYouTubeVideoID(from: url)
        XCTAssertNil(result)
    }

    func test_유튜브_링크가_아닐_때_실패() {
        let url = URL(string: "https://www.naver.com")!
        let result = useCase.extractYouTubeVideoID(from: url)
        XCTAssertNil(result)
    }

    func test_유튜브_링크가_아닌_정상적인_URLMetadata가_반환될_때() {
        let html = """
                <html>
                <head>
                    <meta property="og:title" content="테스트 제목" />
                    <meta property="og:description" content="테스트 설명" />
                </head>
                </html>
            """
        let url = URL(string: "https://example.com")!
        let screenshotData = "image".data(using: .utf8)
        let result = useCase.createParsedURLMetadata(
            url: url,
            html: html,
            screenshotData: screenshotData
        )
        XCTAssertEqual(result.url, url)
        XCTAssertEqual(result.title, "테스트 제목")
        XCTAssertEqual(result.description, "테스트 설명")
        XCTAssertNil(result.thumbnailImageURL)
        XCTAssertEqual(result.screenshotData, screenshotData)
    }

    func test_유튜브_링크로_정상적인_URLMetadata가_반환될_때() {
        let html = """
              <html>
              <head>
                  <title>HTML 제목</title>
              </head>
              </html>
          """
        let url = URL(string: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")!

        let metadata = useCase.createParsedURLMetadata(url: url, html: html, screenshotData: nil)

        XCTAssertEqual(
            metadata.thumbnailImageURL?.absoluteString,
            "https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg"
        )
    }

    func test_title과_description을_파싱할_수_없을_때() {
        let html = """
                <html>
                <head>
                </head>
                </html>
            """
        let url = URL(string: "https://example.com")!
        let screenshotData = "image".data(using: .utf8)
        let result = useCase.createParsedURLMetadata(
            url: url,
            html: html,
            screenshotData: screenshotData
        )
        XCTAssertEqual(result.title, "제목 없음")
        XCTAssertEqual(result.description, "내용 없음")
    }

    func test_정상적인_파라미터_전달_시_URLMetadata_반환_성공() async {
        let mockHTML = """
                <meta property="og:title" content="테스트 제목" />
                <meta property="og:description" content="테스트 설명" />
            """
        let mockScreenshot = "image".data(using: .utf8)!
        let repo = StubURLRepository(
            resolveRedirectURL: URL(string: "https://resolved.com")!,
            htmlResult:  mockHTML,
            captureScreenshot: mockScreenshot
        )
        let useCase = DefaultParseURLUseCase(urlMetaRepository: repo)

        let result = await useCase.execute(url: URL(string: "https://resolved.com")!)

        switch result {
        case .success(let (metadata, isValid)):
            XCTAssertEqual(metadata?.title, "테스트 제목")
            XCTAssertEqual(metadata?.description, "테스트 설명")
            XCTAssertEqual(metadata?.screenshotData, mockScreenshot)
            XCTAssertNil(metadata?.thumbnailImageURL)
            XCTAssertEqual(isValid, true)
        case .failure(let error):
            XCTFail("execute 실패: \(error)")
        }
    }

    func test_유튜브_링크일_경우_URLMetadata에_썸네일_포함() async {
        let mockHTML = """
                <meta property="og:title" content="테스트 제목" />
                <meta property="og:description" content="테스트 설명" />
            """
        let mockScreenshot = "image".data(using: .utf8)!
        let repo = StubURLRepository(
            resolveRedirectURL: URL(string: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")!,
            htmlResult:  mockHTML,
            captureScreenshot: mockScreenshot
        )
        let useCase = DefaultParseURLUseCase(urlMetaRepository: repo)

        let result = await useCase.execute(url: URL(string: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")!)

        switch result {
        case .success(let (metadata, isValid)):
            XCTAssertEqual(metadata?.title, "테스트 제목")
            XCTAssertEqual(metadata?.description, "테스트 설명")
            XCTAssertEqual(metadata?.screenshotData, mockScreenshot)
            XCTAssertNotNil(metadata?.thumbnailImageURL)
            XCTAssertEqual(isValid, true)
        case .failure(let error):
            XCTFail("execute 실패: \(error)")
        }
    }

    func test_URLMetadata에_누락된_데이터가_있어도_반환_성공() async {
        let mockHTML = """
                <html>
                <head>
                </head>
                </html>
            """
        let repo = StubURLRepository(
            resolveRedirectURL: URL(string: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")!,
            htmlResult:  mockHTML,
            captureScreenshot: nil
        )
        let useCase = DefaultParseURLUseCase(urlMetaRepository: repo)

        let result = await useCase.execute(url: URL(string: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")!)

        switch result {
        case .success(let (metadata, isValid)):
            XCTAssertEqual(metadata?.title, "제목 없음")
            XCTAssertEqual(metadata?.description, "내용 없음")
            XCTAssertEqual(metadata?.screenshotData, nil)
            XCTAssertNil(metadata?.thumbnailImageURL)
            XCTAssertEqual(isValid, true)
        case .failure(let error):
            XCTFail("execute 실패: \(error)")
        }
    }
}
