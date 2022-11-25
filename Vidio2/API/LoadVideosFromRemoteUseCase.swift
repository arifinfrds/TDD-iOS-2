//
//  LoadVideosFromRemoteUseCase.swift
//  Vidio2
//
//  Created by Arifin Firdaus on 25/11/22.
//

import Foundation

final class LoadVideosFromRemoteUseCase {
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    enum Error: Swift.Error {
        case failToDecode
        case client
    }
    
    func execute() async throws -> [RootResponse] {
        do {
            let url = URL(string: "https://vidio.com/api/contents")!
            let request = URLRequest(url: url)
            let data = try await client.fetchFromAPI(request)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode([RootResponse].self, from: data)
            return decoded
        } catch {
            if error is DecodingError {
                throw Error.failToDecode
            } else {
                throw Error.client
            }
        }
    }
}
