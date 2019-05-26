//
//  ChargeViewController.swift
//  FaceRecognizer
//
//  Created by I Putu Krisna on 26/05/19.
//  Copyright © 2019 I Putu Krisna. All rights reserved.
//

import UIKit
import ARKit

class ChargeViewController: UIViewController, ARSessionDelegate {

    var session: ARSession!
    let borderColor = UIColor.white
    enum PlayerState:String {
        case neutral = "Neutral"
        case up = "Up"
        case down = "Down"
        
    }
    
    @IBOutlet weak var batteryIndicator: BatteryIndicator!
    @IBOutlet weak var precentLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var borderImage: UIView!
    @IBOutlet weak var calmNight: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        session = ARSession()
        session.delegate = self
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "calm")!)
        
        batteryIndicator.precentCharged = 32
        batteryIndicator.animatedReveal = true
        
        calmNight.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        calmNight.alpha = CGFloat(batteryIndicator.precentCharged/100)
        
        precentLabel.text = "\(Int(batteryIndicator.precentCharged))%"
        precentLabel.layer.zPosition = 1
        
        imageView.transform = CGAffineTransform(rotationAngle: 45/360)
        
        borderImage.layer.masksToBounds = true
        borderImage.backgroundColor = UIColor.clear
        borderImage.layer.cornerRadius = borderImage.frame.width/2
        borderImage.layer.shadowColor = UIColor.white.cgColor
        borderImage.layer.shadowOpacity = 1
        borderImage.layer.shadowOffset = .zero
        borderImage.layer.shadowRadius = CGFloat(batteryIndicator.precentCharged/3)
        
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

    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        if let faceAnchor = anchors.first as? ARFaceAnchor {
            update(withFaceAnchor: faceAnchor)
            
        }
        
    }
    
    func updatePlayer (state:PlayerState) {
        movePlayer(state: state)
        
    }
    
    func movePlayer (state:PlayerState) {
        
        var direction: Double = 0
        
        switch state {
        case .up:
            direction = 0.2
        case .down:
            direction = -0.1
        case .neutral:
            direction = 0
            
        }

        if batteryIndicator.precentCharged + direction <= 100 && batteryIndicator.precentCharged + direction >= 0 {
            batteryIndicator.precentCharged += direction
            precentLabel.text = "\(Int(batteryIndicator.precentCharged))%"
            borderImage.layer.shadowRadius = CGFloat(batteryIndicator.precentCharged/3)
            calmNight.alpha = CGFloat(batteryIndicator.precentCharged/100)
            print(batteryIndicator.precentCharged)
            
        }
        
        if batteryIndicator.precentCharged >= 50 {
            if imageView.image != UIImage(named: "smilee") {
                UIView.transition(with: imageView,
                                  duration: 1,
                                  options: .transitionCrossDissolve,
                                  animations: { self.imageView.image = UIImage(named: "smilee") },
                                  completion: nil)
                
            }

        } else if batteryIndicator.precentCharged >= 20 {
            if imageView.image != UIImage(named: "flat") {
                UIView.transition(with: imageView,
                                  duration: 1,
                                  options: .transitionCrossDissolve,
                                  animations: { self.imageView.image = UIImage(named: "flat") },
                                  completion: nil)
                
            }

        } else {
            if imageView.image != UIImage(named: "sadd") {
                UIView.transition(with: imageView,
                                  duration: 1,
                                  options: .transitionCrossDissolve,
                                  animations: { self.imageView.image = UIImage(named: "sadd") },
                                  completion: nil)
                
            }
            

        }
        
    }
    
    func update(withFaceAnchor faceAnchor: ARFaceAnchor) {
        var bledShapes:[ARFaceAnchor.BlendShapeLocation:Any] = faceAnchor.blendShapes
        
        guard let mouthSmile = bledShapes[.mouthSmileLeft] as? Float else {return}
        guard let browInnerUp = bledShapes[.browInnerUp] as? Float else {return}

        print(mouthSmile)
        
        if mouthSmile > 0.5 || browInnerUp > 0.5{
            updatePlayer(state: .up)
            
        } else if mouthSmile < 0.05 || browInnerUp < 0.2{
            updatePlayer(state: .down)
            
        } else {
            updatePlayer(state: .neutral)
            
        }

    }

}
