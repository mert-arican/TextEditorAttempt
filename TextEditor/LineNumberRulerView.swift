import AppKit
import Cocoa
import Foundation


class LineNumberRulerView: NSRulerView {
    private weak var textView: NSTextView?

    init(textView: NSTextView) {
        self.textView = textView
        super.init(scrollView: textView.enclosingScrollView!, orientation: .verticalRuler)
        clientView = textView.enclosingScrollView!.documentView
        reservedThicknessForMarkers = 60.0
        
        NotificationCenter.default.addObserver(forName: NSView.frameDidChangeNotification, object: textView, queue: nil) { [weak self] _ in
            self?.needsDisplay = true
        }

        NotificationCenter.default.addObserver(forName: NSText.didChangeNotification, object: textView, queue: nil) { [weak self] _ in
            self?.needsDisplay = true
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func drawHashMarksAndLabels(in rect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext,
              let textView = textView,
              let textLayoutManager = textView.textLayoutManager
        else {
            return
        }

        let relativePoint = self.convert(NSZeroPoint, from: textView)

        context.saveGState()
        context.textMatrix = CGAffineTransform(scaleX: 1, y: isFlipped ? -1 : 1)

        let attributes: [NSAttributedString.Key: Any] = [
            .font: textView.font!,
            .foregroundColor: NSColor.secondaryLabelColor
        ]

        var lineNum = 1
        textLayoutManager.enumerateTextLayoutFragments(from: nil, options: .ensuresLayout) { fragment in
            let fragmentFrame = fragment.layoutFragmentFrame

            for (subLineIdx, textLineFragment) in fragment.textLineFragments.enumerated() where subLineIdx == 0 {
                let locationForFirstCharacter = textLineFragment.locationForCharacter(at: 0)
                let ctline = CTLineCreateWithAttributedString(CFAttributedStringCreate(nil, "\(lineNum)" as CFString, attributes as CFDictionary))
                context.textPosition = fragmentFrame.origin.applying(.init(translationX: 4, y: locationForFirstCharacter.y + relativePoint.y))
                CTLineDraw(ctline, context)
            }

            lineNum += 1
            return true
        }

        context.restoreGState()
    }
}
