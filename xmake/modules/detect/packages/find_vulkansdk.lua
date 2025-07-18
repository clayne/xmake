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
-- @author      xq114
-- @file        find_vulkansdk.lua
--

-- imports
import("detect.sdks.find_vulkansdk")

-- find vulkansdk
--
-- @param opt   the package options. e.g. see the options of find_package()
--
-- @return      see the return value of find_package()
--
function main(opt)
    opt = opt or {}
    return find_vulkansdk({arch = opt.arch})
end
