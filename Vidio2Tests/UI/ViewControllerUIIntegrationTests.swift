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
        let sut = ViewController()
        sut.viewModel = ContentsViewModel(useCase: useCase)
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.numberOfSections, 0)
    }
}

extension ViewController {
    var numberOfSections: Int {
        collectionView?.numberOfSections ?? 0
    }
}
