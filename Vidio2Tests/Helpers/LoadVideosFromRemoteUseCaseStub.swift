//
//  LoadVideosFromRemoteUseCaseStub.swift
//  Vidio2Tests
//
//  Created by Arifin Firdaus on 25/11/22.
//

@testable import Vidio2

final class LoadVideosFromRemoteUseCaseStub: LoadVideosUseCase {
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
