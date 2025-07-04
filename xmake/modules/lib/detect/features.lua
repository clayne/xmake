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
-- @file        features.lua
--

-- imports
import("lib.detect.find_tool")
import("core.base.scheduler")

-- get all features of the current tool
--
-- @param name      the tool name
-- @param opt       the argument options, e.g. {program = "", flags = {}}
--
-- @return          the features dictionary
--
-- @code
-- local features = features("clang")
-- local features = features("clang", {flags = "-O0", program = "xcrun -sdk macosx clang"})
-- local features = features("clang", {flags = {"-g", "-O0"}, envs = {PATH = ""}})
-- @endcode
--
function main(name, opt)

    -- init options
    opt = opt or {}

    -- find tool program and version first
    opt.version = true
    local tool = find_tool(name, opt)
    if not tool then
        return {}
    end

    -- init tool
    opt.toolname   = tool.name
    opt.program    = tool.program
    opt.programver = tool.version

    -- init cache and key
    local key     = tool.program .. "_" .. (tool.version or "") .. "_" .. table.concat(table.wrap(opt.flags), ",")
    _g._RESULTS = _g._RESULTS or {}
    local results = _g._RESULTS

    -- @see https://github.com/xmake-io/xmake/issues/4645
    -- @note avoid detect the same program in the same time leading to deadlock if running in the coroutine (e.g. ccache)
    scheduler.co_lock(key)

    -- get result from the cache first
    local result = results[key]
    if result ~= nil then
        scheduler.co_unlock(key)
        return result
    end

    -- core.tools.xxx.features(opt)?
    local features = import("core.tools." .. tool.name .. ".features", {try = true})
    if features then
        result = features(opt)
    end

    result = result or {}
    results[key] = result
    scheduler.co_unlock(key)
    return result
end
