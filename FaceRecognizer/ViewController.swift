//
//  ViewController.swift
//  FaceRecognizer
//
//  Created by I Putu Krisna on 20/05/19.
//  Copyright © 2019 I Putu Krisna. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSessionDelegate {

    var session: ARSession!
//    var moving: Bool = false
    @IBOutlet weak var playerView: UIView!
    
    enum PlayerState:String {
        case neutral = "Neutral"
        case up = "Up"
        case down = "Down"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        session = ARSession()
        session.delegate = self
        
        playerView.layer.cornerRadius = playerView.frame.width/2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard ARFaceTrackingConfiguration.isSupported else {print("iPhone X required"); return}
        
        let configuration = ARFaceTrackingConfiguration()
        
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    // MARK: ARSession Delegate
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        if let faceAnchor = anchors.first as? ARFaceAnchor {
            update(withFaceAnchor: faceAnchor)
        }
    }
    
    func updatePlayer (state:PlayerState) {
        movePlayer(state: state)
        print("yes")
    }
    
    func movePlayer (state:PlayerState) {

        var direction:CGFloat = 0
        
        switch state {
        case .up:
            direction = 116
        case .down:
            direction = -116
        case .neutral:
            direction = 0
        }
        print(Int(playerView.frame.origin.y) + Int(direction))
        if Int(playerView.frame.origin.y) + Int(direction) >= 0 && Int(playerView.frame.origin.y) + Int(direction) <= 896 {

//            moving = true
            print("yesyesyes")
            
            UIView.animate(withDuration: 2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
                
                self.playerView.transform = CGAffineTransform(translationX: 0, y: CGFloat(direction))
                
            })
            
        }
        
    }
    
    
    func update(withFaceAnchor faceAnchor: ARFaceAnchor) {
        var bledShapes:[ARFaceAnchor.BlendShapeLocation:Any] = faceAnchor.blendShapes
        
        guard let browInnerUp = bledShapes[.mouthSmileLeft] as? Float else {return}
        print(browInnerUp)
        
        if browInnerUp > 0.5 {
            updatePlayer(state: .up)
//            UIView.animate(withDuration: 2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
//
//                self.playerView.transform = CGAffineTransform(translationX: 0, y: CGFloat(-232))
//
//            })
//            if Int(playerView.frame.origin.y) + 116 >= -232 && Int(playerView.frame.origin.y) + 116 <= 232 {
//                playerView.frame.origin.y += 116
//            }
        } else if browInnerUp < 0.15 {
            updatePlayer(state: .down)
//            UIView.animate(withDuration: 2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
//
//                self.playerView.transform = CGAffineTransform(translationX: 0, y: CGFloat(232))
//
//            })
//                if Int(playerView.frame.origin.y) - 116 >= -232 && Int(playerView.frame.origin.y) - 116 <= 232 {
//                    playerView.frame.origin.y -= 116
//                }
        } else {
            updatePlayer(state: .neutral)
        }
        
    }


}

