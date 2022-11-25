//
//  ContentsViewModelTests.swift
//  Vidio2Tests
//
//  Created by Arifin Firdaus on 25/11/22.
//

import Combine
import XCTest
@testable import Vidio2

final class ContentsViewModelTests: XCTestCase {

    func test_init_doesNotRequestContents() {
        let (_, useCase) = makeSUT()
        
        XCTAssertEqual(useCase.messages, [])
    }
    
    func test_onLoad_requestContents() async {
        let (sut, useCase) = makeSUT()
        
        await sut.onLoad()
        
        XCTAssertEqual(useCase.messages, [ .loadContents ])
    }
    
    func test_onLoadTwice_requestContentsTwice() async {
        let (sut, useCase) = makeSUT()
        
        await sut.onLoad()
        await sut.onLoad()
        
        XCTAssertEqual(useCase.messages, [ .loadContents, .loadContents ])
    }
    
    func test_onLoad_showsErrorOnLoadError() async {
        let useCase = LoadVideosFromRemoteUseCaseStub(result: .failure(LoadVideosFromRemoteUseCase.Error.failToDecode))
        let sut = makeSUT(useCaseStub: useCase)
        
        await sut.onLoad()
        
        XCTAssertEqual(sut.state.value, .error)
    }
    
    func test_onLoad_showsEmptyItems() async {
        let useCase = LoadVideosFromRemoteUseCaseStub(result: .success([]))
        let sut = makeSUT(useCaseStub: useCase)
        
        await sut.onLoad()
        
        XCTAssertEqual(sut.state.value, .dataUpdated([]))
    }
    
    func test_onLoad_showsSections() async {
        let sampleItem = anyItem()
        let useCase = LoadVideosFromRemoteUseCaseStub(result: .success([
            .init(id: 0, variant: .portrait, items: [ sampleItem ]),
            .init(id: 1, variant: .landscape, items: [ sampleItem ])
        ]))
        let sut = ContentsViewModel(useCase: useCase)
        
        await sut.onLoad()
        
        XCTAssertEqual(sut.state.value, .dataUpdated([
            .portraitItem([ sampleItem ]),
            .landscapeItem([ sampleItem ])
        ]))
    }
    
    func test_onLoad_showsCorrectStateInOrder() async {
        let sampleItem = anyItem()
        let useCase = LoadVideosFromRemoteUseCaseStub(result: .success([
            .init(id: 0, variant: .portrait, items: [ sampleItem ]),
            .init(id: 1, variant: .landscape, items: [ sampleItem ])
        ]))
        let sut = makeSUT(useCaseStub: useCase)
        let stateSpy = Spy<ContentsViewModel.State>(state: sut.state)
        
        await sut.onLoad()
        
        XCTAssertEqual(
            stateSpy.values,
            [
                .initial,
                .loading,
                    .dataUpdated([
                        .portraitItem([ sampleItem ]),
                        .landscapeItem([ sampleItem ])
                    ])
            ]
        )
    }
    
    // MARK: - Helpers
    
    private func makeSUT(useCaseStub: LoadVideosFromRemoteUseCaseStub, file: StaticString = #filePath, line: UInt = #line) -> ContentsViewModel {
        let sut = ContentsViewModel(useCase: useCaseStub)
        trackMemoryLeak(on: sut, file: file, line: line)
        return sut
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ContentsViewModel, useCase: LoadVideosFromRemoteUseCaseSpy) {
        let useCase = LoadVideosFromRemoteUseCaseSpy()
        let sut = ContentsViewModel(useCase: useCase)
        trackMemoryLeak(on: sut, file: file, line: line)
        return (sut, useCase)
    }
    
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
    
    private final class Spy<T> {
        private let state: CurrentValueSubject<T, Never>
        private(set) var values = [T]()
        private var subscriptions = Set<AnyCancellable>()
        
        init(state: CurrentValueSubject<T, Never>) {
            self.state = state
            
            self.state
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { self.values.append($0) }
                )
                .store(in: &subscriptions)
        }
    }
}
