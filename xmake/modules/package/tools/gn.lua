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
-- @file        gn.lua
--

-- imports
import("core.base.option")
import("core.tool.toolchain")
import("lib.detect.find_tool")
import("package.tools.ninja")

-- get build directory
function _get_builddir(opt)
    if opt and (opt.builddir or opt.buildir) then
        if opt.buildir then
            wprint("{buildir = } has been deprecated, please use {builddir = } in gn.install")
        end
        return opt.builddir or opt.buildir
    else
        _g.builddir = _g.builddir or ("build_" .. hash.uuid4():split('%-')[1])
        return _g.builddir
    end
end

-- get configs
function _get_configs(package, configs, opt)
    configs = configs or {}
    if not package:is_plat("windows") then
        configs.cc  = package:build_getenv("cc")
        configs.cxx = package:build_getenv("cxx")
    end
    if package:is_plat("macosx") then
        configs.extra_ldflags = {"-lstdc++"}
        local xcode = toolchain.load("xcode", {plat = package:plat(), arch = package:arch()})
        configs.xcode_sysroot = xcode:config("xcode_sysroot")
    end
    if package:is_plat("linux") then
        configs.target_os = "linux"
    elseif package:is_plat("macosx") then
        configs.target_os = "mac"
    elseif package:is_plat("windows") then
        configs.target_os = "win"
    elseif package:is_plat("iphoneos") then
        configs.target_os = "ios"
    elseif package:is_plat("android") then
        configs.target_os = "android"
    end
    if package:is_arch("x86", "i386") then
        configs.target_cpu = "x86"
    elseif package:is_arch("x64", "x86_64") then
        configs.target_cpu = "x64"
    elseif package:is_arch("arm64", "arm64-v8a") then
        configs.target_cpu = "arm64"
    elseif package:is_arch("arm.*") then
        configs.target_cpu = "arm"
    end
    if configs.is_debug == nil then
        configs.is_debug = package:is_debug() and true or false
    end
    return configs
end

-- get msvc
function _get_msvc(package)
    local msvc = package:toolchain("msvc")
    assert(msvc:check(), "vs not found!") -- we need to check vs envs if it has been not checked yet
    return msvc
end

-- get the build environments
function buildenvs(package, opt)
    local envs = {}
    if package:is_plat("windows") then
        envs = os.joinenvs(_get_msvc(package):runenvs())
    end
    return envs
end

-- generate build files for ninja
function generate(package, configs, opt)

    -- init options
    opt = opt or {}

    -- pass configurations
    local argv = {}
    local args = {}
    table.insert(argv, "gen")
    table.insert(argv, _get_builddir(opt))
    for name, value in pairs(_get_configs(package, configs, opt)) do
        if type(value) == "string" then
            table.insert(args, name .. "=\"" .. value .. "\"")
        elseif type(value) == "table" then
            table.insert(args, name .. "=[\"" .. table.concat(value, "\",\"") .. "\"]")
        else
            table.insert(args, name .. "=" .. tostring(value))
        end
    end
    table.insert(argv, "--args=" .. table.concat(args, ' '))

    -- do configure
    local gn = assert(find_tool("gn"), "gn not found!")
    os.vrunv(gn.program, argv, {envs = opt.envs or buildenvs(package)})
end

-- build package
function build(package, configs, opt)

    -- generate build files
    opt = opt or {}
    generate(package, configs, opt)

    -- do build
    local builddir = _get_builddir(opt)
    local targets = table.wrap(opt.target)
    ninja.build(package, targets, {builddir = builddir, envs = opt.envs or buildenvs(package, opt)})
end

-- install package
function install(package, configs, opt)

    -- generate build files
    opt = opt or {}
    generate(package, configs, opt)

    -- do build and install
    local builddir = _get_builddir(opt)
    local targets = table.wrap(opt.target)
    ninja.install(package, targets, {builddir = builddir, envs = opt.envs or buildenvs(package, opt)})
end
