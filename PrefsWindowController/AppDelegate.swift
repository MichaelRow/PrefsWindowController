//
//  AppDelegate.swift
//  PrefsWindowController
//
//  Created by Eru on 2016/12/30.
//
//

import Cocoa
import PreferencesWindow

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    var prefs: PrefsWindowController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        window.orderOut(nil)
        
        prefs = PrefsWindowController()
        prefs?.viewControllers = [VC1(),VC2()]
        prefs?.showPreferencesWindow()
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

