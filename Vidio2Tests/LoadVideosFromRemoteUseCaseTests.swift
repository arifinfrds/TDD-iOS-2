//
//  LoadVideosFromRemoteUseCaseTests.swift
//  Vidio2Tests
//
//  Created by Arifin Firdaus on 25/11/22.
//

import XCTest

protocol HTTPClient {
    func fetchFromAPI(_ url: URLRequest) async throws -> Data
}

struct RootResponse: Codable, Equatable {
    let id: Int
    let variant: String
    let items: [Item]
}

struct Item: Codable, Equatable {
    let id: Int
    let title: String
    let videoURL: String
    let imageURL: String

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case videoURL = "video_url"
        case imageURL = "image_url"
    }
}

final class LoadVideosFromRemoteUseCase {
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    enum Error: Swift.Error {
        case failToDecode
        case client
    }
    
    func execute() async throws -> [RootResponse] {
        do {
            let url = URL(string: "https://vidio.com/api/contents")!
            let request = URLRequest(url: url)
            let data = try await client.fetchFromAPI(request)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode([RootResponse].self, from: data)
            return decoded
        } catch {
            if error is DecodingError {
                throw Error.failToDecode
            } else {
                throw Error.client
            }
        }
    }
}

final class LoadVideosFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.messages, [])
    }
    
    func test_execute_requestItems() async {
        let (sut, client) = makeSUT()
        
        _ = try? await sut.execute()
        
        XCTAssertEqual(client.messages, [ .fetchFromAPI ])
    }
    
    func test_executeTwice_requestItemsTwice() async {
        let (sut, client) = makeSUT()
        
        _ = try? await sut.execute()
        _ = try? await sut.execute()
        
        XCTAssertEqual(client.messages, [ .fetchFromAPI, .fetchFromAPI ])
    }
    
    func test_execute_deliversErrorOnClientError() async {
        let sut = makeSUT(clientStub: HTTPClientStub(result: .failure(LoadVideosFromRemoteUseCase.Error.client)))
        
        do {
            _ = try await sut.execute()
        } catch {
            XCTAssertEqual(error as? LoadVideosFromRemoteUseCase.Error, LoadVideosFromRemoteUseCase.Error.client)
        }
    }
    
    func test_execute_deliversErrorOnEmptyJSON() async {
        let client = HTTPClientStub(result: .success(emptyJSONData()))
        let sut = makeSUT(clientStub: client)
        
        do {
            _ = try await sut.execute()
        } catch {
            XCTAssertEqual(error as? LoadVideosFromRemoteUseCase.Error, LoadVideosFromRemoteUseCase.Error.failToDecode)
        }
    }
    
    func test_execute_deliversErrorOnEmptyInvalidJSON() async {
        let client = HTTPClientStub(result: .success(invalidJSONData()))
        let sut = makeSUT(clientStub: client)
        
        do {
            _ = try await sut.execute()
        } catch {
            XCTAssertEqual(error as? LoadVideosFromRemoteUseCase.Error, LoadVideosFromRemoteUseCase.Error.failToDecode)
        }
    }
    
    func test_execute_deliversItemsOnValidEmptyItemData() async {
        let client = HTTPClientStub(result: .success(validEmptyItemJSONData()))
        let sut = makeSUT(clientStub: client)
        
        do {
            let decoded = try await sut.execute()
            XCTAssertEqual(decoded, [])
        } catch {
            XCTFail("Expected success, got error instead: \(error)")
        }
    }
    
    func test_execute_deliversItemsOnValidSingleItemData() async {
        let client = HTTPClientStub(result: .success(validSingleItemJSONData()))
        let sut = makeSUT(clientStub: client)
        
        do {
            let decoded = try await sut.execute()
            XCTAssertEqual(decoded.count, 1)
            XCTAssertEqual(decoded.first!.items.count, 1)
        } catch {
            XCTFail("Expected success, got error instead: \(error)")
        }
    }
    
    func test_execute_deliversItemsOnValidMultipleItemData() async {
        let client = HTTPClientStub(result: .success(validMultipleItemJSONData()))
        let sut = makeSUT(clientStub: client)
        
        do {
            let decoded = try await sut.execute()
            XCTAssertEqual(decoded.count, 2)
            XCTAssertEqual(decoded.first!.items.count, 2)
            XCTAssertEqual(decoded.last!.items.count, 2)
        } catch {
            XCTFail("Expected success, got error instead: \(error)")
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LoadVideosFromRemoteUseCase, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = LoadVideosFromRemoteUseCase(client: client)
        trackMemoryLeak(on: sut, file: file, line: line)
        return (sut, client)
    }
    
    private func makeSUT(clientStub: HTTPClientStub, file: StaticString = #filePath, line: UInt = #line) ->  LoadVideosFromRemoteUseCase {
        let sut = LoadVideosFromRemoteUseCase(client: clientStub)
        trackMemoryLeak(on: sut, file: file, line: line)
        return sut
    }
    
    private func emptyJSONData() -> Data {
        "".data(using: .utf8)!
    }
    
    private func invalidJSONData() -> Data {
        "invalid-json-data".data(using: .utf8)!
    }
    
    private func validEmptyItemJSONData() -> Data {
        """
        []
        """.data(using: .utf8)!
    }
    
    private func validSingleItemJSONData() -> Data {
        """
        [
           {
              "id": 1,
              "variant": "portrait",
              "items": [
                 {
                     "id": 1,
                     "title": "title 1",
                     "video_url": "https://vidio.com/watch/32442.m3u8",
                     "image_url": "https://vidio.com/image/32442.png"
                 }
               ]
           }
        ]
        """.data(using: .utf8)!
    }
    
    private func validMultipleItemJSONData() -> Data {
        """
        [
           {
              "id": 1,
              "variant": "portrait",
              "items": [
                 {
                     "id": 1,
                     "title": "title 1",
                     "video_url": "https://vidio.com/watch/32442.m3u8",
                     "image_url": "https://vidio.com/image/32442.png"
                 },
                 {
                     "id": 2,
                     "title": "title 2",
                     "video_url": "https://vidio.com/watch/32443.m3u8",
                    "image_url": "https://vidio.com/image/32443.png"
                 }
               ]
           },
           {
               "id": 2,
               "variant": "landscape",
               "items": [
                  {
                     "id": 1,
                     "title": "title 1",
                     "video_url": "https://vidio.com/watch/32442.m3u8",
                     "image_url": "https://vidio.com/image/32442.png"
                  },
                  {
                     "id": 2,
                     "title": "title 2",
                     "video_url": "https://vidio.com/watch/32443.m3u8",
                     "image_url": "https://vidio.com/image/32443.png"
                  }
               ]
           }
        ]
        """.data(using: .utf8)!
    }
    
    private final class HTTPClientSpy: HTTPClient {
        private(set) var messages = [Message]()
        
        enum Message: Equatable {
            case fetchFromAPI
        }
        
        func fetchFromAPI(_ url: URLRequest) async throws -> Data {
            messages.append(.fetchFromAPI)
            return Data()
        }
    }
    
    private class HTTPClientStub: HTTPClient {
        private let result: Result<Data, Error>
        
        init(result: Result<Data, Error>) {
            self.result = result
        }
        
        func fetchFromAPI(_ url: URLRequest) async throws -> Data {
            switch result {
            case .success(let data):
                return data
            case let .failure(error):
                throw error
            }
        }
    }
}

extension XCTestCase {
    func trackMemoryLeak(on instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}
