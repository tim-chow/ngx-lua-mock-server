local _CONFIG = setmetatable({}, {
    __index={
        -- Redis configuration
        REDIS_HOST="127.0.0.1",
        REDIS_PORT=6379,
        REDIS_PASSWORD="e839fcfe725611e5:123456_78a1A",
        REDIS_DB=8,
        REDIS_TIMEOUT=1000, --unit: ms
        REDIS_MAX_IDLE_TIME=10000, --unit: ms
        REDIS_POOL_SIZE=2;

        DATA_SOURCE_TYPE="Redis",
        CONNECT_TIMEOUT=1000, --unit: ms
        PROXY_TIMEOUT=5000, --unit: ms
    },
    __metatable="permisson denied",
})

return _CONFIG
