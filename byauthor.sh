#!/bin/bash
OWNER=IQSS
REPO=dataverse
# issues and PRs, adjust accordingly
PAGES=14
for i in $(seq 1 $PAGES)
do
  echo "Fetching page $i..."
  #  -H "Authorization: Bearer <YOUR-TOKEN>" \
  curl -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/$OWNER/$REPO/issues?per_page=100&page=$i" > $i.json
  sleep 1;
  cat $i.json | jq -r '.[] | [.html_url, .user.login, .author_association] | @tsv' >> issues-prs.tsv
done
cat issues-prs.tsv | cut -f2 | sort | uniq -c | sort -nr | awk '{print $1","$2}' > byauthor.csv
