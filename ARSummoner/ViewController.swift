//
//  ViewController.swift
//  ARPanelTest
//
//  Created by kawaguchi kohei on 2018/09/16.
//  Copyright © 2018年 kawaguchi kohei. All rights reserved.
//

import ARKit

final class ViewController: UIViewController, ARSCNViewDelegate{
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

    var oldInstructionViewY:CGFloat = 0.0

    @IBOutlet var sceneView: ARSCNView!
    private var planes: [ARPlaneAnchor: PlaneNode] = [:]

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

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Place content only for anchors found by plane detection.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let plane = PlaneNode(anchor: planeAnchor)
        node.addChildNode(plane)
        planes[planeAnchor] = plane
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
        let tapPoint = recognizer.location(in: sceneView)
        let results = sceneView.hitTest(tapPoint, types: .existingPlaneUsingExtent)

        guard let hitResult = results.first, let hitPlaneAnchor = hitResult.anchor as? ARPlaneAnchor, let planeNode = planes[hitPlaneAnchor] else { return }

        let panelNode = PanelNode(material: .otaoA)

        let audioSouce = SCNAudioSource(named: "summon.wav")
        panelNode.runAction(SCNAction.playAudio(audioSouce!, waitForCompletion: true))
        panelNode.position.y += Float(PanelNode.Size.height / 2)
        planeNode.addChildNode(panelNode)
    }
}
