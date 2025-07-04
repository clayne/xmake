--!A cross-platform build utility based on Lua
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
-- Copyright (C) 2015-present, Xmake Open Source Community.
--
-- @author      ruki
-- @file        has_package.lua
--

-- return module
return function (...)
    require("sandbox/modules/import/core/sandbox/module").import("core.project.project")
    local requires = project.required_packages()
    if requires then
        for _, packagename in ipairs(table.join(...)) do
            local pkg = requires[packagename]
            -- attempt to get package with namespace
            if pkg == nil and packagename:find("::", 1, true) then
                local parts = packagename:split("::", {plain = true})
                local namespace_pkg = requires[parts[#parts]]
                if namespace_pkg and namespace_pkg:namespace() then
                    local fullname = namespace_pkg:fullname()
                    if fullname:endswith(packagename) then
                        pkg = namespace_pkg
                    end
                end
            end
            if pkg and pkg:enabled() then
                return true
            end
        end
    end
end
