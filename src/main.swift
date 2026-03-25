import Cocoa

// MARK: - Timing Configuration (microseconds)
// Set to 0 to disable a delay
let HIDE_DELAY_US: useconds_t = 0        // Delay after hiding grid
let FOCUS_DELAY_US: useconds_t = 0       // Delay after activating previous app
let CLICK_DELAY_US: useconds_t = 0       // Delay between mouse down/up

enum MouseButton: String, Codable {
    case left = "left"
    case right = "right"
    case middle = "middle"
}

enum ScrollDirection {
    case up
    case down
    case left
    case right
}

// MARK: - Config Path
func getConfigURL() -> URL {
    let homeDir = FileManager.default.homeDirectoryForCurrentUser
    return homeDir.appendingPathComponent(".config/keybrclicker/config.json")
}

func createDefaultLayoutConfig() -> LayoutConfig {
    let defaultHotkey = HotkeyConfig(
        modifiers: ["cmd", "option"],
        key: "g",
        mouseButton: .left
    )
    let defaultScrollHotkey = ScrollHotkeyConfig(
        modifiers: ["cmd", "option"],
        key: "s"
    )
    return LayoutConfig(
        hotkeys: [defaultHotkey],
        scrollHotkeys: [defaultScrollHotkey],
        scrollKeys: ScrollKeysConfig.defaultConfig(),
        layout: [
            ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
            ["A", "S", "D", "F", "G", "H", "J", "K", "L", ";"],
            ["Z", "X", "C", "V", "B", "N", "M", ",", ".", "/"]
        ]
    )
}

func ensureConfigExists() {
    let configURL = getConfigURL()
    let fileManager = FileManager.default
    
    let configDir = configURL.deletingLastPathComponent()
    
    if !fileManager.fileExists(atPath: configDir.path) {
        do {
            try fileManager.createDirectory(at: configDir, withIntermediateDirectories: true)
            print("Created config directory: \(configDir.path)")
        } catch {
            print("ERROR: Failed to create config directory: \(error)")
            return
        }
    }
    
    if !fileManager.fileExists(atPath: configURL.path) {
        do {
            let defaultConfig = createDefaultLayoutConfig()
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(defaultConfig)
            try data.write(to: configURL)
            print("Created default config at: \(configURL.path)")
        } catch {
            print("ERROR: Failed to create default config: \(error)")
        }
    }
}

struct HotkeyConfig: Codable {
    let modifiers: [String]
    let key: String
    let mouseButton: MouseButton
    
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
        return HotkeyConfig.keyCodeForKey(key)
    }
    
    static func keyCodeForKey(_ key: String) -> CGKeyCode? {
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

struct ScrollHotkeyConfig: Codable {
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
        return HotkeyConfig.keyCodeForKey(key)
    }
}

struct ScrollKeysConfig: Codable {
    let up: String
    let down: String
    let left: String
    let right: String
    let amount: Int
    
    static func defaultConfig() -> ScrollKeysConfig {
        return ScrollKeysConfig(up: "k", down: "j", left: "h", right: "l", amount: 3)
    }
}

struct LayoutConfig: Codable {
    let hotkeys: [HotkeyConfig]
    let scrollHotkeys: [ScrollHotkeyConfig]
    let scrollKeys: ScrollKeysConfig
    let layout: [[String]]
    
    enum CodingKeys: String, CodingKey {
        case hotkeys
        case scrollHotkeys
        case scrollKeys
        case layout
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        hotkeys = try container.decode([HotkeyConfig].self, forKey: .hotkeys)
        scrollHotkeys = try container.decodeIfPresent([ScrollHotkeyConfig].self, forKey: .scrollHotkeys) ?? []
        scrollKeys = try container.decodeIfPresent(ScrollKeysConfig.self, forKey: .scrollKeys) ?? ScrollKeysConfig.defaultConfig()
        layout = try container.decode([[String]].self, forKey: .layout)
    }
    
    init(hotkeys: [HotkeyConfig], scrollHotkeys: [ScrollHotkeyConfig], scrollKeys: ScrollKeysConfig, layout: [[String]]) {
        self.hotkeys = hotkeys
        self.scrollHotkeys = scrollHotkeys
        self.scrollKeys = scrollKeys
        self.layout = layout
    }
    
    var homeRow: [String] {
        return layout[layout.count / 2]
    }
    
    var flattenedKeys: [String] {
        return layout.flatMap { $0 }
    }
    
    var miniGridRows: Int {
        return layout.count
    }
    
    var miniGridCols: Int {
        return layout.first?.count ?? 0
    }
    
    var rowLabels: [String] {
        let alphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
        let extraSymbols = [";", ",", ".", "/", "-", "=", "[", "]", "'", "\\", "`"]
        let allLabels = alphabet + extraSymbols
        return Array(allLabels.prefix(flattenedKeys.count))
    }
}

enum GridState {
    case bigGrid
    case miniGrid
}

var globalConfig: LayoutConfig?

class AppDelegate: NSObject, NSApplicationDelegate {
    var gridWindow: GridWindow!
    var scrollWindow: ScrollWindow!
    var globalMonitor: Any?
    var localMonitor: Any?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("KeybrClicker starting...")
        NSApp.setActivationPolicy(.accessory)
        
        ensureConfigExists()
        loadGlobalConfig()
        
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        let trusted = AXIsProcessTrustedWithOptions(options)
        if !trusted {
            print("WARNING: Accessibility permissions not granted. Please enable in System Settings.")
        } else {
            print("Accessibility permissions granted.")
        }
        
        gridWindow = GridWindow()
        scrollWindow = ScrollWindow()
        
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if let hotkey = self?.isHotkey(event) {
                print("Hotkey detected (global), showing grid")
                DispatchQueue.main.async {
                    self?.showGrid(hotkey)
                }
            } else if let _ = self?.isScrollHotkey(event) {
                print("Scroll hotkey detected (global), showing scroll mode")
                DispatchQueue.main.async {
                    self?.showScrollWindow()
                }
            }
        }
        
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if let hotkey = self?.isHotkey(event) {
                print("Hotkey detected (local), showing grid")
                self?.showGrid(hotkey)
                return nil
            } else if let _ = self?.isScrollHotkey(event) {
                print("Scroll hotkey detected (local), showing scroll mode")
                self?.showScrollWindow()
                return nil
            }
            return event
        }
        
        if let config = globalConfig {
            print("KeybrClicker ready. Registered hotkeys:")
            for (index, hotkey) in config.hotkeys.enumerated() {
                let mods = hotkey.modifiers.joined(separator: "+")
                print("  [click\(index)] \(mods.uppercased())+\(hotkey.key.uppercased()) → \(hotkey.mouseButton.rawValue) click")
            }
            for (index, scrollHotkey) in config.scrollHotkeys.enumerated() {
                let mods = scrollHotkey.modifiers.joined(separator: "+")
                print("  [scroll\(index)] \(mods.uppercased())+\(scrollHotkey.key.uppercased()) → scroll mode")
            }
        } else {
            print("KeybrClicker ready.")
        }
    }
    
func loadGlobalConfig() {
        let configURL = getConfigURL()
        let fileManager = FileManager.default
        
        guard fileManager.fileExists(atPath: configURL.path) else {
            print("ERROR: config.json not found at \(configURL.path), using defaults")
            return
        }
        
        do {
            let data = try Data(contentsOf: configURL)
            globalConfig = try JSONDecoder().decode(LayoutConfig.self, from: data)
            print("Loaded config with \(globalConfig?.hotkeys.count ?? 0) hotkey(s)")
        } catch {
            print("ERROR: Failed to load config.json: \(error)")
        }
    }
    
    func isHotkey(_ event: NSEvent) -> HotkeyConfig? {
        guard let config = globalConfig else {
            return nil
        }
        
        for hotkey in config.hotkeys {
            let requiredFlags = hotkey.getModifierFlags()
            guard let requiredKeyCode = hotkey.getKeyCode() else {
                continue
            }
            
            if event.modifierFlags.contains(requiredFlags) && event.keyCode == requiredKeyCode {
                return hotkey
            }
        }
        
        return nil
    }
    
    func isScrollHotkey(_ event: NSEvent) -> ScrollHotkeyConfig? {
        guard let config = globalConfig else {
            return nil
        }
        
        for scrollHotkey in config.scrollHotkeys {
            let requiredFlags = scrollHotkey.getModifierFlags()
            guard let requiredKeyCode = scrollHotkey.getKeyCode() else {
                continue
            }
            
            if event.modifierFlags.contains(requiredFlags) && event.keyCode == requiredKeyCode {
                return scrollHotkey
            }
        }
        
        return nil
    }
    
    func showGrid(_ hotkey: HotkeyConfig) {
        gridWindow.show(hotkey)
    }
    
    func showScrollWindow() {
        scrollWindow.show()
    }
}

func getMouseScreen() -> NSScreen? {
    let mouseLoc = NSEvent.mouseLocation
    for screen in NSScreen.screens {
        if screen.frame.contains(mouseLoc) {
            return screen
        }
    }
    return NSScreen.main
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
    
    func show(_ hotkey: HotkeyConfig) {
        guard let screen = getMouseScreen() else {
            print("ERROR: No screen found")
            return
        }
        gridView.previousApp = NSWorkspace.shared.frontmostApplication
        gridView.activeHotkey = hotkey
        print("Stored previous app: \(gridView.previousApp?.localizedName ?? "nil")")
        print("Active hotkey: \(hotkey.mouseButton.rawValue) click")
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

class ScrollWindow: NSWindow {
    var scrollView: ScrollView!
    
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
    
    init() {
        let screenFrame = NSScreen.main!.frame
        super.init(contentRect: screenFrame, styleMask: .borderless, backing: .buffered, defer: false)
        
        level = .screenSaver
        backgroundColor = .clear
        isOpaque = false
        hasShadow = false
        ignoresMouseEvents = true
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        hidesOnDeactivate = false
        
        scrollView = ScrollView(frame: NSRect(origin: .zero, size: screenFrame.size))
        contentView = scrollView
    }
    
    func show() {
        guard let config = globalConfig else {
            print("ERROR: No config loaded")
            return
        }
        scrollView.scrollKeys = config.scrollKeys
        scrollView.previousApp = NSWorkspace.shared.frontmostApplication
        print("Scroll mode activated")
        makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        makeFirstResponder(scrollView)
    }
    
    func hide() {
        ignoresMouseEvents = true
        level = .normal
        orderOut(nil)
        print("Scroll mode deactivated")
    }
}

class ScrollView: NSView {
    var scrollKeys: ScrollKeysConfig!
    var previousApp: NSRunningApplication?
    
    override var isFlipped: Bool { true }
    override var acceptsFirstResponder: Bool { true }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 {
            print("Escape pressed, exiting scroll mode")
            (window as? ScrollWindow)?.hide()
            return
        }
        
        guard let chars = event.characters?.lowercased(), chars.count == 1 else {
            return
        }
        
        let char = chars[chars.startIndex]
        handleScrollInput(char: char)
    }
    
    func handleScrollInput(char: Character) {
        let key = String(char).lowercased()
        let upKey = scrollKeys.up.lowercased()
        let downKey = scrollKeys.down.lowercased()
        let leftKey = scrollKeys.left.lowercased()
        let rightKey = scrollKeys.right.lowercased()
        
        var direction: ScrollDirection?
        
        if key == upKey {
            direction = .up
        } else if key == downKey {
            direction = .down
        } else if key == leftKey {
            direction = .left
        } else if key == rightKey {
            direction = .right
        }
        
        if let dir = direction {
            performScroll(direction: dir, amount: scrollKeys.amount)
        }
    }
    
    func performScroll(direction: ScrollDirection, amount: Int) {
        let scrollAmount = Int32(amount)
        
        var verticalScroll: Int32 = 0
        var horizontalScroll: Int32 = 0
        
        switch direction {
        case .up:
            verticalScroll = scrollAmount
        case .down:
            verticalScroll = -scrollAmount
        case .left:
            horizontalScroll = scrollAmount
        case .right:
            horizontalScroll = -scrollAmount
        }
        
        let source = CGEventSource(stateID: .hidSystemState)
        
        let scrollEvent = CGEvent(scrollWheelEvent2Source: source, units: .pixel, wheelCount: 2, wheel1: verticalScroll, wheel2: horizontalScroll, wheel3: 0)
        
        scrollEvent?.post(tap: CGEventTapLocation.cgSessionEventTap)
        
        print("Scrolled \(direction)")
    }
}

class GridView: NSView {
    var config: LayoutConfig!
    var state: GridState = .bigGrid
    var inputBuffer: String = ""
    var selectedBigCell: String = ""
    var previousApp: NSRunningApplication?
    var activeHotkey: HotkeyConfig?
    
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
        let configURL = getConfigURL()
        let fileManager = FileManager.default
        
        guard fileManager.fileExists(atPath: configURL.path) else {
            print("ERROR: config.json not found at \(configURL.path)")
            self.config = createDefaultLayoutConfig()
            return
        }
        
        do {
            let data = try Data(contentsOf: configURL)
            self.config = try JSONDecoder().decode(LayoutConfig.self, from: data)
            print("Loaded layout config: \(config.homeRow.count) columns, \(config.flattenedKeys.count) rows")
        } catch {
            print("ERROR: Failed to load config.json: \(error)")
            self.config = createDefaultLayoutConfig()
        }
    }
    
    func getBigCellCode(col: Int, row: Int) -> String {
        let colKey = config.homeRow[col]
        let rowKey = config.rowLabels[row]
        return colKey + rowKey
    }
    
    func isValidBigCell(_ code: String) -> Bool {
        guard code.count == 2 else { return false }
        let chars = Array(code)
        let colKey = String(chars[0])
        let rowKey = String(chars[1])
        return config.homeRow.contains(colKey) && config.rowLabels.contains(rowKey)
    }
    
    func getBigCellIndices(code: String) -> (col: Int, row: Int)? {
        guard code.count == 2 else { return nil }
        let chars = Array(code)
        let colKey = String(chars[0])
        let rowKey = String(chars[1])
        
        guard let colIndex = config.homeRow.firstIndex(of: colKey),
              let rowIndex = config.rowLabels.firstIndex(of: rowKey) else {
            return nil
        }
        
        return (colIndex, rowIndex)
    }
    
    func findMiniKeyPosition(_ key: String) -> (row: Int, col: Int)? {
        for (rowIndex, row) in config.layout.enumerated() {
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
                guard miniRow < config.layout.count,
                      miniCol < config.layout[miniRow].count else { continue }
                
                let key = config.layout[miniRow][miniCol]
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
            (window as? GridWindow)?.hide()
            return
        }
        
        let clickPoint = screenRect.origin
        
        let globalMaxY = NSScreen.screens.map { $0.frame.maxY }.max() ?? NSScreen.main!.frame.height
        let cgClickPoint = CGPoint(x: clickPoint.x, y: globalMaxY - clickPoint.y)
        
        let mouseButton = activeHotkey?.mouseButton ?? .left
        
        print("=== CLICK DEBUG ===")
        print("Big cell: \(bigCell), Mini key: \(miniKey)")
        print("Click point (CG): (\(cgClickPoint.x), \(cgClickPoint.y))")
        print("Mouse button: \(mouseButton.rawValue)")
        
        let source = CGEventSource(stateID: .hidSystemState)
        
        let downType: CGEventType
        let upType: CGEventType
        let cgButton: CGMouseButton
        
        switch mouseButton {
        case .left:
            downType = .leftMouseDown
            upType = .leftMouseUp
            cgButton = .left
        case .right:
            downType = .rightMouseDown
            upType = .rightMouseUp
            cgButton = .right
        case .middle:
            downType = .otherMouseDown
            upType = .otherMouseUp
            cgButton = .center
        }
        
        guard let downEvent = CGEvent(mouseEventSource: source, mouseType: downType, mouseCursorPosition: cgClickPoint, mouseButton: cgButton),
              let upEvent = CGEvent(mouseEventSource: source, mouseType: upType, mouseCursorPosition: cgClickPoint, mouseButton: cgButton) else {
            print("ERROR: Could not create mouse events")
            (window as? GridWindow)?.hide()
            return
        }
        
        if mouseButton == .middle {
            downEvent.setIntegerValueField(.mouseEventButtonNumber, value: 2)
            upEvent.setIntegerValueField(.mouseEventButtonNumber, value: 2)
        }
        
        downEvent.setIntegerValueField(.mouseEventClickState, value: 1)
        upEvent.setIntegerValueField(.mouseEventClickState, value: 1)
        
        let app = previousApp
        
        (window as? GridWindow)?.hide()
        
        DispatchQueue.global(qos: .userInteractive).async {
            usleep(HIDE_DELAY_US)
            
            if let app = app {
                print("Activating previous app: \(app.localizedName ?? "unknown")")
                app.activate(options: [])
            }
            
            usleep(FOCUS_DELAY_US)
            
            downEvent.post(tap: .cgSessionEventTap)
            usleep(CLICK_DELAY_US)
            upEvent.post(tap: .cgSessionEventTap)
            
            print("=== CLICK COMPLETE ===")
        }
    }
    
    func reset() {
        state = .bigGrid
        inputBuffer = ""
        selectedBigCell = ""
        needsDisplay = true
    }
}

let delegate = AppDelegate()
NSApplication.shared.delegate = delegate
NSApplication.shared.run()
