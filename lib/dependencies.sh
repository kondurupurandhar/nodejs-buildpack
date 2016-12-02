install_node_modules() {
  local build_dir=${1:-}

  if [ -e $build_dir/package.json ]; then
    cd $build_dir

    if [ -e $build_dir/npm-shrinkwrap.json ]; then
      echo "Installing node modules (package.json + shrinkwrap)"
    else
      echo "Installing node modules (package.json)"
    fi
    cat package.json | xargs -0 node -e "console.log(JSON.stringify(JSON.parse(process.argv[1]).dependencies, null, 2))" | while read line
    do
       if [ "$line" != '{' -a "$line" != '}' ]
       then
           a=`echo "$line"| sed -e 's/\"//g' | sed -e 's/,//g'|sed -e 's/ //g'`
           echo $a 
           module_name=`echo $a | cut -d':' -f1`
           version=`echo $a | cut -d':' -f2`
           
             echo "$module_name -- $version"
              echo "Install -- ${module_name}@${version}"
              #npm install --unsafe-perm --userconfig ${module}@${version}
         
      fi     
    done
    #npm install --unsafe-perm --userconfig $build_dir/.npmrc 2>&1
  else
    echo "Skipping (no package.json)"
  fi
}

rebuild_node_modules() {
  local build_dir=${1:-}

  if [ -e $build_dir/package.json ]; then
    cd $build_dir
    echo "Rebuilding any native modules"
    npm rebuild --nodedir=$build_dir/.heroku/node 2>&1
    if [ -e $build_dir/npm-shrinkwrap.json ]; then
      echo "Installing any new modules (package.json + shrinkwrap)"
    else
      echo "Installing any new modules (package.json)"
    fi
    npm install --unsafe-perm --userconfig $build_dir/.npmrc 2>&1
  else
    echo "Skipping (no package.json)"
  fi
}
