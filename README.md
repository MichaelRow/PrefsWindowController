# PrefsWindowController
Preferences Window Controller For macOS

### How to Use
It's really easy, just setup the prefs window controller, and then add VC that confirm to PrefsWindowControllerProtocol to it.

1. VC Setup

    Just implementate 3 required methods:
    
```
class VC1: NSViewController, PrefsWindowControllerProtocol {
    
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
```

2. Prefs Setup

```
let prefs = PrefsWindowController()  
prefs.viewControllers = [VC1(),VC2()]  
```

3. Show Prefs

```
prefs.showPreferencesWindow()
```
4. Hide Prefs

```
prefs.dismissPreferencesWindow()
```
