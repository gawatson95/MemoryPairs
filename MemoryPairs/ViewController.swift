//
//  ViewController.swift
//  MemoryPairs
//
//  Created by Grant Watson on 11/3/22.
//

import UIKit

class ViewController: UICollectionViewController {
    var cards = ["🐶", "🐱", "🐭", "🐼", "🐻", "🐵"]
    var pairs = [String]()
    var selectedCards = [Card]()
    
    var highScore = 0
    var tries = 0
    var score = 0 {
        didSet {
            navigationItem.rightBarButtonItem?.title = "Score: \(score)"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Pairs"
        
        // Make pairs of each of emojis to use in the game
        pairs = [[String]](repeating: cards, count: 2).flatMap{$0}.shuffled()
        
        let defaults = UserDefaults.standard
        highScore = defaults.value(forKey: "highScore") as? Int ?? 0
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Score: \(score)", style: .plain, target: self, action: #selector(showHighScore))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(resetGame))
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Card", for: indexPath) as? Card else {
            fatalError("Could not dequeue cell as Card")
        }
        
        cell.backgroundColor = UIColor.systemIndigo
        cell.layer.cornerRadius = 10
        cell.label.isHidden = true
        cell.label.text = pairs[indexPath.row]
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count * 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! Card
        cell.label.isHidden = false
        cell.label.alpha = 1
        selectedCards.append(cell)
        cell.isUserInteractionEnabled = false
        
        if selectedCards.count == 2 {
            // If two selected cards match, gain a point and remove cards
            if selectedCards[0].label.text == selectedCards[1].label.text {
                score += 1
                
                displayMatch()
                
                // Remove cards from view
                for card in selectedCards {
                    card.isUserInteractionEnabled = true
                    UIView.animate(withDuration: 0.75) {
                        card.backgroundColor = UIColor.white
                        card.label.alpha = 0
                    }
                }
                
                pairs.removeAll(where: { $0 == selectedCards[0].label.text! })
                
            } else {
                // Give users 5 tries to memorize before deducting points
                tries += 1
                if tries > 5 {
                    score -= 1
                }
                // "Flip" cards back to original state
                for card in selectedCards {
                    card.isUserInteractionEnabled = true
                    UIView.animate(withDuration: 0.75) {
                        card.label.alpha = 0
                    }
                }
            }
            
            selectedCards.removeAll()
        }
        
        if pairs.isEmpty {
            //Game Over
            saveHighScore()
            let message = score > highScore ? "New high score: \(score)! Great job!" : "Score: \(score)"
            
            let ac = UIAlertController(title: "Game Over", message: message, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "New Game", style: .default, handler: { [weak self] _ in
                self?.resetGame()
            }))
            present(ac, animated: true)
        }
    }
    
    @objc func resetGame() {
        pairs = [[String]](repeating: cards, count: 2).flatMap{$0}.shuffled()
        score = 0
        tries = 0
        collectionView.reloadData()
    }
    
    func saveHighScore() {
        let defaults = UserDefaults.standard
        // Retrieve high score, if not one, set it one
        guard let savedScore = defaults.value(forKey: "highScore") as? Int else {
            defaults.set(score, forKey: "highScore")
            return
        }
        // Set new high score if score is higher than saved score.
        if score > savedScore {
            defaults.set(score, forKey: "highScore")
            highScore = score
        }
    }
    
    @objc func showHighScore() {
        let ac = UIAlertController(title: "High Score", message: "\(highScore)", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func displayMatch() {
        let match = UIImageView(image: UIImage(named: "match"))
        match.frame = CGRect(x: (view.frame.width / 2) - 175, y: (view.frame.height / 2) - 50, width: 350, height: 100)
        match.alpha = 0
        view.addSubview(match)
        UIView.animate(withDuration: 1.75, animations: {
            match.alpha = 1
            match.alpha = 0
        }) { _ in
            match.removeFromSuperview()
        }
    }
}

