//
//  ViewController.swift
//  ARPanelTest
//
//  Created by kawaguchi kohei on 2018/09/16.
//  Copyright © 2018年 kawaguchi kohei. All rights reserved.
//

import ARKit

final class ViewController: UIViewController, ARSCNViewDelegate, UIGestureRecognizerDelegate {
    lazy var tapGestuer: UITapGestureRecognizer = {
        let gestuer = UITapGestureRecognizer(target: self, action: #selector(didTappedScreen(_:)))
        gestuer.delegate = self
        return gestuer
    }()

    @IBOutlet var sceneView: ARSCNView!
    var planes: [ARPlaneAnchor: PlaneNode] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the view's delegate
        sceneView.delegate = self

        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true

        // Set the scene to the view
        sceneView.scene = SCNScene()

        view.addGestureRecognizer(tapGestuer)

        #if DEBUG
        sceneView.debugOptions = [.showWorldOrigin, .showFeaturePoints]
        #endif
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Pause the view's session
        sceneView.session.pause()
    }

    @objc func didTappedScreen(_ recognizer: UITapGestureRecognizer) {
        // sceneView上のタップ箇所を取得
        let tapPoint = recognizer.location(in: sceneView)

        // scneView上の位置を取得
        let results = sceneView.hitTest(tapPoint, types: .existingPlaneUsingExtent)

        guard let hitResult = results.first, let hitPlaneAnchor = hitResult.anchor as? ARPlaneAnchor, let planeNode = planes[hitPlaneAnchor] else { return }
        // 箱を生成
        let panelNode = PanelNode(material: .otaoA)

        let audioSouce = SCNAudioSource(named: "summon.wav")
        panelNode.runAction(SCNAction.playAudio(audioSouce!, waitForCompletion: true))

        // sceneView上のタップ座標のどこに箱を出現させるかを指定
        panelNode.position.y += Float(PanelNode.Size.height / 2)
        // ノードを追加
        planeNode.addChildNode(panelNode)
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
