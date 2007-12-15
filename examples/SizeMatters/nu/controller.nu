;; @file controller.nu
;; @discussion Controller for Plist -> YAML converter.
;;
;; @copyright Copyright © 2007 Patrick Thomson

(load "helpers") ;; Macros for convenience
(load-framework "YAML.framework") ;; Ensuring we load the YAML framework.

;; Main controller for the SizeMatters application.
(class SMController is NSObject
     
     ; Declaring IB outlets with the helper macro.
     (outlets resultsPanel
              resultsText
              xmlArea
              yamlArea
              mainWindow)
     
     ;; Ensuring the application's main window is selected at startup.
     (imethod (void) awakeFromNib is
          (@mainWindow makeKeyAndOrderFront: nil))
     
     ;; Hooks up to the conversion button in the nib.
     (imethod (void) convertXMLtoYAML:(id) sender is 
          ;; Creating an NSDictionary from the contents of the xml text area...
          (set plist-repr ((@xmlArea string) propertyList))
          ;; ...and calling yamlDescription on that text.
          (@yamlArea setString: (plist-repr yamlDescription))
          (@resultsText setStringValue: "The XML area contains #{((@xmlArea string) length)} characters, whereas the YAML area contains #{((@yamlArea string) length)} characters."))
     
     ;; Returns the plist file name the user selects, or nil if cancelled.
     (imethod (id) fileNameFromPanelWithTypes:(id) types is
          (set panel (NSOpenPanel openPanel))
          ;; The set: method might be my favorite Nu idiom.
          (panel set: (canChooseFiles: YES
                       canChooseDirectories: NO
                       allowsMultipleSelection: NO))
          (set return-code (panel runModalForDirectory: nil file: nil types:types))
          (if (eq return-code NSOKButton)
              (panel filename)
              (else nil)))
     
     (- openXMLFile:(id) sender is
        (set the-file (self fileNameFromPanelWithTypes: (array "xml" "plist")))
        (unless (the-file nil?)
                (self copyFile: the-file toTextArea: @xmlArea)))
     
     (- copyFile:(id) name toTextArea:(id) area is 
        (set contents ((NSString alloc) initWithContentsOfFile: name
                       encoding: NSUTF8StringEncoding
                       error: nil))
        
        (area setString: contents)))