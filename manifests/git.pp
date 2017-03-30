define backup::git() {
  backup::model { "git-$name":
    content => template("backup/git.rb")
  }
}
