//
//  VC2.swift
//  PrefsWindowController
//
//  Created by Eru on 2017/6/11.
//
//

import Cocoa

class VC2: NSViewController, PrefsWindowControllerProtocol {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func preferencesIdentifier() -> String {
        return "VC2"
    }
    
    func preferencesTitle() -> String {
        return "VC2"
    }
    
    func preferencesIcon() -> NSImage {
        return NSImage(named: NSImageNamePreferencesGeneral)!
    }
    
    
    
}
