. scripts/install-pre-commit.sh
if [ $? -ne 0 ]
then
  exit 1
fi

npx lint-staged
if [ $? -ne 0 ]
then
  exit 1
fi