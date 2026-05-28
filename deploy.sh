#!/usr/bin/env bash
# =========================================================================
# Texnoptom ERP — bitta buyruq bilan GitHub'ga push
#
# Avval bir marta ushbu skriptdagi 3 ta o'zgaruvchini to'ldiring:
#   GITHUB_USER, REPO_NAME, GITHUB_PAT
#
# Keyin terminalda:
#   bash deploy.sh
# =========================================================================

set -e

# ----- SOZLAMALAR -----
GITHUB_USER="abdulazizsirojkurs-spec"
REPO_NAME="ERP.uz"                    # GitHub'da ochgan yangi repo nomi
BRANCH="main"

GIT_EMAIL="xontorayevabdulaziz@gmail.com"
GIT_NAME="Abdulaziz"

# Token alohida `.deploy-secrets` faylda saqlanadi (gitignored,
# kodga commit qilinmaydi). Skript shu fayldan o'qiydi.
# -----------------------------------------------

# Colors
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
NC="\033[0m"

# Skript joylashgan papkaga o'tamiz
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo -e "${GREEN}===> Loyiha papkasi: $SCRIPT_DIR${NC}"

# ----- Tokenni .deploy-secrets fayldan o'qish -----
if [ -f "$SCRIPT_DIR/.deploy-secrets" ]; then
  # shellcheck disable=SC1091
  source "$SCRIPT_DIR/.deploy-secrets"
fi

# ----- Validatsiyalar -----
if [ -z "$GITHUB_PAT" ]; then
  echo -e "${RED}XATO:${NC} GITHUB_PAT topilmadi."
  echo "Quyidagi faylni yarating: $SCRIPT_DIR/.deploy-secrets"
  echo "Ichiga shu qatorni yozing:"
  echo "  GITHUB_PAT=\"ghp_xxxxxxxxxxxxx\""
  echo "Token olish: https://github.com/settings/tokens"
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  echo -e "${RED}XATO:${NC} 'git' topilmadi."
  echo "macOS Command Line Tools'ni o'rnating: xcode-select --install"
  exit 1
fi

# ----- 1. Toza git init -----
echo -e "${GREEN}===> 1/3: Toza git repo yaratish${NC}"
rm -rf .git
git init -q
git checkout -b "$BRANCH" -q
git config user.email "$GIT_EMAIL"
git config user.name "$GIT_NAME"

# ----- 2. Commit -----
echo -e "${GREEN}===> 2/3: Fayllarni commit qilish${NC}"
git add -A
COUNT=$(git diff --cached --name-only | wc -l | tr -d ' ')
echo -e "       ${COUNT} ta fayl tayyor"
git commit -q -m "feat: initial release — Texnoptom ERP (Vercel-ready)"

# ----- 3. Push -----
echo -e "${GREEN}===> 3/3: GitHub'ga force-push${NC}"
AUTH_URL="https://${GITHUB_PAT}@github.com/${GITHUB_USER}/${REPO_NAME}.git"
git remote remove origin 2>/dev/null || true
git remote add origin "$AUTH_URL"

if git push -f origin "$BRANCH"; then
  # Tokenni remote URL'dan tozalash (xavfsizlik)
  git remote set-url origin "https://github.com/${GITHUB_USER}/${REPO_NAME}.git"

  echo ""
  echo -e "${GREEN}====================================================${NC}"
  echo -e "${GREEN}✓ Muvaffaqiyatli push!${NC}"
  echo -e "${GREEN}====================================================${NC}"
  echo ""
  echo -e "  Repo:    https://github.com/${GITHUB_USER}/${REPO_NAME}"
  echo -e "  Branch:  ${BRANCH}"
  echo -e "  Commit:  $(git rev-parse --short HEAD)"
  echo ""
  echo -e "${YELLOW}Keyingi qadamlar:${NC}"
  echo -e "  1) Vercel'ga GitHub repo'ni import qiling: https://vercel.com/new"
  echo -e "  2) Environment Variables qo'shing:"
  echo -e "     NEXT_PUBLIC_SUPABASE_URL"
  echo -e "     NEXT_PUBLIC_SUPABASE_ANON_KEY"
  echo -e "  3) Deployment Protection: 'Disabled' yoki 'Only Preview Deployments'"
  echo -e "  4) Supabase SQL Editor'da supabase_rbac.sql ni run qiling"
  echo ""
  echo -e "${RED}MUHIM:${NC} GitHub PAT'ni revoke qilishni unutmang!"
  echo -e "   https://github.com/settings/tokens"
  echo ""
else
  echo ""
  echo -e "${RED}XATO:${NC} Push muvaffaqiyatsiz."
  echo "Sabablari bo'lishi mumkin:"
  echo "  - GITHUB_PAT noto'g'ri yoki muddati o'tgan"
  echo "  - REPO_NAME GitHub'da hali mavjud emas (avval https://github.com/new orqali yarating)"
  echo "  - GITHUB_USER noto'g'ri"
  exit 1
fi
