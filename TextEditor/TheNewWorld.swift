//
//  TheNewWorld.swift
//  Pg2
//
//  Created by Mert Arıcan on 20.08.2023.
//

import Foundation

struct TheNewWorld {
    // MARK: TODO: misses the last one...
    
    func tokenize(code: String) -> ([NSRange], [Token]) {
        stage5.flagLand.reset()
        var allTokens = [Token]()
        var allRange = [NSRange]()
        let END_INDEX_OF_THE_CODE = (((code.endIndex)))
        var currentIndex = code.startIndex
        var current_token_start_index: String.Index? // only used for non-delimiter tokens
        var text_end_index = END_INDEX_OF_THE_CODE
        var lastIndex = 0
        while currentIndex != END_INDEX_OF_THE_CODE {
            if code[currentIndex].isWhitespace {
                if let startIndex = current_token_start_index {
//                    allTokens.append(.init(type: .plainTextType, value: String(code[startIndex...text_end_index])))
                    allTokens.append(match(String(code[startIndex...text_end_index])))
                    allRange.append(NSMakeRange(lastIndex, allTokens.last!.value.count))
                    lastIndex += allRange.last!.length
                    current_token_start_index = nil
                }
                text_end_index = code.index(after: currentIndex)
                if text_end_index < END_INDEX_OF_THE_CODE {
                    while code[text_end_index].isWhitespace {
                        text_end_index = code.index(after: text_end_index)
                        if text_end_index == END_INDEX_OF_THE_CODE { break }
                    }
                }
                allTokens.append(.init(type: "whitespace", value: String(code[currentIndex..<text_end_index])))
                allRange.append(NSMakeRange(lastIndex, allTokens.last!.value.count))
                lastIndex += allRange.last!.length
                if allTokens.last?.value.contains("\n") == true { _ = match("\n") }
                else { _ = match(" ") }
                currentIndex = text_end_index
                continue
            }
            
            // if char is delimiter...
            if table[String(code[currentIndex...currentIndex])] != nil {
                if let startIndex = current_token_start_index {
//                    allTokens.append(.init(type: .plainTextType, value: String(code[startIndex...text_end_index])))
                    allTokens.append(match(String(code[startIndex...text_end_index])))
                    allRange.append(NSMakeRange(lastIndex, allTokens.last!.value.count))
                    lastIndex += allRange.last!.length
                    current_token_start_index = nil
                }
                text_end_index = currentIndex
                
                while let a = table[String(code[currentIndex...text_end_index])] {
//                    var tokenAdded = false
                    let nextIndex = code.index(after: text_end_index)
                    guard nextIndex != END_INDEX_OF_THE_CODE else {
                        allTokens.append(match(String(code[currentIndex...text_end_index])))
                        allRange.append(NSMakeRange(lastIndex, allTokens.last!.value.count))
                        lastIndex += allRange.last!.length
                        currentIndex = nextIndex ;
                        break
                    } // Return ...
                    let nextChar = String(code[nextIndex])
                    let count = allTokens.count
                    if a.contains(nextChar) {
                        text_end_index = nextIndex
                    } else if a.contains("") {
//                        let delimiter = Token(type: .delimiterType, value: String(code[currentIndex...text_end_index]))
                        allTokens.append(match(String(code[currentIndex...text_end_index])))
                        allRange.append(NSMakeRange(lastIndex, allTokens.last!.value.count))
                        lastIndex += allRange.last!.length
//                        if delimiter.value == "(" { flagLand.parenStack += 1 }
//                        else if delimiter.value == ")" { flagLand.parenStack -= 1 }
//                        else if delimiter.value == "{" { flagLand.curlyStack += 1}
//                        else if delimiter.value == "}" { flagLand.curlyStack += 1 }
//                        tokenAdded = true
                    } else {
//                        allTokens.append(.init(type: .plainTextType, value: String(code[currentIndex...text_end_index])))
                        allTokens.append(match(String(code[currentIndex...text_end_index])))
                        allRange.append(NSMakeRange(lastIndex, allTokens.last!.value.count))
                        lastIndex += allRange.last!.length
//                        tokenAdded = true
                    }
                    
                    if allTokens.count != count {
                        text_end_index = code.index(after: text_end_index)
                        guard text_end_index != END_INDEX_OF_THE_CODE else {
                            allTokens.append(match(String(code[currentIndex...text_end_index])))
                            allRange.append(NSMakeRange(lastIndex, allTokens.last!.value.count))
                            lastIndex += allRange.last!.length
                            currentIndex = nextIndex;
                            break
                        }
                        currentIndex = text_end_index
                    }
                }
            } else {
                if current_token_start_index == nil {
                    current_token_start_index = currentIndex
                }
                text_end_index = currentIndex
                currentIndex = code.index(after: currentIndex)
                if currentIndex == END_INDEX_OF_THE_CODE {
                    allTokens.append(match(String(code[current_token_start_index!..<currentIndex])))
                    allRange.append(NSMakeRange(lastIndex, allTokens.last!.value.count))
                    lastIndex += allRange.last!.length
                }
            }
        }
        return (allRange, allTokens)
    }
    
    var stage5: Stage5 = .init()
    
    private func match(_ string: String) -> Token {
//        var type: Token.TokenType = .plainTextType
//        var token = Token(type: "plainText", value: string)
//        return token
        return stage5.match(string)
    }
    
    struct InPlaceRule {
        let type: TokenType
        let predicate: (String) -> Bool
        let overrides: [TokenType]
        let collection: [String]
    }
    
    class FlagLand {
        var stringFlag = false
        var commentFlag = false
        var propertyFlag = false
        var variableDeclarationFlag = false
        var typeDeclarationFlag = false
        
        var stringJust = false
        var commentJust = false
        
        func resetAfterNewLine() {
            propertyFlag = false
            stringFlag = false
            commentFlag = false
            variableDeclarationFlag = false
            typeDeclarationFlag = false
        }
         
        var globalVar: Set<String> = []
    }
    
    let flagLand = FlagLand()
    
    private func applyLookAfter(_ token: inout Token) {
        if flagLand.stringFlag {
            token.type = "stringLiteral"
            if token.value == "\"" { flagLand.stringFlag = false ; flagLand.stringJust = true }
        }
        else if flagLand.commentFlag {
            token.type = "comment"
            if token.value.contains("\n") {
                flagLand.commentFlag = false
            }
        }
        else if flagLand.propertyFlag {
            if token.type != "whitespace" || token.value.contains("\n") {
                flagLand.propertyFlag = false
            }
            if token.type == "plainText" { token.type = "propertyAccess" }
        }
        else if flagLand.typeDeclarationFlag {
            if token.type != "whitespace" || token.value.contains("\n") {
                flagLand.typeDeclarationFlag = false
            }
            if token.type == "plainText" { token.type = "type" }
        }
    }
    
    func adjustLookNextFlags(_ value: String) {
        if !(flagLand.commentFlag || flagLand.propertyFlag || flagLand.stringFlag || flagLand.typeDeclarationFlag) {
            if value == "\"" { flagLand.stringFlag = !flagLand.stringJust; flagLand.stringJust = false; return }
            if value == "//" { flagLand.commentFlag = true; return }
            if value == "var" { flagLand.typeDeclarationFlag = true; return }
            if value == "let" { flagLand.typeDeclarationFlag = true; return }
            if value == "." { flagLand.propertyFlag = true; return; }
        }
    }
    
    enum Match {
        case all
        case some([String])
        case none
    }
    
    init() {
        self.table = Self.getTable(delimiters)
    }
    
    var table: [String: [String]]
    
    var delimiters = [
        "/*",
        "*/",
        "//",
        "///",
        
        "#\"\"\"", // raw multiline string opening
        "\"\"\"#", // raw multiline string closing
        "#\"", // raw string opening
        "\"#", // raw string closing
        "\\#(", // raw string interpolation
        
        "\"\"\"", // multiline string opening - closing
        "\"", // string opening - closing
        "\\(", // string interpolation opening
        
        "\\", // escape character
        "\\#", // raw escape character
        
        "\\\\",
        
        #"\""#,
        
        "...",
        "..<",
        "..>",
        
        "->",
        "??",
        
        "&&",
        "||",
        
        "|",
        "&",
        "^",
        "~",
        "<<",
        ">>",
        "#",
        "{",
        "}",
        "[",
        "]",
        "(",
        ")",
        "<",
        ">",
        ".",
        ",",
        ";",
        ":",
        
        "+",
        "-",
        "/",
        "*",
        "%",
        "=",
        
        "?",
        "!"
    ]
    
    static func getTable(_ delimiters: [String]) -> [String: [String]] {
        var table = [String: [String]]()
        for delimiter in delimiters {
            let startIndex = delimiter.startIndex
            for i in 0..<delimiter.count {
                let index = delimiter.index(startIndex, offsetBy: i)
                let nextIndex = delimiter.index(after: index)
                if nextIndex != delimiter.endIndex {
                    table.add(String(delimiter[nextIndex]), forKey: String(delimiter[startIndex...index]))
                } else {
                    table.add("", forKey: delimiter)
                }
            }
        }
        return table
    }
    
    let keywords: Set<String> = [
        "struct",
        "class",
        "enum",
        "actor",
        "let",
        "var",
        "func",
        "associatedtype",
        "deinit",
        "extension",
        "fileprivate",
        "import",
        "init",
        "inout",
        "internal",
        "open",
        "any",
        "operator",
        "private",
        "precedencegroup",
        "protocol",
        "public",
        "rethrows",
        "static",
        "subscript",
        "typealias",
        "break",
        "case",
        "catch",
        "continue",
        "default",
        "defer",
        "do",
        "else",
        "fallthrough",
        "for",
        "guard",
        "if",
        "in",
        "repeat",
        "return",
        "throw",
        "switch",
        "where",
        "while",
        "Any",
        "as",
        "await",
        "catch",
        "false",
        "is",
        "nil",
        "rethrows",
        "self",
        "Self",
        "super",
        "throw",
        "throws",
        "true",
        "try",
        "associativity",
        "convenience",
        "didSet",
        "dynamic",
        "final",
        "get",
        "indirect",
        "infix",
        "lazy",
        "left",
        "mutating",
        "none",
        "nonmutating",
        "optional",
        "override",
        "postfix",
        "precedence",
        "prefix",
        "Protocol",
        "required",
        "right",
        "set",
        "some",
        "Type",
        "unowned",
        "weak",
        "willSet"
    ]
}

extension String {
    var isNumber: Bool { Int(self) != nil }
}
