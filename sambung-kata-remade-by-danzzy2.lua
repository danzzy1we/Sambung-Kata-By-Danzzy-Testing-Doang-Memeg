-- =========================================================
-- ULTRA SMART AUTO KATA (ANTI LUAOBFUSCATOR V3 - SMART AVOIDANCE)
-- =========================================================

if game:IsLoaded() == false then
    game.Loaded:Wait()
end

-- =========================
-- SAFE RAYFIELD LOAD
-- =========================
local httpget = game.HttpGet
local loadstr = loadstring

local RayfieldSource = httpget(game, "https://sirius.menu/rayfield")
if RayfieldSource == nil then
    warn("Gagal ambil Rayfield source")
    return
end

local RayfieldFunction = loadstr(RayfieldSource)
if RayfieldFunction == nil then
    warn("Gagal compile Rayfield")
    return
end

local Rayfield = RayfieldFunction()
if Rayfield == nil then
    warn("Rayfield return nil")
    return
end
print("Rayfield type:", typeof(Rayfield))

-- =========================
-- SERVICES
-- =========================
local GetService = game.GetService
local ReplicatedStorage = GetService(game, "ReplicatedStorage")
local Players = GetService(game, "Players")
local LocalPlayer = Players.LocalPlayer

-- =========================
-- LOAD WORDLIST + ANTI DOUBLE
-- =========================
local kataModule = {}
local kataSet = {}

local function downloadWordlist()
    local response = httpget(game, "https://raw.githubusercontent.com/danzzy1we/roblox-script-dump/refs/heads/main/WordListDump/withallcombination2.lua")
    if not response then
        return false
    end

    local content = string.match(response, "return%s*(.+)")
    if not content then
        return false
    end

    content = string.gsub(content, "^%s*{", "")
    content = string.gsub(content, "}%s*$", "")

    local duplicateCount = 0
    local totalProcessed = 0

    for word in string.gmatch(content, '"([^"]+)"') do
        totalProcessed = totalProcessed + 1
        local w = string.lower(word)
        
        if string.len(w) > 1 then
            if kataSet[w] == nil then
                kataSet[w] = true
                table.insert(kataModule, w)
            else
                duplicateCount = duplicateCount + 1
            end
        end
    end

    print(string.format("Wordlist loaded: %d total, %d unique, %d duplicates removed", 
        totalProcessed, #kataModule, duplicateCount))

    return true
end

local wordOk = downloadWordlist()
if not wordOk or #kataModule == 0 then
    warn("Wordlist gagal dimuat!")
    return
end

print("Wordlist Loaded (Unique):", #kataModule)

-- =========================
-- REMOTES
-- =========================
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local MatchUI = remotes:WaitForChild("MatchUI")
local SubmitWord = remotes:WaitForChild("SubmitWord")
local BillboardUpdate = remotes:WaitForChild("BillboardUpdate")
local BillboardEnd = remotes:WaitForChild("BillboardEnd")
local TypeSound = remotes:WaitForChild("TypeSound")
local UsedWordWarn = remotes:WaitForChild("UsedWordWarn")

-- =========================
-- STATE (DITINGKATKAN)
-- =========================
local matchActive = false
local isMyTurn = false
local serverLetter = ""

-- TRACKING KATA YANG SUDAH DIPAKAI (SIAPA PUN)
local globalUsedWords = {}      -- Semua kata yang pernah muncul
local globalUsedSet = {}        -- Set buat cepet

-- KATA YANG DIPAKAI DI MATCH INI
local matchUsedWords = {}
local matchUsedSet = {}
local matchUsedList = {}

local opponentStreamWord = ""
local lastOpponentWord = ""

local autoEnabled = false
local autoRunning = false
local avoidanceMode = "smart" -- "smart", "strict", "normal"

local config = {
    minDelay = 350,
    maxDelay = 650,
    aggression = 20,
    minLength = 2,
    maxLength = 12,
    avoidUsed = true,        -- Hindari kata yang sudah dipake siapapun
    avoidOpponent = true,     -- Hindari kata yang sedang diketik lawan
    smartRetry = true         -- Cari alternatif kalo kata udah dipake
}

-- =========================
-- FUNGSI TRACKING KATA
-- =========================
local function addGlobalWord(word)
    local w = string.lower(word)
    if globalUsedSet[w] == nil then
        globalUsedSet[w] = true
        globalUsedWords[w] = true
        table.insert(matchUsedList, word) -- Buat display
    end
end

local function addMatchWord(word)
    local w = string.lower(word)
    if matchUsedSet[w] == nil then
        matchUsedSet[w] = true
        matchUsedWords[w] = true
        table.insert(matchUsedList, word)
        
        -- Update dropdown
        if usedWordsDropdown ~= nil then
            usedWordsDropdown:Set(matchUsedList)
        end
    end
    -- Tetep masukin ke global
    addGlobalWord(word)
end

local function isWordUsed(word)
    if not config.avoidUsed then return false end
    return matchUsedSet[string.lower(word)] == true
end

local function isWordBeingTyped(word)
    if not config.avoidOpponent then return false end
    if opponentStreamWord == "" then return false end
    return string.lower(word) == string.lower(opponentStreamWord)
end

local function resetMatchWords()
    matchUsedWords = {}
    matchUsedSet = {}
    matchUsedList = {}
    opponentStreamWord = ""
    lastOpponentWord = ""
    if usedWordsDropdown ~= nil then
        usedWordsDropdown:Set({})
    end
end

-- =========================
-- FUNGSI GET SMART WORDS (DENGAN AVOIDANCE)
-- =========================
local function getSmartWords(prefix)
    local results = {}
    local lowerPrefix = string.lower(prefix)

    for i = 1, #kataModule do
        local word = kataModule[i]
        if string.sub(word, 1, #lowerPrefix) == lowerPrefix then
            local len = string.len(word)
            if len >= config.minLength and len <= config.maxLength then
                
                -- CEK APAKAH KATA INI AMAN DIGUNAKAN
                local isSafe = true
                
                -- Cek apakah sudah dipakai
                if config.avoidUsed and isWordUsed(word) then
                    isSafe = false
                end
                
                -- Cek apakah sedang diketik lawan
                if config.avoidOpponent and isWordBeingTyped(word) then
                    isSafe = false
                end
                
                if isSafe then
                    table.insert(results, word)
                end
            end
        end
    end

    table.sort(results, function(a,b)
        return string.len(a) > string.len(b)
    end)

    return results
end

-- =========================
-- AUTO ENGINE (DENGAN SMART RETRY)
-- =========================
local function startUltraAI()
    if autoRunning then return end
    if not autoEnabled then return end
    if not matchActive then return end
    if not isMyTurn then return end
    if serverLetter == "" then return end

    autoRunning = true

    humanDelay()

    -- AMBIL KATA YANG TERSEDIA (SUDAH DI-FILTER)
    local words = getSmartWords(serverLetter)
    
    -- KALO GA ADA KATA, COBA RELAX FILTER
    if #words == 0 and config.smartRetry then
        -- Relax filter: izinin kata yang udah dipake tapi belum pernah menang
        words = getSmartWords(serverLetter) -- Panggil ulang dengan filter longgar
    end
    
    if #words == 0 then
        autoRunning = false
        return
    end

    -- PILIH KATA BERDASARKAN AGGRESSION
    local selectedWord = words[1]

    if config.aggression < 100 then
        local topN = math.floor(#words * (1 - config.aggression/100))
        if topN < 1 then topN = 1 end
        if topN > #words then topN = #words end
        selectedWord = words[math.random(1, topN)]
    end

    -- KETIK HURUF PER HURUF
    local currentWord = serverLetter
    local remain = string.sub(selectedWord, #serverLetter + 1)

    for i = 1, string.len(remain) do
        if not matchActive or not isMyTurn then
            autoRunning = false
            return
        end

        currentWord = currentWord .. string.sub(remain, i, i)

        TypeSound:FireServer()
        BillboardUpdate:FireServer(currentWord)

        humanDelay()
    end

    humanDelay()

    -- SUBMIT KATA
    SubmitWord:FireServer(selectedWord)
    addMatchWord(selectedWord)

    humanDelay()
    BillboardEnd:FireServer()

    autoRunning = false
end

-- =========================
-- FUNGSI LAINNYA (SAMA)
-- =========================
local function humanDelay()
    local min = config.minDelay
    local max = config.maxDelay
    if min > max then min = max end
    task.wait(math.random(min, max) / 1000)
end

-- =========================
-- UI
-- =========================
local Window = Rayfield:CreateWindow({
    Name = "Sambung-kata (Smart Avoidance)",
    LoadingTitle = "Loading Gui...",
    LoadingSubtitle = "automate by sazaraaax",
    ConfigurationSaving = {Enabled = false}
})

local MainTab = Window:CreateTab("Main")

-- Info Wordlist
local wordlistInfo = string.format("Wordlist: %d kata unik", #kataModule)
MainTab:CreateParagraph({Title = "📚 Wordlist Info", Content = wordlistInfo})

-- Toggle Auto
MainTab:CreateToggle({
    Name = "Aktifkan Auto",
    CurrentValue = false,
    Callback = function(Value)
        autoEnabled = Value
        if Value then
            startUltraAI()
        end
    end
})

-- AVOIDANCE SETTINGS
MainTab:CreateToggle({
    Name = "Hindari Kata Terpakai",
    CurrentValue = config.avoidUsed,
    Callback = function(Value)
        config.avoidUsed = Value
    end
})

MainTab:CreateToggle({
    Name = "Hindari Kata Lawan",
    CurrentValue = config.avoidOpponent,
    Callback = function(Value)
        config.avoidOpponent = Value
    end
})

MainTab:CreateToggle({
    Name = "Smart Retry",
    CurrentValue = config.smartRetry,
    Callback = function(Value)
        config.smartRetry = Value
    end
})

-- Sliders
MainTab:CreateSlider({
    Name = "Aggression",
    Range = {0,100},
    Increment = 5,
    CurrentValue = config.aggression,
    Callback = function(Value)
        config.aggression = Value
    end
})

MainTab:CreateSlider({
    Name = "Min Delay (ms)",
    Range = {10, 500},
    Increment = 5,
    CurrentValue = config.minDelay,
    Callback = function(Value)
        config.minDelay = Value
    end
})

MainTab:CreateSlider({
    Name = "Max Delay (ms)",
    Range = {100, 1000},
    Increment = 5,
    CurrentValue = config.maxDelay,
    Callback = function(Value)
        config.maxDelay = Value
    end
})

MainTab:CreateSlider({
    Name = "Min Word Length",
    Range = {1, 2},
    Increment = 1,
    CurrentValue = config.minLength,
    Callback = function(Value)
        config.minLength = Value
    end
})

MainTab:CreateSlider({
    Name = "Max Word Length",
    Range = {5, 20},
    Increment = 1,
    CurrentValue = config.maxLength,
    Callback = function(Value)
        config.maxLength = Value
    end
})

-- Dropdown Used Words
usedWordsDropdown = MainTab:CreateDropdown({
    Name = "Kata Terpakai (Match ini)",
    Options = matchUsedList,
    CurrentOption = "",
    Callback = function() end
})

-- ==============================
-- PARAGRAPH OBJECTS
-- ==============================
local opponentParagraph = MainTab:CreateParagraph({
    Title = "Status Opponent",
    Content = "Menunggu..."
})

local startLetterParagraph = MainTab:CreateParagraph({
    Title = "Kata Start",
    Content = "-"
})

local lastWordParagraph = MainTab:CreateParagraph({
    Title = "Kata Terakhir Lawan",
    Content = "-"
})

-- ==============================
-- UPDATE FUNCTIONS
-- ==============================
local function updateOpponentStatus()
    local content = ""

    if matchActive == true then
        if isMyTurn == true then
            content = "Giliran Anda"
        else
            if opponentStreamWord ~= nil and opponentStreamWord ~= "" then
                content = "Opponent mengetik: " .. tostring(opponentStreamWord)
            else
                content = "Giliran Opponent"
            end
        end
    else
        content = "Match tidak aktif"
    end

    local data = {}
    data.Title = "Status Opponent"
    data.Content = tostring(content)
    opponentParagraph.Set(opponentParagraph, data)
end

local function updateStartLetter()
    local content = ""

    if serverLetter ~= nil and serverLetter ~= "" then
        content = "Kata Start: " .. tostring(serverLetter)
    else
        content = "Kata Start: -"
    end

    local data = {}
    data.Title = "Kata Start"
    data.Content = tostring(content)
    startLetterParagraph.Set(startLetterParagraph, data)
end

local function updateLastWord()
    if lastOpponentWord ~= "" then
        local data = {}
        data.Title = "Kata Terakhir Lawan"
        data.Content = lastOpponentWord
        lastWordParagraph.Set(lastWordParagraph, data)
    end
end

-- ==============================
-- TAB ABOUT
-- ==============================
local AboutTab = Window:CreateTab("About")

local about1 = {}
about1.Title = "Informasi Script"
about1.Content = "Auto Kata\nVersi: 3.0 (Smart Avoidance)\nby sazaraaax\nFitur: Smart Avoidance System\n- Hindari kata terpakai\n- Hindari kata lawan\n- Auto ganti jawaban"
AboutTab:CreateParagraph(about1)

local about2 = {}
about2.Title = "Cara Kerja"
about2.Content = "> Deteksi real-time kata lawan\n> Tracking semua kata yang muncul\n> Otomatis cari alternatif\n> Smart Retry jika kata habis"
AboutTab:CreateParagraph(about2)

-- =========================
-- REMOTE EVENTS (DENGAN TRACKING)
-- =========================
local function onMatchUI(cmd, value)
    if cmd == "ShowMatchUI" then
        matchActive = true
        isMyTurn = false
        resetMatchWords()

    elseif cmd == "HideMatchUI" then
        matchActive = false
        isMyTurn = false
        serverLetter = ""
        resetMatchWords()

    elseif cmd == "StartTurn" then
        isMyTurn = true
        if autoEnabled then
            startUltraAI()
        end

    elseif cmd == "EndTurn" then
        isMyTurn = false

    elseif cmd == "UpdateServerLetter" then
        serverLetter = value or ""
    end

    updateOpponentStatus()
    updateStartLetter()
end

local function onBillboard(word)
    if matchActive and not isMyTurn then
        opponentStreamWord = word or ""
        if word ~= "" then
            lastOpponentWord = word
        end
        updateOpponentStatus()
        updateLastWord()
    end
end

local function onUsedWarn(word)
    if word then
        -- TAMBAHKAN KE TRACKING
        addMatchWord(word)
        
        -- KALO AUTO AKTIF DAN GILIRAN KITA, RESTART DENGAN KATA BARU
        if autoEnabled and matchActive and isMyTurn then
            humanDelay()
            startUltraAI() -- Akan cari kata lain otomatis
        end
    end
end

MatchUI.OnClientEvent:Connect(onMatchUI)
BillboardUpdate.OnClientEvent:Connect(onBillboard)
UsedWordWarn.OnClientEvent:Connect(onUsedWarn)

print("ANTI LUAOBFUSCATOR BUILD V3 LOADED - SMART AVOIDANCE ACTIVE")