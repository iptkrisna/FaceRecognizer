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
    var batteryCharged: Int = 0
    let borderColor = UIColor.white
    enum PlayerState:String {
        case neutral
        case up
        case down
        
    }
    
    @IBOutlet weak var precentLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var borderImage: UIView!
    @IBOutlet weak var calmNight: UIView!
    @IBOutlet weak var askSmileLabel: UILabel!
    @IBOutlet weak var backgroundPrecent: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        session = ARSession()
        session.delegate = self
        
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(animateText), userInfo: nil, repeats: true)
        view.backgroundColor = UIColor(patternImage: UIImage(named: "calm")!)
        
        batteryCharged = 32
        
        calmNight.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        calmNight.alpha = CGFloat(batteryCharged/100)
        
        precentLabel.text = "\(Int(batteryCharged))%"
        precentLabel.layer.zPosition = 1
        backgroundPrecent.layer.cornerRadius = backgroundPrecent.frame.width/2
        backgroundPrecent.layer.shadowColor = UIColor.white.cgColor
        backgroundPrecent.layer.shadowOpacity = 1
        backgroundPrecent.layer.shadowOffset = .zero
        backgroundPrecent.layer.shadowRadius = CGFloat(batteryCharged/3)
        
        imageView.transform = CGAffineTransform(rotationAngle: 45/360)
        askSmileLabel.layer.masksToBounds = true
        askSmileLabel.layer.cornerRadius = 10
        askSmileLabel.layer.borderColor = UIColor.red.cgColor
        askSmileLabel.layer.borderWidth = 5
        askSmileLabel.textColor = UIColor.red
        askSmileLabel.alpha = 0.1
        askSmileLabel.isHidden = true
        
        borderImage.layer.masksToBounds = true
        borderImage.backgroundColor = UIColor.clear
        borderImage.layer.cornerRadius = borderImage.frame.width/2
        borderImage.layer.shadowColor = UIColor.white.cgColor
        borderImage.layer.shadowOpacity = 1
        borderImage.layer.shadowOffset = .zero
        borderImage.layer.shadowRadius = CGFloat(batteryCharged/3)
        
        print(CGFloat.pi)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard ARFaceTrackingConfiguration.isSupported else {print("iPhone X required"); return}
        let configuration = ARFaceTrackingConfiguration()
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        animateText()
//
//    }
    
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
    
    @objc func askSmile(state: Bool) {
        UIView.transition(with: askSmileLabel,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: { self.askSmileLabel.isHidden = state },
                          completion: nil)

    }
    
    @objc func animateText() {
        UIView.animate(withDuration: 1,
                       delay: 0.5,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: [.repeat, .autoreverse],
                       animations: {
                        self.imageView.transform = CGAffineTransform(translationX: 0, y: 10)
                        self.askSmileLabel.alpha = 1
                        self.askSmileLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi/12)
                        
        },
                       completion: nil)
        
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
        
        var direction: Int = 0
        
        switch state {
        case .up:
            direction = 1
        case .down:
            direction = -1
        case .neutral:
            direction = 0
            
        }

        if batteryCharged <= 99 && batteryCharged + direction >= 0 {
            batteryCharged += direction
            precentLabel.text = "\(batteryCharged)%"
            borderImage.layer.shadowRadius = CGFloat(Double(batteryCharged)/3)
            calmNight.alpha = CGFloat(Double(batteryCharged)/100)
            print(batteryCharged)
            
        } else if batteryCharged > 99 {
            timer.invalidate()
            askSmileLabel.alpha = 0
            session.pause()
            performSegue(withIdentifier: "playGame", sender: self)

        }
        
        if batteryCharged >= 20 && state == .up {
            if imageView.image != UIImage(named: "smilee") {
                UIView.transition(with: imageView,
                                  duration: 1,
                                  options: .transitionCrossDissolve,
                                  animations: { self.imageView.image = UIImage(named: "smilee") },
                                  completion: nil)
                
            }

        } else if batteryCharged >= 20 && state == .down {
            if imageView.image != UIImage(named: "flat") {
                UIView.transition(with: imageView,
                                  duration: 1,
                                  options: .transitionCrossDissolve,
                                  animations: { self.imageView.image = UIImage(named: "flat") },
                                  completion: nil)
                
            }

        } else if batteryCharged < 20 {
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

        print(mouthSmile)
        
        if mouthSmile > 0.5 {
            updatePlayer(state: .up)
            askSmile(state: true)
            
        } else if mouthSmile < 0.05 {
            updatePlayer(state: .down)
            askSmile(state: false)
            
        } else {
            updatePlayer(state: .neutral)
            
        }

    }

}
