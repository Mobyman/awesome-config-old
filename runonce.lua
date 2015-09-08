-- @автор Peter J. Kranz (Absurd-Mind, peter@myref.net)
-- Любые вопросы, критику или благодарности отправляйте на электронную почту

local M = {}

-- получаем текущий идентификатор(Pid) awesome
local function getCurrentPid()
    -- получаем идентификатор awesome используя pgrep
--    local fpid = io.popen("pgrep -u " .. os.getenv("USER") .. " -o awesome")
--    local pid = fpid:read("*n")
--    fpid:close()

     local fpid = assert(io.open("/proc/self/stat", "r"))
     local pid = fpid:read("*all")
     fpid:close()
     pid = string.match(t, "%S+")

    -- проверка корректности
    if pid == nil then
        return -1
    end

    return pid
end

local function getOldPid(filename)
    -- открыаем файл
    local pidFile = io.open(filename)
    if pidFile == nil then
        return -1
    end

    -- считываем колличество
    local pid = pidFile:read("*n")
    pidFile:close()

    -- проверка на то, что колличество больше 0
    if pid <= 0 then
        return -1
    end

    return pid;
end

local function writePid(filename, pid)
    local pidFile = io.open(filename, "w+")
    pidFile:write(pid)
    pidFile:close()
end

local function shallExecute(oldPid, newPid)
    -- простая проверка на равенство
    if oldPid == newPid then
        return false
    end

    return true
end

local function getPidFile()
    local host = io.lines("/proc/sys/kernel/hostname")()
    return awful.util.getdir("cache") .. "/awesome." .. host .. ".pid"
end

-- запускаем один раз при первом запуске awesome (настройка перезапуска работает)
-- не распростраянется на "pkill awesome && awesome"
function M.run(shellCommand)
    -- проверяем и запускаем
    if shallExecute(M.oldPid, M.currentPid) then
        awful.util.spawn_with_shell(shellCommand)
    end
end

M.pidFile = getPidFile()
M.oldPid = getOldPid(M.pidFile)
M.currentPid = getCurrentPid()
writePid(M.pidFile, M.currentPid)

return M
