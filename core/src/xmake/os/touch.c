/*!A cross-platform build utility based on Lua
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Copyright (C) 2015-present, Xmake Open Source Community.
 *
 * @author      ruki
 * @file        touch.c
 *
 */

/* //////////////////////////////////////////////////////////////////////////////////////
 * trace
 */
#define TB_TRACE_MODULE_NAME                "touch"
#define TB_TRACE_MODULE_DEBUG               (0)

/* //////////////////////////////////////////////////////////////////////////////////////
 * includes
 */
#include "prefix.h"

/* //////////////////////////////////////////////////////////////////////////////////////
 * implementation
 */
tb_int_t xm_os_touch(lua_State* lua)
{
    // check
    tb_assert_and_check_return_val(lua, 0);

    tb_char_t const* path = luaL_checkstring(lua, 1);
    tb_check_return_val(path, 0);

    tb_time_t atime = (tb_time_t)luaL_checknumber(lua, 2);
    tb_time_t mtime = (tb_time_t)luaL_checknumber(lua, 3);

    lua_pushboolean(lua, tb_file_touch(path, atime, mtime));
    return 1;
}
