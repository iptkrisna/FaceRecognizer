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
    var timer: Timer!
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
    @IBOutlet weak var askSmileLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        session = ARSession()
        session.delegate = self
        
//        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(counterProcess), userInfo: nil, repeats: true)
        view.backgroundColor = UIColor(patternImage: UIImage(named: "calm")!)
        
        batteryIndicator.precentCharged = 32
        batteryIndicator.animatedReveal = true
        
        calmNight.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        calmNight.alpha = CGFloat(batteryIndicator.precentCharged/100)
        
        precentLabel.text = "\(Int(batteryIndicator.precentCharged))%"
        precentLabel.layer.zPosition = 1
        
        imageView.transform = CGAffineTransform(rotationAngle: 45/360)
        askSmileLabel.layer.masksToBounds = true
        askSmileLabel.layer.cornerRadius = 10
        askSmileLabel.alpha = 1
        askSmileLabel.isHidden = true
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        animateText()
        
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
    
    @objc func counterProcess() {
        UIView.transition(with: askSmileLabel,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: { self.askSmileLabel.text = "Smile!!!" },
                          completion: nil)
        
    }
    
    func animateText() {
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.repeat, .autoreverse], animations: {
            self.askSmileLabel.alpha = 0
        }, completion: nil)
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
            direction = -0.2
        case .neutral:
            direction = 0
            
        }

        if batteryIndicator.precentCharged + direction <= 100 && batteryIndicator.precentCharged + direction >= 0 {
            batteryIndicator.precentCharged += direction
            precentLabel.text = "\(Int(batteryIndicator.precentCharged + 0.5))%"
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
            askSmileLabel.isHidden = true

        } else {
            if imageView.image != UIImage(named: "sadd") {
                UIView.transition(with: imageView,
                                  duration: 1,
                                  options: .transitionCrossDissolve,
                                  animations: { self.imageView.image = UIImage(named: "sadd") },
                                  completion: nil)
                
            }
            askSmileLabel.isHidden = false

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
