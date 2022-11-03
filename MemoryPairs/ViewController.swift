//
//  ViewController.swift
//  MemoryPairs
//
//  Created by Grant Watson on 11/3/22.
//

import UIKit

class ViewController: UICollectionViewController {
    var cards = ["🐶", "🐱", "🐭", "🐼", "🐻", "🐵", "🐨", "🦆", "🐰", "🐧"]
    var pairs: [String]!
    var selectedCards = [Card]()
    
    var highScore = 0
    var score = 0 {
        didSet {
            navigationItem.rightBarButtonItem?.title = "Score: \(score)"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Pairs"
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
        return pairs.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! Card
        cell.label.isHidden = false
        selectedCards.append(cell)
        cell.isUserInteractionEnabled = false
        
        if selectedCards.count == 2 {
            if selectedCards[0].label.text == selectedCards[1].label.text {
                score += 1
                self.pairs.removeAll { $0 == selectedCards[0].label.text! }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    collectionView.reloadData()
                }
                
                for card in self.selectedCards {
                    card.isUserInteractionEnabled = true
                }
            } else {
//                if score > 0 {
//                    score -= 1
//                }
                for card in self.selectedCards {
                    card.isUserInteractionEnabled = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        card.label.isHidden = true
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
        collectionView.reloadData()
    }
    
    func saveHighScore() {
        let defaults = UserDefaults.standard
        guard let savedScore = defaults.value(forKey: "highScore") as? Int else {
            defaults.set(score, forKey: "highScore")
            return
        }
        
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
}

