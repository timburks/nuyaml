;; Convenience method for (ivar (id) outlet1 (id) outlet2 (id) outlet3)
;; As of now, all outlets are id's, so we don't need to worry about types.
(macro outlets
     (margs each: (do (__n)
                      (_class addInstanceVariable: (__n stringValue) signature: "@"))))

(class NSNull
     (- (id) nil? is t))

(class NSObject
     (- (id) nil? is f))

;; Ensures that the named framework is loaded from the .app's framework dir.
(macro load-framework
     (set __path (((NSBundle mainBundle) privateFrameworksPath) 
                  stringByAppendingPathComponent: (car margs)))
     (set __bundle (NSBundle bundleWithPath:__path))
     (__bundle load))