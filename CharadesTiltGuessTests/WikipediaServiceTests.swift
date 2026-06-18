import Foundation
import XCTest
@testable import CharadesTiltGuess

final class WikipediaServiceTests: XCTestCase {
    override func tearDown() {
        WikipediaURLProtocol.responseData = nil
        WikipediaURLProtocol.statusCode = 200
        WikipediaURLProtocol.requestedURLs = []
        super.tearDown()
    }

    func testLoadRandomTitlesKeepsOnlyPlayableSingleWords() async throws {
        WikipediaURLProtocol.responseData = try JSONEncoder().encode(
            WikipediaFixtureResponse(query: .init(pages: [
                "1": .init(title: "Banana"),
                "2": .init(title: "Moon landing"),
                "3": .init(title: "Car"),
                "4": .init(title: "Spider-Man"),
                "5": .init(title: "Camera"),
                "6": .init(title: "Camera"),
                "7": .init(title: "Dragon"),
                "8": .init(title: "Oak_(tree)"),
                "9": .init(title: "Triceratops"),
                "10": .init(title: "Alpha2")
            ]))
        )

        let service = WikipediaService(session: makeSession(), endpoint: URL(string: "https://example.com/wiki")!)

        let titles = try await service.loadRandomTitles(limit: 12)

        XCTAssertTrue(titles.contains("Banana"))
        XCTAssertTrue(titles.contains("Camera"))
        XCTAssertTrue(titles.contains("Dragon"))
        XCTAssertFalse(titles.contains("Moon landing"))
        XCTAssertFalse(titles.contains("Car"))
        XCTAssertFalse(titles.contains("Spider-Man"))
        XCTAssertFalse(titles.contains("Oak (tree)"))
        XCTAssertFalse(titles.contains("Triceratops"))
        XCTAssertFalse(titles.contains("Alpha2"))
        XCTAssertEqual(titles.count, Set(titles.map { $0.lowercased() }).count)
        XCTAssertEqual(titles.count, 12)

        let requestedLimit = WikipediaURLProtocol.requestedURLs
            .first
            .flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }?
            .queryItems?
            .first(where: { $0.name == "grnlimit" })?
            .value
        XCTAssertEqual(requestedLimit, "80")
    }

    private func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [WikipediaURLProtocol.self]
        return URLSession(configuration: configuration)
    }
}

private final class WikipediaURLProtocol: URLProtocol {
    static var responseData: Data?
    static var statusCode = 200
    static var requestedURLs: [URL] = []

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        if let url = request.url {
            Self.requestedURLs.append(url)
        }

        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: Self.statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Self.responseData ?? Data())
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

private struct WikipediaFixtureResponse: Encodable {
    let query: WikipediaFixtureQuery
}

private struct WikipediaFixtureQuery: Encodable {
    let pages: [String: WikipediaFixturePage]
}

private struct WikipediaFixturePage: Encodable {
    let title: String
}
