//
//  Plane.swift
//  ARPanelTest
//
//  Created by kawaguchi kohei on 2018/09/16.
//  Copyright © 2018年 kawaguchi kohei. All rights reserved.
//

import ARKit

extension UIColor {
    static var plane: UIColor {
        return UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 0.3)
    }
}

final class PlaneNode: SCNNode {
    init(anchor: ARPlaneAnchor) {
        super.init()
        geometry = SCNBox(width: CGFloat(anchor.extent.x),
                          height: 0.00000000001,
                          length: CGFloat(anchor.extent.z),
                          chamferRadius: 0)
        position = SCNVector3(anchor.center.x, 0, anchor.center.z)
        guard let strongGeometry = geometry else { assert(true); return }
        physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: strongGeometry, options: nil))
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "target")
        geometry?.firstMaterial = material
    }

    func update(anchor: ARPlaneAnchor) {
        guard let geometry = geometry as? SCNBox else { assert(true); return }
        let newWidth = CGFloat(anchor.extent.x)
        let newLength = CGFloat(anchor.extent.z)
        geometry.width = newWidth
        geometry.length = newLength
        position = SCNVector3(anchor.center.x, 0, anchor.center.z)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
