name "devbox"
description "Basic development tooling"
run_list "recipe[apt]",
"recipe[git]",
"recipe[java]",
"recipe[zookeeper]",
"recipe[devtools-editors]",
"recipe[devtools-search]",
"recipe[devtools-compilers]",
"recipe[devtools-debuggers]"
