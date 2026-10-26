local titles = {
    checking = "Checking for updates…",
    up_to_date = "Your system is up to date",
    update_available = "An update is available",
    updating = "Updating your system…",
    reboot_required = "Restart when you’re ready",
    error = "Updates need your attention",
}

local confirmingReboot = false

local function canReboot(value)
    return value ~= nil and value.status == "reboot_required" and not value.busy
end

local function render(value)
    value = value or { status = "checking", message = "Getting update information…", busy = true }
    if not canReboot(value) then
        confirmingReboot = false
    end
    local children = {
        ui.label({ text = "System updates", fontSize = 13, color = "primary" }),
        ui.label({ text = titles[value.status] or titles.error, fontSize = 20, fontWeight = "bold", maxWidth = 340 }),
        ui.label({ text = value.message, maxWidth = 340, maxLines = 6 }),
        ui.label({ text = "Updates never restart your computer automatically.", maxWidth = 340, fontSize = 12 }),
        ui.row({ gap = 8 }, {
            ui.button({ text = "Check again", onClick = "checkAgain", enabled = not value.busy }),
            ui.button({ text = "Install update", variant = "primary", onClick = "applyUpdate",
                visible = value.status == "update_available", enabled = not value.busy }),
            ui.button({ text = "Restart", variant = "primary", onClick = "reboot",
                visible = value.status == "reboot_required" and not confirmingReboot, enabled = not value.busy }),
        }),
    }
    if confirmingReboot then
        table.insert(children, ui.label({ text = "Save your work before restarting. Your computer will restart after you confirm.",
            maxWidth = 340, fontSize = 12 }))
        table.insert(children, ui.row({ gap = 8 }, {
            ui.button({ text = "Confirm restart", variant = "primary", onClick = "confirmReboot", enabled = not value.busy }),
            ui.button({ text = "Cancel", onClick = "cancelReboot" }),
        }))
    end
    panel.render(ui.column({ padding = 20, gap = 14, width = 380 }, children))
end

function checkAgain()
    noctalia.state.set("request", { action = "check", nonce = tostring({}) .. tostring(os.time()) })
end

function applyUpdate()
    noctalia.state.set("request", { action = "update", nonce = tostring({}) .. tostring(os.time()) })
end

function reboot()
    local value = noctalia.state.get("status")
    confirmingReboot = canReboot(value)
    render(value)
end

function confirmReboot()
    local value = noctalia.state.get("status")
    local confirmed = confirmingReboot and canReboot(value)
    confirmingReboot = false
    render(value)
    if not confirmed then
        return
    end
    noctalia.state.set("request", { action = "reboot", nonce = tostring({}) .. tostring(os.time()) })
end

function cancelReboot()
    confirmingReboot = false
    render(noctalia.state.get("status"))
end

function onOpen()
    confirmingReboot = false
    render(noctalia.state.get("status"))
end

noctalia.state.watch("status", render)
render(noctalia.state.get("status"))
