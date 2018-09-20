//
//  PanelNode.swift
//  ARSummoner
//
//  Created by kawaguchi kohei on 2018/09/21.
//  Copyright © 2018年 kawaguchi kohei. All rights reserved.
//

import SceneKit

class PanelNode: SCNNode {

    enum ImageType {
        case otaoA
        case ossan

        var image: UIImage {
            switch self {
            case .otaoA:
                return UIImage(named: "otao")!
            case .ossan:
                return UIImage(named: "otao")!
            }
        }
    }

    enum Size {
        static let height: CGFloat = 1.76
        static let width: CGFloat = 1.76  * (127 / 262) // アスペクト比
    }

    init(material: ImageType) {
        super.init()

        let panelNode = SCNNode(geometry: SCNBox(width: Size.width, height: Size.height, length: 0.001, chamferRadius: 0))

        let material_front = SCNMaterial()
        material_front.diffuse.contents = material.image
        let material_other = SCNMaterial()
        material_other.diffuse.contents = UIColor.white
        panelNode.geometry?.materials = [material_front, material_front, material_front, material_front, material_front, material_front]

        addChildNode(panelNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
