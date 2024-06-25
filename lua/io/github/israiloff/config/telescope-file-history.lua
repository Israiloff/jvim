require('file_history').setup {
  backup_dir = "~/.file-history-git",
  git_cmd = "git"
}
require('telescope').load_extension('file_history')
