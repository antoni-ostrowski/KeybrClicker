import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var gridWindow: GridWindow!
    var globalMonitor: Any?
    var localMonitor: Any?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("KeybrClicker starting...")
        NSApp.setActivationPolicy(.accessory)
        
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        let trusted = AXIsProcessTrustedWithOptions(options)
        if !trusted {
            print("WARNING: Accessibility permissions not granted. Please enable in System Settings.")
        } else {
            print("Accessibility permissions granted.")
        }
        
        gridWindow = GridWindow()
        
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if self?.isHotkey(event) == true {
                print("Hotkey detected (global), showing grid")
                DispatchQueue.main.async {
                    self?.showGrid()
                }
            }
        }
        
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if self?.isHotkey(event) == true {
                print("Hotkey detected (local), showing grid")
                self?.showGrid()
                return nil
            }
            return event
        }
        
        print("KeybrClicker ready. Press Cmd+Option+G to show grid.")
    }
    
    func isHotkey(_ event: NSEvent) -> Bool {
        let cmdOpt = NSEvent.ModifierFlags([.command, .option])
        return event.modifierFlags.contains(cmdOpt) && event.keyCode == 5
    }
    
    func showGrid() {
        gridWindow.show()
    }
}

class GridWindow: NSWindow {
    var gridView: GridView!
    
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
    
    init() {
        let screenFrame = NSScreen.main!.frame
        super.init(contentRect: screenFrame, styleMask: .borderless, backing: .buffered, defer: false)
        
        level = .screenSaver
        backgroundColor = .clear
        isOpaque = false
        hasShadow = false
        ignoresMouseEvents = false
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        hidesOnDeactivate = false
        
        gridView = GridView(frame: NSRect(origin: .zero, size: screenFrame.size))
        contentView = gridView
    }
    
    func show() {
        guard let screen = NSScreen.main else {
            print("ERROR: No main screen found")
            return
        }
        gridView.previousApp = NSWorkspace.shared.frontmostApplication
        print("Stored previous app: \(gridView.previousApp?.localizedName ?? "nil")")
        setFrame(screen.frame, display: true)
        makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        makeFirstResponder(gridView)
        gridView.reset()
    }
    
    func hide() {
        ignoresMouseEvents = true
        level = .normal
        orderOut(nil)
    }
}

class GridView: NSView {
    let columns = 170
    let rows = 96
    var inputBuffer = ""
    var previousApp: NSRunningApplication?
    
    override var isFlipped: Bool { true }
    
    func indexToCode(_ index: Int) -> String {
        let first = index / 26
        let second = index % 26
        let c1 = Character(UnicodeScalar(UInt32(UnicodeScalar("A").value) + UInt32(first))!)
        let c2 = Character(UnicodeScalar(UInt32(UnicodeScalar("A").value) + UInt32(second))!)
        return String(c1) + String(c2)
    }
    
    func codeToIndex(_ code: String) -> Int? {
        guard code.count == 2 else { return nil }
        let chars = Array(code)
        let aVal = UInt8(ascii: "A")
        let zVal = UInt8(ascii: "Z")
        guard let v1 = chars[0].asciiValue, v1 >= aVal, v1 <= zVal,
              let v2 = chars[1].asciiValue, v2 >= aVal, v2 <= zVal else { return nil }
        let first = Int(v1 - aVal)
        let second = Int(v2 - aVal)
        return first * 26 + second
    }
    
    func getCellCode(col: Int, row: Int) -> String {
        return indexToCode(col) + indexToCode(row)
    }
    
    func cellMatchesBuffer(col: Int, row: Int) -> Bool {
        if inputBuffer.isEmpty { return true }
        let cellCode = getCellCode(col: col, row: row)
        return cellCode.hasPrefix(inputBuffer)
    }
    
    func letterForCell(col: Int, row: Int) -> String {
        let cellCode = getCellCode(col: col, row: row)
        let index = inputBuffer.count
        if index < cellCode.count {
            return String(cellCode[cellCode.index(cellCode.startIndex, offsetBy: index)])
        }
        return ""
    }
    
    override func draw(_ dirtyRect: NSRect) {
        let bounds = self.bounds
        let cellWidth = bounds.width / CGFloat(columns)
        let cellHeight = bounds.height / CGFloat(rows)
        
        for col in 0..<columns {
            for row in 0..<rows {
                let matches = cellMatchesBuffer(col: col, row: row)
                guard matches else { continue }
                
                let cellX = CGFloat(col) * cellWidth
                let cellY = CGFloat(row) * cellHeight
                let cellRect = NSRect(x: cellX, y: cellY, width: cellWidth, height: cellHeight)
                
                NSColor.lightGray.withAlphaComponent(0.15).setFill()
                cellRect.fill()
            }
        }
        
        NSColor.darkGray.withAlphaComponent(1.0).setStroke()
        let path = NSBezierPath()
        path.lineWidth = 0.5
        
        for col in 0...columns {
            let hasMatch = (0..<rows).contains { row in cellMatchesBuffer(col: col, row: row) }
            guard hasMatch else { continue }
            let x = CGFloat(col) * cellWidth
            path.move(to: NSPoint(x: x, y: 0))
            path.line(to: NSPoint(x: x, y: bounds.height))
        }
        
        for row in 0...rows {
            let hasMatch = (0..<columns).contains { col in cellMatchesBuffer(col: col, row: row) }
            guard hasMatch else { continue }
            let y = CGFloat(row) * cellHeight
            path.move(to: NSPoint(x: 0, y: y))
            path.line(to: NSPoint(x: bounds.width, y: y))
        }
        
        path.stroke()
        
        let font = NSFont.systemFont(ofSize: 8)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor.white
        ]
        
        for col in 0..<columns {
            for row in 0..<rows {
                let matches = cellMatchesBuffer(col: col, row: row)
                guard matches else { continue }
                
                let letter = letterForCell(col: col, row: row)
                guard !letter.isEmpty else { continue }
                
                let cellX = CGFloat(col) * cellWidth
                let cellY = CGFloat(row) * cellHeight
                let cellCenter = NSPoint(x: cellX + cellWidth / 2, y: cellY + cellHeight / 2)
                
                let textSize = letter.size(withAttributes: attrs)
                let textRect = NSRect(
                    x: cellCenter.x - textSize.width / 2,
                    y: cellCenter.y - textSize.height / 2,
                    width: textSize.width,
                    height: textSize.height
                )
                
                letter.draw(in: textRect, withAttributes: attrs)
            }
        }
    }
    
    override var acceptsFirstResponder: Bool { true }
    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 {
            print("Escape pressed, hiding grid")
            (window as? GridWindow)?.hide()
            return
        }
        
        guard let chars = event.characters?.uppercased(), chars.count == 1 else {
            print("WARNING: Could not get characters from key event")
            return
        }
        let char = chars[chars.startIndex]
        guard char >= "A" && char <= "Z" else {
            print("Ignored non-letter key: \(char)")
            return
        }
        
        inputBuffer.append(char)
        print("Input buffer: \(inputBuffer)")
        needsDisplay = true
        
        if inputBuffer.count == 4 {
            handleClick(code: inputBuffer)
            inputBuffer = ""
        }
    }
    
    func handleClick(code: String) {
        let colCode = String(code.prefix(2))
        let rowCode = String(code.suffix(2))
        
        guard let col = codeToIndex(colCode), col < columns,
              let row = codeToIndex(rowCode), row < rows else {
            print("Invalid code: \(code), hiding grid")
            (window as? GridWindow)?.hide()
            return
        }
        
        let cellWidth = bounds.width / CGFloat(columns)
        let cellHeight = bounds.height / CGFloat(rows)
        
        let localX = CGFloat(col) * cellWidth + cellWidth / 2
        let localY = CGFloat(row) * cellHeight + cellHeight / 2
        
        let windowPoint = convert(NSPoint(x: localX, y: localY), to: nil)
        guard let screenRect = window?.convertToScreen(NSRect(origin: windowPoint, size: .zero)) else {
            print("ERROR: Could not convert to screen coordinates")
            (window as? GridWindow)?.hide()
            return
        }
        
        let clickPoint = screenRect.origin
        let screenHeight = NSScreen.main!.frame.height
        let cgClickPoint = CGPoint(x: clickPoint.x, y: screenHeight - clickPoint.y)
        print("=== CLICK DEBUG START ===")
        print("Code: \(code)")
        print("Screen height: \(screenHeight)")
        print("Click point (AppKit): (\(clickPoint.x), \(clickPoint.y))")
        print("Click point (CG): (\(cgClickPoint.x), \(cgClickPoint.y))")
        
        let trusted = AXIsProcessTrusted()
        print("Accessibility trusted: \(trusted)")
        
        let source = CGEventSource(stateID: .hidSystemState)
        
        guard let downEvent = CGEvent(mouseEventSource: source, mouseType: .leftMouseDown, mouseCursorPosition: cgClickPoint, mouseButton: .left),
              let upEvent = CGEvent(mouseEventSource: source, mouseType: .leftMouseUp, mouseCursorPosition: cgClickPoint, mouseButton: .left) else {
            print("ERROR: Could not create mouse events")
            (window as? GridWindow)?.hide()
            return
        }
        
        print("Mouse events created successfully")
        
        downEvent.setIntegerValueField(.mouseEventClickState, value: 1)
        upEvent.setIntegerValueField(.mouseEventClickState, value: 1)
        print("Click state set to 1")
        
        print("[\(Date().timeIntervalSince1970)] Window visible before hide: \(window?.isVisible ?? false)")
        print("About to hide window")
        (window as? GridWindow)?.hide()
        print("[\(Date().timeIntervalSince1970)] Window visible after hide: \(window?.isVisible ?? false)")
        print("Window hidden, waiting 150ms for window to fully disappear")
        
        usleep(150000)
        
        print("[\(Date().timeIntervalSince1970)] Window visible after delay: \(window?.isVisible ?? false)")
        
        if let app = previousApp {
            print("Activating previous app: \(app.localizedName ?? "unknown")")
            app.activate(options: [])
        } else {
            print("No previous app stored")
        }
        
        print("Waiting 50ms for app activation")
        usleep(50000)
        
        print("Posting first mouseDown to cgSessionEventTap")
        downEvent.post(tap: .cgSessionEventTap)
        print("Mouse down posted")
        
        usleep(50000)
        
        print("Posting first mouseUp to cgSessionEventTap")
        upEvent.post(tap: .cgSessionEventTap)
        print("Mouse up posted")
        
        usleep(50000)
        
        downEvent.setIntegerValueField(.mouseEventClickState, value: 2)
        upEvent.setIntegerValueField(.mouseEventClickState, value: 2)
        print("Click state set to 2 (double-click)")
        
        print("Posting second mouseDown to cgSessionEventTap")
        downEvent.post(tap: .cgSessionEventTap)
        print("Mouse down posted")
        
        usleep(50000)
        
        print("Posting second mouseUp to cgSessionEventTap")
        upEvent.post(tap: .cgSessionEventTap)
        print("Mouse up posted")
        print("=== CLICK DEBUG END ===")
    }
    
    func reset() {
        inputBuffer = ""
        needsDisplay = true
    }
}

let delegate = AppDelegate()
NSApplication.shared.delegate = delegate
NSApplication.shared.run()
