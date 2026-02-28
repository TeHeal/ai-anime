env "local" {
  src = "file://sch/schema.sql"
  dev = "docker://postgres/16/dev?search_path=public"

  migration {
    dir = "file://migration"
  }
}
