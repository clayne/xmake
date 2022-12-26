import("private.xrepo.quick_search.cache")
function main(complete, opt)
    local packages = cache.get()
    local candidates = {}
    for _, package in ipairs(packages) do
        if package.name:startswith(complete) then
            table.insert(candidates, package.name)
        end
    end
    return candidates
end