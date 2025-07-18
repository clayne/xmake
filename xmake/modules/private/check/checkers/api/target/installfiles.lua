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
-- @file        installfiles.lua
--

-- imports
import(".api_checker")

function main(opt)
    opt = opt or {}
    api_checker.check_targets("installfiles", table.join(opt, {check = function(target, value)
        value = value:gsub("[()]", "")
        local installfiles = os.files(value)
        if not installfiles or #installfiles == 0 then
            return false, string.format("installfiles '%s' not found", value)
        end
        return true
    end}))
end
