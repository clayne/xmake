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
-- @file        llvm_ar.lua
--

-- imports
import("core.tool.compiler")

-- init it
function init(self)
    self:set("arflags", "cr")
end

-- make the strip flag
function strip(self, level)
    local maps = {
        debug = "S"
    ,   all   = "S"
    }
    return maps[level]
end

-- make the link arguments list
function linkargv(self, objectfiles, targetkind, targetfile, flags, opt)
    assert(targetkind == "static")
    opt = opt or {}
    local argv = table.join(flags, targetfile, objectfiles)
    if is_host("windows") and not opt.rawargs then
        argv = winos.cmdargv(argv, {escape = true})
    end
    return self:program(), argv
end

-- link the library file
function link(self, objectfiles, targetkind, targetfile, flags)
    assert(targetkind == "static", "the target kind: %s is not support for ar", targetkind)
    os.mkdir(path.directory(targetfile))
    -- @note remove the previous archived file first to force recreating a new file
    os.tryrm(targetfile)
    os.runv(linkargv(self, objectfiles, targetkind, targetfile, flags))
end

