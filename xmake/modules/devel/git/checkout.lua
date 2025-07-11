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
-- @file        checkout.lua
--

-- imports
import("core.base.option")
import("core.base.semver")
import("lib.detect.find_tool")

-- checkout to given branch, tag or commit
--
-- @param commit    the commit, tag or branch
-- @param opt       the argument options
--
-- @code
--
-- import("devel.git")
--
-- git.checkout("master", {repodir = "/tmp/xmake"})
-- git.checkout("v1.0.1", {repodir = "/tmp/xmake"})
--
-- @endcode
--
function main(commit, opt)
    opt = opt or {}
    local git = assert(find_tool("git", {version = true}), "git not found!")
    local argv = {}
    if opt.fsmonitor then
        table.insert(argv, "-c")
        table.insert(argv, "core.fsmonitor=true")
    else
        table.insert(argv, "-c")
        table.insert(argv, "core.fsmonitor=false")
    end

    -- @see https://github.com/xmake-io/xmake/issues/6071
    -- https://github.blog/open-source/git/bring-your-monorepo-down-to-size-with-sparse-checkout/
    if opt.includes and git.version and semver.compare(git.version, "2.25") >= 0 then
        os.vrunv(git.program, {"sparse-checkout", "init", "--cone"}, {curdir = opt.repodir})
        os.vrunv(git.program, table.join({"sparse-checkout", "set"}, opt.includes), {curdir = opt.repodir})
    end

    table.insert(argv, "checkout")
    table.insert(argv, commit)
    os.vrunv(git.program, argv, {curdir = opt.repodir})
end
