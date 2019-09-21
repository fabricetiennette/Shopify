//
//  GameNavigationController.swift
//  Shopify
//
//  Created by Fabrice Etiennette on 17/09/2019.
//  Copyright © 2019 Fabrice Etiennette. All rights reserved.
//

import Foundation
import UIKit

class GameCollectionController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    var imageSrc: [ProductImage] = []
    let scoreLabel = UILabel()
    var currentScore = 0
    var firstFlippedCell: IndexPath?
    var soundManager = SoundManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scoreLabelSetUp()
        fetchJson()
        collectionView.backgroundColor = UIColor(red:0.53, green:0.67, blue:0.75, alpha:1.0)
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        soundManager.playSound(.shuffle)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageSrc.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? CollectionViewCell {
            do {
                if let url = URL(string: imageSrc[indexPath.row].src) {
                    let data = try Data(contentsOf: url)
                    cell.frontImageView.image = UIImage(data: data)
                }
            } catch {
                print(error)
            }
            return cell
        }
        return UICollectionViewCell.init()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.frame.width / 4) - 18, height: 65)
    }

    func collectionView(_ collectionView: UICollectionView,  layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let top = self.view.center.y/2
        return UIEdgeInsets(top: top, left: 21, bottom: 10, right: 21)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        
        if cell.isFlipped == false && cell.isMatched == false {
            cell.flip()
            soundManager.playSound(.flip)
            cell.isFlipped = true
            
            if firstFlippedCell == nil {
                firstFlippedCell = indexPath
            } else {
                checkMatches(indexPath)
            }
        }
    }

    func scoreLabelSetUp() {
        scoreLabel.frame.size = CGSize(width: 200, height: 50)
        scoreLabel.isHidden = false
        scoreLabel.text = "Score \(currentScore)"
        scoreLabel.font = UIFont(name: "Helvetica", size: 22)
        scoreLabel.textAlignment = .center
        scoreLabel.textColor = UIColor.white
        scoreLabel.center.x = self.view.center.x
        scoreLabel.center.y = self.view.center.y + 250
        self.view.addSubview(scoreLabel)
    }
    
    func checkMatches(_ secondFlippedCell: IndexPath) {
        let cardOneCell = collectionView.cellForItem(at: firstFlippedCell!) as? CollectionViewCell
        let cardTwoCell  = collectionView.cellForItem(at: secondFlippedCell) as? CollectionViewCell
        
        let cardOne = imageSrc[firstFlippedCell!.row]
        let cardTwo = imageSrc[secondFlippedCell.row]
        
        if cardOne.src == cardTwo.src {
            cardOneCell?.isMatched = true
            cardTwoCell?.isMatched = true
            
            cardOneCell?.remove()
            cardTwoCell?.remove()
            
            updateScore()
            checkGameEnded()
            soundManager.playSound(.match)
        } else {
            cardOneCell?.isFlipped = false
            cardTwoCell?.isFlipped = false
            
            cardOneCell?.flipBack()
            cardTwoCell?.flipBack()
            soundManager.playSound(.nomatch)
        }
        firstFlippedCell = nil
    }
    
    func updateScore() {
        UIView.animate(withDuration: 0.3, delay: 0.5, options: [], animations: {
            self.currentScore += 1
            self.scoreLabel.text = NSString(format: "Score %i", self.currentScore) as String
        }, completion: nil)
    }

    func checkGameEnded() {
        if currentScore == 10 {
            showWinner()
        }
    }
    
    func showWinner() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
        let blurEffect = UIBlurEffect(style: .regular)
        let visualEffect = UIVisualEffectView(effect: blurEffect)
        self.view.addSubview(visualEffect)
        
        let winnerLabel = UILabel()
        winnerLabel.frame.size = CGSize(width: 300, height: 100)
        winnerLabel.isHidden = false
        winnerLabel.text = "YOU WIN!"
        winnerLabel.font = UIFont(name: "Helvetica", size: 30)
        winnerLabel.textAlignment = .center
        winnerLabel.textColor = UIColor.white
        winnerLabel.center.x = self.view.center.x
        winnerLabel.center.y = self.view.center.y - 50
        self.view.addSubview(winnerLabel)
        
        let backButton = UIButton()
        backButton.frame.size = CGSize(width: 300, height: 100)
        backButton.setTitle("BACK TO MENU", for: .normal)
        backButton.titleLabel?.font = UIFont(name: "Helvetica", size: 30)
        backButton.titleLabel?.textAlignment = .center
        backButton.titleLabel?.numberOfLines = 0
        backButton.isHidden = false
        backButton.titleLabel?.textColor = .white
        backButton.center.x = self.view.center.x
        backButton.center.y = self.view.center.y
        backButton.addTarget(self, action: #selector(self.backToHomeView), for: .touchUpInside)
        self.view.addSubview(backButton)
        })
    }
    
    @objc
    func backToHomeView() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let HomeViewController = storyBoard.instantiateViewController(withIdentifier: "Home") as! HomeViewController
        self.present(HomeViewController, animated: true, completion: nil)
    }
    
    func fetchJson() {
        var myProducts: [ProductImage] = []
        let jsonUrlString = "https://shopicruit.myshopify.com/admin/products.json?page=1&access_token=c32313df0d0ef512ca64d5b336a0d7c6"
        guard let url = URL(string: jsonUrlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            guard let data = data else { return }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else { return }
                
                guard let productArray = json["products"] as? [Any] else {
                    print("Unexpected collection array type")
                    return
                }
                for prod in productArray {
                    guard let prodT = prod as? [String: Any] else {
                        print("Unexpected product element type")
                        return
                    }
                    guard let image = prodT["image"] as? [String: Any] else {
                        print("Unexpected image type")
                        return
                    }
                    guard let url = image["src"] as? String,
                        let id = prodT["id"] as? Int else {
                            print("Unexpcted data type")
                            return
                    }
                    let product = ProductImage(id: id, src: url)
                    myProducts.append(product)
                }
                myProducts.shuffle()
                for i in 1...(myProducts.count/5) {
                    let image = myProducts[i]
                    self.imageSrc.append(image)
                    self.imageSrc.append(image)
                }
                self.imageSrc.shuffle()
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            } catch let jsonErr {
                print("Error serializing json: ", jsonErr)
            }
        }.resume()
    }
}
