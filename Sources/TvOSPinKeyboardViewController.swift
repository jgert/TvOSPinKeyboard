//
//  TvOSPinKeyboardViewController.swift
//  TvOSPinKeyboard
//
//  Created by David Cordero on 13.07.17.
//  Copyright © 2017 Zattoo. All rights reserved.
//

import Foundation
import Cartography
import FocusTvButton


private let defaultTitleFont: UIFont = .boldSystemFont(ofSize: 50)
private let defaultTitleColor: UIColor = .white
private let defaultSubtitleFont: UIFont = .systemFont(ofSize: 30)
private let defaultSubtitleColor: UIColor = .white
private let defaultLegalInfoFont: UIFont = .systemFont(ofSize: 30)
private let defaultLegalInfoColor: UIColor = .white
private let defaultPinFont: UIFont = .boldSystemFont(ofSize: 50)
private let defaultPinColor: UIColor = .black
private let defaultPinBackgroundColor: UIColor = .white
private let defaultNumpadButtons: [String] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
private let defaultNumpadFont: UIFont = .boldSystemFont(ofSize: 30)
private let defaultNumpadNormalTitleColor: UIColor = .white
private let defaultNumpadFocusedTitleColor: UIColor = .white
private let defaultNumpadFocusedBackgroundColor: UIColor = .gray
private let defaultNumpadNormalBackgroundColor: UIColor = .clear
private let defaultDeleteButtonFont: UIFont = .boldSystemFont(ofSize: 30)
private let defaultDeleteButtonTitle: String = "←"
private let defaultPinLength = 4
private let pinStackSpacing = CGFloat(30)
private let numpadButtonsStackSpacing = CGFloat(5)
private let numpadButtonsPadding = CGFloat(15)

open class TvOSPinKeyboardViewController: UIViewController {
    
    public var pinLength = defaultPinLength

    public weak var delegate: TvOSPinKeyboardViewDelegate?
    public var callsCancelCompletion = false
    
    public var backgroundView: UIView!
    
    public var titleFont = defaultTitleFont
    public var titleColor = defaultTitleColor
    
    public var subtitleFont = defaultSubtitleFont
    public var subtitleColor = defaultSubtitleColor

    public var legalInfoFont = defaultLegalInfoFont
    public var legalInfoColor = defaultLegalInfoColor
    
    public var pinFont = defaultPinFont
    public var pinColor = defaultPinColor
    public var pinBackgroundColor = defaultPinBackgroundColor
    
    public var numpadButtons = defaultNumpadButtons
    public var numpadFont = defaultNumpadFont
    
    public var deleteButtonTitle = defaultDeleteButtonTitle
    public var deleteButtonFont = defaultNumpadFont
    
    public var buttonsNormalTitleColor = defaultNumpadNormalTitleColor
    public var buttonsFocusedTitleColor = defaultNumpadFocusedTitleColor
    public var buttonsFocusedBackgroundColor = defaultNumpadFocusedBackgroundColor
    public var buttonsFocusedBackgroundEndColor: UIColor?
    public var buttonsNormalBackgroundColor = defaultNumpadNormalBackgroundColor
    public var buttonsNormalBackgroundEndColor: UIColor?
    
    private var subject: String?
    private var message: String?
    private var legalInfo: String?
    private var titleLabel: UILabel!
    private var subtitleLabel: UILabel!
    private var legalInfoLabel: UILabel!
    private var pinStack: UIStackView!
    private var numpadButtonsStack: UIStackView!
    private var deleteButton: FocusTvButton!
    private var menuTapGestureRecognizer: UITapGestureRecognizer?
    
    private var introducedPin: String = "" {
        didSet {
            guard let pinStackLabels = pinStack.arrangedSubviews as? [UILabel] else { return }
            for (index, pinLabel) in pinStackLabels.enumerated() {
                pinLabel.text = index < introducedPin.count ? "•" : nil
            }
            
            if introducedPin.count == pinLength {
                dismiss(animated: true, completion: {
                    self.delegate?.pinKeyboardDidEndEditing(pinCode: self.introducedPin)
                })
            }
        }
    }
    
    convenience public init(withTitle title: String, message: String, legalInfo: String? = nil) {
        self.init()
        
        self.subject = title
        self.message = message
        self.legalInfo = legalInfo
    }
    
    // MARK: - UIViewController
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if callsCancelCompletion {
            setUpGestureRecognizer()
        }
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if callsCancelCompletion, let menuTapGestureRecognizer = menuTapGestureRecognizer {
            view.removeGestureRecognizer(menuTapGestureRecognizer)
        }
    }
    
    // MARK: - Private
    
    private func setUpView() {
        setUpBackgroundView()
        setUpTitleLabel()
        setUpSubtitleLabel()
        setUpLegalInfoLabel()
        setUpPinStack()
        setUpNumpadButtonsStack()
        setUpDeleteButton()
        
        setUpContrainsts()
    }
    
    private func setUpBackgroundView() {
        if backgroundView == nil {
            let backgroundBlurEffectSyle = UIBlurEffect(style: .dark)
            backgroundView = UIVisualEffectView(effect: backgroundBlurEffectSyle)
        }
        view.addSubview(backgroundView)
    }
    
    private func setUpTitleLabel() {
        titleLabel = UILabel()
        titleLabel.text = subject ?? ""
        titleLabel.font = titleFont
        titleLabel.textColor = titleColor
        view.addSubview(titleLabel)
    }
    
    private func setUpSubtitleLabel() {
        subtitleLabel = UILabel()
        subtitleLabel.text = message ?? ""
        subtitleLabel.font = subtitleFont
        subtitleLabel.textColor = subtitleColor
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        view.addSubview(subtitleLabel)
    }

    private func setUpLegalInfoLabel() {
        legalInfoLabel = UILabel()
        legalInfoLabel.text = legalInfo ?? ""
        legalInfoLabel.font = legalInfoFont
        legalInfoLabel.textColor = legalInfoColor
        legalInfoLabel.textAlignment = .center
        legalInfoLabel.numberOfLines = 0
        view.addSubview(legalInfoLabel)
    }
    
    private func setUpPinStack() {
        pinStack = UIStackView()
        pinStack.distribution = .equalSpacing
        pinStack.axis = .horizontal
        pinStack.alignment = .fill
        pinStack.spacing = pinStackSpacing
        view.addSubview(pinStack)
        
        for _ in 0..<pinLength {
            let pinLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 100))
            pinLabel.layer.cornerRadius = 5
            pinLabel.clipsToBounds = true
            pinLabel.font = pinFont
            pinLabel.backgroundColor = pinBackgroundColor
            pinLabel.textColor = pinColor
            pinLabel.textAlignment = .center
            
            constrain(pinLabel) {
                pinLabel in
                pinLabel.width >= 120
                pinLabel.height >= 180
            }
            
            pinStack.addArrangedSubview(pinLabel)
        }
    }
    
    private func setUpNumpadButtonsStack() {
        numpadButtonsStack = UIStackView()
        numpadButtonsStack.distribution = .equalSpacing
        numpadButtonsStack.axis = .horizontal
        numpadButtonsStack.alignment = .fill
        numpadButtonsStack.spacing = numpadButtonsStackSpacing
        view.addSubview(numpadButtonsStack)
        
        numpadButtons.forEach {
            let button = numpadButton(withTitle: $0)
            button.addTarget(self, action: #selector(numPadButtonWasPressed), for: .primaryActionTriggered)
            
            button.contentEdgeInsets = UIEdgeInsets(top: numpadButtonsPadding,
                                                    left: numpadButtonsPadding,
                                                    bottom: numpadButtonsPadding,
                                                    right: numpadButtonsPadding)
            
            numpadButtonsStack.addArrangedSubview(button)
        }
    }
    
    private func setUpDeleteButton() {
        deleteButton = numpadButton(withTitle: deleteButtonTitle)
        deleteButton.accessibilityIdentifier = "PinKeyboard.Button.Delete"
        deleteButton.accessibilityLabel = "Delete"
        deleteButton.titleLabel?.font = deleteButtonFont
        
        deleteButton.sizeToFit()
        deleteButton.addTarget(self, action: #selector(deleteButtonWasPressed), for: .primaryActionTriggered)
        
        deleteButton.contentEdgeInsets = UIEdgeInsets(top: numpadButtonsPadding,
                                                      left: numpadButtonsPadding,
                                                      bottom: numpadButtonsPadding,
                                                      right: numpadButtonsPadding)
        
        numpadButtonsStack.addArrangedSubview(deleteButton)
    }
    
    private func numpadButton(withTitle title: String) -> FocusTvButton {
        let numpadButton = FocusTvButton()
        numpadButton.setTitle(title, for: .normal)
        numpadButton.accessibilityIdentifier = "PinKeyboard.Button.\(title)"
        numpadButton.sizeToFit()
        numpadButton.titleLabel?.font = numpadFont
        numpadButton.normalTitleColor = buttonsNormalTitleColor
        numpadButton.focusedTitleColor = buttonsFocusedTitleColor
        numpadButton.focusedBackgroundColor = buttonsFocusedBackgroundColor
        numpadButton.focusedBackgroundEndColor = buttonsFocusedBackgroundEndColor
        numpadButton.normalBackgroundColor = buttonsNormalBackgroundColor
        numpadButton.normalBackgroundEndColor = buttonsNormalBackgroundEndColor
    
        return numpadButton
    }
    
    private func setUpContrainsts() {
        constrain(backgroundView, view) {
            backgroundView, view in
            backgroundView.edges == view.edges
        }
        
        constrain(pinStack, view) {
            pinStack, view in
            pinStack.centerY == view.centerY
            pinStack.centerX == view.centerX
        }
        
        constrain(numpadButtonsStack, pinStack, view) {
            numpadButtonsStack, pinStack, view in
            numpadButtonsStack.top == pinStack.bottom + 111
            numpadButtonsStack.centerX == view.centerX
        }
        
        constrain(subtitleLabel, pinStack, view) {
            subtitleLabel, pinStack, view in
            subtitleLabel.bottom == pinStack.top - 75
            subtitleLabel.leading == view.leading + 100
            subtitleLabel.trailing == view.trailing - 100
        }
        
        constrain(titleLabel, subtitleLabel, view) {
            titleLabel, subtitleLabel, view in
            titleLabel.bottom == subtitleLabel.top - 18
            titleLabel.centerX == view.centerX
        }

        constrain(legalInfoLabel, pinStack, view) {
            legalInfoLabel, pinStack, view in
            pinStack.bottom == legalInfoLabel.top - 300
            legalInfoLabel.centerX == view.centerX
        }
    }

    private func setUpGestureRecognizer() {
        menuTapGestureRecognizer = UITapGestureRecognizer(target: self, action: .menuButtonWasPressed)
        menuTapGestureRecognizer?.allowedPressTypes = [NSNumber(integerLiteral: UIPress.PressType.menu.rawValue)]

        if let menuTapGestureRecognizer = menuTapGestureRecognizer {
            view.addGestureRecognizer(menuTapGestureRecognizer)
        }
    }
    
    @objc
    func numPadButtonWasPressed(sender: FocusTvButton) {
        guard introducedPin.count < pinLength else { return }
        guard let numPadValue = sender.titleLabel?.text else { return }
        introducedPin += numPadValue
    }
    
    @objc
    func deleteButtonWasPressed(sender: FocusTvButton) {
        introducedPin = String(introducedPin.dropLast())
    }

    @objc
    func menuButtonWasPressed() {
        dismiss(animated: true, completion: {
            [weak self] in
            self?.delegate?.pinKeyboardDidCancel()
        })
    }
}

private extension Selector {
    static let numPadButtonWasPressed = #selector(TvOSPinKeyboardViewController.numPadButtonWasPressed)
    static let deleteButtonWasPressed = #selector(TvOSPinKeyboardViewController.deleteButtonWasPressed)
    static let menuButtonWasPressed = #selector(TvOSPinKeyboardViewController.menuButtonWasPressed)
}
