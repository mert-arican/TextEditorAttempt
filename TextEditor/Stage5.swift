//
//  Stage5.swift
//  Pg2
//
//  Created by Mert Arıcan on 23.08.2023.
//

import Foundation

class Stage5 {
    
    static let numberRule = InPlaceRule(
        type: "number"
        ,predicate: { string in
            string.isNumber
        },
        overrides: [
            "plainText"
        ]
    )
    
    static let keywordRule = InPlaceRule(
        type: "keyword",
        predicate: { string in
            keywords.contains(string)
        },
        overrides: [
            "plainText"
        ]
    )
    
    static let delimiterRule = InPlaceRule(
        type: "delimiter",
        predicate: { string in
            delimiters.contains(string)
        },
        overrides: [
            "plainText"
        ]
    )
    
    static let propertyWrapperRule = InPlaceRule(
        type: "propertyWrapper",
        predicate: { string in
            string.first == "@"
        },
        overrides: [
            "plainText"
        ]
    )
    
    static let otherTypeNameRule = InPlaceRule(
        type: "otherTypeName",
        predicate: { string in
            string.first?.isUppercase == true
        },
        overrides: [
            "plainText"
        ]
    )
    
    static let typeDeclarationRule = LookForwardRule(
        type: "typeDeclaration",
        overrides: [otherTypeNameRule.type],
        exit: [.onType("delimiter")],
        collection: ["struct", "class", "protocol", "actor"]
    )
    
    static let functionDeclarationRule = LookForwardRule(
        type: "functionDeclaration",
        overrides: ["plainText", "otherTypeName", "typeName"],
        exit: [.onType("delimiter")],
        collection: ["func"]
    )
    
    static let variableDeclarationRule = LookForwardRule(
        type: "variableDeclaration",
        overrides: ["plainText", "otherTypeName", "typeName"],
        exit: [.newline, .onType("delimiter")],
        collection: ["let", "var"]
    )
    
    static let singleLineCommentRule = LookForwardRule(
        type: "singleLineComment",
        overrides: ["all"],
        exit: [.newline],
        collection: ["//"]
    )
    
    static let singleLineCommentRule2 = LookForwardRule(
        type: "singleLineComment2",
        overrides: ["all"],
        exit: [.newline],
        collection: ["///"]
    )
    
    static let multilineCommentRule = LookForwardRule(
        type: "multilineComment",
        overrides: ["all"],
        exit: [.onDelimiter("*/")],
        collection: ["/*"]
        // allows nesting ???
    )
    
    static let stringLiteralRule = LookForwardRule(
        type: "stringLiteral",
        overrides: ["all"],
        exit: [.newline, .onDelimiter("\"")],
        collection: ["\""]
        // swallows delimiter ???
    )
    
    static let rawStringLiteralRule = LookForwardRule(
        type: "rawStringLiteral",
        overrides: ["all"],
        exit: [.newline, .onDelimiter("\"#")],
        collection: ["#\""]
    )
    
    static let multilineStringRule = LookForwardRule(
        type: "multilineStringLiteral",
        overrides: ["all"],
        exit: [.onDelimiter("\"\"\"")],
        collection: ["\"\"\""]
    )
    
    static let rawMultilineStringLiteral = LookForwardRule(
        type: "rawMultilineStringLiteral",
        overrides: ["all"],
        exit: [.onDelimiter("\"\"\"#")],
        collection: ["#\"\"\""]
    )
    
    // raw string arbitrariness???
    
    class FlagLand {
        var dict: [TokenType : Bool] = [
            "functionDeclaration" : false,
            "variableDeclaration" : false,
            "singleLineComment" : false,
            "multilineComment" : false,
            "stringLiteral" : false,
            "rawStringLiteral" : false,
            "multilineStringLiteral": false,
            "rawMultilineStringLiteral" : false
        ]
        
        var lastFlag: TokenType?
        
        var globalVar: Set<String> = []
        
        func reset() {
            for key in dict.keys {
                dict[key] = false
            }
        }
    }
    
    private static let exits = [
        functionDeclarationRule.type : functionDeclarationRule,
        variableDeclarationRule.type : variableDeclarationRule,
        singleLineCommentRule.type : singleLineCommentRule,
        multilineCommentRule.type : multilineCommentRule,
        stringLiteralRule.type : stringLiteralRule,
        rawStringLiteralRule.type : rawStringLiteralRule,
        multilineStringRule.type : multilineStringRule,
        rawMultilineStringLiteral.type : multilineStringRule
    ]
    
    private lazy var userDeclaredTypeRule = InPlaceRule(
        type: "userType",
        predicate: { str in
            self.flagLand.globalVar.contains(str)
        },
        overrides: ["plainText", "otherTypeName"]
    )
    
    let flagLand = FlagLand()
    
    func match(_ string: String) -> Token {
        var token = Token(type: "plainText", value: string)
        
        for rule in [Self.numberRule, Self.propertyWrapperRule, Self.delimiterRule, Self.keywordRule, userDeclaredTypeRule, Self.otherTypeNameRule] {
            if rule.predicate(string) {
                if rule.overrides.first == "all" || rule.overrides.contains(token.type) {
                    token.type = rule.type
                }
            }
        }
        
        applyLookForwardRules(&token)

        adjustLookForwardFlags(token.value)
        return token
    }
    
    func applyLookForwardRules(_ token: inout Token) {
        for key in flagLand.dict.keys {
            if flagLand.dict[key] == true {
                let rule = Self.exits[key]!
                for exit in rule.exit {
                    switch exit {
                    case .whitespace:
                        // if it invalidates itself when faced with a whitespace token
                        if token.type == "whitespace" {
                            flagLand.dict[key] = false; return
                        }
                    case .newline:
                        // if becomes invalid when faced with a newline token
                        if token.value.contains("\n") {
                            flagLand.dict[key] = false; return
                        }
                        
                    case .followUp:
                        // if it invalidates after first successfull match...
                        if rule.overrides.first == "all" || rule.overrides.contains(token.type) {
                            token.type = key
//                            flagLand.globalVar.insert(token.value)
                            flagLand.dict[key] = false; return
                        }
                    case .onType(let type):
                        if rule.overrides.first == "all" || rule.overrides.contains(token.type) {
                            token.type = key
                        }
                        if token.type == type {
                            flagLand.dict[key] = false; return
                        }
                    case .onDelimiter(let closingDelimiter):
                        if closingDelimiter == token.value {
                            if rule.collection.contains(closingDelimiter) {
                                flagLand.lastFlag = rule.type
                            }
                            flagLand.dict[key] = false; return
                        }
                        // !!! bON LAST !!!
                    }
                    if rule.overrides.first == "all" || rule.overrides.contains(token.type) {
                        token.type = key
                    }
                }
            }
        }
    }
    
    func adjustLookForwardFlags(_ value: String) {
        if !flagLand.dict.values.contains(true) {
            for (key, rule) in Self.exits {
                if rule.predicate(value) {
                    if flagLand.lastFlag == key {
                        flagLand.lastFlag = nil
                        return
                    }
                    else {
                        flagLand.dict[key] = true
                    }
                    return
                }
            }
        }
    }
    
    static let delimiters = [
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
    
//    static func getTable(_ delimiters: [String]) -> [String: [String]] {
//        var table = [String: [String]]()
//        for delimiter in delimiters {
//            let startIndex = delimiter.startIndex
//            for i in 0..<delimiter.count {
//                let index = delimiter.index(startIndex, offsetBy: i)
//                let nextIndex = delimiter.index(after: index)
//                if nextIndex != delimiter.endIndex {
//                    table.add(String(delimiter[nextIndex]), forKey: String(delimiter[startIndex...index]))
//                } else {
//                    table.add("", forKey: delimiter)
//                }
//            }
//        }
//        return table
//    }
    
    static let keywords: Set<String> = [
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

typealias TokenType = String
