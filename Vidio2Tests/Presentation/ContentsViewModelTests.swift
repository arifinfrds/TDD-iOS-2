//
//  ContentsViewModelTests.swift
//  Vidio2Tests
//
//  Created by Arifin Firdaus on 25/11/22.
//

import Combine
import XCTest
@testable import Vidio2

final class ContentsViewModel {
    private let useCase: LoadVideosUseCase
    
    private(set) var state: CurrentValueSubject<State, Never> = .init(.initial)
    
    enum State: Equatable {
        case initial
        case error
        case dataUpdated([Section])
        case loading
    }
    
    enum Section: Equatable {
        case portraitItem([Item])
        case landscapeItem([Item])
    }
    
    init(useCase: LoadVideosUseCase) {
        self.useCase = useCase
    }
    
    func onLoad() async {
        state.send(.loading)
        do {
            let contents = try await self.useCase.execute()
            
            let sections = contents
                .map { $0.variant == "portrait" ? Section.portraitItem($0.items) : Section.landscapeItem($0.items) }
            
            self.state.send(.dataUpdated(sections))
        } catch {
            self.state.send(.error)
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
        
        XCTAssertEqual(sut.state.value, .error)
    }
    
    func test_onLoad_showsEmptyItems() async {
        let useCase = LoadVideosFromRemoteUseCaseStub(result: .success([]))
        let sut = ContentsViewModel(useCase: useCase)
        
        await sut.onLoad()
        
        XCTAssertEqual(sut.state.value, .dataUpdated([]))
    }
    
    func test_onLoad_showsSections() async {
        let sampleItem = anyItem()
        let useCase = LoadVideosFromRemoteUseCaseStub(result: .success([
            .init(id: 0, variant: "portrait", items: [ sampleItem ]),
            .init(id: 1, variant: "landscape", items: [ sampleItem ])
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
            .init(id: 0, variant: "portrait", items: [ sampleItem ]),
            .init(id: 1, variant: "landscape", items: [ sampleItem ])
        ]))
        let sut = ContentsViewModel(useCase: useCase)
        let stateSpy = Spy(state: sut.state)
        
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
    
    private final class Spy {
        private let state: CurrentValueSubject<ContentsViewModel.State, Never>
        private(set) var values = [ContentsViewModel.State]()
        private var subscriptions = Set<AnyCancellable>()
        
        init(state: CurrentValueSubject<ContentsViewModel.State, Never>) {
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
