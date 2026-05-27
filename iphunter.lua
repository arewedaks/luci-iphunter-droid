module("luci.controller.iphunter", package.seeall)

function index()
    entry({"admin", "status", "iphunter"}, template("iphunter_view"), _("IP Hunter Pro"), 80)
    entry({"admin", "status", "iphunter_action"}, call("action_ctl"))
    entry({"admin", "status", "iphunter_log"}, call("get_log"))
    entry({"admin", "status", "iphunter_clear"}, call("action_clear"))
    entry({"admin", "status", "iphunter_get_auto"}, call("get_auto"))
    entry({"admin", "status", "iphunter_save_range"}, call("save_ip_range"))
    entry({"admin", "status", "iphunter_get_range"}, call("get_ip_range"))
end

function action_ctl()
    local cmd = luci.http.formvalue("cmd")
    if cmd == "start" then luci.sys.exec("/etc/init.d/iphunter start")
    elseif cmd == "stop" then luci.sys.exec("/etc/init.d/iphunter stop")
    elseif cmd == "enable" then luci.sys.exec("/etc/init.d/iphunter enable")
    elseif cmd == "disable" then luci.sys.exec("/etc/init.d/iphunter disable")
    end
end

function get_auto()
    local status = luci.sys.exec("/etc/init.d/iphunter enabled && echo 1 || echo 0")
    luci.http.write(status)
end

function action_clear()
    luci.sys.exec("echo '' > /tmp/ip_hunter.log")
end

function get_log()
    local log = luci.sys.exec("tail -n 50 /tmp/ip_hunter.log")
    luci.http.write(log)
end

function save_ip_range()
    local range = luci.http.formvalue("range")
    local config_file = "/tmp/ip_hunter_range.conf"

    -- Sanitize input: hanya izinkan digit, hyphen, koma, spasi, dan titik
    local safe_range = string.gsub(range, "[^%d%-%,%s%.]", "")

    luci.sys.exec("echo '" .. safe_range .. "' > " .. config_file)
    luci.http.write("OK")
end

function get_ip_range()
    local config_file = "/tmp/ip_hunter_range.conf"
    local f = io.open(config_file, "r")
    if f then
        local range = f:read("*all")
        f:close()
        luci.http.write(range)
    else
        luci.http.write("")
    end
end
