name "devbox"
description "Basic development tooling"
run_list "recipe[apt]", "recipe[git]", "recipe[java]"
