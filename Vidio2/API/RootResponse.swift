//
//  RootResponse.swift
//  Vidio2
//
//  Created by Arifin Firdaus on 25/11/22.
//

struct RootResponse: Decodable, Equatable {
    let id: Int
    let variant: VariantType
    let items: [Item]
}

enum VariantType: String, Decodable {
    case portrait
    case landscape
}

struct Item: Decodable, Equatable {
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

