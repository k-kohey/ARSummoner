//
//  PanelFactory.swift
//  ARSummoner
//
//  Created by kawaguchi kohei on 2018/09/22.
//  Copyright © 2018年 kawaguchi kohei. All rights reserved.
//

import SceneKit

enum PanelFactory {
    static func create(on position: SCNVector3) -> PanelNode{
        let random = arc4random_uniform(UInt32(99))
        let material = distribution[Int(random)]
        let panelNode = PanelNode(material: material)
        let audioSouce = material.resultSound
        panelNode.runAction(SCNAction.playAudio(audioSouce, waitForCompletion: true))
        panelNode.position = position
        panelNode.position.y += Float(material.size.height / 2)
        return panelNode
    }

    private static var distribution: [PanelType] = {
        var distribution: [PanelType] = []
        for i in 1...100 {
            if (1...30).contains(i) {
                distribution.append(.otaoA)
            }
            else if (31...70).contains(i) {
                distribution.append(.otaoB)
            }
            else if (71...85).contains(i) {
                distribution.append(.kirin)
            }
            else if (86...100).contains(i) {
                distribution.append(.zozoOssan)
            }
        }
        return distribution
    }()
}
