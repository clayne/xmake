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
-- @file        armclang.lua
--

inherit("gcc")
import("core.language.language")

function init(self)
    _super.init(self)
end

-- make runtime flag
function nf_runtime(self, runtime)
    if runtime == "microlib" then
        return "-D__MICROLIB"
    end
end

-- make the optimize flag
function nf_optimize(self, level)
    -- only for source kind
    local kind = self:kind()
    if language.sourcekinds()[kind] then
        local maps =
        {
            none       = "-O0"
        ,   fast       = "-O1"
        ,   faster     = "-O2"
        ,   fastest    = "-O3"
        ,   smallest   = "-Oz" -- smaller than -Os
        ,   aggressive = "-Ofast"
        }
        return maps[level]
    end
end

