//
//  CardController.swift
//  DeckOfOneCard
//
//  Created by Lee McCormick on 1/26/21.
//  Copyright © 2021 Warren. All rights reserved.
//

import UIKit

class CardController {
    static let baseURL = URL(string: "https://deckofcardsapi.com/api/deck")
    static let drawACardURL = "new/draw"
    static let queryCount = "count"
    
    static func fetchCard(completion: @escaping (Result<Card, CardError>) -> Void) {
        // 1 - Prepare URL
        guard let baseURL = baseURL else { return completion(.failure(.invalidURL))}
        let drawCardURL = baseURL.appendingPathComponent(drawACardURL)
        var components = URLComponents(url: drawCardURL, resolvingAgainstBaseURL: true)
        let countOneQuery = URLQueryItem(name: queryCount, value: "1")
        components?.queryItems = [countOneQuery]
        
        guard let finalURL = components?.url else { return completion(.failure(.invalidURL))}
        print(finalURL)
        
        // 2 - Contact server
        URLSession.shared.dataTask(with: finalURL) { (data, _, error) in
            // 3 - Handle errors from the server
            if let unwrappedError = error {
                print("======== ERROR ========")
                print("Function: \(#function)")
                print("Error: \(unwrappedError)")
                print("Description: \(unwrappedError.localizedDescription)")
                print("======== ERROR ========")
                return completion(.failure(.throwError(unwrappedError)))
            }
            
            // 4 - Check for json data
            guard let data = data else { return completion(.failure(.noData))}
            
            // 5 - Decode json into a Card
            do {
                let topLevelObject = try JSONDecoder().decode(TopLevelObject.self, from: data)
                guard let cards = topLevelObject.cards else { return completion(.failure(.noData))}
                let card = cards[0]
                return completion(.success(card))
            } catch {
                print("======== ERROR ========")
                print("Function: \(#function)")
                print("Error: \(error)")
                print("Description: \(error.localizedDescription)")
                print("======== ERROR ========")
                return completion(.failure(.throwError(error)))
            }
        }.resume()
    }
    
    static func fetchImage(for card: Card, completion: @escaping (Result<UIImage, CardError>) -> Void) {
        // 1 - Prepare URL
        let cardURL = card.image
        
        // 2 - Contact server
        URLSession.shared.dataTask(with: cardURL) { (data, _, error) in
            // 3 - Handle errors from the server
            if let error = error {
                print("======== ERROR ========")
                print("Function: \(#function)")
                print("Error: \(error)")
                print("Description: \(error.localizedDescription)")
                print("======== ERROR ========")
                return completion(.failure(.throwError(error)))
            }
            
            // 4 - Check for image data
            guard let data = data else { return completion(.failure(.noData))}
            
            // 5 - Initialize an image from the data
            guard let image = UIImage(data: data) else { return completion(.failure(.unableToDecode))}
            completion(.success(image))
            
        }.resume()
    }
}
