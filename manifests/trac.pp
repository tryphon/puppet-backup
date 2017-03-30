define backup::trac() {
  backup::model { "trac-$name":
    content => template("backup/trac.rb")
  }
}
