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
    var timer: Timer?
    var counter: [Int] = []
    var red: CGFloat = 255
    var green: CGFloat = 0
    var blue: CGFloat = 0
//    var moving: Bool = false
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var smileyImage: UIImageView!
    @IBOutlet weak var angerImage: UIImageView!
    
    enum PlayerState:String {
        case neutral = "Neutral"
        case up = "Up"
        case down = "Down"
    }
    let colorArray: [CGColor] = [#colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        session = ARSession()
        session.delegate = self
        
        playerView.layer.cornerRadius = playerView.frame.width/2
        playerView.layer.borderWidth = 0
        playerView.layer.backgroundColor = colorArray[1]
        view.layer.backgroundColor = colorArray[0]
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(counterProcess), userInfo: nil, repeats: true)
//        for _ in 0...10 {
//            let myView = UIView(
//        }

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
//        print("yes")
    }
    
    func movePlayer (state:PlayerState) {

        var direction:CGFloat = 0
        
        switch state {
        case .up:
            direction = -25
        case .down:
            direction = 25
        case .neutral:
            direction = 0
        }
//        print(Int(playerView.frame.origin.y) + Int(direction))
        if Int(playerView.frame.origin.y) + Int(direction) >= 210 && Int(playerView.frame.origin.y) + Int(direction) <= 660 {

//            moving = true
//            print("yesyesyes")
            print(playerView.frame.origin.y)
            UIView.animate(withDuration: 2, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
                
                self.playerView.frame.origin.y += direction
                
                if state.rawValue == "Up" {
                    self.playerView.transform = CGAffineTransform(scaleX: 2, y: 2)
//                    self.playerView.backgroundColor = UIColor(patternImage: UIImage(named: "smiley")!)
                } else if state.rawValue == "Down" {
                    self.playerView.transform = CGAffineTransform(scaleX: 1, y: 1)
//                    self.playerView.backgroundColor = UIColor(patternImage: UIImage(named: "angry")!)
                }
                
            })
            
        }
        
    }
    
    @objc func counterProcess() {
        
        if playerView.frame.origin.y <= 129 {
            counter.append(counter.count+1)
            if counter.count > 10 {
                counter.remove(at: counter.count-1)
            }
            view.viewWithTag(counter.count)?.backgroundColor = UIColor(red: 1, green: 0, blue: 1, alpha: CGFloat(Double(counter.count)/10.0))
        } else {
            view.viewWithTag(counter.popLast() ?? 1)?.backgroundColor = UIColor.clear
        }
        print("\(counter.count)")
        
    }
    
    func update(withFaceAnchor faceAnchor: ARFaceAnchor) {
        var bledShapes:[ARFaceAnchor.BlendShapeLocation:Any] = faceAnchor.blendShapes
        
        guard let mouthSmile = bledShapes[.mouthSmileLeft] as? Float else {return}
        print(mouthSmile)
        
        if mouthSmile > 0.5 {
            updatePlayer(state: .up)

        } else if mouthSmile < 0.1 {
            updatePlayer(state: .down)

        } else {
            updatePlayer(state: .neutral)
        }
        
        guard let browInnerUp = bledShapes[.browInnerUp] as? Float else {return}
        print(browInnerUp)
        
        if browInnerUp > 0.5 {
            view.alpha = 1
        } else if browInnerUp < 0.1 {
            view.alpha = 0.2
        } else {
            view.alpha = 0.6
        }
        
    }


}

