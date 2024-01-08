//
//  MainViewModel.swift
//  SentenceTokenizer
//
//  Created by Sergey Petrosyan on 06.01.24.
//

import Foundation
import Combine
import NaturalLanguage

protocol MainViewModelDelegate {
    func outputText() -> AnyPublisher<String, Never>
    func update(inputText: String?)
}

final class MainViewModel {
    
    // MARK: — Private properties
    
    @Published private var tokenizedOutputText = ""
    
    // MARK: — Private methods
    
    private func createOutputText(from inputText: String) {
        guard !inputText.isEmpty, let language = detectLanguage(sentence: inputText) else {
            tokenizedOutputText = inputText
            return
        }
        
        let newSentenceTriggerWords: [String]
        var tokenizedWords: [(word: String, tag: NLTag?)] = []
        
        switch language {
        case .english:
            newSentenceTriggerWords = ["IF", "If", "if", "AND", "And", "and"]
        case .spanish:
            newSentenceTriggerWords = ["SI", "Si", "si", "Y", "y"]
        case .german:
            newSentenceTriggerWords = ["ODER", "Oder", "oder", "UND", "Und", "und"]
        case .russian:
            newSentenceTriggerWords = ["ЕСЛИ", "Если", "если", "И", "и"]
        default:
            newSentenceTriggerWords = []
        }
        
        let tokenizer = NLTagger(tagSchemes: [.tokenType])
        tokenizer.string = inputText
        var mutableText = ""
        
        tokenizer.enumerateTags(in: inputText.startIndex ..< inputText.endIndex, unit: .word, scheme: .tokenType) { tag, tokenRange in
            let word = String(inputText[tokenRange])
            if !tokenizedWords.isEmpty {
                if newSentenceTriggerWords.contains(word) {
                    tokenizedWords.removeLast()
                    
                    if tokenizedWords.last?.tag == .punctuation {
                        tokenizedWords.removeLast()
                    }
                    
                    tokenizedWords.append(("\n — \(word.capitalized)", tag))
                } else {
                    tokenizedWords.append((word, tag))
                }
            } else {
                tokenizedWords.append((" ", .whitespace))
                tokenizedWords.append(("—", .punctuation))
                tokenizedWords.append((" ", .whitespace))
                tokenizedWords.append((word, tag))
            }
            return true
        }
               
        tokenizedWords.forEach { token in
            mutableText += token.word
        }
        
        tokenizedOutputText = mutableText
    }
    
    private func detectLanguage(sentence: String) -> NLLanguage? {
        let tagger = NLTagger(tagSchemes: [.language])
        tagger.string = sentence
        let detectedLanguage = tagger.dominantLanguage
        return detectedLanguage
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
