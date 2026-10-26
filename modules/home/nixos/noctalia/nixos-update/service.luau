-- One service owns all work, including on multi-monitor desktops.
local executable = "/run/current-system/sw/bin/nixos-update"
local status = "checking"
local busy = false
local generation = 0
local deadline = nil
local valid = { up_to_date = true, update_available = true, reboot_required = true, updating = true, error = true }

local function publish(nextStatus, message)
    status = nextStatus
    noctalia.state.set("status", { status = status, message = message, busy = busy })
end

local function decode(raw)
    local ok, value = pcall(noctalia.json.decode, raw)
    if ok and type(value) == "table" and valid[value.status] and type(value.message) == "string" then
        return value
    end
    return nil
end

local function finish(value, fallback)
    busy = false
    deadline = nil
    if value then
        publish(value.status, value.message)
    else
        publish("error", fallback)
    end
end

local function check()
    if busy then return end
    busy = true
    generation = generation + 1
    local token = generation
    publish(status, "Checking for updates…")
    local ok, accepted = pcall(noctalia.runAsync, { executable, "check" }, function(result)
        if token ~= generation then return end
        local value = decode(result.stdout)
        if result.timedOut or result.stdoutTruncated or result.exitCode ~= 0 then
            finish(nil, value and value.message or "Could not check for updates. Check again to retry.")
        else
            finish(value, "The update checker returned an invalid response. Check again to retry.")
        end
    end, 60000)
    if not ok or not accepted then
        finish(nil, "Could not start the update checker. Check again to retry.")
    end
end

local function apply()
    if busy or status ~= "update_available" then return end
    busy = true
    generation = generation + 1
    local token = generation
    -- runAsync is capped at 60s in the pinned host. runStream has no timeout
    -- and only accepts a shell string. This is entirely literal, never input.
    -- The shell emits an exit marker even for exec failure / nonzero exit.
    local command = executable .. " update; code=$?; printf '\\nNOCTALIA_UPDATE_EXIT:%s\\n' \"$code\""
    local response = nil
    deadline = os.time() + 24 * 60 * 60
    publish("updating", "Applying updates. This may take a while; do not power off.")
    local ok, accepted = pcall(noctalia.runStream, command, function(line)
        if token ~= generation then return end
        local exit = line:match("^NOCTALIA_UPDATE_EXIT:(%d+)$")
        if exit then
            generation = generation + 1
            if exit ~= "0" then
                finish(nil, response and response.message or "Update failed. Check again, then retry the update.")
            elseif response and (response.status == "up_to_date" or response.status == "reboot_required") then
                finish(response)
            else
                finish(nil, "The updater returned an invalid response. Check again before retrying.")
            end
        elseif line ~= "" then
            response = decode(line)
        end
    end)
    if not ok or not accepted then
        generation = generation + 1
        finish(nil, "Could not start the update. Check again to retry.")
    end
end

function update()
    -- A killed shell cannot emit its marker. Recover the UI, not the service:
    -- never cancel a Nix build or automatically start a second update.
    if deadline and os.time() >= deadline then
        generation = generation + 1
        finish(nil, "Update monitoring expired. The system may still be updating. Check its status before retrying.")
        return
    end
    check()
end

noctalia.state.watch("request", function(request)
    if type(request) ~= "table" then return end
    if request.action == "check" then check() end
    if request.action == "update" then apply() end
end)
noctalia.setUpdateInterval(300000)
publish("checking", "Checking for updates…")
check()
