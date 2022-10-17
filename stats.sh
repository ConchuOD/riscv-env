authors=$(git log --pretty="%an"  --author=".*microchip.*" $1..$2 | sort)
author_count=$(printf "$authors" | uniq -c | sort -nr)

codevelopers=$(git log $1..$2 --pretty="%(trailers:key=Co-developed-by,valueonly=true)"  --grep=".*microchip.com" | grep microchip | cut -f1 -d"<" | sort)
codeveloper_count=$(printf "$codevelopers" | uniq -c | sort -nr)

reviewers=$(git log $1..$2 --pretty="%(trailers:key=Reviewed-by,key=Tested-by,key=Acked-by,valueonly=true)"  --grep=".*microchip.com" | grep microchip | cut -f1 -d"<" | sort)
reviewer_count=$(printf "$reviewers" | uniq -c | sort -nr)

contributors="$authors $codevelopers $reviewers"
contributor_count=$(printf "$contributors" | sort | uniq | wc -l)

printf "from $1 to $2 we had $contributor_count contributors \n"
printf "\n"
printf "authors:\n"
printf "$author_count\n"
printf "\n"
printf "co-developers:\n"
printf "$codeveloper_count\n"
printf "\n"
printf "reviewers:\n"
printf "$reviewer_count\n"

git log --pretty="%<|(25)%an%s" --author=".*microchip.*" $1..$2 | sort

