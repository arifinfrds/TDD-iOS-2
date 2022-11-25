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
        case dataUpdated([Section])
    }
    
    enum Section: Equatable {
        case portraitItem([Item])
        case landscapeItem([Item])
    }
    
    init(useCase: LoadVideosUseCase) {
        self.useCase = useCase
    }
    
    func onLoad() async {
        do {
            let contents = try await self.useCase.execute()
            
            let sections = contents
                .map {
                    if $0.variant == "portrait" {
                        return Section.portraitItem($0.items)
                    } else {
                        return Section.landscapeItem($0.items)
                    }
                }
            
            self.state = .dataUpdated(sections)
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
    
    func test_onLoad_showsEmptyItems() async {
        let useCase = LoadVideosFromRemoteUseCaseStub(result: .success([]))
        let sut = ContentsViewModel(useCase: useCase)
        
        await sut.onLoad()
        
        XCTAssertEqual(sut.state, .dataUpdated([]))
    }
    
    func test_onLoad_showsSections() async {
        let sampleItem = anyItem()
        let useCase = LoadVideosFromRemoteUseCaseStub(result: .success([
            .init(id: 0, variant: "portrait", items: [ sampleItem ]),
            .init(id: 1, variant: "landscape", items: [ sampleItem ])
        ]))
        let sut = ContentsViewModel(useCase: useCase)
        
        await sut.onLoad()
        
        XCTAssertEqual(sut.state, .dataUpdated([
            .portraitItem([ sampleItem ]),
            .landscapeItem([ sampleItem ])
        ]))
    }
    
    // MARK: - Helpers
    
    private func anyItem() -> Item {
        Item(id: 1, title: "title 1", videoURL: "https://vidio.com/watch/32442.m3u8", imageURL: "https://vidio.com/image/32442.png")
    }
    
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
