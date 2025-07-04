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
-- @file        jobpool.lua
--

-- imports
import("core.base.object")
import("core.base.list")
import("core.base.hashset")

-- define module
local jobpool = jobpool or object {_init = {"_size", "_rootjob", "_leafjobs"}}

-- the job status
local JOB_STATUS_FREE     = 1
local JOB_STATUS_PENDING  = 2
local JOB_STATUS_FINISHED = 3

-- get jobs size
function jobpool:size()
    return self._size
end

-- get root job
function jobpool:rootjob()
    return self._rootjob
end

-- new run job
--
-- e.g.
-- local job = jobpool:newjob("xxx", function (index, total) end)
-- jobpool:add(job, rootjob1)
-- jobpool:add(job, rootjob2)
-- jobpool:add(job, rootjob3)
--
function jobpool:newjob(name, run, opt)
    opt = opt or {}
    return {name = name, run = run, distcc = opt.distcc, status = JOB_STATUS_FREE}
end

-- add run job to the given job node
--
-- e.g.
-- local job = jobpool:addjob("xxx", function (index, total) end, {rootjob = rootjob})
--
-- @param name      the job name
-- @param run       the run command/script
-- @param opt       the options (rootjob, distcc)
--                  we can support distcc build if distcc is true
--
function jobpool:addjob(name, run, opt)
    opt = opt or {}
    return self:add({name = name, run = run, distcc = opt.distcc, status = JOB_STATUS_FREE}, opt.rootjob)
end

-- add job to the given job node
--
-- @param job       the job
-- @param rootjob   the root job node (optional)
--
function jobpool:add(job, rootjob)

    -- add job to the root job
    rootjob = rootjob or self:rootjob()
    rootjob._deps = rootjob._deps or hashset.new()
    rootjob._deps:insert(job)

    -- attach parents node
    local parents = job._parents
    if not parents then
        parents = {}
        job._parents = parents
        self._size = self._size + 1 -- @note only update number for new job without parents
    end
    table.insert(parents, rootjob)

    -- in group? attach the group node
    local group = self._group
    if group then
        job._deps = job._deps or hashset.new()
        job._deps:insert(group)
        group._parents = group._parents or {}
        table.insert(group._parents, job)
    end
    return job
end

-- get a free job from the leaf jobs
function jobpool:getfree()
    if self:size() == 0 then
        return
    end

    -- get a free job from the leaf jobs
    local leafjobs = self:_getleafjobs()
    if not leafjobs:empty() then
        -- try to get next free job fastly
        if self._nextfree then
            local job = self._nextfree
            local nextfree = leafjobs:prev(job)
            if nextfree ~= job and self:_isfree(nextfree) then
                self._nextfree = nextfree
            else
                self._nextfree = nil
            end
            job.status = JOB_STATUS_PENDING
            return job
        end
        -- find the next free job
        local removed_jobs = {}
        for job in leafjobs:ritems() do
            if self:_isfree(job) then
                local nextfree = leafjobs:prev(job)
                if nextfree ~= job and self:_isfree(nextfree) then
                    self._nextfree = nextfree
                end
                job.status = JOB_STATUS_PENDING
                return job
            elseif job.group or job.status == JOB_STATUS_FINISHED then
                table.insert(removed_jobs, job)
            end
        end
        -- not found? if remove group and referenced node exist,
        -- we try to remove them and find the next free job again
        if #removed_jobs > 0 then
            for _, job in ipairs(removed_jobs) do
                self:remove(job)
            end
            for job in leafjobs:ritems() do
                if self:_isfree(job) then
                    local nextfree = leafjobs:prev(job)
                    if nextfree ~= job and self:_isfree(nextfree) then
                        self._nextfree = nextfree
                    end
                    job.status = JOB_STATUS_PENDING
                    return job
                end
            end
        end
    end
end

-- remove the given job from the leaf jobs
function jobpool:remove(job)
    assert(self:size() > 0)
    local leafjobs = self:_getleafjobs()
    if not leafjobs:empty() then
        assert(job ~= self._nextfree)

        -- remove this job from leaf jobs
        job.status = JOB_STATUS_FINISHED
        leafjobs:remove(job)

        -- get parents node
        local parents = assert(job._parents, "invalid job without parents node!")

        -- update all parents nodes
        for _, p in ipairs(parents) do
            -- we need to avoid adding it to leafjobs repeatly, it will cause dead-loop when poping group job
            -- @see https://github.com/xmake-io/xmake/issues/2740
            if not p._leaf then
                p._deps:remove(job)
                if p._deps:empty() and self._size > 0 then
                    p._leaf = true
                    leafjobs:insert_first(p)
                end
            end
        end
    end
end

-- enter group
--
-- @param name      the group name
-- @param opt       the options, e.g. {rootjob = ..}
--
function jobpool:group_enter(name, opt)
    opt = opt or {}
    assert(not self._group, "jobpool: cannot enter group(%s)!", name)
    self._group = {name = name, group = true, rootjob = opt.rootjob}
end

-- leave group
--
-- @return          the group node
--
function jobpool:group_leave()
    local group = self._group
    self._group = nil
    if group then
        if group._parents then
            return group
        else
            -- we just return the rootjob if there is not any jobs in this group
            return group.rootjob
        end
    end
end

-- is free job?
-- we need to ignore group node (empty job) and referenced node (finished job)
function jobpool:_isfree(job)
    if job and job.status == JOB_STATUS_FREE and not job.group then
        return true
    end
end

-- get leaf jobs
function jobpool:_getleafjobs()
    local leafjobs = self._leafjobs
    if leafjobs == nil then
        leafjobs = list.new()
        local refs = {}
        self:_genleafjobs(self:rootjob(), leafjobs, refs)
        self._leafjobs = leafjobs
    end
    return leafjobs
end

-- generate all leaf jobs from the given job
function jobpool:_genleafjobs(job, leafjobs, refs)
    local deps = job._deps
    if deps and not deps:empty() then
        for _, dep in deps:keys() do
            local depkey = tostring(dep)
            if not refs[depkey] then
                refs[depkey] = true
                self:_genleafjobs(dep, leafjobs, refs)
            end
        end
    else
        job._leaf = true
        leafjobs:insert_last(job)
    end
end

-- generate jobs tree for the given job
function jobpool:_gentree(job, refs)
    local tree = {job.group and ("group(" .. job.name .. ")") or job.name}
    local deps = job._deps
    if deps and not deps:empty() then
        for _, dep in deps:keys() do
            local depkey = tostring(dep)
            if refs[depkey] then
                local depname = dep.group and ("group(" .. dep.name .. ")") or dep.name
                table.insert(tree, "ref(" .. depname .. ")")
            else
                refs[depkey] = true
                table.insert(tree, self:_gentree(dep, refs))
            end
        end
    end
    -- strip tree
    local smalltree = hashset.new()
    for _, item in ipairs(tree) do
        item = table.unwrap(item)
        if smalltree:size() < 16 or type(item) == "table" then
            smalltree:insert(item)
        else
            smalltree:insert("...")
        end
    end
    return smalltree:to_array()
end

-- tostring
function jobpool:__tostring()
    local refs = {}
    return string.serialize(self:_gentree(self:rootjob(), refs), {indent = 2, orderkeys = true})
end

-- new a jobpool
function new()
    return jobpool {0, {name = "root"}, nil}
end
