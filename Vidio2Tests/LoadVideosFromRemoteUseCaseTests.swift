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

final class LoadVideosFromRemoteUseCase {
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func execute() async throws {
        do {
            let url = URL(string: "https://vidio.com/api/contents")!
            let request = URLRequest(url: url)
            _ = try await client.fetchFromAPI(request)
        } catch {
            throw error
        }
    }
}

final class LoadVideosFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestFromURL() {
        let client = HTTPClientSpy()
        _ = LoadVideosFromRemoteUseCase(client: client)
        
        XCTAssertEqual(client.messages, [])
    }
    
    func test_execute_requestItems() async throws {
        let client = HTTPClientSpy()
        let sut = LoadVideosFromRemoteUseCase(client: client)
        
        try await sut.execute()
        
        XCTAssertEqual(client.messages, [ .fetchFromAPI ])
    }
    
    func test_executeTwice_requestItemsTwice() async throws {
        let client = HTTPClientSpy()
        let sut = LoadVideosFromRemoteUseCase(client: client)
        
        try await sut.execute()
        try await sut.execute()
        
        XCTAssertEqual(client.messages, [ .fetchFromAPI, .fetchFromAPI ])
    }
    
    func test_execute_deliversErrorOnClientError() async {
        let clientError = NSError(domain: "client error", code: 1)
        let client = HTTPClientStub(result: .failure(clientError))
        let sut = LoadVideosFromRemoteUseCase(client: client)
        
        do {
            _ = try await sut.execute()
        } catch {
            XCTAssertEqual(error as NSError, clientError)
        }
    }
    
    // MARK: - Helpers
    
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
