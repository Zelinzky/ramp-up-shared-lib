if [ "$1" == "" ]; then
  echo 'please enter the url of the artifact repository'
fi

curl -s -O "$1"

for a in *.tar.gz; do
  a_dir=$(expr "$a" : '\(.*\).tar.gz')
  tar -xvzf "$a" --one-top-level
  rm "$a"
done

cd "$a_dir" || exit
