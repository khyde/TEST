pro test_git

  cd, '/Users/kimberly.hyde/nadata/IDL_PROJECTS/TEST'
  
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
  
  cmd = "get status"
  spawn, cmd
  stop

end