//
//  ViewController.swift
//  PokemonProject
//
//  Created by MAC on 8/27/20.
//  Copyright © 2020 PaulRenfrew. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  @IBOutlet weak var pokemonNameLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.pokemonNameLabel.text = "Getting the pokemon..."
    //    guard let fileURL = Bundle.main.url(forResource: "pokemonJSON", withExtension: "json"),
    //      let fileData = try? Data(contentsOf: fileURL) else {
    //      print("No such file")
    //      return
    //    }
    //    /*
    //     JSONSerialization
    //     */
    //
    ////    guard let json = try? JSONSerialization.jsonObject(with: fileData, options: []) as? [String: Any] else { return }
    ////    let pokemon = Pokemon(dictionary: json)
    ////    print(pokemon)
    //
    //    /*
    //     Codable
    //     */
    //    let jsonDecoder = JSONDecoder()
    //    let pokemon = try? jsonDecoder.decode(Pokemon.self, from: fileData)
    //    print(pokemon)
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    /*
     DispatchGroup - Useful when you want to do multiple async network calls, and do one big update when all of them finish
     */
    var pokemonArray: [Pokemon] = []
    let group = DispatchGroup()
    for _ in 1...6 {
      group.enter()
      self.getPokemon { (pokemon) in
        defer { group.leave() }
        //      switch pokemon {
        //      case .success(let pokemonModel):
        //        print(pokemonModel)
        //      case .failure(_):
        //        print("There was an error")
        //      }
        
        do {
          let pokemonModel = try pokemon.get()
          /*
           GCD - Grand Central Dispatch
           This is a low-level C Library for multithreading
           */
          
          /*
           GCD has 2 threads/Dispatch queues
           First is the main thread. This is where you make your UI updates
           
           Second is the global thread. This is where we would do background work
           Quality of service
           
           User-interactive
           User-initiated
           Default
           Utility
           Background
           Unspecified
           
           Dispatch queues can do their work in 2 different ways:
           async and sync
           sync - this will pause the current thread, and wait for the sync task to be done
           async - basically skips of the work temporarily, and executes it when it has time
           
           GCD has 2 types of queues
           1. Serial - Queues will do one thing at a time. Main dispatch queue is an example
           tangent****
           The main thread works with a run loop
           Run loop is basically a scheduler for the main thread
           Run loop finishes a loop every 1/60 of a second
           *****end tangent
           2. Concurrent - Queues will do many things at the same time, generally related to the number of cores. Background/global thread is a good example of this
           */
          
          pokemonArray.append(pokemonModel)
          print("finished")
        } catch {
          print("There was an error")
        }
      }
    }
    group.notify(queue: .main) {
      let pokemonNames = pokemonArray.map { $0.pokemonName }
      self.pokemonNameLabel.text = pokemonNames.joined(separator: "\n")
    }
  }
  
  func getPokemon(completionHandler: @escaping (Result<Pokemon, Error>) -> Void) {
    /*
     Escaping vs nonescaping
     nonescaping closure will be called within the scope of the function it was passed into
     
     Escaping closure can be called outside of the scope of the function, such as within a completion handler of a network call
     
     By default, closures are nonescaping
     However, optional closures are escaping by default
     */
    let urlString = "https://pokeapi.co/api/v2/pokemon/\(Int.random(in: 1...800))/"
    guard let url = URL(string: urlString) else {
      completionHandler(.failure(NetworkError.invalidURL))
      return
    }
    //    let pokemonData = try? Data(contentsOf: url)
    /*
     404 - not found
     403 - Forbidden
     200 - Success
     500 - Server error
     100 - informational
     300 - resource is somewhere
     400 - client error
     */
    
    /*
     ATS - App Transport Security
     By default only allows access to secure(https) URLs
     */
    URLSession.shared.dataTask(with: url) { (data, response, error) in
      guard let data = data else {
        if let error = error {
          completionHandler(.failure(error))
        } else {
          //Should be impossible
          completionHandler(.failure(NetworkError.unknown))
        }
        
        return
      }
      guard let pokemon = try? JSONDecoder().decode(Pokemon.self, from: data) else {
        completionHandler(.failure(NetworkError.invalidData))
        return
      }
      completionHandler(.success(pokemon))
    }.resume()
  }
}

enum NetworkError: Error {
  case invalidURL
  case unknown
  case invalidData
}
