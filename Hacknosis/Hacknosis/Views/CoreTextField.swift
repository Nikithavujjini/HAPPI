//
//  CoreTextField.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 16/10/23.
//

import SwiftUI

struct CoreTextField: UIViewRepresentable {
    
    //MARK: - Variables
    @Binding var text: String
    @Binding public var isFirstResponder: Bool
    let autoEnableReturnKey: Bool
    let textColor:Color
    let placeholderText:String
    let placeholderColor:Color
    let keyboardType:UIKeyboardType
    let returnKeyType: UIReturnKeyType
    let autoCapitalizationType:UITextAutocapitalizationType
    let autoCorrectionType:UITextAutocorrectionType
    let accessibilityIdentifier:String

    let onCommit:(() -> Void)?
    let onEditingChanged: (() -> Void)?
    
    //MARK: - Initialization
    init(text:Binding<String>, isFirstResponder:Binding<Bool> = .constant(false), autoEnableReturnKey:Bool = false, textColor:Color = .black, placeholderText:String = "",accessibilityIdentifier:String = "", placeholderColor:Color = .gray, keyboardType:UIKeyboardType = .default, returnKeyType:UIReturnKeyType = .default, autoCapitalizationType:UITextAutocapitalizationType = .none, autoCorrectionType: UITextAutocorrectionType = .default, onCommit:(() -> Void)? = nil, onEditingChanged: (() -> Void)? = nil){
        self._text = text
        self._isFirstResponder = isFirstResponder
        self.autoEnableReturnKey = autoEnableReturnKey
        self.textColor = textColor
        self.placeholderText = placeholderText
        self.accessibilityIdentifier = accessibilityIdentifier
        self.placeholderColor = placeholderColor
        self.keyboardType = keyboardType
        self.returnKeyType = returnKeyType
        self.autoCapitalizationType = autoCapitalizationType
        self.autoCorrectionType = autoCorrectionType
        self.onCommit = onCommit
        self.onEditingChanged = onEditingChanged
    }

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textField.keyboardType = self.keyboardType
        textField.returnKeyType = self.returnKeyType
        textField.enablesReturnKeyAutomatically = autoEnableReturnKey
        textField.textColor = UIColor(textColor)
        textField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [NSAttributedString.Key.foregroundColor: UIColor(placeholderColor)])
        textField.delegate = context.coordinator
        textField.autocapitalizationType = autoCapitalizationType
        textField.autocorrectionType = .no
        textField.setAccessibility(fontSize: .body)
        textField.tintColor = UIColor(textColor)
        textField.text = text

        if UIAccessibility.isVoiceOverRunning {
            textField.accessibilityElementsHidden = true
        }
        textField.accessibilityIdentifier = accessibilityIdentifier
        textField.addTarget(context.coordinator, action: #selector(context.coordinator.textChanged), for: .editingChanged)

        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if text.isEmpty == true {
            uiView.text = ""
        } else if text.isNotEmpty && uiView.text?.isEmpty == true {
            uiView.text = text
        }
        
        if uiView.window != nil, !uiView.isFirstResponder {
            //This triggers attribute cycle if not dispatched
            DispatchQueue.main.async {
                switch isFirstResponder {
                case true: uiView.becomeFirstResponder()
                case false: uiView.resignFirstResponder()
                }
            }
        }
    }
    
    func makeCoordinator() -> CoreTextFieldCoordinator {
        CoreTextFieldCoordinator(self, isFirstResponder: $isFirstResponder)
    }
}

//MARK: - Extension - UITextFieldDelegate
class CoreTextFieldCoordinator: NSObject, UITextFieldDelegate {
    
    var coreTextField: CoreTextField
    @Binding var isFirstResponder: Bool
    
    init(_ textField: CoreTextField, isFirstResponder:Binding<Bool>) {
        self.coreTextField = textField
        self._isFirstResponder = isFirstResponder
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        coreTextField.onCommit?()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        if !textField.isFirstResponder {
//            isFirstResponder = true
//        }
        DispatchQueue.main.async {
            self.coreTextField.onEditingChanged?()
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        coreTextField.text = textField.text ?? ""
        isFirstResponder = false
        return true
    }
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if let text = textField.text, let rangeExp = Range(range, in: text) {
//            coreTextField.text = text.replacingCharacters(in: rangeExp, with: string)
//        }
//        return true
//    }
    
    @objc func textChanged(_ sender: UITextField) {
        guard let text = sender.text else { return }
        coreTextField.text = text
    }
}


extension UIContentSizeCategoryAdjusting {

    func setAccessibility(fontSize : UIFont.TextStyle) {
        switch self {
        case let self as UILabel:
            self.font = .preferredFont(forTextStyle: fontSize)
        case let self as UITextView:
            self.font = .preferredFont(forTextStyle: fontSize)
        case let self as UITextField:
            self.font = .preferredFont(forTextStyle: fontSize)
        default:
            break
        }
        adjustsFontForContentSizeCategory = true
    }
}

extension Collection {
    var isNotEmpty: Bool {
        return !self.isEmpty
    }
}
