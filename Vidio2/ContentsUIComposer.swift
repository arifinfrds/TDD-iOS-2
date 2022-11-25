//
//  ContentsUIComposer.swift
//  Vidio2
//
//  Created by Arifin Firdaus on 25/11/22.
//

import UIKit

final class ContentsUIComposer {
    static func composeWith(loadVideosUseCase: LoadVideosUseCase) -> ViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        viewController.viewModel = ContentsViewModel(useCase: MainQueueDispatchDecorator(decoratee: loadVideosUseCase))
        return viewController
    }
}

final class MainQueueDispatchDecorator: LoadVideosUseCase {
    private let decoratee: LoadVideosUseCase
    
    init(decoratee: LoadVideosUseCase) {
        self.decoratee = decoratee
    }
    
    @MainActor
    func execute() async throws -> [RootResponse] {
        return try await decoratee.execute()
    }
}
