//
//  HandleView.swift
//  ARSummoner
//
//  Created by kawaguchi kohei on 2018/09/22.
//  Copyright © 2018年 kawaguchi kohei. All rights reserved.
//

import UIKit

class HandleView: UIView {
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 96, height: 6))
        layer.cornerRadius = 2.5
        backgroundColor = .lightGray
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
