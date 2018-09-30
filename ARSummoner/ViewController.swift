//
//  ViewController.swift
//  ARPanelTest
//
//  Created by kawaguchi kohei on 2018/09/16.
//  Copyright © 2018年 kawaguchi kohei. All rights reserved.
//

import ARKit

typealias Planes = [ARPlaneAnchor: PlaneNode]

final class ViewController: UIViewController{
    private lazy var tapPlaneGestuer: UITapGestureRecognizer = {
        let gestuer = UITapGestureRecognizer(target: self, action: #selector(didTappedScreen(_:)))
        gestuer.delegate = self
        return gestuer
    }()

    private lazy var instructionView: InteractiveTransitionView = {
        let height = self.view.frame.height * 0.9
        let positionY = self.view.frame.height - self.view.frame.height * 0.2
        let view = InteractiveTransitionView(frame: CGRect(x: 0, y: positionY, width: self.view.frame.width, height: height))
        view.backgroundColor = .black

        return view
    }()
    
    private lazy var cameraButton: UIButton = {
        let y = self.view.frame.height * 0.85
        let button = UIButton(frame: CGRect(x: 0, y: y, width: 70, height: 70))
        button.center.x = self.view.center.x
        button.setBackgroundImage(UIImage(named: "cameraButton"), for: .normal)
        button.alpha = 0.0
        button.isEnabled = false
        button.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
        return button
    }()
    
    // State Manager
    private struct Phase {
        enum Phase: Int, CaseIterable {
            case detection
            case summons
            case takePhoto
        }
        
        static var action: [Phase: ()->()] = [:]
        
        static var current: Phase = .detection
        
        static func next() {
            let allPhase = Phase.allCases
            current = allPhase[(current.rawValue + 1) % allPhase.count]
            action[current]?()
        }
        
        static func setAction(for phase: Phase, action: @escaping () -> ()) {
            self.action[phase] = action
            
            // if initial state, run
            phase.rawValue == 0 ? action() : ()
        }
    }

    @IBOutlet var sceneView: ARSCNView!
    private var planes: Planes = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView.delegate = self
        sceneView.scene = SCNScene()
        #if DEBUG
        sceneView.debugOptions = [.showWorldOrigin, .showFeaturePoints]
        //sceneView.showsStatistics = true
        #endif

        view.addGestureRecognizer(tapPlaneGestuer)
        view.addSubview(cameraButton)
        view.addSubview(instructionView)
        
        Phase.setAction(for: .detection) { [weak self] in
            self?.cameraButton.alpha = 0.0
            self?.cameraButton.isEnabled = false
            self?.planes.forEach {
                let material = SCNMaterial()
                material.diffuse.contents = UIImage(named: "target")
                $0.value.geometry?.firstMaterial = material
            }
            DispatchQueue.main.async {
                let contents: DisplayContents = (title: "召喚場所を選定", description: "端末を平な場所で横に振って\n召喚する領域<<ゲート>>をみつけよう.\nいい場所にゲートが出来たらタップ！")
                self?.instructionView.setDisplayContents(contents)
                self?.instructionView.translate(to: .closed)
            }
        }
        
        Phase.setAction(for: .summons) { [weak self] in
            DispatchQueue.main.async {
                let contents: DisplayContents = (title: "召喚を開始する", description: "地面に現れた召喚ゲートをタップして\n召喚を開始してみよう！！")
                self?.instructionView.setDisplayContents(contents)
            }
        }
        
        Phase.setAction(for: .takePhoto) { [weak self] in
            self?.cameraButton.alpha = 1.0
            self?.cameraButton.isEnabled = true
            DispatchQueue.main.async {
                let contents: DisplayContents = (title: "さあ，写真を撮ろう", description: "召喚成功を祝福し，その瞬間をフレームに残そう\n撮影した写真はSNSでシェア出来るよ．")
                self?.instructionView.setDisplayContents(contents)
                self?.instructionView.translate(to: .exit)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    @objc private func takePhoto() {
        planes.forEach {
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.clear
            $0.value.geometry?.firstMaterial = material
        }
        
        UIImageWriteToSavedPhotosAlbum(sceneView.snapshot(),
                                       self,
                                       #selector(self.didFinishSavingImage(_:didFinishSavingWithError:contextInfo:)),
                                       nil)
        
        DispatchQueue.main.async {
            let whiteOutView = UIView(frame: self.view.frame)
            whiteOutView.backgroundColor = .white
            whiteOutView.alpha = 0.75
            self.view.addSubview(whiteOutView)
            AudioServicesPlaySystemSound(1108)
            
            UIView.animate(withDuration: 0.15, animations: {
                whiteOutView.alpha = 0.0
            }){ _ in
                whiteOutView.removeFromSuperview()
            }
        }
        
        Phase.next()
    }
    
    func evokeTap() {
//        DispatchQueue.main.async { [weak self] in
//            guard let self = self else {return}
//            let image = UIImage(named: "tapIcon")!
//            let imageView = UIImageView(image: image)
//            imageView.contentMode = .scaleAspectFit
//            imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
//            imageView.center = self.view.center
//            self.view.addSubview(imageView)
//
//            UIView.animate(withDuration: 0.6, delay: 0.2, options: [.curveEaseInOut], animations: {
//                imageView.center.y -= 30
//                imageView.center.x += 10
//            }) { _ in
//                UIView.animate(withDuration: 0.4, animations: {
//                    imageView.alpha = 0.0
//                }){ _ in
//                    imageView.removeFromSuperview()
//                }
//            }
//        }
    }
    
    @objc func didFinishSavingImage(_ image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutableRawPointer) {
        
        // 結果によって出すアラートを変更する
        var title = "保存完了！"
        var message = "カメラロールに保存しました\nSNSでシェアしますか？？"
        
        if error != nil {
            title = "エラー"
            message = "保存に失敗しました"
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if Phase.current != .detection { return }
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let plane = PlaneNode(anchor: planeAnchor)
        node.addChildNode(plane)
        planes[planeAnchor] = plane
        
        evokeTap()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {fatalError()}
        let willRenderedPlane = planes[planeAnchor]
        willRenderedPlane?.update(anchor: planeAnchor)
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    @objc func didTappedScreen(_ recognizer: UITapGestureRecognizer) {
        //if Phase.current == .takePhoto { return }
        switch Phase.current {
        case .detection:
            if planes.count > 0 {
                Phase.next()
            }
        case .summons:
            let tapPoint = recognizer.location(in: sceneView)
            let results = sceneView.hitTest(tapPoint, types: .existingPlaneUsingExtent)
            guard let hitResult = results.first, let hitPlaneAnchor = hitResult.anchor as? ARPlaneAnchor, let planeNode = planes[hitPlaneAnchor] else { return }
            let panelNode = PanelFactory.create()
            planeNode.addChildNode(panelNode)
            Phase.next()
        default:
            return
        }
    }
}
