//
//  RootResponse.swift
//  Vidio2
//
//  Created by Arifin Firdaus on 25/11/22.
//

struct RootResponse: Codable, Equatable {
    let id: Int
    let variant: String
    let items: [Item]
}

struct Item: Codable, Equatable {
    let id: Int
    let title: String
    let videoURL: String
    let imageURL: String

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case videoURL = "video_url"
        case imageURL = "image_url"
    }
}

