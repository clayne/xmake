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
-- @file        xmake.lua
--

toolchain("sdcc")
    set_kind("standalone")
    set_homepage("http://sdcc.sourceforge.net/")
    set_description("Small Device C Compiler")

    set_toolset("cc",  "sdcc")
    set_toolset("cxx", "sdcc")
    set_toolset("cpp", "sdcpp")
    set_toolset("as",  "sdcc")
    set_toolset("ld",  "sdcc")
    set_toolset("sh",  "sdcc")
    set_toolset("ar",  "sdar")

    set_archs("stm8", "mcs51", "z80", "z180", "r2k", "r3ka", "s08", "hc08")

    set_formats("static", "$(name).lib")
    set_formats("object", "$(name).rel")
    set_formats("binary", "$(name).bin")
    set_formats("symbol", "$(name).sym")

    on_check("check")

    on_load(function (toolchain)
        local arch = toolchain:arch()
        if arch and arch ~= "none" then
            toolchain:add("cxflags", "-m" .. arch)
            toolchain:add("ldflags", "-m" .. arch)
        end
    end)
