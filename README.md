# smeserver

Notes on managing a Koozali SME server configuration using git

Instructions:
1. Create a repository for your scripts in github.  I named mine "smeserver".

   If your git account is using 2FA, you will need to upload your server's public ssh key to your git account and use the 'git@' protocol when pushing or pulling to/from the repository.
  
1. Initialize a git repository in root's home folder on your SME server - eg "/root/git"

   ```
   mkdir ~/git
   cd ~/git
   echo "# smeserver" >> README.md
   git init
   git add README.md
   git commit -m "first commit"
   git remote add origin git@github.com:mmccarn/smeserver.git
   git config --global user.name "Michael J McCarn"
   git config --global user.email mmccarn-github@mmsionline.us
   git commit --amend --author='Michael J McCarn <mmccarn-github@mmsionline.us>'
   git push -u origin master
   ```

1. Gather any existing customizations into your git repository, and replace the original locations with symlinks

   ```
   # templates-custom
   mv /etc/e-smith/templates-custom /root/git
   ln -s /root/git/templates-custom /etc/e-smith/
   
   # local scripts
   # (I keep local scripts in /root/bin, which is added to $PATH if it exists)
   mv ~/bin ~/git
   ln -s ~/git/bin ~/
   ```
   
1. Push the edits to git

   ```
   git add --all 
   git commit -am "Gather scripts & templates into git"
   git push
   ```

1. Document future changes and push them to git
  * edit your script(s)
  * commit the changes including a commit message using ```git commit -m "here's what changed"```
  * push the changes to git using ```git push```
