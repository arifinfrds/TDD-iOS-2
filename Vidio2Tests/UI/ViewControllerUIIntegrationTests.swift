//
//  ViewControllerUIIntegrationTests.swift
//  Vidio2Tests
//
//  Created by Arifin Firdaus on 25/11/22.
//

import XCTest
@testable import Vidio2

final class ViewControllerUIIntegrationTests: XCTestCase {
    
    func test_loadView_inInInitialState() {
        let useCase = LoadVideosFromRemoteUseCaseStub(result: .failure(LoadVideosFromRemoteUseCase.Error.failToDecode))
        let sut = makeSUT(loadVideosUseCase: useCase)
        
        XCTAssertEqual(sut.numberOfSections, 0)
    }
    
    func test_loadView_loadSections() async {
        let sampleItem = anyItem()
        let useCase = LoadVideosFromRemoteUseCaseStub(result: .success([
            .init(id: 0, variant: .portrait, items: [ sampleItem ]),
            .init(id: 1, variant: .landscape, items: [ sampleItem ])
        ]))
        let sut = makeSUT(loadVideosUseCase: useCase)
        
        // FIXME: Forced to make a non private API to await.
        _ = await sut.onLoad().result
        
        // FIXME: Main actor-isolated property 'sections' can not be referenced from a non-isolated autoclosure
        // FIXME: Main actor-isolated property 'numberOfSections' can not be referenced from a non-isolated autoclosure
        XCTAssertEqual(sut.sections.count, 2)
        XCTAssertEqual(sut.numberOfSections, 2)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(loadVideosUseCase: LoadVideosUseCase) -> ViewController {
        let viewController = ContentsUIComposer.composeWith(loadVideosUseCase: loadVideosUseCase)
        viewController.loadViewIfNeeded()
        return viewController
    }
    
    private func anyItem() -> Item {
        Item(id: 1, title: "title 1", videoURL: "https://vidio.com/watch/32442.m3u8", imageURL: "https://vidio.com/image/32442.png")
    }
}

extension ViewController {
    var numberOfSections: Int {
        collectionView?.numberOfSections ?? 0
    }
}
