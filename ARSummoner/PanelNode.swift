//
//  PanelNode.swift
//  ARSummoner
//
//  Created by kawaguchi kohei on 2018/09/21.
//  Copyright © 2018年 kawaguchi kohei. All rights reserved.
//

import SceneKit

enum PanelType: CaseIterable {
    case otaoA
    case otaoB
    case zozoOssan
    case kirin

    var image: UIImage {
        switch self {
        case .otaoA:
            return UIImage(named: "otaoA")!
        case .otaoB:
            return UIImage(named: "otaoB")!
        case .zozoOssan:
            return UIImage(named: "zozoOssan")!
        case .kirin:
            return UIImage(named: "kirin")!
        }
    }

    var size: CGSize {
        switch self {
        case .otaoA:
            return CGSize(width: 1.72  * (576 / 1983), height: 1.72)
        case .otaoB:
            return CGSize(width: 1.68  * (606 / 1314), height: 1.68)
        case .zozoOssan:
            return CGSize(width: 1.72  * (558 / 1984), height: 1.72)
        case .kirin:
            return CGSize(width: 2.5  * (1536 / 2301), height: 2.5)
        }
    }

    var resultSound: SCNAudioSource {
        switch self {
        case .otaoA:
            return SCNAudioSource(named: "summon.wav")!
        case .otaoB:
            return SCNAudioSource(named: "summon.wav")!
        default:
            return SCNAudioSource(named: "hello.m4a")!
        }
    }
}

final class PanelNode: SCNNode {
    init(material: PanelType) {
        super.init()
        let panelNode = SCNNode(geometry: SCNBox(width: material.size.width, height: material.size.height, length: 0.001, chamferRadius: 0))

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
