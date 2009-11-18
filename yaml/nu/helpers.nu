(function make-setter-name (oldName) 
     (set newName "set")
     (newName appendString:((oldName substringToIndex:1) capitalizedString))
     (newName appendString:((oldName substringFromIndex:1)))
     (newName appendString:":")
     newName)

(macro-0 reader 
     (set __name ((car margs) stringValue)) 
     (_class addInstanceVariable:__name 
             signature:"@") 
     (_class addInstanceMethod:__name 
             signature:"@@:" 
             body:(do () (self valueForIvar:__name)))) 

(macro-0 writer 
     (set __name ((car margs) stringValue)) 
     (_class addInstanceVariable:__name 
             signature:"@") 
     (_class addInstanceMethod:(make-setter-name __name) 
             signature:"v@:" 
             body:(do (new) (self setValue:new forIvar:__name)))) 

(macro-0 accessor 
     (set __name ((car margs) stringValue)) 
     (_class addInstanceVariable:__name 
             signature:"@") 
     (_class addInstanceMethod:__name 
             signature:"@@:" 
             body:(do () (self valueForIvar:__name))) 
     (_class addInstanceMethod:(make-setter-name __name) 
             signature:"v@:" 
             body:(do (new) (self setValue:new forIvar:__name))))
