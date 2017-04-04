#!/usr/bin/env bash

set -e

count=$(git status --porcelain | wc -l)
if test $count -gt 0; then
  git status
  echo "Not all files have been committed in Git. Release aborted"
  exit 1
fi

git checkout deploy
git pull origin deploy --tags

select_part() {
  local choice=$1
  case "$choice" in
      "Patch release")
          bumpversion patch
          ;;
      "Minor release")
          bumpversion minor
          ;;
      "Major release")
          bumpversion major
          ;;
      *)
          read -p "Version > " version
          bumpversion --new_version=$version $part
          ;;
  esac
}

if test -z "(git rev-list --max-count 1 deploy..master)"; then
  git merge --no-ff master
  latest_version=$(git describe --abbrev=00 || \
    (bumpversion --dry-run --list patch | grep current_version | sed -r s,"^.*=",,) || echo '0.0.1')
  echo
  echo "Current commit has not been tagged with a version. Latest known version is $latest_version."
  echo
  echo 'What do you want to release?'
  PS3='Select the version increment> '
  options=("Patch release" "Minor release" "Major release" "Release with a custom version")
  select choice in "${options[@]}";
  do
    select_part "$choice"
    break
  done
  updated_version=$(bumpversion --dry-run --list patch | grep current_version | sed -r s,"^.*=",,)
  echo "Add a signoff for this deployment"
  echo "* $(date +"%d/%m/%Y") v$updated_version - $USER" >> signoffs.md
  until false
  do
    vi signoffs.md
    git diff
    read -p "Are you happy with the signoff message? [N/y/q] > " ok
    case "$ok" in
      y|Y)
        break
        ;;
      q|Q|x|X)
        echo "Release aborted"
        exit 1
        ;;
    esac
  done
  git commit -S -m "Signoff" signoffs.md
  # Bumpversion v0.5.3 does not support annotated tags nor signed tags
  git tag -s  -a -m "Signoff from $USER" "$updated_version"
fi

git push origin deploy
git push origin deploy --tags

git checkout master
git merge deploy
git push

# Notify on slack
set -e
get_script_dir () {
     SOURCE="${BASH_SOURCE[0]}"

     while [ -h "$SOURCE" ]; do
          DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
          SOURCE="$( readlink "$SOURCE" )"
          [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
     done
     cd -P "$( dirname "$SOURCE" )"
     pwd
}
export WORKSPACE=$(get_script_dir)
sed "s/USER/${USER^}/" $WORKSPACE/slack.json > $WORKSPACE/.slack.json
sed -i.bak "s/VERSION/$(git describe)/" $WORKSPACE/.slack.json
curl -k -X POST --data-urlencode payload@$WORKSPACE/.slack.json https://hbps1.chuv.ch/slack/dev-activity
rm -f $WORKSPACE/.slack.json
rm -f $WORKSPACE/.slack.json.bak
