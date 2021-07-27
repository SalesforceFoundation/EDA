if [ ! -d node_modules ] || [ \"$(cat .node_hash)\" != \"$(cat yarn.lock | npx hasha)\" ]; 
then 
    . scripts/update-dependencies.sh 
fi
