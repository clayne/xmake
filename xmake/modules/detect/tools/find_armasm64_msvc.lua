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
-- @file        find_armasm64_msvc.lua
--

-- imports
import("lib.detect.find_program")
import("lib.detect.find_programver")
import("detect.sdks.find_mdk")

-- find armasm
--
-- @param opt   the argument options, e.g. {version = true}
--
-- @return      program, version
--
-- @code
--
-- local armasm = find_armasm64_msvc()
-- local armasm, version = find_armasm64_msvc({program = "armasm64", version = true})
--
-- @endcode
--
function main(opt)

    -- init options
    opt = opt or {}
    opt.check = "-h"

    -- find program
    local program = find_program(opt.program or "armasm64.exe", opt)

    -- find program version
    local version = nil
    if program and opt.version then
        version = find_programver(program, opt)
    end
    return program, version
end
