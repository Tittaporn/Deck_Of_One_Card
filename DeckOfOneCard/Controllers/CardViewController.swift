//
//  CardViewController.swift
//  DeckOfOneCard
//
//  Created by Lee McCormick on 1/26/21.
//  Copyright © 2021 Warren. All rights reserved.
//

import UIKit

class CardViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var valueCardLabel: UILabel!
    @IBOutlet weak var cardImageView: UIImageView!
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        valueCardLabel.isHidden = true
    }
    
    // MARK: - Actions
    @IBAction func drawButtonTapped(_ sender: Any) {
        CardController.fetchCard { [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let card):
                    self?.fetchImageAndUpdateViews(for: card)
                case .failure(let error):
                    self?.presentErrorToUser(localizedError: error)
                }
            }
        }
    }
    
    // MARK: - Helper Fuctions
    func fetchImageAndUpdateViews(for card: Card) {
        // An escaping closure, so we need to create a capture list [weak self] to avoid memory leaks.
        CardController.fetchImage(for: card) { [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let cardImage):
                    self?.cardImageView.image = cardImage
                    self?.valueCardLabel.isHidden = false
                    self?.valueCardLabel.text = "\(card.value) of \(card.suit)"
                case .failure(let error):
                    self?.presentErrorToUser(localizedError: error)
                }
            }
        }
    }
}
