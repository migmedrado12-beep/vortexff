-- ============================================================
--   VORTEX FF  -  EXECUTOR (lancador)
--   Roda o VORTEX mais recente direto da nuvem.
-- ============================================================

local VERSAO  = "1.0"
local AUTOR   = "SEU NOME"
local CONTATO = "@seu_usuario"

-- >>> COLE AQUI O LINK DIRETO DO SEU VORTEXFF.lua (veja como no item 2)
local REMOTO = "https://SEU-LINK-AQUI/VORTEXFF.lua"

-- arquivo local de reserva (caso esteja sem internet)
local LOCALF = "/sdcard/VORTEXFF/VORTEXFF.lua"

gg.setVisible(false)

gg.toast("VORTEX Executor v" .. VERSAO .. " - carregando...")
gg.sleep(600)

local code = nil

-- 1) tenta baixar da nuvem
if REMOTO:find("http") then
  local r = gg.makeRequest(REMOTO)
  if r and r.code == 200 and r.content and #r.content > 100 then
    code = r.content
    gg.toast("VORTEX: versao ATUALIZADA da nuvem")
  end
end

-- 2) se falhou, usa a copia local
if not code then
  local f = io.open(LOCALF, "r")
  if f then code = f:read("*a"); f:close()
    gg.toast("VORTEX: usando versao local (offline)") end
end

if not code then
  gg.setVisible(true)
  gg.alert("VORTEX Executor\n\nNao consegui carregar o script.\nConfira sua internet ou o link do executor.")
  os.exit()
end

-- 3) executa
local chunk, err = load(code)
if not chunk then
  gg.setVisible(true)
  gg.alert("VORTEX: erro ao carregar.\n" .. tostring(err))
  os.exit()
end

gg.setVisible(true)
chunk()