//
//  GameViewController.swift
//  EcoloFinal
//
//  Created by Alex Cao on 4/3/17.
//  Copyright © 2017 Alex Cao. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

protocol EcosystemSceneDelegate: SKSceneDelegate {
    @discardableResult func introduceFactor(_ newFactorName: String, ofType: FactorType, withLevel: Double) -> Bool
}

class EcosystemViewController: UIViewController, EcosystemSceneDelegate {

    var ecosystemModel: Ecosystem!
    
    @discardableResult func introduceFactor(_ newFactorName: String, ofType: FactorType, withLevel: Double) -> Bool {
        return ecosystemModel.add(newFactorName, ofType: ofType, withLevel: withLevel)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        ecosystemModel = Ecosystem(name: "Antarctic")
        ecosystemModel.add("Sunlight", ofType: .Resource, withLevel: 3)
        ecosystemModel.add("Phytoplankton", ofType: .Producer, withLevel: 2)
        ecosystemModel.add("Fish", ofType: .Consumer, withLevel: 4)
        ecosystemModel.add("Penguin", ofType: .Consumer, withLevel: 1)
        ecosystemModel.add("Orca", ofType: .Consumer, withLevel: 1)
        ecosystemModel.add("Leopard Seal", ofType: .Consumer, withLevel: 1)
        ecosystemModel.add("Baleen Whale", ofType: .Consumer, withLevel: 0.5)
        
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.
        if let scene = GKScene(fileNamed: "GameScene") {
            
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! GameScene? {
                
                // Copy gameplay related content over to the scene
                //sceneNode.entities = scene.entities
                //sceneNode.graphs = scene.graphs
                
                // Set the scale mode to scale to fit the window
                sceneNode.scaleMode = .aspectFill
                
                // Present the scene
                if let view = self.view as! SKView? {
                    view.presentScene(sceneNode)
                    
                    view.ignoresSiblingOrder = true
                    
                    view.showsFPS = true
                    view.showsNodeCount = true
                }
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

}
