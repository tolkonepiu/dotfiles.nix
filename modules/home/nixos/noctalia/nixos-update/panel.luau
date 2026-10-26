local titles = {
    checking = "Checking for updates…",
    up_to_date = "Your system is up to date",
    update_available = "An update is ready",
    updating = "Updating your system…",
    reboot_required = "Restart when you’re ready",
    error = "Updates need your attention",
}

local function render(value)
    value = value or { status = "checking", message = "Waiting for the update checker…", busy = true }
    panel.render(ui.column({ padding = 20, gap = 14, width = 380 }, {
        ui.label({ text = "NixOS updates", fontSize = 13, color = "primary" }),
        ui.label({ text = titles[value.status] or titles.error, fontSize = 20, fontWeight = "bold", maxWidth = 340 }),
        ui.label({ text = value.message, maxWidth = 340, maxLines = 6 }),
        ui.label({ text = "Updates never restart your computer automatically.", maxWidth = 340, fontSize = 12 }),
        ui.row({ gap = 8 }, {
            ui.button({ text = "Check again", onClick = "checkAgain", enabled = not value.busy }),
            ui.button({ text = "Apply update", variant = "primary", onClick = "applyUpdate",
                visible = value.status == "update_available", enabled = not value.busy }),
        }),
    }))
end

function checkAgain()
    noctalia.state.set("request", { action = "check", nonce = tostring({}) .. tostring(os.time()) })
end

function applyUpdate()
    noctalia.state.set("request", { action = "update", nonce = tostring({}) .. tostring(os.time()) })
end

function onOpen()
    render(noctalia.state.get("status"))
end

noctalia.state.watch("status", render)
render(noctalia.state.get("status"))
