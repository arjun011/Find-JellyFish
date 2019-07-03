//
//  ViewController.swift
//  Hit jelly
//
//  Created by JiniGuruiOS on 03/07/19.
//  Copyright © 2019 jiniguru. All rights reserved.
//

import UIKit
import ARKit
import Each
class ViewController: UIViewController {
    
    private let timer = Each(1).seconds
    /// countDown is use in count second
    private var countDown = 10
    /// Reset button outlet
    @IBOutlet weak var IBReset: UIButton!
    /// Play button outlet
    @IBOutlet weak var IBPlay: UIButton!
    /// Timer label outlet
    @IBOutlet weak var IBlblTimer: UILabel!
    /// ARSCNView outlet
    @IBOutlet weak var scenView: ARSCNView!
    /// Configure ARWorldTracking Configuration
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Configure ARSCNView
        self.scenView.debugOptions = [ARSCNDebugOptions.showWorldOrigin,ARSCNDebugOptions.showFeaturePoints]
        self.scenView.session.run(configuration)
        
        /// Add TapGesture on scnView for identify user clicks
        let tapGuestureReco = UITapGestureRecognizer.init(target: self, action: #selector(handleTap))
        self.scenView.addGestureRecognizer(tapGuestureReco)

    }
    
    /// Add Jellyfish on scnView
    func addNode() {
        
        let xRandomPosition = self.randomNumbers(firstNum: -1, secondNum: 1)
        let yRandomPosition = self.randomNumbers(firstNum: -1, secondNum: 1)
        let zRandomPosition = self.randomNumbers(firstNum: -1, secondNum: 1)
        
        
        let jellyfishScene = SCNScene.init(named: "arts.scnassets/Jellyfish.scn")
        let jellyFishNode = jellyfishScene?.rootNode.childNode(withName: "JellyFish", recursively: false)
        jellyFishNode?.position = SCNVector3.init(xRandomPosition, yRandomPosition, zRandomPosition)
        self.scenView.scene.rootNode.addChildNode(jellyFishNode!)
        
//        let boxNode = SCNNode.init(geometry: SCNBox.init(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 5))
//        boxNode.position = SCNVector3.init(0, 0, -1)
//        boxNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
//        self.scenView.scene.rootNode.addChildNode(boxNode)
    }
    
    @objc func handleTap(sender:UITapGestureRecognizer) {
        guard let sceneViewTapedon = sender.view as? SCNView else {
            return
        }
        let touchCordinate = sender.location(in: sceneViewTapedon)
        let hitTest = sceneViewTapedon.hitTest(touchCordinate)
        if hitTest.isEmpty {
            print("didn't touch anything")
        }else {
            let result = hitTest.first!
            let _ = result.node.geometry
            
          // if Time is finished user can't tap anything
           if self.countDown > 0 {
                if result.node.animationKeys.isEmpty {
                    SCNTransaction.begin()
                    self.animationNode(node: result.node)
                    SCNTransaction.completionBlock = {
                        result.node.removeFromParentNode()
                        self.addNode()
                        self.resetTimer()
                    }
                    SCNTransaction.commit()
                }
            }
        }
    }
    
    /// Set spin animation on requested node
    ///
    /// - Parameter node: SCNNode
    func animationNode(node:SCNNode) {
        let spin = CABasicAnimation(keyPath: "position")
        spin.fromValue = node.presentation.position
        spin.toValue = SCNVector3(node.presentation.position.x - 1,node.presentation.position.y - 1,node.presentation.position.z - 1)
        spin.duration = 0.07
        spin.repeatCount = 5
        spin.autoreverses = true
        node.addAnimation(spin, forKey: "position")
    }
    
    /// Find random postion
    ///
    /// - Parameters:
    ///   - firstNum: Minimum number
    ///   - secondNum: Maximum number
    /// - Returns: Float value between two parameters
    func randomNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    /// Set Timer
    func setTimer() {
        self.timer.perform { () -> NextStep in
            self.countDown -= 1
            if self.countDown == 0 {
                self.IBlblTimer.text = "You lose"
                return .stop
            }
            self.IBlblTimer.text = String(self.countDown)
            return .continue
        }
    }
    
    /// Reset Timer
    func resetTimer(){
        self.countDown = 10
        self.IBlblTimer.text = String(self.countDown)
    }
}

//MARK: - Button action methods -
extension ViewController {
    @IBAction func btnReset(_ sender: Any) {
        self.timer.stop()
        self.resetTimer()
        self.IBPlay.isEnabled = true
        self.scenView.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
    }
    
    @IBAction func btnPlay(_ sender: Any) {
        self.IBPlay.isEnabled = false
        self.addNode()
        self.setTimer()
    }
}
