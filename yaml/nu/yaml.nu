;; Main file for the YAML framework

;;; These are the comments that Will Thimbleby put in his Cocoa code, upon which
;;; I was almost comically dependent. Kudos to him for making my life much easier.

;; -toYAML and +fromYAML are the methods you will need to override for your classes
;; overide -toYAML to return a NSArray, NSDictionary, NSString or NSNumber

;; overide +fromYAML to read the same back in
;; [MyClass fromYAML:[me toYAML]] should give a copy of me 


;;; To be honest, I'm not sure why we need to add tags - I suppose that one could argue
;;; that the YAML serializations of objects deserve to know what class they are, but that
;;; seems pretty weak. Hell, if you need to do it, fix this yourself.

;; -wrappedYAMLData is a sibling of -toYAML
;; it wraps up the -toYAML data in a wrapper that also contains the Class
;; -unwrapYAMLData is the opposite of -wrappedYAMLData
;; it will decode the wrapped up data of -yamlData
;; [[me yamlData] unwrapYAMLData] should give a copy of me 


(load "beautify")             ; For spaces-related functions
(load "YAML:helpers")         ; Accessors.

; Declared in SyckInput.m in /objc - it does all the heavy lifting.
(global syck_yaml_parse (NuBridgedFunction functionWithName: "yaml_parse"
                             signature: "@@"))

; Please see the above comments questioning the utility of this class.
(class YAMLWrapper is NSObject
     
     (reader tag)   ; Accessors = own.
     (reader data)
     
     (+ (id) wrapperWithData:(id)d tag:(id)tag is
        ((YAMLWrapper alloc) initWithData: d tag: tag))
     
     (- (id) initWithData:(id)data tag:(id)tag is
        (set @data data)
        (set @tag tag)
        self)
     
     ; Necessary? Who the hell knows?
     (- (id) copyWithZone:(id)zone is 
        ((YAMLWrapper allocWithZone: z) initWithData: @data tag: @tag))
     
     (- (id) unwrapYAMLData is
        (tag objectWithYAML: data)))

(class NSObject
     ; NSArray. NSDictionary, NSString and NSNumber override this.
     (+ (id) goesDirectlyToYAML? is 0)
     
     (- (id) toYAML is (self description))
     
     (- (id) wrappedYAMLData is 
        (unless ((self class) goesDirectlyToYAML?)
                (YAMLWrapper wrapperWithData: (self toYAML) tag: (self class))
                (else
                     (self toYAML))))
     
     (+ (id) fromYAML:(id)obj is 
        (syck_yaml_parse obj))
     
     (- (id) yamlDescription is (self yamlDescriptionWithIndent: 0))
     
     (- (id) yamlDescriptionWithIndent:(id)spaces is 
        ((self toYAML) yamlDescriptionWithIndent: spaces)))

(class NSNumber
     
     (+ (id) goesDirectlyToYAML? is t)
     
     (+ (id) objectWithYAML:(id)data is
        (NSNumber numberWithFloat: (data floatValue)))
     
     (- (id) toYAML is (self description)))

(class NSString
     
     (+ (id) goesDirectlyToYAML? is t)
     
     (+ (id) fromYAML:(id)obj is 
        (syck_yaml_parse obj))
     
     (- (id) toYAML is self)
     
     ; Counts the number of spaces before the beginning of a string.
     (- (id) indentLevel is 
        (((/^(\ )+/ findInString: self) group) length))
     
     ; Returns a new string with the specified number of spaces added to it.
     (- (id) indentSpaces:(id)num is 
        ((NSString spaces:num) stringByAppendingString: self))
     
     ; If this contains a newline, then you have to format all specially-like.
     (- (id) yamlDescriptionWithIndent:(id)spaces is 
        (unless (/\n/ findInString: self)
                self
                (else
                     "|-\n#{(self indentSpaces: spaces)}"))))


(class NSDictionary
     
     (+ (id) goesDirectlyToYAML? is t)
     
     (+ (id) fromYAML:(id)obj is 
        (syck_yaml_parse obj))
     
     (- (id) toYAML is self)
     
     (- (id) yamlDescriptionWithIndent:(id)indent is 
        (set description "\n")
        
        (if (== (self count) 0)
            "{}"
            (else
                 (set sortedKeys ((self allKeys) sortedArrayUsingSelector: "caseInsensitiveCompare:"))
                 (set lastobject (sortedKeys lastObject))
                 
                 ; Getting the longest key length. Now you're thinking with portals!
                 (set longest-key
                      ((sortedKeys reduce: 
                            (do (left right)
                                (if (> (left length) (right length))
                                    left
                                    (else right)))
                            from: "") length))
                 
                 (sortedKeys each: 
                      (do (key)
                          (set object (self objectForKey: key))
                          (set tag "")
                          (unless ((self class) goesDirectlyToYAML?)
                                  (set tag "!!#{(object className)}"))
                          (set object (object toYAML))
                          
                          (description appendString: (NSString spaces: indent))
                          (description appendString: 
                               (key stringByPaddingToLength: longest-key
                                    withString: " "
                                    startingAtIndex: 0))
                          (description appendString: ": ")
                          (description appendString: tag)
                          (description appendString: (object yamlDescriptionWithIndent: (+ indent 2)))
                          (unless (eq key lastobject)
                                  (description appendString: "\n"))))
                 description)))
     
     (- (id) wrappedYAMLData is 
        (set result (dict))
        ((self allKeys) each: (do (key)
                                  (set obj (self objectForKey: key))
                                  (unless ((obj class) goesDirectlyToYAML?)
                                          (result setValue: (obj wrappedYAMLData) forKey: key))
                                  (else
                                       (result setObject: 
                                               (YAMLWrapper wrapperWithData: (obj wrappedYAMLData) tag: (obj class))))))
        result)
     
     (- (id) unwrapYAMLData is 
        (self map: unwrapYAMLData))
     
     (- (id) map:(id)block is 
        (set ret-value (dict))
        ((self allKeys) each: (do (key)
                                  (ret-value setObject: (block (self objectForKey: key))
                                       forKey: key)))
        ret-value))

(class NSArray
     
     (+ (id) goesDirectlyToYAML? is t)
     
     (+ (id) fromYAML:(id)obj is 
        (syck_yaml_parse obj))
     
     (- (id) toYAML is self)
     
     (- (id) wrappedYAMLData is 
        (self map: (do (item) (item wrappedYAMLData))))
     
     (- (id) unwrapYAMLData is 
        (self map: unwrapYAMLData))    
     
     (- (id) yamlDescriptionWithIndent:(id)indent is 
        (set description "\n")
        (if (== (self count) 0) 
            "[]"
            (else
                 (self each: 
                       (do (object)
                           (set tag "")
                           (unless ((object class) goesDirectlyToYAML?)
                                   (set tag "!!#{(object className)}"))
                           (set yaml-object (object toYAML))
                           (description appendString: (NSString spaces: indent))
                           (description appendString: "- ")
                           (description appendString: tag)
                           (description appendString: (yaml-object yamlDescriptionWithIndent: (+ 2 indent)))
                           (unless (eq object (self lastObject))
                                   (description appendString: "\n"))))))
        description))

(class NuCell
     (- (id) toYAML is
        (NSArray arrayWithList: self)))

(class NuSymbol
     (- (id) length is 
        ((self stringValue) length)))