import Cocoa

struct HotkeyConfig: Codable {
    let modifiers: [String]
    let key: String
    
    func getModifierFlags() -> NSEvent.ModifierFlags {
        var flags: NSEvent.ModifierFlags = []
        for modifier in modifiers {
            switch modifier.lowercased() {
            case "cmd", "command":
                flags.insert(.command)
            case "option", "alt":
                flags.insert(.option)
            case "control", "ctrl":
                flags.insert(.control)
            case "shift":
                flags.insert(.shift)
            default:
                print("WARNING: Unknown modifier: \(modifier)")
            }
        }
        return flags
    }
    
    func getKeyCode() -> CGKeyCode? {
        let keyLower = key.lowercased()
        switch keyLower {
        case "a": return 0
        case "b": return 11
        case "c": return 8
        case "d": return 2
        case "e": return 14
        case "f": return 3
        case "g": return 5
        case "h": return 4
        case "i": return 34
        case "j": return 38
        case "k": return 40
        case "l": return 37
        case "m": return 46
        case "n": return 45
        case "o": return 31
        case "p": return 35
        case "q": return 12
        case "r": return 15
        case "s": return 1
        case "t": return 17
        case "u": return 32
        case "v": return 9
        case "w": return 13
        case "x": return 7
        case "y": return 16
        case "z": return 6
        case "0": return 29
        case "1": return 18
        case "2": return 19
        case "3": return 20
        case "4": return 21
        case "5": return 23
        case "6": return 22
        case "7": return 26
        case "8": return 28
        case "9": return 25
        case "space": return 49
        case "return", "enter": return 36
        case "tab": return 48
        case "escape", "esc": return 53
        case "delete", "backspace": return 51
        case "f1": return 122
        case "f2": return 120
        case "f3": return 99
        case "f4": return 118
        case "f5": return 96
        case "f6": return 97
        case "f7": return 98
        case "f8": return 100
        case "f9": return 101
        case "f10": return 109
        case "f11": return 103
        case "f12": return 111
        case "up": return 126
        case "down": return 125
        case "left": return 123
        case "right": return 124
        default:
            print("WARNING: Unknown key: \(key)")
            return nil
        }
    }
}

struct LayoutConfig: Codable {
    let hotkey: HotkeyConfig
    let homeRow: [String]
    let allKeys: [[String]]
    
    enum CodingKeys: String, CodingKey {
        case hotkey
        case homeRow = "home_row"
        case allKeys = "all_keys"
    }
    
    var flattenedKeys: [String] {
        return allKeys.flatMap { $0 }
    }
    
    var miniGridRows: Int {
        return allKeys.count
    }
    
    var miniGridCols: Int {
        return allKeys.first?.count ?? 0
    }
}

enum GridState {
    case bigGrid
    case miniGrid
}

let MINI_GRID_ZOOM_FACTOR: CGFloat = 3.0

var globalConfig: LayoutConfig?

class ZoomedMiniGridView: NSView {
    var config: LayoutConfig!
    
    override var isFlipped: Bool { true }
    
    init(frame frameRect: NSRect, config: LayoutConfig) {
        super.init(frame: frameRect)
        self.config = config
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        let bounds = self.bounds
        
        NSColor.black.withAlphaComponent(0.75).setFill()
        let bgPath = NSBezierPath(roundedRect: bounds, xRadius: 12, yRadius: 12)
        bgPath.fill()
        
        let miniRows = config.miniGridRows
        let miniCols = config.miniGridCols
        
        let padding: CGFloat = 24
        let availableWidth = bounds.width - padding * 2
        let availableHeight = bounds.height - padding * 2
        
        let cellAspectRatio = CGFloat(miniCols) / CGFloat(miniRows)
        let viewAspectRatio = availableWidth / availableHeight
        
        var gridWidth: CGFloat
        var gridHeight: CGFloat
        
        if viewAspectRatio > cellAspectRatio {
            gridHeight = availableHeight
            gridWidth = gridHeight * cellAspectRatio
        } else {
            gridWidth = availableWidth
            gridHeight = gridWidth / cellAspectRatio
        }
        
        let gridX = (bounds.width - gridWidth) / 2
        let gridY = (bounds.height - gridHeight) / 2
        
        let miniCellWidth = gridWidth / CGFloat(miniCols)
        let miniCellHeight = gridHeight / CGFloat(miniRows)
        
        NSColor.white.withAlphaComponent(0.2).setStroke()
        let gridPath = NSBezierPath()
        gridPath.lineWidth = 0.5
        
        for miniCol in 0...miniCols {
            let x = gridX + CGFloat(miniCol) * miniCellWidth
            gridPath.move(to: NSPoint(x: x, y: gridY))
            gridPath.line(to: NSPoint(x: x, y: gridY + gridHeight))
        }
        
        for miniRow in 0...miniRows {
            let y = gridY + CGFloat(miniRow) * miniCellHeight
            gridPath.move(to: NSPoint(x: gridX, y: y))
            gridPath.line(to: NSPoint(x: gridX + gridWidth, y: y))
        }
        
        gridPath.stroke()
        
        let dotRadius: CGFloat = max(2, min(miniCellWidth, miniCellHeight) * 0.035)
        let fontSize: CGFloat = max(16, min(miniCellWidth, miniCellHeight) * 0.35)
        let font = NSFont.systemFont(ofSize: fontSize)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor.white
        ]
        
        for miniRow in 0..<miniRows {
            for miniCol in 0..<miniCols {
                guard miniRow < config.allKeys.count,
                      miniCol < config.allKeys[miniRow].count else { continue }
                
                let key = config.allKeys[miniRow][miniCol]
                let centerX = gridX + CGFloat(miniCol) * miniCellWidth + miniCellWidth / 2
                let centerY = gridY + CGFloat(miniRow) * miniCellHeight + miniCellHeight / 2
                
                let dotPath = NSBezierPath()
                dotPath.appendOval(in: NSRect(x: centerX - dotRadius, y: centerY - dotRadius, width: dotRadius * 2, height: dotRadius * 2))
                NSColor.white.withAlphaComponent(0.9).setFill()
                dotPath.fill()
                
                let textSize = key.size(withAttributes: attrs)
                let textRect = NSRect(
                    x: centerX + dotRadius + 4,
                    y: centerY - textSize.height / 2,
                    width: textSize.width,
                    height: textSize.height
                )
                key.draw(in: textRect, withAttributes: attrs)
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var gridWindow: GridWindow!
    var globalMonitor: Any?
    var localMonitor: Any?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("KeybrClicker starting...")
        NSApp.setActivationPolicy(.accessory)
        
        loadGlobalConfig()
        
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
        
        if let config = globalConfig {
            let mods = config.hotkey.modifiers.joined(separator: "+")
            print("KeybrClicker ready. Press \(mods.uppercased())+\(config.hotkey.key.uppercased()) to show grid.")
        } else {
            print("KeybrClicker ready.")
        }
    }
    
    func loadGlobalConfig() {
        let configPath = Bundle.main.bundlePath + "/layout.json"
        let fileManager = FileManager.default
        
        guard fileManager.fileExists(atPath: configPath) else {
            print("ERROR: layout.json not found at \(configPath), using defaults")
            return
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: configPath))
            globalConfig = try JSONDecoder().decode(LayoutConfig.self, from: data)
            print("Loaded config with hotkey: \(globalConfig?.hotkey.modifiers.joined(separator: "+") ?? "")+\(globalConfig?.hotkey.key ?? "")")
        } catch {
            print("ERROR: Failed to load layout.json: \(error)")
        }
    }
    
    func isHotkey(_ event: NSEvent) -> Bool {
        guard let config = globalConfig else {
            let cmdOpt = NSEvent.ModifierFlags([.command, .option])
            return event.modifierFlags.contains(cmdOpt) && event.keyCode == 5
        }
        
        let requiredFlags = config.hotkey.getModifierFlags()
        guard let requiredKeyCode = config.hotkey.getKeyCode() else {
            return false
        }
        
        return event.modifierFlags.contains(requiredFlags) && event.keyCode == requiredKeyCode
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
    var config: LayoutConfig!
    var state: GridState = .bigGrid
    var inputBuffer: String = ""
    var selectedBigCell: String = ""
    var previousApp: NSRunningApplication?
    var zoomedMiniGridView: ZoomedMiniGridView?
    
    override var isFlipped: Bool { true }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        loadConfig()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadConfig()
    }
    
    func loadConfig() {
        let configPath = Bundle.main.bundlePath + "/layout.json"
        let fileManager = FileManager.default
        
        guard fileManager.fileExists(atPath: configPath) else {
            print("ERROR: layout.json not found at \(configPath)")
            let defaultHotkey = HotkeyConfig(modifiers: ["cmd", "option"], key: "g")
            let defaultConfig = LayoutConfig(
                hotkey: defaultHotkey,
                homeRow: ["A", "S", "D", "F", "G", "H", "J", "K", "L", ";"],
                allKeys: [
                    ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
                    ["A", "S", "D", "F", "G", "H", "J", "K", "L", ";"],
                    ["Z", "X", "C", "V", "B", "N", "M", ",", ".", "/"]
                ]
            )
            self.config = defaultConfig
            return
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: configPath))
            self.config = try JSONDecoder().decode(LayoutConfig.self, from: data)
            print("Loaded layout config: \(config.homeRow.count) columns, \(config.flattenedKeys.count) rows")
        } catch {
            print("ERROR: Failed to load layout.json: \(error)")
            let defaultHotkey = HotkeyConfig(modifiers: ["cmd", "option"], key: "g")
            let defaultConfig = LayoutConfig(
                hotkey: defaultHotkey,
                homeRow: ["A", "S", "D", "F", "G", "H", "J", "K", "L", ";"],
                allKeys: [
                    ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
                    ["A", "S", "D", "F", "G", "H", "J", "K", "L", ";"],
                    ["Z", "X", "C", "V", "B", "N", "M", ",", ".", "/"]
                ]
            )
            self.config = defaultConfig
        }
    }
    
    func getBigCellCode(col: Int, row: Int) -> String {
        let colKey = config.homeRow[col]
        let rowKey = config.flattenedKeys[row]
        return colKey + rowKey
    }
    
    func isValidBigCell(_ code: String) -> Bool {
        guard code.count == 2 else { return false }
        let chars = Array(code)
        let colKey = String(chars[0])
        let rowKey = String(chars[1])
        return config.homeRow.contains(colKey) && config.flattenedKeys.contains(rowKey)
    }
    
    func getBigCellIndices(code: String) -> (col: Int, row: Int)? {
        guard code.count == 2 else { return nil }
        let chars = Array(code)
        let colKey = String(chars[0])
        let rowKey = String(chars[1])
        
        guard let colIndex = config.homeRow.firstIndex(of: colKey),
              let rowIndex = config.flattenedKeys.firstIndex(of: rowKey) else {
            return nil
        }
        
        return (colIndex, rowIndex)
    }
    
    func findMiniKeyPosition(_ key: String) -> (row: Int, col: Int)? {
        for (rowIndex, row) in config.allKeys.enumerated() {
            if let colIndex = row.firstIndex(of: key) {
                return (rowIndex, colIndex)
            }
        }
        return nil
    }
    
    func cellMatchesBuffer(col: Int, row: Int) -> Bool {
        if inputBuffer.isEmpty { return true }
        let cellCode = getBigCellCode(col: col, row: row)
        return cellCode.hasPrefix(inputBuffer)
    }
    
    func letterForCell(col: Int, row: Int) -> String {
        return getBigCellCode(col: col, row: row)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        let bounds = self.bounds
        
        switch state {
        case .bigGrid:
            drawBigGrid(bounds: bounds)
        case .miniGrid:
            drawBigGridDimmed(bounds: bounds)
            drawMiniGrid(bounds: bounds)
        }
    }
    
    func drawBigGrid(bounds: NSRect) {
        let columns = config.homeRow.count
        let rows = config.flattenedKeys.count
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
            let x = CGFloat(col) * cellWidth
            path.move(to: NSPoint(x: x, y: 0))
            path.line(to: NSPoint(x: x, y: bounds.height))
        }
        
        for row in 0...rows {
            let y = CGFloat(row) * cellHeight
            path.move(to: NSPoint(x: 0, y: y))
            path.line(to: NSPoint(x: bounds.width, y: y))
        }
        
        path.stroke()
        
        let font = NSFont.systemFont(ofSize: 12)
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
    
    func drawBigGridDimmed(bounds: NSRect) {
        let columns = config.homeRow.count
        let rows = config.flattenedKeys.count
        let cellWidth = bounds.width / CGFloat(columns)
        let cellHeight = bounds.height / CGFloat(rows)
        
        guard let selectedIndices = getBigCellIndices(code: selectedBigCell) else { return }
        
        for col in 0..<columns {
            for row in 0..<rows {
                let cellX = CGFloat(col) * cellWidth
                let cellY = CGFloat(row) * cellHeight
                let cellRect = NSRect(x: cellX, y: cellY, width: cellWidth, height: cellHeight)
                
                if col == selectedIndices.col && row == selectedIndices.row {
                    NSColor.lightGray.withAlphaComponent(0.15).setFill()
                } else {
                    NSColor.black.withAlphaComponent(0.35).setFill()
                }
                cellRect.fill()
            }
        }
        
        NSColor.darkGray.withAlphaComponent(0.4).setStroke()
        let path = NSBezierPath()
        path.lineWidth = 0.5
        
        for col in 0...columns {
            let x = CGFloat(col) * cellWidth
            path.move(to: NSPoint(x: x, y: 0))
            path.line(to: NSPoint(x: x, y: bounds.height))
        }
        
        for row in 0...rows {
            let y = CGFloat(row) * cellHeight
            path.move(to: NSPoint(x: 0, y: y))
            path.line(to: NSPoint(x: bounds.width, y: y))
        }
        
        path.stroke()
    }
    
    func drawMiniGrid(bounds: NSRect) {
        let columns = config.homeRow.count
        let rows = config.flattenedKeys.count
        let cellWidth = bounds.width / CGFloat(columns)
        let cellHeight = bounds.height / CGFloat(rows)
        
        guard let selectedIndices = getBigCellIndices(code: selectedBigCell) else { return }
        
        let bigCellX = CGFloat(selectedIndices.col) * cellWidth
        let bigCellY = CGFloat(selectedIndices.row) * cellHeight
        
        let miniRows = config.miniGridRows
        let miniCols = config.miniGridCols
        let miniCellWidth = cellWidth / CGFloat(miniCols)
        let miniCellHeight = cellHeight / CGFloat(miniRows)
        
        let dotRadius: CGFloat = max(1.5, min(miniCellWidth, miniCellHeight) * 0.035)
        let fontSize: CGFloat = max(8, min(miniCellWidth, miniCellHeight) * 0.2)
        let font = NSFont.systemFont(ofSize: fontSize)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor.white.withAlphaComponent(0.9)
        ]
        
        for miniRow in 0..<miniRows {
            for miniCol in 0..<miniCols {
                guard miniRow < config.allKeys.count,
                      miniCol < config.allKeys[miniRow].count else { continue }
                
                let key = config.allKeys[miniRow][miniCol]
                let centerX = bigCellX + CGFloat(miniCol) * miniCellWidth + miniCellWidth / 2
                let centerY = bigCellY + CGFloat(miniRow) * miniCellHeight + miniCellHeight / 2
                
                let dotPath = NSBezierPath()
                dotPath.appendOval(in: NSRect(x: centerX - dotRadius, y: centerY - dotRadius, width: dotRadius * 2, height: dotRadius * 2))
                NSColor.white.withAlphaComponent(0.7).setFill()
                dotPath.fill()
                
                let textSize = key.size(withAttributes: attrs)
                let textRect = NSRect(
                    x: centerX + dotRadius + 2,
                    y: centerY - textSize.height / 2,
                    width: textSize.width,
                    height: textSize.height
                )
                key.draw(in: textRect, withAttributes: attrs)
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
            (window as? GridWindow)?.hide()
            return
        }
        
        let char = chars[chars.startIndex]
        
        switch state {
        case .bigGrid:
            handleBigGridInput(char: char)
        case .miniGrid:
            handleMiniGridInput(char: char)
        }
    }
    
    func handleBigGridInput(char: Character) {
        inputBuffer.append(char)
        print("Big grid input buffer: \(inputBuffer)")
        needsDisplay = true
        
        if inputBuffer.count == 2 {
            if isValidBigCell(inputBuffer) {
                print("Valid big cell selected: \(inputBuffer), switching to mini grid")
                selectedBigCell = inputBuffer
                state = .miniGrid
                applyZoomToSelectedCell()
                needsDisplay = true
            } else {
                print("Invalid big cell code: \(inputBuffer), hiding grid")
                (window as? GridWindow)?.hide()
            }
        }
    }
    
    func handleMiniGridInput(char: Character) {
        let key = String(char)
        
        if let _ = findMiniKeyPosition(key) {
            print("Mini grid key pressed: \(key)")
            handleClick(bigCell: selectedBigCell, miniKey: key)
        } else {
            print("Invalid mini grid key: \(key), hiding grid")
            (window as? GridWindow)?.hide()
        }
    }
    
    func handleClick(bigCell: String, miniKey: String) {
        guard let bigIndices = getBigCellIndices(code: bigCell),
              let miniPosition = findMiniKeyPosition(miniKey) else {
            print("ERROR: Invalid cell or key")
            resetZoom()
            (window as? GridWindow)?.hide()
            return
        }
        
        let columns = config.homeRow.count
        let rows = config.flattenedKeys.count
        let cellWidth = bounds.width / CGFloat(columns)
        let cellHeight = bounds.height / CGFloat(rows)
        
        let bigCellX = CGFloat(bigIndices.col) * cellWidth
        let bigCellY = CGFloat(bigIndices.row) * cellHeight
        
        let miniRows = config.miniGridRows
        let miniCols = config.miniGridCols
        let miniCellWidth = cellWidth / CGFloat(miniCols)
        let miniCellHeight = cellHeight / CGFloat(miniRows)
        
        let localX = bigCellX + CGFloat(miniPosition.col) * miniCellWidth + miniCellWidth / 2
        let localY = bigCellY + CGFloat(miniPosition.row) * miniCellHeight + miniCellHeight / 2
        
        let windowPoint = convert(NSPoint(x: localX, y: localY), to: nil)
        guard let screenRect = window?.convertToScreen(NSRect(origin: windowPoint, size: .zero)) else {
            print("ERROR: Could not convert to screen coordinates")
            resetZoom()
            (window as? GridWindow)?.hide()
            return
        }
        
        let clickPoint = screenRect.origin
        let screenHeight = NSScreen.main!.frame.height
        let cgClickPoint = CGPoint(x: clickPoint.x, y: screenHeight - clickPoint.y)
        
        print("=== CLICK DEBUG ===")
        print("Big cell: \(bigCell), Mini key: \(miniKey)")
        print("Click point (CG): (\(cgClickPoint.x), \(cgClickPoint.y))")
        
        let source = CGEventSource(stateID: .hidSystemState)
        
        guard let downEvent = CGEvent(mouseEventSource: source, mouseType: .leftMouseDown, mouseCursorPosition: cgClickPoint, mouseButton: .left),
              let upEvent = CGEvent(mouseEventSource: source, mouseType: .leftMouseUp, mouseCursorPosition: cgClickPoint, mouseButton: .left) else {
            print("ERROR: Could not create mouse events")
            resetZoom()
            (window as? GridWindow)?.hide()
            return
        }
        
        downEvent.setIntegerValueField(.mouseEventClickState, value: 1)
        upEvent.setIntegerValueField(.mouseEventClickState, value: 1)
        
        resetZoom()
        (window as? GridWindow)?.hide()
        
        usleep(150000)
        
        if let app = previousApp {
            print("Activating previous app: \(app.localizedName ?? "unknown")")
            app.activate(options: [])
        }
        
        usleep(50000)
        
        downEvent.post(tap: .cgSessionEventTap)
        usleep(50000)
        upEvent.post(tap: .cgSessionEventTap)
        
        print("=== CLICK COMPLETE ===")
    }
    
    func applyZoomToSelectedCell() {
        zoomedMiniGridView?.removeFromSuperview()
        
        let panelWidth = bounds.width * 0.28
        let panelHeight = bounds.height * 0.22
        let padding: CGFloat = 20
        let panelX = bounds.width - panelWidth - padding
        let panelY = bounds.height - panelHeight - padding
        
        let panelFrame = NSRect(x: panelX, y: panelY, width: panelWidth, height: panelHeight)
        zoomedMiniGridView = ZoomedMiniGridView(frame: panelFrame, config: config)
        addSubview(zoomedMiniGridView!)
    }
    
    func resetZoom() {
        zoomedMiniGridView?.removeFromSuperview()
        zoomedMiniGridView = nil
        needsDisplay = true
    }
    
    func reset() {
        resetZoom()
        state = .bigGrid
        inputBuffer = ""
        selectedBigCell = ""
        needsDisplay = true
    }
}

let delegate = AppDelegate()
NSApplication.shared.delegate = delegate
NSApplication.shared.run()
