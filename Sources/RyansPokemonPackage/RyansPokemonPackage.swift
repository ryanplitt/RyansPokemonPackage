import Foundation

public struct Pokemon: Decodable {
    let name: String
    fileprivate let photo: URL
    var abilities: [String] = []
    var types: [String] = []
    
    enum CodingKeys: String, CodingKey {
        case name
        case sprites
        case abilities
        case types
    }
    
    enum CodingKeysSprites: String, CodingKey {
        case other
    }
    
    enum OtherKeysSprites: String, CodingKey {
        case official = "official-artwork"
    }
    
    enum FrontKeysSprites: String, CodingKey {
        case front = "front_default"
    }
    
    enum AbilitiesKeys: String, CodingKey {
        case ability
    }
    
    struct Ability: Decodable {
        let name: String
        
        enum CodingKeys: String, CodingKey {
            case ability
        }
        
        enum AbilityCodingKeys: String, CodingKey {
            case name
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let ability = try values.nestedContainer(keyedBy: AbilityCodingKeys.self, forKey: .ability)
            self.name = try ability.decode(String.self, forKey: .name)
        }
    }
    
    struct PokemonType: Decodable {
        let name: String
        enum CodingKeys: String, CodingKey {
            case type
        }
        
        enum TypeCodingKeys: String, CodingKey {
            case name
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let pType = try values.nestedContainer(keyedBy: TypeCodingKeys.self, forKey: .type)
            self.name = try pType.decode(String.self, forKey: .name)
        }
    }
    
    public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        let sprites = try values.nestedContainer(keyedBy: CodingKeysSprites.self, forKey: .sprites)
        let other = try sprites.nestedContainer(keyedBy: OtherKeysSprites.self, forKey: .other)
        let front = try other.nestedContainer(keyedBy: FrontKeysSprites.self, forKey: .official)
        self.photo = try front.decode(URL.self, forKey: .front)
        
        var abilities = try values.nestedUnkeyedContainer(forKey: .abilities)
        while !abilities.isAtEnd {
            let ability = try abilities.decode(Ability.self)
            self.abilities.append(ability.name)
        }
        
        var pType = try values.nestedUnkeyedContainer(forKey: .types)
        while !pType.isAtEnd {
            let type = try pType.decode(PokemonType.self)
            self.types.append(type.name)
        }
    }
}

public enum PokemonGen {
    case original, all
}

@available(iOS 15.0, *)
public func getRandomPokemon(gen: PokemonGen = .original) async -> Pokemon {
    let randomNumber = Int.random(in: gen == .original ? 1...150 : 1...905)
    let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(String(randomNumber))/")!
    let urlSession = URLSession.shared
    let (data, _) = try! await urlSession.data(from: url)
    let pokemon = try! JSONDecoder().decode(Pokemon.self, from: data)
    return pokemon
}

#if canImport(UIKit)

import UIKit
import Kingfisher

public extension UIImageView {
    public func setPokemon(pokemon: Pokemon) {
        self.kf.setImage(with: pokemon.photo)
    }
}

#endif
