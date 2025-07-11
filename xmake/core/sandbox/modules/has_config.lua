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
-- @file        has_config.lua
--

local config  = require("project/config")
local sandbox = require("sandbox/sandbox")

return function (...)
    local namespace
    local instance = sandbox.instance()
    if instance then
        namespace = instance:namespace()
    end
    local names = table.pack(...)
    for _, name in ipairs(names) do
        local value = config.get(name)
        if value == nil and namespace then
            value = config.get(namespace .. "::" .. name)
        end
        if value then
            return true
        end
    end
    return false
end

