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
-- @file        windres.lua
--

-- imports
import("core.base.option")
import("core.base.global")
import("core.project.policy")
import("core.project.project")

-- init it
function init(self)
    self:add("mrcflags", "--use-temp-file", "-O", "coff")
end

-- make the define flag
function nf_define(self, macro)
    return {"-D" .. macro}
end

-- make the undefine flag
function nf_undefine(self, macro)
    return "-U" .. macro
end

-- make the includedir flag
function nf_includedir(self, dir)
    return {"-I", dir}
end

-- make the sysincludedir flag
function nf_sysincludedir(self, dir)
    return nf_includedir(self, dir)
end

-- make the compile arguments list
function compargv(self, sourcefile, objectfile, flags)
    return self:program(), table.join(flags, sourcefile, objectfile)
end

-- compile the source file
function compile(self, sourcefile, objectfile, dependinfo, flags, opt)
    os.mkdir(path.directory(objectfile))
    try
    {
        function ()
            local program, argv = compargv(self, sourcefile, objectfile, flags)
            local outdata, errdata = os.iorunv(program, argv, {envs = self:runenvs()})
            return (outdata or "") .. (errdata or "")
        end,
        catch
        {
            function (errors)
                os.raise(errors)
            end
        },
        finally
        {
            function (ok, warnings)
                if warnings and #warnings > 0 and policy.build_warnings(opt) then
                    cprint("${color.warning}%s", table.concat(table.slice(warnings:split('\n'), 1, 8), '\n'))
                end
            end
        }
    }
end

