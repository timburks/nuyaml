;; @file main.nu
;; @discussion Entry point for the SizeMatters program.
;; No actual application code goes in here. It's all loaded in controller.nu.
;;
;; @copyright Copyright © 2007 Patrick Thomson

(load "Nu:nu")		;; basics
(load "Nu:cocoa")	;; cocoa definitions
(load "controller") ;; application controller

;; this makes the application window take focus when we've started it from the terminal
((NSApplication sharedApplication) activateIgnoringOtherApps:YES)

;; run the main Cocoa event loop
(NSApplicationMain 0 nil)
