//
//  VC1.swift
//  PrefsWindowController
//
//  Created by Eru on 2017/6/11.
//
//

import Cocoa

class VC1: NSViewController, PrefsWindowControllerProtocol {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func preferencesIdentifier() -> String {
        return "VC1"
    }
    
    func preferencesTitle() -> String {
        return "VC1"
    }
    
    func preferencesIcon() -> NSImage {
        return NSImage(named: NSImageNameAdvanced)!
    }

}
