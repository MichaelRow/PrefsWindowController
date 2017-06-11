//
//  PrefsWindowController.swift
//  PrefsWindowController
//
//  Created by Eru on 2016/12/30.
//
//

import Cocoa

fileprivate let PrefsControllerIdentifier = "PrefsWindowToolBar"

class PrefsWindow: NSWindow {
    
    override func keyDown(with theEvent: NSEvent) {
        switch Int(theEvent.keyCode) {
        case 53: //Escape Key
            orderOut(nil)
            close()
        default:
            super.keyDown(with: theEvent)
        }
    }
}

public class PrefsWindowController: NSWindowController, NSToolbarDelegate, NSWindowDelegate {
    
    fileprivate var toolbar: NSToolbar?
    fileprivate var toolbarIdentifiers: [String]
    fileprivate var activeViewController: PrefsWindowControllerProtocol?
    
    /// The preference panels this preferences window controller displays.
    public var viewControllers = [PrefsWindowControllerProtocol]() {
        
        didSet {
            self.setupToolbar();
        }
    }
    
    ///  Determines whether or not the toolbar's items are centered.
    ///
    ///  Defaults to true.
    ///
    public var centerToolbarItems = false {
        
        didSet {
            if centerToolbarItems != oldValue {
                setupToolbar()
            }
        }
    }
    
    // MARK: - Constructors
    
    public init() {
        
        toolbarIdentifiers = [String]()
        super.init(window: nil)
        let styleMask: NSWindowStyleMask = [.titled, .closable, .miniaturizable, .unifiedTitleAndToolbar, .texturedBackground]
        window = PrefsWindow(contentRect:NSMakeRect(0,0,100,100), styleMask: styleMask, backing: .buffered, defer: true)
        window?.isMovableByWindowBackground = false
    }
    
    required public init?(coder: NSCoder) {
        toolbarIdentifiers = [String]()
        super.init(coder:coder)
    }
    
    // MARK: Show & Hide Preferences Window
    
    ///  Show the preferences window.
    ///
    public func showPreferencesWindow() {
        
        if window!.isVisible {
            return
        }
        window?.alphaValue = 0.0
        showWindow(self)
        window?.makeKeyAndOrderFront(self)
        NSApplication.shared().activate(ignoringOtherApps: true)
        
        if window?.toolbar != nil {
            if toolbarIdentifiers.count > 0 {
                window?.toolbar!.selectedItemIdentifier = toolbarIdentifiers[(centerToolbarItems ? 1 : 0)]
            }
        }
        
        if activeViewController == nil && viewControllers.count > 0 {
            activateViewController(viewControllers[0], animate:false)
            window?.center()
        }
        window?.alphaValue = 1.0
    }
    
    ///
    ///  Hide the preferences window.
    ///
    public func dismissPreferencesWindow() {
        
        close()
    }
    
    // MARK: - Private
    
    fileprivate func setupToolbar() {
        
        window?.toolbar = nil
        toolbar = nil
        toolbarIdentifiers.removeAll()
        
        if viewControllers.count > 0 {
            toolbar = NSToolbar(identifier: PrefsControllerIdentifier)
            toolbar?.allowsUserCustomization = true
            toolbar?.autosavesConfiguration = true
            toolbar?.delegate = self
            window?.toolbar = toolbar
        }
    }
    
    fileprivate func activateViewController(_ viewController: PrefsWindowControllerProtocol, animate: Bool) {
        
        guard let preferencesViewController = viewController as? NSViewController else {
            return
        }
        
        let viewControllerFrame = preferencesViewController.view.frame
        
        guard let currentWindowFrame = window?.frame,
            let frameRectForContentRect = window?.frameRect(forContentRect: viewControllerFrame) else {
                return
        }
        
        let deltaX = NSWidth(currentWindowFrame) - NSWidth(frameRectForContentRect)
        let deltaY = NSHeight(currentWindowFrame) - NSHeight(frameRectForContentRect)
        let newWindowFrame = NSMakeRect(NSMinX(currentWindowFrame) + (centerToolbarItems ? deltaX / 2 : 0), NSMinY(currentWindowFrame) + deltaY, NSWidth(frameRectForContentRect), NSHeight(frameRectForContentRect))
        
        window?.title = viewController.preferencesTitle() as String
        
        let newView = preferencesViewController.view
        newView.frame.origin = NSMakePoint(0, 0)
        newView.alphaValue = 0.0
        newView.autoresizingMask = NSAutoresizingMaskOptions()
        
        if let previousViewController = activeViewController as? NSViewController {
            previousViewController.view.removeFromSuperview()
        }
        
        window?.contentView!.addSubview(newView)
        
        if let firstResponder = viewController.firstResponder?() {
            window?.makeFirstResponder(firstResponder)
        }
        
        NSAnimationContext.runAnimationGroup({
            (context: NSAnimationContext) -> Void in
            context.duration = (animate ? 0.25 : 0.0)
            context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            self.window?.animator().setFrame(newWindowFrame, display: true)
            newView.animator().alphaValue = 1.0
        }) {
            () -> Void in
            self.activeViewController = viewController
        }
    }
    
    fileprivate func viewControllerWithIdentifier(_ identifier: String) -> PrefsWindowControllerProtocol? {
        
        for viewController in viewControllers {
            if viewController.preferencesIdentifier() == identifier {
                return viewController
            }
        }
        return nil
    }
    
    // MARK: Toolbar Delegate Protocol
    
    public func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: String, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        
        if itemIdentifier == NSToolbarFlexibleSpaceItemIdentifier {
            return nil
        }
        guard let viewController = viewControllerWithIdentifier(itemIdentifier) else {
            return nil
        }
        let identifier = viewController.preferencesIdentifier()
        let label = viewController.preferencesTitle()
        let icon = viewController.preferencesIcon()
        
        let toolbarItem = NSToolbarItem(itemIdentifier: identifier as String)
        toolbarItem.label = label
        toolbarItem.paletteLabel = label
        toolbarItem.image = icon
        if let tooltip = viewController.preferencesToolTip?() {
            toolbarItem.toolTip = tooltip
        }
        toolbarItem.target = self
        toolbarItem.action = #selector(PrefsWindowController.toolbarItemAction(_:))
        
        return toolbarItem
    }
    
    public func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [String] {
        if toolbarIdentifiers.count == 0 && viewControllers.count > 0 {
            if centerToolbarItems {
                toolbarIdentifiers.append(NSToolbarFlexibleSpaceItemIdentifier)
            }
            for viewController in viewControllers {
                toolbarIdentifiers.append(viewController.preferencesIdentifier())
            }
            if centerToolbarItems {
                toolbarIdentifiers.append(NSToolbarFlexibleSpaceItemIdentifier)
            }
        }
        return toolbarIdentifiers
    }
    
    public func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [String] {
        
        return toolbarDefaultItemIdentifiers(toolbar)
    }
    
    public func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [String] {
        
        return toolbarDefaultItemIdentifiers(toolbar)
    }
    
    func toolbarItemAction(_ toolbarItem: NSToolbarItem) {
        
        if  activeViewController == nil || activeViewController!.preferencesIdentifier() == toolbarItem.itemIdentifier {
            return
        }
        
        guard let destViewController = viewControllerWithIdentifier(toolbarItem.itemIdentifier) else {
            self.window?.toolbar?.selectedItemIdentifier = activeViewController?.preferencesIdentifier()
            return
        }
        
        guard let canResign = activeViewController!.canResignActiveView?() else {
            activateViewController(destViewController, animate: true)
            return
        }
        
        if canResign {
            activateViewController(destViewController, animate: true)
        } else {
            DispatchQueue.main.async {
                destViewController.refuseResignActiveView?()
            }
            self.window?.toolbar?.selectedItemIdentifier = activeViewController?.preferencesIdentifier()
        }
    }
    
    // MARK: - Window Delegate
    
    public func windowShouldClose(_ sender: Any) -> Bool {
        guard let canClose = activeViewController?.canClosePrefsWindow?() else {
            return true;
        }
        if canClose {
            return true
        } else {
            DispatchQueue.main.async {
                self.activeViewController!.refuseClosePrefsWindow?()
            }
            return false
        }
    }
}
