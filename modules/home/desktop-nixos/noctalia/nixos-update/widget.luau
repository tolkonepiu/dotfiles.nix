local labels = {
    checking = { "refresh", "", "Checking for updates" },
    up_to_date = { "circle-check", "", "Your system is up to date" },
    update_available = { "download", "Update", "An update is available" },
    updating = { "refresh", "Updating", "Installing updates" },
    reboot_required = { "power", "Restart", "Restart required" },
    error = { "alert-triangle", "Check", "Updates need your attention" },
}

local function render(value)
    value = value or { status = "checking", message = "Checking for updates…" }
    local view = labels[value.status] or labels.error
    barWidget.setGlyph(view[1])
    barWidget.setText(view[2])
    barWidget.setTooltip(view[3] .. "\n" .. value.message .. "\nClick for details · Right-click to check")
end

function onClick()
    noctalia.togglePanel("dotfiles/nixos-update:updates")
end

function onRightClick()
    noctalia.state.set("request", { action = "check", nonce = tostring({}) .. tostring(os.time()) })
end

noctalia.state.watch("status", render)
render(noctalia.state.get("status"))
