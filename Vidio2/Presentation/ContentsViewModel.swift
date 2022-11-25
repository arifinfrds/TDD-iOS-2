//
//  ContentsViewModel.swift
//  Vidio2
//
//  Created by Arifin Firdaus on 25/11/22.
//

import Combine

final class ContentsViewModel {
    
    private(set) var state: CurrentValueSubject<State, Never> = .init(.initial)
    
    private let useCase: LoadVideosUseCase
    
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
                .map { $0.variant == .portrait ? Section.portraitItem($0.items) : Section.landscapeItem($0.items) }
            
            self.state.send(.dataUpdated(sections))
        } catch {
            self.state.send(.error)
        }
    }
}

