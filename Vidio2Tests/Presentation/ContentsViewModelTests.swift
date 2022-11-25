//
//  ContentsViewModelTests.swift
//  Vidio2Tests
//
//  Created by Arifin Firdaus on 25/11/22.
//

import XCTest
@testable import Vidio2

final class ContentsViewModel {
    private let useCase: LoadVideosUseCase
    
    init(useCase: LoadVideosUseCase) {
        self.useCase = useCase
    }
}

final class ContentsViewModelTests: XCTestCase {

    func test_init_doesNotRequestContents() {
        let useCase = LoadVideosFromRemoteUseCaseSpy()
        _ = ContentsViewModel(useCase: useCase)
        
        XCTAssertEqual(useCase.messages, [])
    }
    
    // MARK: - Helpers
    
    private final class LoadVideosFromRemoteUseCaseSpy: LoadVideosUseCase {
        private(set) var messages = [Message]()
        
        enum Message: Equatable { }
        
        func execute() async throws -> [RootResponse] {
            return []
        }
    }
}
