//
//  ViewController.swift
//  ARPanelTest
//
//  Created by kawaguchi kohei on 2018/09/16.
//  Copyright © 2018年 kawaguchi kohei. All rights reserved.
//

import ARKit

// State Manager
struct Phase {
    enum Phase: Int, CaseIterable {
        case detection
        case summons
        case takePhoto
    }
    
    static var action: [Phase: ()->()] = [:]
    
    static var current: Phase = .detection {
        didSet {
            action[current]?()
        }
    }
    
    static func next() {
        let allPhase = Phase.allCases
        current = allPhase[(current.rawValue + 1) % allPhase.count]
    }
    
    static func setAction(for phase: Phase, action: @escaping () -> ()) {
        self.action[phase] = action
        
        // if initial state, run
        phase.rawValue == 0 ? action() : ()
    }
}

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
    
    private lazy var topArrowButton: UIButton = {
        let width: CGFloat = 35.0
        let y = self.view.frame.height * 0.85
        let button = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - width - 45.0, y: y + width / 2.0, width: width, height: width))
        button.setBackgroundImage(UIImage(named: "topArrow")!, for: .normal)
        button.addTarget(self, action: #selector(didTappedTopArrow), for: .touchUpInside)
        button.alpha = 0.0
        button.isEnabled = false
        return button
    }()

    @IBOutlet var sceneView: ARSCNView!
    private var planes: Planes = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        instructionView.resetButton.addTarget(self, action: #selector(restPlanes), for: .touchUpInside)
        
        uiviewSetup: do {
            view.addGestureRecognizer(tapPlaneGestuer)
            view.addSubview(cameraButton)
            view.addSubview(topArrowButton)
            view.addSubview(instructionView)
        }
        arViewSetup: do {
            sceneView.delegate = self
            sceneView.scene = SCNScene()
            #if DEBUG
            sceneView.debugOptions = [.showWorldOrigin, .showFeaturePoints]
            //sceneView.showsStatistics = true
            #endif
        }
        
        
        let visibleAction = { [weak self] in
            self?.cameraButton.alpha = 1.0
            self?.cameraButton.isEnabled = true
            self?.topArrowButton.alpha = 0.7
            self?.topArrowButton.isEnabled = true
        }
        
        
        let invisibleAction = { [weak self] in
            self?.cameraButton.alpha = 0.0
            self?.cameraButton.isEnabled = false
            self?.topArrowButton.alpha = 0.0
            self?.topArrowButton.isEnabled = false
        }
        
        Phase.setAction(for: .detection) { [weak self] in
            invisibleAction()
            DispatchQueue.main.async {
                let contents: DisplayContents = (title: "1. 召喚場所を選定", description: "端末を平な場所で横に振って\n召喚する領域<<ゲート>>をみつけよう.\nいい場所にゲートが出来たらタップ！")
                self?.instructionView.setDisplayContents(contents)
                self?.instructionView.translate(to: .closed)
            }
        }
        
        Phase.setAction(for: .summons) { [weak self] in
            DispatchQueue.main.async {
                let contents: DisplayContents = (title: "2. 召喚を開始する", description: "地面に現れた召喚ゲートをタップして\n召喚を開始してみよう！！")
                self?.instructionView.setDisplayContents(contents)
            }
        }
        
        Phase.setAction(for: .takePhoto) { [weak self] in
            visibleAction()
            DispatchQueue.main.async {
                let contents: DisplayContents = (title: "3. さあ，写真を撮ろう", description: "召喚成功を祝福し，その瞬間をフレームに残そう\n撮影した写真はSNSでシェア出来るよ．")
                self?.instructionView.setDisplayContents(contents)
                self?.instructionView.translate(to: .exit)
            }
        }
        
        instructionView.didExit = visibleAction
        instructionView.didOpened = invisibleAction
        instructionView.didClosed = invisibleAction
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
                Phase.current == .takePhoto ? Phase.next() : ()
            }
        }
        
        planes.forEach {
            let material = SCNMaterial()
            material.diffuse.contents = UIImage(named: "target")
            $0.value.geometry?.firstMaterial = material
        }
    }
    
    func evokeTap() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            let image = UIImage(named: "tapIcon")!
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            imageView.center = self.view.center
            self.view.addSubview(imageView)

            UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseInOut], animations: {
                imageView.center.y -= 30
                imageView.center.x += 10
            }) { _ in
                UIView.animate(withDuration: 0.4, animations: {
                    imageView.alpha = 0.0
                }){ _ in
                    imageView.removeFromSuperview()
                }
            }
        }
    }
    
    @objc func didFinishSavingImage(_ image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutableRawPointer) {
        let alertController = UIAlertController()
        var title = "保存完了！"
        var message = "カメラロールに保存しました\nSNSでシェアしますか？？"
        
        if error != nil {
            title = "エラー"
            message = "保存に失敗しました"
        }
        else {
            alertController.addAction(UIAlertAction(title: "シェアする", style: .default, handler: { [weak self]_ in
                let activityVC = UIActivityViewController(activityItems: ["大峠なう #AR_Otao", image], applicationActivities: nil)
                let excludedActivityTypes: [UIActivity.ActivityType] = []
                activityVC.excludedActivityTypes = excludedActivityTypes
                
                self?.present(activityVC, animated: true, completion: nil)
            }))
        }
        
        alertController.title = title
        alertController.message = message
        alertController.addAction(UIAlertAction(title: "閉じる", style: .destructive, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func didTappedTopArrow() {
        instructionView.translate(to: .opened)
    }
    
    @objc func restPlanes() {
        sceneView.scene.rootNode.childNodes.forEach { $0.removeFromParentNode() }
        planes.removeAll()
        Phase.current = .detection
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
        if Phase.current != .detection {return}
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
            guard let hitResult = results.first else { return }
            let panelPosition = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
            let panelNode = PanelFactory.create(on: panelPosition)
            sceneView.scene.rootNode.addChildNode(panelNode)
            Phase.next()
        default:
            return
        }
    }
}
