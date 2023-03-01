if [ "$#" -ne 2 ]; then
    echo "This script finds any commits that are missing in one branch but are present in another."
    echo "The commit message headers must be the same between the branches."
    echo "The command must be run from within the repository."
    echo "Usage: $0 <mainline branch> <release branch>"
    exit 1
fi

MAINLINE_BRANCH="$1"
RELEASE_BRANCH="$2"

ROOT_COMMIT="$(git merge-base "$MAINLINE_BRANCH" "$RELEASE_BRANCH")"

git log --oneline --ancestry-path "${ROOT_COMMIT}..${MAINLINE_BRANCH}" > /tmp/mainline_commits.txt
git log --oneline --ancestry-path "${ROOT_COMMIT}..${RELEASE_BRANCH}" > /tmp/release_commits.txt

while read RELEASE_COMMIT;
do
  RELEASE_MESSAGE=$(echo "$RELEASE_COMMIT" | cut -f 2- -d ' ' -)
  if ! grep -q "$RELEASE_MESSAGE" /tmp/mainline_commits.txt;
  then
    echo "$RELEASE_COMMIT"
  fi
done < /tmp/release_commits.txt