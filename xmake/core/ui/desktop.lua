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
-- @file        desktop.lua
--

-- load modules
local log    = require("ui/log")
local rect   = require("ui/rect")
local view   = require("ui/view")
local panel  = require("ui/panel")
local curses = require("ui/curses")

-- define module
local desktop = desktop or panel()

-- init desktop
function desktop:init(name, bounds)

    -- init panel
    panel.init(self, name, bounds)

    -- init background
    self:background_set("blue")
end

-- return module
return desktop
