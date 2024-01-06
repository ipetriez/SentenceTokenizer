//
//  MainViewModel.swift
//  SentenceTokenizer
//
//  Created by Sergey Petrosyan on 06.01.24.
//

import Foundation
import Combine

protocol MainViewModelDelegate {
    func outputText() -> AnyPublisher<String, Never>
    func update(inputText: String?)
}

final class MainViewModel {
    
    // MARK: — Private properties
    
    @Published private var tokenizedOutputText = ""
    
    // MARK: — Private methods
    
    private func createOutputText(from inputText: String) {
        tokenizedOutputText = inputText.uppercased()
    }
}

// MARK: — MainViewModelDelegate

extension MainViewModel: MainViewModelDelegate {
    func update(inputText: String?) {
        createOutputText(from: inputText ?? "")
    }
    
    func outputText() -> AnyPublisher<String, Never> {
        $tokenizedOutputText.eraseToAnyPublisher()
    }
}
