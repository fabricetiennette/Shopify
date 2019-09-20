//
//  HomeViewController.swift
//  Shopify
//
//  Created by Fabrice Etiennette on 17/09/2019.
//  Copyright © 2019 Fabrice Etiennette. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    private let backgroundImageWinter = UIImage(named: "background-winter.jpg")
    private let gameTitle = UILabel()
    private let playNowButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mainMenu()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @objc
    func go() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let GameCollectionController = storyBoard.instantiateViewController(withIdentifier: "GameCollection") as! GameCollectionController
        self.present(GameCollectionController, animated: true, completion: nil)
    }
    
    func mainMenu() {
        if let backgroundImage = backgroundImageWinter {
            self.view.backgroundColor = UIColor(patternImage: backgroundImage)
        }
        
        gameTitle.frame = CGRect(x: 0, y: 150, width: view.frame.width, height: 35)
        gameTitle.font = UIFont(name: "AIR", size: 35)
        gameTitle.textAlignment = .center
        gameTitle.text = "Shopify Challenge"
        gameTitle.isHidden = false
        gameTitle.numberOfLines = 0
        gameTitle.textColor = UIColor.white
        self.view.addSubview(gameTitle)
        
        playNowButton.frame.size = CGSize(width: 125, height: 125)
        playNowButton.setTitle("PLay Now", for: .normal)
        playNowButton.titleLabel?.font = UIFont(name: "Air", size: 25)
        playNowButton.titleLabel?.textAlignment = .center
        playNowButton.titleLabel?.numberOfLines = 0
        playNowButton.isHidden = false
        playNowButton.setTitleColor(UIColor(red:0.36, green:0.42, blue:0.77, alpha:1.0), for: .normal)
        playNowButton.setBackgroundImage(UIImage(named: "Group"), for: .normal)
        playNowButton.center.x = self.view.center.x
        playNowButton.center.y = self.view.center.y + 70
        playNowButton.addTarget(self, action: #selector(self.go), for: .touchUpInside)
        self.view.addSubview(playNowButton)
    }
}
