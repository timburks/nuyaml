(task "build" is
      (SH "cd libsyck; nuke")
      (SH "cd yaml; nuke"))

(task "clobber" is
      (SH "cd libsyck; nuke clobber")
      (SH "cd yaml; nuke clobber"))

(task "test" => "build" is
      (SH "nutest test/test_yaml.nu"))

(task "default" => "build")
