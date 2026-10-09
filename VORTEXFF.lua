# -- ============================================================
--   VORTEX FF  -  Mod Menu para GameGuardian
--   Versao 1.0  |  Autor: SEU NOME  |  Contato: @seu_usuario
--   Revenda permitida? Sim.  Edite AUTOR e CONTATO abaixo.
-- ============================================================

local VERSION = "1.0"
local AUTOR   = "SEU NOME"
local CONTATO = "@seu_usuario"

-- pasta do config (salva junto do script)
local DIR  = (gg.getFile():match("(.*)/") or "/sdcard") .. "/"
local ARQ  = DIR .. "vortex_config.txt"

-- ---------- VALORES (o cliente muda pelo menu) ----------
local cfg = {
  danoOn = false, danoSrc = "1.0",  danoNew = "2.0",
  hpOn   = false, hpSrc   = "100",  hpNew   = "9999",
  velOn  = false, velSrc  = "1.0",  velNew  = "2.0",
  esp    = false,
  aim    = false,
  cor    = 0xFFFF3B00,   -- laranja
  cor2   = 0xFF00E5FF,   -- ciano
}

local function toast(m) gg.toast("VORTEX » " .. m) end

-- ---------- CONFIG: carregar / salvar ----------
local function carregar()
  local f = io.open(ARQ, "r"); if not f then return end
  local t = f:read("*a"); f:close()
  for k, v in t:gmatch("([%w_]+)=([%-%w%.]+)") do
    if cfg[k] ~= nil then
      if type(cfg[k]) == "boolean" then cfg[k] = (v == "true")
      elseif type(cfg[k]) == "number" then cfg[k] = tonumber(v) or cfg[k]
      else cfg[k] = v end
    end
  end
end

local function salvar()
  local f = io.open(ARQ, "w"); if not f then return end
  for k, v in pairs(cfg) do f:write(k .. "=" .. tostring(v) .. "\n") end
  f:close()
end

-- ---------- BUSCA E EDIÇAO NA MEMORIA ----------
local function editar(de, para, tipo)
  gg.clearResults()
  gg.setRanges(gg.REGION_C_ALLOC | gg.REGION_ANONYMOUS)
  gg.searchNumber(de, tipo)
  if gg.getResultsCount() == 0 then return false end
  gg.getResults(gg.getResultsCount())
  gg.editAll(para, tipo)
  return true
end

local function aplicarDano() editar(cfg.danoSrc, cfg.danoNew, gg.TYPE_FLOAT) end
local function aplicarHP()   editar(cfg.hpSrc,   cfg.hpNew,   gg.TYPE_DWORD) end
local function aplicarVel()  editar(cfg.velSrc,  cfg.velNew,  gg.TYPE_FLOAT) end

-- ---------- ESP + MIRA (desenho na tela) ----------
local function desenhar()
  gg.clearDrawings()
  local w, h = gg.getScreenSize()
  local cx, cy = w / 2, h / 2

  if cfg.aim then                        -- retículo central
    gg.drawCircle(cx, cy, 12, cfg.cor2, 2)
    gg.drawLine(cx - 22, cy, cx + 22, cy, cfg.cor2, 2)
    gg.drawLine(cx, cy - 22, cx, cy + 22, cfg.cor2, 2)
  end

  if cfg.esp then                        -- caixas nos inimigos
    -- EXEMPLO de posicoes. Calibre conforme seu aparelho/jogo.
    local alvos = {
      {x = w*0.14, y = h*0.28, bw = w*0.13, bh = h*0.46},
      {x = w*0.63, y = h*0.24, bw = w*0.13, bh = h*0.46},
      {x = w*0.40, y = h*0.34, bw = w*0.11, bh = h*0.42},
    }
    for _, a in ipairs(alvos) do
      gg.drawRect(a.x, a.y, a.x + a.bw, a.y + a.bh, cfg.cor, 3)
      gg.drawText(a.x, a.y - 30, "INIMIGO", cfg.cor2, 26)
      gg.drawLine(cx, cy, a.x + a.bw/2, a.y + a.bh/2, cfg.cor, 2)
    end
  end
end

-- ---------- MENU ----------
local function menu()
  local m = {
    (cfg.danoOn and "[X] " or "[  ] ") .. "Dano  (" .. cfg.danoSrc .. " -> " .. cfg.danoNew .. ")",
    (cfg.hpOn   and "[X] " or "[  ] ") .. "Vida infinita  (" .. cfg.hpNew .. ")",
    (cfg.velOn  and "[X] " or "[  ] ") .. "Velocidade  (" .. cfg.velSrc .. " -> " .. cfg.velNew .. ")",
    (cfg.esp    and "[X] " or "[  ] ") .. "ESP - ver inimigos",
    (cfg.aim    and "[X] " or "[  ] ") .. "Assistente de mira",
    ">> Configurar valores",
    ">> SALVAR config",
    ">> INICIAR VORTEX",
    "Sair",
  }
  return gg.choice(m, nil, "VORTEX FF v" .. VERSION .. " | " .. AUTOR)
end

-- ---------- CONFIGURAR VALORES ----------
local function configurar()
  local r = gg.prompt(
    {"Valor ORIGINAL do dano:", "Valor NOVO do dano:",
     "Valor de vida (HP):", "Valor ORIGINAL da velocidade:", "Valor NOVO da velocidade:"},
    {cfg.danoSrc, cfg.danoNew, cfg.hpNew, cfg.velSrc, cfg.velNew},
    {"number", "number", "number", "number", "number"})
  if not r then return end
  cfg.danoSrc = r[1]; cfg.danoNew = r[2]; cfg.hpNew = r[3]
  cfg.velSrc  = r[4]; cfg.velNew  = r[5]
  toast("valores atualizados")
end

-- ---------- LOOP PRINCIPAL ----------
local function iniciar()
  salvar()
  gg.clearResults()
  if cfg.danoOn then aplicarDano() end
  if cfg.hpOn   then aplicarHP()   end
  if cfg.velOn  then aplicarVel()  end
  toast("rodando... pare o script p/ voltar ao menu")
  while true do
    if cfg.esp or cfg.aim then desenhar() end
    gg.sleep(16)
  end
end

-- ---------- ARRANQUE ----------
carregar()
while true do
  local op = menu()
  if op == nil or op == 9 then break
  elseif op == 1 then cfg.danoOn = not cfg.danoOn; if cfg.danoOn then aplicarDano() end
  elseif op == 2 then cfg.hpOn   = not cfg.hpOn;   if cfg.hpOn   then aplicarHP()   end
  elseif op == 3 then cfg.velOn  = not cfg.velOn;  if cfg.velOn  then aplicarVel()  end
  elseif op == 4 then cfg.esp = not cfg.esp
  elseif op == 5 then cfg.aim = not cfg.aim
  elseif op == 6 then configurar()
  elseif op == 7 then salvar(); toast("config salva")
  elseif op == 8 then iniciar()
  end
end
gg.clearDrawings()
toast("VORTEX encerrado")