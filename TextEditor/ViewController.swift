//
//  ViewController.swift
//  TextEditor
//
//  Created by Mert Arıcan on 20.08.2023.
//

import Cocoa
import AppKit

class ViewController: NSViewController, NSTextStorageDelegate, NSTextViewDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    var highlighter = TheNewWorld()
    
//    func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
////        Range(<#T##range: NSRange##NSRange#>, in: <#T##StringProtocol#>)
////        textView?.textContainer?.textView.str
//    }
    
//    func textDidBeginEditing(_ notification: Notification) {
//        let glyphRange = self.textView?.layoutManager?.glyphRange(forBoundingRectWithoutAdditionalLayout: self.scrollView.documentVisibleRect, in: self.textView!.textContainer!)
//        if let glyphRange = glyphRange {
//            print(glyphRange, "rrang")
////            let editedRange = textView?.layoutManager?.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
////            print(editedRange)
//        }
//    }
    
    func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        var start = CFAbsoluteTimeGetCurrent()
        let a = highlighter.tokenize(code: textStorage.string)
        var diff = CFAbsoluteTimeGetCurrent() - start
        
        start = CFAbsoluteTimeGetCurrent()
        textStorage.removeAttribute(.foregroundColor, range: NSMakeRange(0, textStorage.string.count))
        for (index, range) in a.0.enumerated() {
            textStorage.addAttribute(.foregroundColor, value: getColor(for: a.1[index].type), range: range)
        }
        diff = CFAbsoluteTimeGetCurrent() - start
        print(diff, "2")
    }
    
//    override func keyUp(with event: NSEvent) {
//        if event.characters == "{" {
//            print("add }")
//            let a = (2, "4")
//            if a == (for: 2, at: "4") {
//                print("IT IS EQUAL")
//            }
////            event.{
//            NSResponder.insertText(self)("{")
//        }
//
//    }
    
    override func keyDown(with event: NSEvent) {
        print("o")
    }
//    override func doCommand(by selector: Selector) {
//        if selector == #selector(NSResponder.inse) {
//            let a = self.view.window?.currentEvent;
//            if a?.characters == "{" {
//                NSResponder.insertText(self)("}")
//            }
//        }
//    }
    private var textView:NSTextView?
//    override func insertText(_ insertString: Any) {
//        super.insertText(insertString)
//        let string = insertString as! String
//        if string.count != 1 { return }
//        var firstChar = string.first
//        
//        switch (firstChar) {
//            case "(":
//                super.insertText(")")
//            case "[":
//                super.insertText("]")
//            case "{":
//                super.insertText("}")
//            default:
//                return;
//        }
//        
//    }
    
//    func textView(_ view: NSTextView, writablePasteboardTypesFor cell: NSTextAttachmentCellProtocol, at charIndex: Int) -> [NSPasteboard.PasteboardType] {
//
//    }
    var scrollView: NSScrollView!
    
    private func setupTextView() {
        let scrollView = NSTextView.scrollableTextView()
        self.scrollView = scrollView
//        scrollView.documentView = CodeEditorView(frame: .init(origin: scrollView.bounds.origin, size: .init(width: 400, height: 400)))
        textView = scrollView.documentView as? NSTextView
        textView?.font = .monospacedSystemFont(ofSize: 12.0, weight: .regular)
        textView?.textStorage?.foregroundColor = .white
        textView?.textColor = .white
        textView?.textStorage?.delegate = self
        textView?.isEditable = true
        textView?.allowsUndo = true
        textView?.delegate = self
//        scrollView.verticalRulerView = LineNumberRulerView(textView: textView!)
//        textView?.lnv_setUpLineNumberView()
//        textView?.textStorage?.
//      MARK: IMPORTANT!!!  textView?.isAutomaticTextCompletionEnabled
        view.addSubview(scrollView)
        scrollView.hasVerticalRuler = true
        scrollView.rulersVisible = true
        scrollView.verticalRulerView?.ruleThickness = 60.0
        scrollView.translatesAutoresizingMaskIntoConstraints = false

                let leading = NSLayoutConstraint(item: scrollView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0.0)
                let trailing = NSLayoutConstraint(item: scrollView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0.0)
                let top = NSLayoutConstraint(item: scrollView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0)
                let bottom = NSLayoutConstraint(item: scrollView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        
//        self.view.addSubview(scrollView)
                self.view.addConstraints([leading, trailing, top, bottom])

//        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
//        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
//        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        setupTextView()
//        let codeEditor = textView! //CodeEditorView(frame: self.view.bounds)
//
//        codeEditor.translatesAutoresizingMaskIntoConstraints = false
//
//        let leading = NSLayoutConstraint(item: codeEditor, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0.0)
//        let trailing = NSLayoutConstraint(item: codeEditor, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0.0)
//        let top = NSLayoutConstraint(item: codeEditor, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0)
//        let bottom = NSLayoutConstraint(item: codeEditor, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0.0)

//        let horizontalConstraint = NSLayoutConstraint(item: codeEditor, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
//        let verticalConstraint = NSLayoutConstraint(item: codeEditor, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        
//        codeEditor.highlighter = .init()
//        codeEditor.textContainer?.textView?.textStorage?.delegate = self
//        self.view.addSubview(codeEditor)
//        self.view.addConstraints([leading, trailing, top, bottom])
    }
    
    func getColor(for type: TokenType) -> NSColor {
        let a = [
            "number": NSColor.yellow,
            "keyword": .systemPink,
            "otherTypeName" : .orange,
            "typeDeclaration" : .green,
            "functionDeclaration" : .green,
            "variableDeclaration" : .green,
            "singleLineComment" : .gray,
            "singleLineComment2" : .gray,
            "stringLiteral" : .red,
            "multilineComment" : .gray
        ]
        return a[type] ?? .white
    }
}

class CodeEditorView: NSTextView {
    var highlighter: TheNewWorld!
    
//    override func didChangeText() {
//        let res = highlighter.tokenize(code: self.string.count == 1 ? (self.string + "a ") : self.string )
//        let a = NSMutableAttributedString()
//        for word in res {
//            a.append(.init(string: word.value, attributes: [.foregroundColor:getColor(for: word.type)]))
//        }
//        self.textStorage?.setAttributedString(a)
//    }
    
    override var readablePasteboardTypes: [NSPasteboard.PasteboardType] {
        [.string]
    }
    
    func getColor(for type: TokenType) -> NSColor {
        let a = [
            "number": NSColor.yellow,
            "keyword": .systemPink,
            "otherTypeName" : .blue,
            "typeDeclaratin" : .green,
            "functionDeclaration" : .green,
            "variableDeclaration" : .green,
            "singleLineComment" : .gray,
            "singleLineComment2" : .gray

        ]
        return a[type] ?? .white
    }
}





















//class ViewController: NSViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
////        self.addTarget(self, action: #selector(ViewController.textFieldDidChange(_:)), for: .editingChanged)
//        // Do any additional setup after loading the view.
//    }
//
//    override var representedObject: Any? {
//        didSet {
//        // Update the view, if already loaded.
//        }
//    }
//
//    var textField: CustomTextField = .init()
//
//
//    override func viewDidAppear() {
//        super.viewDidAppear()
//        textField = CustomTextField(frame: self.view.bounds)
//        var secondField = CustomTextField(frame: self.view.bounds)
////        textField.backgroundColor = .purple
//        self.view.addSubview(secondField)
//        self.view.addSubview(textField)
//        secondField.isEditable = false
//        secondField.backgroundColor = .clear
//        textField.second = secondField
//        textField.textColor = .clear
////        textField.attributedStringValue = .init(
////            string: "HOPO",
////            attributes: [
////                .foregroundColor : NSColor.systemPink,
////                NSAttributedString.Key.backgroundColor: NSColor.yellow
////            ]
////        )
//    }
//}

//class CustomTextField: NSTextField {
//
//    var second: CustomTextField?
//
//    override func doCommand(by selector: Selector) {
//        if let event: NSEvent = NSApp.currentEvent {
//
//                if event.keyCode == 36 {
//                    print("caught [⌘ + ⏎]")
//                }
//
//            }
//    }
//
//    override func textDidChange(_ notification: Notification) {
//        super.textDidChange(notification)
//        self.second?.attributedStringValue = NSAttributedString(string: self.stringValue, attributes: [.foregroundColor : NSColor.purple])
//    }
//}
