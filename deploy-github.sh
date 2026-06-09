#!/bin/bash
set -e
cd "$(dirname "$0")"
REPO="traffic-manager-vacancy"

# gh: brew или portable
if ! command -v gh >/dev/null 2>&1; then
  for p in /tmp/gh_2.69.0_macOS_arm64/bin/gh /tmp/gh_2.69.0_macOS_amd64/bin/gh; do
    [ -x "$p" ] && export PATH="$(dirname "$p"):$PATH" && break
  done
fi
command -v gh >/dev/null || { echo "Установите: brew install gh"; exit 1; }

gh auth status >/dev/null 2>&1 || { echo "Войдите в GitHub:"; gh auth login -w; }

rm -rf .git
git init -b main
git add -A
git commit -m "Сайт для кандидатов: условия и личный кабинет"

if git remote get-url origin 2>/dev/null; then
  git push -u origin main
else
  gh repo create "$REPO" --public --source=. --remote=origin --push
fi

OWNER=$(gh api user -q .login)
gh api -X POST "repos/$OWNER/$REPO/pages" -f build_type=legacy -f source[branch]=main -f source[path]=/ 2>/dev/null || \
gh api -X PUT "repos/$OWNER/$REPO/pages" -f build_type=legacy -f source[branch]=main -f source[path]=/ 2>/dev/null || true

echo ""
echo "ГОТОВО — отправляйте людям:"
echo "  https://$OWNER.github.io/$REPO/"
echo "  https://$OWNER.github.io/$REPO/chast-1.html"
echo "  https://$OWNER.github.io/$REPO/cabinet.html"
