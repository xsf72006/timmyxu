# This script will push Jekyll branches.

warn () {
  printf '\e[36m%s\e[m\n' "$*"
}

log () {
  unset PS4
  sx=$(( set -x
         : "$@" )2>&1)
  warn "${sx:2}"
  eval "${sx:2}"
}

cd /srv
select repo in $(find -maxdepth 2 -name css | sed 's,./,,;s,/css,,')
do
  break
done
cd $repo

# Push source branch
log git checkout -q source
type git-ac.sh >/dev/null && git-ac.sh || exit
git push origin source || exit

# Push master branch
jekyll build || exit
grep --color -r 'Liquid.error' . && exit
log git checkout -q master
git rm -qr .
cp -r _site/. .
rm -r _site
git-ac.sh
git push origin master || exit
log git checkout source