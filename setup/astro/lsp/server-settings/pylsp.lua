return {
    settings = {

        pylsp = {
            plugins = {
                -- not very useful with blue. w/o the 120 it did still format though, so:
                pycodestyle = { enabled = false, maxLineLength = 220 },
                pyflakes = { enabled = false }, -- by ruff
                pylint = { enabled = false },
            },
        },
    },
}
