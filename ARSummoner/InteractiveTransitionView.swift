//
//  InteractiveTransitionView.swift
//  ARSummoner
//
//  Created by kawaguchi kohei on 2018/09/21.
//  Copyright © 2018年 kawaguchi kohei. All rights reserved.
//

import UIKit
import SnapKit

typealias DisplayContents = (title: String, description: String)

final class InteractiveTransitionView: UIView, UIGestureRecognizerDelegate {
    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 25, y: 35, width: frame.width, height: 24))
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.text = "召喚場所を選定"
        labels.append(label)
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = -1
        label.frame = CGRect(x: 25, y: 65,
                             width: frame.width, height: 40)

        let LineSpaceStyle = NSMutableParagraphStyle()
        LineSpaceStyle.lineSpacing = CGFloat(1.6)
        let lineSpaceAttr = [NSAttributedString.Key.paragraphStyle: LineSpaceStyle]
        label.text = "端末を平な場所で横に振って\n召喚する領域をみつけよう"
        label.attributedText = NSMutableAttributedString(string: label.text!, attributes: lineSpaceAttr)
        labels.append(label)
        return label
    }()
    
    private lazy var toDetectionButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .red
        return button
    }()
    
    private lazy var toSummonButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    private lazy var toPhotoButton: UIButton = {
        let button = UIButton()
        return button
    }()

    private var labels: [UILabel] = []
    private var buttons: [UIButton] = []

    enum State {
        case opened
        case opening
        case closing
        case closed
        case exit
    }

    private enum AlphaRange {
        static let min: CGFloat = 0.4
        static let max: CGFloat = 1.0
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

    private lazy var handleView: HandleView = {
        let view = HandleView()
        view.center = center
        view.frame.origin.y = 10.0
        return view

    }()
    
    var didOpened: ()->() = {}
    var didClosed: ()->() = {}
    var didExit: ()->() = {}


    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addGestureRecognizer(tapHandleGesturer)
        addGestureRecognizer(panHandleGestuer)

        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(handleView)
        
        addSubview(toDetectionButton)

        alpha = AlphaRange.min
        layer.cornerRadius = 17.0
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }


    @objc private func didTappedHandle(_ recognizer: UITapGestureRecognizer) {
        switch state {
        case .opened, .closing:
            translate(to: .closed)
        case .opening, .closed:
            translate(to: .opened)
        default: break
        }
    }

    @objc private func didPaneddHandle(_ recognizer: UIPanGestureRecognizer) {
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
            
            if previousState == .closed && state == .closing {
                state = .exit
                translate(to: .exit)
            }
            else if !(previousState == .opened && state == .opening) && !(previousState == .closed && state == .closing){
                transform = transform.translatedBy(x: 0, y: move)
                alpha -= move / superview.frame.height * 1.2
            }
        default:
            break
        }


        if frame.origin.y > superview.frame.height * 0.25 && state == .closing {
            translate(to: .closed)
        }
        else if frame.origin.y < superview.frame.height * 0.65 && state == .opening {
            translate(to: .opened)
        }
    }

    func translate(to state: State) {
        guard let superview = superview else {return}
        tapHandleGesturer.isEnabled = false
        var frame = self.frame
        switch state {
        case .opened:
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {[weak self]  in
                guard let self = self else {return}
                frame.origin.y = (superview.frame.height) * 0.1
                self.frame = frame
                self.alpha = AlphaRange.max
                self.backgroundColor = .white
                self.labels.forEach { $0.textColor = .black }
                self.state = .opened
                self.didOpened()
            }){ _ in
                self.tapHandleGesturer.isEnabled = true
            }
        case .closed:
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {[weak self]  in
                guard let self = self else {return}
                frame.origin.y = (superview.frame.height) * 0.8
                self.frame = frame
                self.alpha = AlphaRange.min
                self.backgroundColor = .black
                self.labels.forEach { $0.textColor = .white }
                self.state = .closed
                self.didClosed()
            }){ _ in
                self.tapHandleGesturer.isEnabled = true
            }
        
        case .exit:
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: { [weak self]  in
                guard let self = self else {return}
                frame.origin.y = UIScreen.main.bounds.height
                self.frame = frame
                self.alpha = AlphaRange.min
                self.backgroundColor = .black
                self.labels.forEach { $0.textColor = .white }
                self.state = .exit
                self.didExit()
            }){ _ in
                self.tapHandleGesturer.isEnabled = true
            }
        default:
            break
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setDisplayContents(_ contents: DisplayContents) {
        titleLabel.text = contents.title
        descriptionLabel.text = contents.description
    }
}
