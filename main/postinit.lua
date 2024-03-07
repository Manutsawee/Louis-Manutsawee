local modimport = modimport
GLOBAL.setfenv(1, GLOBAL)

modimport("postinit/entityscript")
modimport("postinit/recipe")

local postinit = {
    prefabs = {
        "nightmarefissure",
        "winter_tree",
        "smallghost",
        "abigail",
    },
    stategraphs = {
        "SGwilson",
        "SGwilson_client",
    },
    components = {
        "eater",
        "sanity",
        "sanity_replica",
        "grogginess",
        "equippable",
        "wisecracker",
        "combat",
        "cursable",
    },
    widgets = {
        "skinspuppet",
    },
}

for k, v in pairs(postinit) do
    for i = 1, #v do
        modimport("postinit/dst_postinit/" .. k .. "/" .. postinit[k][i])
    end
end
