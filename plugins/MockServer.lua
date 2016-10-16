local http = require "resty.http"

local CONFIG = require "MyConfig"
local data_source_type = CONFIG.DATA_SOURCE_TYPE
local data_source = require("DataSource_"..data_source_type)

local function _split_host(host)
    local s = string.find(host, ":")
    if not s then return host, 80 end
    return string.sub(host, 1, s-1), tonumber(string.sub(host, s+1))
end

local function proxy_request()
    local httpc = http.new()
    httpc:set_timeout(CONFIG.CONNECT_TIMEOUT)
    local ok, err = httpc:connect(_split_host(ngx.var.host))
    if not ok then return false, 1, err end

    httpc:set_timeout(CONFIG.PROXY_TIMEOUT)
    local res, err = httpc:proxy_request()
    if not res then return false, 2, err end

    httpc:proxy_response(res)
    httpc:set_keepalive()
    return true
end

local function main()
    local data, code, message = data_source.get_data(
        ngx.var.host, ngx.var.request_uri, ngx.var.request_method)

    -- when error accurs
    if not data then 
        ngx.header["Error-Message"] = message
        ngx.header["Error-Code"] = code
        return ngx.exit(500)
    end

    -- when no mock data
    if data == ngx.null then
        local status, code, message = proxy_request()
        if not status then
            ngx.header["Error-Message"] = message
            ngx.header["Error-Code"] = code
            return ngx.exit(500)
        end
    else
        ngx.header["Is-Mocked"] = "1"
        ngx.say(data)
    end
end

main()
