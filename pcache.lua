--
-- pcache - a simple in-process memory caching library
-- (c) 2011 Alexandre Erwin Ittner <alexandre@ittner.com.br>
--
--
-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation files (the
-- "Software"), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish,
-- distribute, sublicense, and/or sell copies of the Software, and to
-- permit persons to whom the Software is furnished to do so, subject
-- to the following conditions:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE AUTHOR OR COPYRIGHT HOLDER BE LIABLE FOR ANY
-- CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
-- TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
-- SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--
-- If you use this package in a product, an acknowledgment in the product
-- documentation would be greatly appreciated (but it is not required).
--




local os = require("os")

local M = { }

local cache = { }
local time = os.time

--
-- Add or replace a value in the cache.
--
-- Arguments:
--  key: a unique key to identify the value
--  value: the value
--  timeout: value expire time, in seconds
--
-- Returns: nothing
--
function M.add(key, value, timeout)
    if not timeout or timeout < 0 then
        error("Bad timeout")
    end
    assert(key, "Key is nil")
    local t = cache[key] or { }
    t.v = value
    t.t = time() + timeout
    cache[key] = t
end

--
-- Get an item from the cache. 
--
-- Arguments:
--  key: a unique key to identify the value
--
-- Returns: the stored value or 'nil' if non-existent or expired.
--
function M.get(key)
    assert(key, "Key is nil")
    local t = cache[key]
    if t and t.t > time() then
        return t.v
    end
    cache[key] = nil
    return nil
end


--
-- Delete an item from the cache.
--
-- Arguments:
--  key: a unique key to identify the value
--
-- Returns: nothing
--
function M.del(key)
    assert(key, "Key is nil")
    cache[key] = nil
end


--
-- Runs through the cache, removing all expired items.
-- This function have complexity of O(n) and should be used with care.
--
-- Arguments: none
-- Returns: nothing
--
function M.gc()
    local to_delete = { }
    local t = time()
    for k, v in pairs(cache) do
        if v and v.t and v.t < t then
            to_delete[k] = true
        end
    end
    for k, v in pairs(to_delete) do
        cache[k] = nil
    end
end


return M
