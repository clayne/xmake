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
-- @file        menu.lua
--

-- define module
local sandbox_core_platform_menu = sandbox_core_platform_menu or {}

-- load modules
local menu      = require("platform/menu")
local raise     = require("sandbox/modules/raise")

-- get the platform menu options for the given action: config or global
function sandbox_core_platform_menu.options(action)

    -- get it
    local options, errors = menu.options(action)
    if not options then
        raise(errors)
    end

    -- ok?
    return options
end


-- return module
return sandbox_core_platform_menu
