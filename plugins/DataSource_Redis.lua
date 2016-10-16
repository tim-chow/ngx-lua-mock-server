local redis = require "resty.redis"
local CONFIG = require "MyConfig"
local _M = {}

local function _create_connection()
    local red = redis:new()
    red:set_timeout(CONFIG.REDIS_TIMEOUT)
    local ok, err = red:connect(CONFIG.REDIS_HOST, CONFIG.REDIS_PORT)
    if not ok then return false, err end
    if type(CONFIG.REDIS_PASSWORD) == "string" then
        red:auth(CONFIG.REDIS_PASSWORD)
    end
    red:select(CONFIG.REDIS_DB)
    return red
end

local function _put_conn_into_pool(red)
    local ok, err = red:set_keepalive(CONFIG.REDIS_MAX_IDLE_TIME,
        CONFIG.REDIS_POOL_SIZE)
    if not ok then return false, err end
    return true
end

function _M.get_data(host, request_uri, request_method)
    if type(host) ~= "string" or type(request_uri) ~= "string" or
        type(request_method) ~= "string" then
        error("invalid host, request_uri or request_method", 2)
    end

    local red, err = _create_connection()
    if not red then return false, 1, err end

    local data, err = red:hget(host..request_uri, request_method)
    pcall(_put_conn_into_pool, red)
    if not data then return false, 2, err end
    if data == ngx.null then return ngx.null end
    return data
end

return _M
