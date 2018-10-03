//
//  PanelFactory.swift
//  ARSummoner
//
//  Created by kawaguchi kohei on 2018/09/22.
//  Copyright © 2018年 kawaguchi kohei. All rights reserved.
//

import SceneKit

enum PanelFactory {
    static func prepare() {
        // あらかじめ生成してprivateなプロパティに持たせとく
        // createはcloneしたものを返す．
    }

    static func create(on position: SCNVector3) -> PanelNode{
        let allCases = PanelType.allCases
        let random = arc4random_uniform(UInt32(allCases.count))
        let material = allCases[Int(random)]
        let panelNode = PanelNode(material: material)
        let audioSouce = material.resultSound
        panelNode.runAction(SCNAction.playAudio(audioSouce, waitForCompletion: true))
        panelNode.position = position
        panelNode.position.y = Float(material.size.height / 2)
        return panelNode
    }

    private static var distribution: [PanelType] {
        return [.otaoA, .zozoOssan]
    }
}
