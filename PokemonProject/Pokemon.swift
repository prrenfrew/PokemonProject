//
//  Pokemon.swift
//  PokemonProject
//
//  Created by MAC on 8/27/20.
//  Copyright © 2020 PaulRenfrew. All rights reserved.
//

import Foundation

struct Pokemon: Decodable {
  let pokemonName: String
  let frontSpriteURL: URL
  
  enum CodingKeys: String, CodingKey {
    case pokemonName = "name"
    case spriteContainer = "sprites"
  }
  
  enum SpriteCodingKeys: String, CodingKey {
    case frontSprite = "front_default"
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let spriteContainer = try container.nestedContainer(keyedBy: SpriteCodingKeys.self, forKey: .spriteContainer)
    self.pokemonName = try container.decode(String.self, forKey: .pokemonName)
    self.frontSpriteURL = try spriteContainer.decode(URL.self, forKey: .frontSprite)
  }
  
//  init?(dictionary: [String: Any]) {
//    guard let pokemonName = dictionary["name"] as? String else { return nil }
//    self.name = pokemonName
//  }
}
