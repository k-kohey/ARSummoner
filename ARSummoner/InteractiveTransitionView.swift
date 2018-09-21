//
//  InteractiveTransitionView.swift
//  ARSummoner
//
//  Created by kawaguchi kohei on 2018/09/21.
//  Copyright © 2018年 kawaguchi kohei. All rights reserved.
//

import UIKit

final class InteractiveTransitionView: UIView, UIGestureRecognizerDelegate {
    private enum State {
        case opened
        case opening
        case closing
        case closed
    }

    private enum AlphaRange {
        static let min: CGFloat = 0.4
        static let max: CGFloat = 0.9
    }

    private var previousOffset: CGFloat = 0
    private var state: State = .closed

    private lazy var tapHandleGesturer: UITapGestureRecognizer = {
        let gestuer = UITapGestureRecognizer(target: self, action: #selector(didTappedHandle(_:)))
        gestuer.delegate = self
        return gestuer
    }()

    private lazy var panHandleGestuer: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(didPaneddHandle(_:)))
        gesture.delegate = self
        return gesture
    }()


    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addGestureRecognizer(tapHandleGesturer)
        addGestureRecognizer(panHandleGestuer)

        alpha = AlphaRange.min
        layer.cornerRadius = 17.0
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }


    @objc func didTappedHandle(_ recognizer: UITapGestureRecognizer) {
        translate()
    }

    @objc func didPaneddHandle(_ recognizer: UIPanGestureRecognizer) {
        guard let superview = superview else {return}
        let offset = recognizer.translation(in: self).y
        switch recognizer.state {
        case .began:
            previousOffset = offset
        case .changed:
            let move = offset - previousOffset
            previousOffset = offset

            let previousState = state
            state = offset > 0 ? .closing : .opening
            if !(previousState == .opened && state == .opening) && !(previousState == .closed && state == .closing){
                transform = transform.translatedBy(x: 0, y: move)
                // alpha 0.6 ~~ 0.9 を 0.0 ~~ superview.frame.height にマッピングしたい
                alpha -= move / superview.frame.height
            }
        default:
            break
        }


        if frame.origin.y > superview.frame.height * 0.35 && state == .closing {
            translate()
        }
        else if frame.origin.y < superview.frame.height * 0.65 && state == .opening {
            translate()
        }
    }

    private func translate() {
        guard let superview = superview else {return}
        switch state {
        case .closed, .opening:
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
                var frame = self.frame
                frame.origin.y = (superview.frame.height) * 0.1
                self.frame = frame
                self.alpha = AlphaRange.max
                self.state = .opened
            })
        case .closing, .opened:
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
                var frame = self.self.frame
                frame.origin.y = (superview.frame.height) * 0.8
                self.self.frame = frame
                self.alpha = AlphaRange.min
                self.state = .closed
            })
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
