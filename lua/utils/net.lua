-- DevOps / networking helper functions exposed as user commands and keymaps.
-- All pure-Lua, no external deps except jq / yq / base64 where noted.

local M = {}

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "devops" })
end

---------------------------------------------------------------------------
-- IPv4 helpers
---------------------------------------------------------------------------
local function ip2int(ip)
  local a, b, c, d = ip:match "^(%d+)%.(%d+)%.(%d+)%.(%d+)$"
  if not a then
    return nil
  end
  a, b, c, d = tonumber(a), tonumber(b), tonumber(c), tonumber(d)
  for _, v in ipairs { a, b, c, d } do
    if v > 255 then
      return nil
    end
  end
  return a * 16777216 + b * 65536 + c * 256 + d
end

local function int2ip(n)
  return string.format("%d.%d.%d.%d", math.floor(n / 16777216) % 256, math.floor(n / 65536) % 256, math.floor(n / 256) % 256, n % 256)
end

local function mask2prefix(mask)
  local n = ip2int(mask)
  if not n then
    return nil
  end
  local bits = 0
  for i = 31, 0, -1 do
    if math.floor(n / 2 ^ i) % 2 == 1 then
      bits = bits + 1
    else
      break
    end
  end
  return bits
end

local function prefix2mask(p)
  if p == 0 then
    return 0
  end
  return (2 ^ 32 - 2 ^ (32 - p))
end

local function wildcard(p)
  return 2 ^ (32 - p) - 1
end

--- Parse "10.0.0.0/24", "10.0.0.0 255.255.255.0", or "10.0.0.5/255.255.255.0"
function M.cidr_info(input)
  input = vim.trim(input or "")
  local ip, rest = input:match "^([%d%.]+)[/%s]+(.+)$"
  if not ip then
    ip, rest = input, "32"
  end
  local ipn = ip2int(ip)
  if not ipn then
    return nil, "invalid IPv4 address: " .. tostring(ip)
  end
  local prefix
  if rest:match "^%d+$" then
    prefix = tonumber(rest)
    if prefix > 32 then
      return nil, "prefix must be 0-32"
    end
  else
    prefix = mask2prefix(rest)
    if not prefix then
      return nil, "invalid netmask: " .. rest
    end
  end

  local mask = prefix2mask(prefix)
  local network = ipn - (ipn % 2 ^ (32 - prefix))
  local broadcast = network + wildcard(prefix)
  local total = 2 ^ (32 - prefix)
  local usable = prefix >= 31 and total or math.max(total - 2, 0)
  local first = prefix >= 31 and network or network + 1
  local last = prefix >= 31 and broadcast or broadcast - 1

  local class = "A"
  local first_octet = math.floor(ipn / 16777216)
  if first_octet >= 224 then
    class = "D/E (multicast/reserved)"
  elseif first_octet >= 192 then
    class = "C"
  elseif first_octet >= 128 then
    class = "B"
  end

  local private = (first_octet == 10) or (first_octet == 172 and math.floor(ipn / 65536) % 256 >= 16 and math.floor(ipn / 65536) % 256 <= 31)
    or (first_octet == 192 and math.floor(ipn / 65536) % 256 == 168)
  local loopback = first_octet == 127
  local linklocal = first_octet == 169 and math.floor(ipn / 65536) % 256 == 254

  return {
    { "Address", ip .. "/" .. prefix },
    { "Netmask", int2ip(mask) },
    { "Wildcard", int2ip(wildcard(prefix)) },
    { "Network", int2ip(network) .. "/" .. prefix },
    { "Broadcast", int2ip(broadcast) },
    { "First host", int2ip(first) },
    { "Last host", int2ip(last) },
    { "Total addrs", string.format("%d", total) },
    { "Usable hosts", string.format("%d", usable) },
    { "Class", class },
    { "Scope", loopback and "loopback" or linklocal and "link-local" or private and "private (RFC1918)" or "public" },
  }
end

local function float_win(lines, title)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"
  local w = 0
  for _, l in ipairs(lines) do
    w = math.max(w, vim.fn.strdisplaywidth(l))
  end
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "cursor",
    row = 1,
    col = 0,
    width = w + 2,
    height = #lines,
    style = "minimal",
    border = "rounded",
    title = " " .. title .. " ",
    title_pos = "center",
  })
  vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = buf, nowait = true })
  vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", { buffer = buf, nowait = true })
  vim.keymap.set("n", "y", function()
    vim.fn.setreg("+", table.concat(lines, "\n"))
    notify "copied to clipboard"
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, nowait = true })
  return win
end

--- :Cidr [addr/prefix]  or use word under cursor
function M.cidr_cmd(arg)
  local input = arg ~= "" and arg or vim.fn.expand "<cWORD>"
  local info, err = M.cidr_info(input)
  if not info then
    return notify(err, vim.log.levels.ERROR)
  end
  local lines = {}
  for _, kv in ipairs(info) do
    table.insert(lines, string.format("%-13s %s", kv[1] .. ":", kv[2]))
  end
  float_win(lines, "CIDR")
end

--- Convert netmask <-> prefix for the word under cursor
function M.mask_toggle()
  local w = vim.fn.expand "<cWORD>"
  local out
  if w:match "^/?%d%d?$" then
    local p = tonumber(w:gsub("/", ""))
    if p and p <= 32 then
      out = int2ip(prefix2mask(p))
    end
  else
    local p = mask2prefix(w)
    if p then
      out = "/" .. p
    end
  end
  if not out then
    return notify("not a netmask or prefix: " .. w, vim.log.levels.WARN)
  end
  notify(w .. "  =>  " .. out)
  vim.fn.setreg("+", out)
end

---------------------------------------------------------------------------
-- Text transforms on visual selection / whole buffer
---------------------------------------------------------------------------
local function get_visual()
  local s = vim.fn.getpos "'<"
  local e = vim.fn.getpos "'>"
  local lines = vim.api.nvim_buf_get_lines(0, s[2] - 1, e[2], false)
  if #lines == 0 then
    return nil
  end
  if #lines == 1 then
    lines[1] = lines[1]:sub(s[3], e[3])
  else
    lines[1] = lines[1]:sub(s[3])
    lines[#lines] = lines[#lines]:sub(1, e[3])
  end
  return table.concat(lines, "\n"), s, e
end

local function replace_visual(text, s, e)
  local new_lines = vim.split(text, "\n", { plain = true })
  local first = vim.api.nvim_buf_get_lines(0, s[2] - 1, s[2], false)[1] or ""
  local last = vim.api.nvim_buf_get_lines(0, e[2] - 1, e[2], false)[1] or ""
  new_lines[1] = first:sub(1, s[3] - 1) .. new_lines[1]
  new_lines[#new_lines] = new_lines[#new_lines] .. last:sub(e[3] + 1)
  vim.api.nvim_buf_set_lines(0, s[2] - 1, e[2], false, new_lines)
end

function M.base64(mode) -- mode = "encode" | "decode"
  local text, s, e = get_visual()
  if not text then
    return
  end
  local out
  if mode == "encode" then
    out = vim.base64.encode(text)
  else
    local ok, res = pcall(vim.base64.decode, vim.trim(text))
    if not ok then
      return notify("not valid base64", vim.log.levels.ERROR)
    end
    out = res
  end
  replace_visual(out, s, e)
end

local function run_filter(cmd, range_only)
  if vim.fn.executable(cmd[1]) == 0 then
    return notify(cmd[1] .. " not installed (run :MasonInstallAll or pacman -S " .. cmd[1] .. ")", vim.log.levels.ERROR)
  end
  local r = range_only and "'<,'>" or "%"
  vim.cmd(r .. "!" .. table.concat(cmd, " "))
end

function M.json_pretty(range)
  run_filter({ "jq", "." }, range)
end
function M.json_minify(range)
  run_filter({ "jq", "-c", "." }, range)
end
function M.yaml_to_json(range)
  run_filter({ "yq", "-o=json", "." }, range)
  vim.bo.filetype = "json"
end
function M.json_to_yaml(range)
  run_filter({ "yq", "-P", "." }, range)
  vim.bo.filetype = "yaml"
end

---------------------------------------------------------------------------
-- Misc devops helpers
---------------------------------------------------------------------------
function M.uuid()
  local tpl = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
  return (tpl:gsub("[xy]", function(c)
    local v = (c == "x") and math.random(0, 15) or math.random(8, 11)
    return string.format("%x", v)
  end))
end

function M.insert_timestamp()
  vim.api.nvim_put({ os.date "%Y-%m-%dT%H:%M:%S%z" }, "c", true, true)
end

--- Copy file path (relative/absolute) or path:line
function M.copy_path(kind)
  local p = ({
    rel = vim.fn.expand "%:.",
    abs = vim.fn.expand "%:p",
    line = vim.fn.expand "%:." .. ":" .. vim.fn.line ".",
    name = vim.fn.expand "%:t",
  })[kind]
  vim.fn.setreg("+", p)
  notify("copied: " .. p)
end

--- Run current file / selection with the right tool
function M.run_current()
  local ft = vim.bo.filetype
  local f = vim.fn.expand "%:p"
  local cmds = {
    sh = "bash " .. f,
    bash = "bash " .. f,
    zsh = "zsh " .. f,
    fish = "fish " .. f,
    python = "python3 " .. f,
    go = "go run " .. f,
    lua = "nvim -l " .. f,
    terraform = "terraform -chdir=" .. vim.fn.expand "%:p:h" .. " plan",
    ["yaml.ansible"] = "ansible-playbook " .. f,
    ["yaml.kubernetes"] = "kubectl apply --dry-run=client -f " .. f,
    ["yaml.docker-compose"] = "docker compose -f " .. f .. " config",
    dockerfile = "docker build -f " .. f .. " " .. vim.fn.expand "%:p:h",
    make = "make -f " .. f,
    hurl = "hurl --test " .. f,
  }
  local cmd = cmds[ft]
  if not cmd or cmd == "" then
    return notify("no runner for filetype " .. ft, vim.log.levels.WARN)
  end
  vim.cmd "write"
  require("nvchad.term").runner { pos = "sp", id = "runner", cmd = cmd, clear_cmd = true }
end

--- Validate the current file with the right linter/validator, show output in a split
function M.validate_current()
  local ft = vim.bo.filetype
  local f = vim.fn.expand "%:p"
  local d = vim.fn.expand "%:p:h"
  local cmds = {
    yaml = "yamllint " .. f,
    ["yaml.ansible"] = "ansible-lint " .. f,
    ["yaml.kubernetes"] = "kubectl apply --dry-run=server -f " .. f,
    ["yaml.docker-compose"] = "docker compose -f " .. f .. " config -q && echo OK",
    ["yaml.github"] = "yamllint " .. f,
    helm = "helm lint " .. d .. "/..",
    ["yaml.helm-chart"] = "helm lint " .. d,
    ["yaml.helm-values"] = "helm lint " .. d,
    dockerfile = "hadolint " .. f,
    terraform = "cd " .. d .. " && terraform fmt -check -diff && terraform validate",
    hcl = "cd " .. d .. " && terraform fmt -check -diff",
    sh = "shellcheck " .. f,
    bash = "shellcheck " .. f,
    json = "jq empty " .. f .. " && echo 'valid JSON'",
    nginx = "nginx -t -c " .. f,
    sshdconfig = "sshd -t -f " .. f,
    systemd = "systemd-analyze verify " .. f,
    python = "python3 -m py_compile " .. f .. " && echo OK",
    bindzone = "named-checkzone " .. vim.fn.expand "%:t:r" .. " " .. f,
  }
  local cmd = cmds[ft]
  if not cmd then
    return notify("no validator for filetype " .. ft, vim.log.levels.WARN)
  end
  vim.cmd "write"
  require("nvchad.term").runner { pos = "sp", id = "validator", cmd = cmd, clear_cmd = true }
end

---------------------------------------------------------------------------
-- Register user commands
---------------------------------------------------------------------------
function M.setup()
  local cmd = vim.api.nvim_create_user_command

  cmd("Cidr", function(o)
    M.cidr_cmd(o.args)
  end, { nargs = "?", desc = "IPv4 subnet calculator (arg or word under cursor)" })

  cmd("MaskToggle", M.mask_toggle, { desc = "Convert netmask <-> /prefix under cursor" })

  cmd("Base64Encode", function()
    M.base64 "encode"
  end, { range = true, desc = "base64-encode selection" })
  cmd("Base64Decode", function()
    M.base64 "decode"
  end, { range = true, desc = "base64-decode selection" })

  cmd("JsonPretty", function(o)
    M.json_pretty(o.range > 0)
  end, { range = true, desc = "jq pretty-print" })
  cmd("JsonMinify", function(o)
    M.json_minify(o.range > 0)
  end, { range = true, desc = "jq minify" })
  cmd("YamlToJson", function(o)
    M.yaml_to_json(o.range > 0)
  end, { range = true, desc = "yq: YAML -> JSON" })
  cmd("JsonToYaml", function(o)
    M.json_to_yaml(o.range > 0)
  end, { range = true, desc = "yq: JSON -> YAML" })

  cmd("Uuid", function()
    vim.api.nvim_put({ M.uuid() }, "c", true, true)
  end, { desc = "insert a UUIDv4" })
  cmd("Timestamp", M.insert_timestamp, { desc = "insert ISO-8601 timestamp" })

  cmd("RunFile", M.run_current, { desc = "run / apply current file" })
  cmd("ValidateFile", M.validate_current, { desc = "validate / lint current file with its native tool" })

  cmd("Keymaps", function()
    vim.cmd("edit " .. vim.fn.stdpath "config" .. "/docs/KEYMAPS.md")
  end, { desc = "open the keymap documentation" })
end

return M
