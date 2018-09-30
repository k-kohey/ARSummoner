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
        view.addSubview(instructionView)
        
        Phase.setAction(for: .detection) { [weak self] in
            DispatchQueue.main.async {
                let contents: DisplayContents = (title: "召喚場所を選定", description: "端末を平な場所で横に振って\n召喚する領域<<ゲート>>をみつけよう")
                self?.instructionView.setDisplayContents(contents)
                
            }
        }
        
        Phase.setAction(for: .summons) { [weak self] in
            DispatchQueue.main.async {
                let contents: DisplayContents = (title: "召喚を開始する", description: "地面に現れた召喚ゲートをタップして\n召喚を開始してみよう！！")
                self?.instructionView.setDisplayContents(contents)
            }
        }
        
        Phase.setAction(for: .takePhoto) { [weak self] in
            DispatchQueue.main.async {
                let contents: DisplayContents = (title: "さあ，写真を撮ろう", description: "召喚成功を祝福し，その瞬間をフレームに残そう\n撮影した写真はSNSでシェア出来るよ．")
                self?.instructionView.setDisplayContents(contents)
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
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if Phase.current != .detection { return }
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let plane = PlaneNode(anchor: planeAnchor)
        node.addChildNode(plane)
        planes[planeAnchor] = plane
        Phase.next()
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
        if Phase.current != .summons { return }
        let tapPoint = recognizer.location(in: sceneView)
        let results = sceneView.hitTest(tapPoint, types: .existingPlaneUsingExtent)

        guard let hitResult = results.first, let hitPlaneAnchor = hitResult.anchor as? ARPlaneAnchor, let planeNode = planes[hitPlaneAnchor] else { return }

        let panelNode = PanelFactory.create()
        planeNode.addChildNode(panelNode)
        Phase.next()
    }
}
