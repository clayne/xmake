--!A cross-toolchain build utility based on Lua
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
-- @file        check.lua
--

-- imports
import("core.project.config")
import("lib.detect.find_tool")
import("detect.sdks.find_cross_toolchain")

-- check the cross toolchain
function main(toolchain)
    local sdkdir = toolchain:sdkdir()
    local bindir = toolchain:bindir()
    local cross_toolchain = find_cross_toolchain(sdkdir, {bindir = bindir})
    if cross_toolchain then
        toolchain:config_set("cross", cross_toolchain.cross)
        toolchain:config_set("bindir", cross_toolchain.bindir)
        toolchain:configs_save()
        return true
    end
    return find_tool("sdcc")
end
