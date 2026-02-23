local M = {}

local defaults = {
    commit_limit = 20,
    keymap = "<leader>gf",
    instant_fixup_keymap = "<leader>gF",
}

local config = {}

local function has_staged_changes()
    vim.fn.system("git diff --cached --quiet")
    return vim.v.shell_error ~= 0
end

local function show_commit_picker(opts)
    opts = opts or {}
    local instant = opts.instant or false

    require("fzf-lua").git_commits({
        cmd = "git log --oneline -n " .. config.commit_limit .. " --color --format='%C(yellow)%h%Creset %s'",
        actions = {
            ["default"] = function(selected)
                local sha = selected[1]:match("^(%S+)")
                vim.fn.system("git commit --fixup=" .. sha)
                if vim.v.shell_error ~= 0 then
                    vim.notify("Fixup failed", vim.log.levels.ERROR)
                    return
                end

                if instant then
                    vim.notify("Rebasing...", vim.log.levels.INFO)
                    vim.fn.system("GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash " .. sha .. "~1")
                    if vim.v.shell_error == 0 then
                        vim.notify("Fixup applied to " .. sha:sub(1, 7), vim.log.levels.INFO)
                    else
                        vim.notify("Rebase failed - resolve conflicts and continue", vim.log.levels.ERROR)
                    end
                else
                    vim.notify("Created fixup for " .. sha:sub(1, 7), vim.log.levels.INFO)
                end
            end,
        },
    })
end

local function show_file_picker(opts)
    opts = opts or {}
    local files = vim.fn.systemlist("git diff --name-only && git ls-files --others --exclude-standard")
    if #files == 0 then
        vim.notify("No files to stage", vim.log.levels.WARN)
        return
    end

    table.insert(files, 1, "-- Stage All --")

    require("fzf-lua").fzf_exec(files, {
        prompt = "Stage files for fixup> ",
        preview = "git diff --color -- {} 2>/dev/null || cat {}",
        actions = {
            ["default"] = function(selected)
                local selection = selected[1]
                if selection == "-- Stage All --" then
                    vim.fn.system("git add -A")
                else
                    vim.fn.system("git add " .. vim.fn.shellescape(selection))
                end
                show_commit_picker(opts)
            end,
        },
    })
end

function M.fixup(opts)
    opts = opts or {}
    if has_staged_changes() then
        show_commit_picker(opts)
    else
        show_file_picker(opts)
    end
end

function M.instant_fixup()
    M.fixup({ instant = true })
end

function M.setup(opts)
    config = vim.tbl_deep_extend("force", defaults, opts or {})

    if config.keymap then
        vim.keymap.set("n", config.keymap, M.fixup, { desc = "Git fixup commit" })
    end
    if config.instant_fixup_keymap then
        vim.keymap.set(
            "n",
            config.instant_fixup_keymap,
            M.instant_fixup,
            { desc = "Git instant fixup (fixup + rebase)" }
        )
    end
end

return M
