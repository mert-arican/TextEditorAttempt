//
//  AQuest.swift
//  Pg2
//
//  Created by Mert Arıcan on 23.08.2023.
//

import Foundation

struct InPlaceRule {
    let type: TokenType
    let predicate: (String) -> Bool
    let overrides: [TokenType]
}

struct LookForwardRule {
    let type: TokenType
    let predicate: ((String) -> Bool)
    let overrides: [TokenType]
    let exit: [ForwardRuleExit]
    let collection: Set<String>
    let completion: (()->())?
    
    init(type: TokenType, overrides: [TokenType], exit: [ForwardRuleExit], collection: Set<String>, completion: (()->())?=nil) {
        self.type = type
        self.predicate = { str in collection.contains(str) }
        self.overrides = overrides
        self.exit = exit
        self.collection = collection
        self.completion = completion
    }
}

struct LookBackwardRule {
    let type: TokenType
    let predicate: (String) -> Bool
    let overrides: [TokenType]
    let exit: [ForwardRuleExit]
}

//typealias TokenType = String

enum ForwardRuleExit: Hashable, Equatable {
    case newline
    case whitespace
    case followUp
    case onType(String)
    case onDelimiter(String)
}
