import("lib.detect.find_tool")
import("core.base.semver")
import("core.tool.toolchain")
import("utils.ci.is_running", {alias = "ci_is_running"})

function _build()
    if ci_is_running() then
        os.run("xmake -rvD")
    else
        os.run("xmake -r")
    end
    local outdata = os.iorun("xmake")
    if outdata then
        if outdata:find("compiling") or outdata:find("linking") or outdata:find("generating") then
            raise("Modules incremental compilation does not work\n%s", outdata)
        end
    end
end

function main(t)
    if is_subhost("windows") then
        local clang = find_tool("clang", {version = true})
        if clang and clang.version and semver.compare(clang.version, "19.0") >= 0 then
            os.exec("xmake clean -a")
            os.exec("xmake f --toolchain=clang -c --yes")
            _build()
        end
        local msvc = toolchain.load("msvc")
        if msvc and msvc:check() then
            local vcvars = msvc:config("vcvars")
            if vcvars and vcvars.VCInstallDir and vcvars.VCToolsVersion and semver.compare(vcvars.VCToolsVersion, "14.35") then
                local stdmodulesdir = path.join(vcvars.VCInstallDir, "Tools", "MSVC", vcvars.VCToolsVersion, "modules")
                if os.isdir(stdmodulesdir) then
                    os.exec("xmake clean -a")
                    os.exec("xmake f -c --yes")
                    _build()
                end
            end
        end
    elseif is_subhost("msys") then
        local gcc = find_tool("gcc", {version = true})
        if is_host("linux") and gcc and gcc.version and semver.compare(gcc.version, "15.0") >= 0 then
            os.exec("xmake f -c -p mingw --yes")
            _build()
        end
    elseif is_host("linux") then -- or is_host("macosx") then
        local gcc = find_tool("gcc", {version = true})
        if is_host("linux") and gcc and gcc.version and semver.compare(gcc.version, "15.0") >= 0 then
            os.exec("xmake f -c --yes")
            _build()
        end
        local clang = find_tool("clang", {version = true})
        if clang and clang.version and semver.compare(clang.version, "19.0") >= 0 then
            local gcc = find_tool("clang", {version = true})
            if gcc and gcc.version and semver.compare(gcc.version, "15.0") >= 0 then
                os.exec("xmake clean -a")
                os.exec("xmake f --toolchain=clang -c --yes")
                _build()
            end
            os.exec("xmake clean -a")
            os.exec("xmake f --toolchain=clang --runtimes=c++_shared -c --yes")
            _build()
        end
    end
end
