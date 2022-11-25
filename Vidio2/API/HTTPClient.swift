//
//  HTTPClient.swift
//  Vidio2
//
//  Created by Arifin Firdaus on 25/11/22.
//

import Foundation

protocol HTTPClient {
    func fetchFromAPI(_ url: URLRequest) async throws -> Data
}
