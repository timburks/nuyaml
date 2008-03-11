(task "build" is
      (SH "cd libsyck; nuke")
      (SH "cd yaml; nuke")
      (SH "rm -rf ./YAML.framework")
      (SH "mv ./yaml/YAML.framework ./"))

(task "clobber" is
      (SH "cd libsyck; nuke clobber")
      (SH "cd yaml; nuke clobber")
      (SH "rm -rf ./YAML.framework"))
      
(task "install" => "build" is
     (SH "sudo rm -rf /Library/Frameworks/YAML.framework")
     (SH "ditto YAML.framework /Library/Frameworks/YAML.framework"))

(task "test" => "build" is
      (SH "nutest test/test_yaml.nu"))

(task "default" => "build")
