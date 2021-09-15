pro test_git

  
; Set up a series of "git" programs to execute git commands.
; Will assume all "repos" are in IDL_PROJECTS and will cd to that directory based on the input "repo"
;   1) git_status, repo - Use to check the status of the repo
;   2) git_pull, repo - Use to pull information to the local
;   3) git_add, repo, file - Use to indicate the file to add to the repo
;   4) git_commit, file, message - Use to commit the changes with the associated message
;   5) git_push, repo - Use to "push" the changes to the repo
; Will want to incorporate into make_program and file_doc
; Should add dialog boxes to confirm certain steps and add the commit message if not provided
;  
  
  
  cd, '/Users/kimberly.hyde/nadata/IDL_PROJECTS/TEST'
  
  cmd = "git status"
  spawn, cmd, log, exit_status=es
  stop
  
  cmd = "git add 'test_git.pro'"
  spawn, cmd
  stop
  
  cmd = "git commit -m 'new test git pro'"
  print, cmd
  spawn, cmd
  stop
  
  cmd = "git push"
  spawn, cmd
  stop
  
  cmd = "git status"
  spawn, cmd
  stop

end