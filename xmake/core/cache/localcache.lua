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
-- @file        localcache.lua
--

-- define module: localcache
local localcache  = localcache or {}
local _instance = _instance or {}

-- load modules
local table   = require("base/table")
local io      = require("base/io")
local os      = require("base/os")
local path    = require("base/path")
local config  = require("project/config")

-- new an instance
function _instance.new(name)
    local instance = table.inherit(_instance)
    instance._NAME = name
    instance:load()
    instance._DATA = instance._DATA or {}
    return instance
end

-- get cache name
function _instance:name()
    return self._NAME
end

-- get cache data
function _instance:data()
    return self._DATA
end

-- load cache
function _instance:load()
    if os.isfile(os.projectfile()) or os.isdir(config.directory()) then
        local result = io.load(path.join(config.cachedir(), self:name()))
        if result ~= nil then
            self._DATA = result
        end
    end
end

-- save cache
function _instance:save()
    -- for xmake project or trybuild mode
    if os.isfile(os.projectfile()) or os.isdir(config.directory()) then
        local ok, errors = io.save(path.join(config.cachedir(), self:name()), self._DATA)
        if not ok then
            os.raise(errors)
        end
    end
end

-- get cache value in level/1
function _instance:get(key)
    return self._DATA[key]
end

-- get cache value in level/2
function _instance:get2(key1, key2)
    local value1 = self:get(key1)
    if value1 ~= nil then
        return value1[key2]
    end
end

-- get cache value in level/3
function _instance:get3(key1, key2, key3)
    local value2 = self:get2(key1, key2)
    if value2 ~= nil then
        return value2[key3]
    end
end

-- set cache value in level/1
function _instance:set(key, value)
    self._DATA[key] = value
end

-- set cache value in level/2
function _instance:set2(key1, key2, value2)
    local value1 = self:get(key1)
    if value1 == nil then
        value1 = {}
        self:set(key1, value1)
    end
    value1[key2] = value2
end

-- set cache value in level/3
function _instance:set3(key1, key2, key3, value3)
    local value2 = self:get2(key1, key2)
    if value2 == nil then
        value2 = {}
        self:set2(key1, key2, value2)
    end
    value2[key3] = value3
end

-- clear cache scopes
function _instance:clear()
    self._DATA = {}
end

-- get cache instance
function localcache.cache(cachename)
    local caches = localcache._CACHES
    if not caches then
        caches = {}
        localcache._CACHES = caches
    end
    local instance = caches[cachename]
    if not instance then
        instance = _instance.new(cachename)
        caches[cachename] = instance
    end
    return instance
end

-- get all caches
function localcache.caches(opt)
    opt = opt or {}
    if opt.flush then
        for _, cachefile in ipairs(os.files(path.join(config.cachedir(), "*"))) do
            local cachename = path.filename(cachefile)
            localcache.cache(cachename)
        end
    end
    return localcache._CACHES
end

-- get cache value in level/1
function localcache.get(cachename, key)
    return localcache.cache(cachename):get(key)
end

-- get cache value in level/2
function localcache.get2(cachename, key1, key2)
    return localcache.cache(cachename):get2(key1, key2)
end

-- get cache value in level/3
function localcache.get3(cachename, key1, key2, key3)
    return localcache.cache(cachename):get3(key1, key2, key3)
end

-- set cache value in level/1
function localcache.set(cachename, key, value)
    return localcache.cache(cachename):set(key, value)
end

-- set cache value in level/2
function localcache.set2(cachename, key1, key2, value)
    return localcache.cache(cachename):set2(key1, key2, value)
end

-- set cache value in level/3
function localcache.set3(cachename, key1, key2, key3, value)
    return localcache.cache(cachename):set3(key1, key2, key3, value)
end

-- save the given cache, it will save all caches if cache name is nil
function localcache.save(cachename)
    if cachename then
        localcache.cache(cachename):save()
    else
        local caches = localcache.caches()
        if caches then
            for _, cache in pairs(caches) do
                cache:save()
            end
        end
    end
end

-- clear the given cache, it will clear all caches if cache name is nil
function localcache.clear(cachename)
    if cachename then
        localcache.cache(cachename):clear()
    else
        local caches = localcache.caches({flush = true})
        if caches then
            for _, cache in pairs(caches) do
                cache:clear()
            end
        end
    end
end

-- return module: localcache
return localcache

