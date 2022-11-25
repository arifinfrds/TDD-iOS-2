//
//  LoadVideosFromRemoteUseCaseTests.swift
//  Vidio2Tests
//
//  Created by Arifin Firdaus on 25/11/22.
//

import XCTest

protocol HTTPClient {
    
}

final class LoadVideosFromRemoteUseCase {
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
}

final class LoadVideosFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestFromURL() {
        let client = HTTPClientSpy()
        _ = LoadVideosFromRemoteUseCase(client: client)
        
        XCTAssertEqual(client.messages, [])
    }
    
    // MARK: - Helpers
    
    private final class HTTPClientSpy: HTTPClient {
        private(set) var messages = [Message]()
        
        enum Message: Equatable {}
    }
}
