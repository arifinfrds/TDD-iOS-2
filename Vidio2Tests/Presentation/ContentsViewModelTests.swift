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
    
    private(set) var state: State = .initial
    
    enum State: Equatable {
        case initial
        case error
    }
    
    init(useCase: LoadVideosUseCase) {
        self.useCase = useCase
    }
    
    func onLoad() async {
        do {
            _ = try await self.useCase.execute()
        } catch {
            self.state = .error
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
    
    func test_onLoadTwice_requestContentsTwice() async {
        let useCase = LoadVideosFromRemoteUseCaseSpy()
        let sut = ContentsViewModel(useCase: useCase)
        
        await sut.onLoad()
        await sut.onLoad()
        
        XCTAssertEqual(useCase.messages, [ .loadContents, .loadContents ])
    }
    
    func test_onLoad_showsErrorOnLoadError() async {
        let useCase = LoadVideosFromRemoteUseCaseStub(result: .failure(LoadVideosFromRemoteUseCase.Error.failToDecode))
        let sut = ContentsViewModel(useCase: useCase)
        
        await sut.onLoad()
        
        XCTAssertEqual(sut.state, .error)
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
    
    private final class LoadVideosFromRemoteUseCaseStub: LoadVideosUseCase {
        private let result: Result<[RootResponse], LoadVideosFromRemoteUseCase.Error>
        
        init(result: Result<[RootResponse], LoadVideosFromRemoteUseCase.Error>) {
            self.result = result
        }
        
        func execute() async throws -> [RootResponse] {
            switch result {
            case let .success(rootResponse):
                return rootResponse
            case let .failure(error):
                throw error
            }
        }
    }
}
