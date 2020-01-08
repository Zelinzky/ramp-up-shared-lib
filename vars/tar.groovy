def compressCurrentDirectory(String name){
    echo "file ./artifacts/${name}.tar.gz will be crated with current directory content"
    sh "mkdir -p artifacts && tar --exclude=./artifacts -czvf artifacts/${name}.tar.gz ."
}