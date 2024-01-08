//
//  ViewController.swift
//  SentenceTokenizer
//
//  Created by Sergey Petrosyan on 06.01.24.
//

import UIKit
import Combine

class MainViewController: UIViewController {

    // MARK: — IBOutlets
    
    @IBOutlet private weak var outputLabel: UILabel!
    @IBOutlet private weak var inputTextField: UITextField!
    
    // MARK: — Private properties
    
    private var mainVM =  MainViewModel()
    private var keyboardIsVisible = false
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: — Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        let textPublisher = NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: inputTextField).compactMap { ($0.object as? UITextField)?.text }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // MARK: — Subscriptions
        
        mainVM.outputText()
            .compactMap { $0 }
            .assign(to: \.text, on: outputLabel)
            .store(in: &subscriptions)
        
        textPublisher
            .sink { [weak self] text in
                self?.mainVM.update(inputText: text)
            }
            .store(in: &subscriptions)
    }
    
    // MARK: — Actions
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let initialKeyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue,
              keyboardFrame != initialKeyboardFrame,
              !keyboardIsVisible else {
            return
        }
        
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        let offset: CGFloat = 20
        
        UIView.animate(withDuration: 0.3) {
            self.view.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.origin.y - keyboardHeight + offset)
        } completion: { _ in
            self.keyboardIsVisible = true
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.view.transform = .identity
        } completion: { _ in
            self.keyboardIsVisible = false
        }
    }
    
    @objc private func dismissKeyboard() {
        _ = inputTextField.resignFirstResponder()
    }
}
