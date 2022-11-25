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
    
    func onLoad() async {
        do {
            _ = try await self.useCase.execute()
        } catch {
            
        }
    }
}

final class ContentsViewModelTests: XCTestCase {

    func test_init_doesNotRequestContents() {
        let useCase = LoadVideosFromRemoteUseCaseSpy()
        _ = ContentsViewModel(useCase: useCase)
        
        XCTAssertEqual(useCase.messages, [])
    }
    
    func test_onLoad_requestContents() async {
        let useCase = LoadVideosFromRemoteUseCaseSpy()
        let sut = ContentsViewModel(useCase: useCase)
        
        await sut.onLoad()
        
        XCTAssertEqual(useCase.messages, [ .loadContents ])
    }
    
    
    // MARK: - Helpers
    
    private final class LoadVideosFromRemoteUseCaseSpy: LoadVideosUseCase {
        private(set) var messages = [Message]()
        
        enum Message: Equatable {
            case loadContents
        }
        
        func execute() async throws -> [RootResponse] {
            self.messages.append(.loadContents)
            return []
        }
    }
}
