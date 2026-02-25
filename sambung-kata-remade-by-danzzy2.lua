-- =========================================================
-- ULTRA SMART AUTO KATA (FIX FORCE START + DEBUG)
-- =========================================================

if game:IsLoaded() == false then
    game.Loaded:Wait()
end

-- =========================
-- DEBUG PRINT (BUAT LIAT ERROR)
-- =========================
local function debugPrint(...)
    local args = {...}
    local msg = "[DEBUG] " .. table.concat(args, " ")
    print(msg)
    -- Kalo ada notifikasi, kirim juga
    if Rayfield and Rayfield:Notify then
        pcall(function()
            Rayfield:Notify({Title = "Debug", Content = msg, Duration = 3})
        end)
    end
end

debugPrint("Script dimulai...")

-- =========================
-- SAFE RAYFIELD LOAD
-- =========================
local httpget = game.HttpGet
local loadstr = loadstring

debugPrint("Loading Rayfield...")
local RayfieldSource = httpget(game, "https://sirius.menu/rayfield")
if RayfieldSource == nil then
    debugPrint("GAGAL: Rayfield source nil")
    return
end

local RayfieldFunction = loadstr(RayfieldSource)
if RayfieldFunction == nil then
    debugPrint("GAGAL: Rayfield function nil")
    return
end

local Rayfield = RayfieldFunction()
if Rayfield == nil then
    debugPrint("GAGAL: Rayfield return nil")
    return
end
debugPrint("Rayfield loaded:", typeof(Rayfield))

-- =========================
-- SERVICES
-- =========================
local GetService = game.GetService
local ReplicatedStorage = GetService(game, "ReplicatedStorage")
local Players = GetService(game, "Players")
local LocalPlayer = Players.LocalPlayer

debugPrint("Services loaded")

-- =========================
-- LOAD WORDLIST
-- =========================
local kataModule = {}
local kataSet = {}

local function downloadWordlist()
    debugPrint("Downloading wordlist...")
    local response = httpget(game, "https://raw.githubusercontent.com/danzzy1we/roblox-script-dump/refs/heads/main/WordListDump/withallcombination2.lua")
    if not response then
        debugPrint("GAGAL: Wordlist download failed")
        return false
    end

    local content = string.match(response, "return%s*(.+)")
    if not content then
        debugPrint("GAGAL: No 'return' found in wordlist")
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

    debugPrint(string.format("Wordlist: %d total, %d unique, %d duplicates", 
        totalProcessed, #kataModule, duplicateCount))

    return true
end

local wordOk = downloadWordlist()
if not wordOk or #kataModule == 0 then
    debugPrint("GAGAL: Wordlist empty or failed")
    return
end

debugPrint("Wordlist loaded OK:", #kataModule)

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

debugPrint("Remotes loaded")

-- =========================
-- STATE
-- =========================
local matchActive = false
local isMyTurn = false
local serverLetter = ""

local usedWords = {}
local usedWordsSet = {}
local usedWordsList = {}
local opponentStreamWord = ""

local autoEnabled = false
local autoRunning = false

local config = {
    minDelay = 350,
    maxDelay = 650,
    aggression = 20,
    minLength = 2,
    maxLength = 12
}

-- =========================
-- FUNGSI LOGIC (DENGAN DEBUG)
-- =========================
local function isUsed(word)
    return usedWordsSet[string.lower(word)] == true
end

local usedWordsDropdown = nil

local function addUsedWord(word)
    local w = string.lower(word)
    if usedWordsSet[w] == nil then
        usedWordsSet[w] = true
        usedWords[w] = true
        table.insert(usedWordsList, word)
        debugPrint("Added used word:", word)
        if usedWordsDropdown ~= nil then
            pcall(function()
                usedWordsDropdown:Set(usedWordsList)
            end)
        end
    end
end

local function resetUsedWords()
    usedWords = {}
    usedWordsSet = {}
    usedWordsList = {}
    debugPrint("Reset used words")
    if usedWordsDropdown ~= nil then
        pcall(function()
            usedWordsDropdown:Set({})
        end)
    end
end

local function getSmartWords(prefix)
    debugPrint("Getting words for prefix:", prefix)
    local results = {}
    local lowerPrefix = string.lower(prefix)

    for i = 1, #kataModule do
        local word = kataModule[i]
        if string.sub(word, 1, #lowerPrefix) == lowerPrefix then
            if not isUsed(word) then
                local len = string.len(word)
                if len >= config.minLength and len <= config.maxLength then
                    table.insert(results, word)
                end
            end
        end
    end

    table.sort(results, function(a,b)
        return string.len(a) > string.len(b)
    end)

    debugPrint("Found", #results, "words for", prefix)
    return results
end

local function humanDelay()
    local min = config.minDelay
    local max = config.maxDelay
    if min > max then min = max end
    local delay = math.random(min, max) / 1000
    task.wait(delay)
end

-- =========================
-- AUTO ENGINE (FORCE START + DEBUG)
-- =========================
local function startUltraAI()
    debugPrint("=== START ULTRA AI ===")
    debugPrint("autoRunning:", autoRunning)
    debugPrint("autoEnabled:", autoEnabled)
    debugPrint("matchActive:", matchActive)
    debugPrint("isMyTurn:", isMyTurn)
    debugPrint("serverLetter:", serverLetter)

    if autoRunning then 
        debugPrint("EXIT: Already running")
        return 
    end
    
    if not autoEnabled then 
        debugPrint("EXIT: Auto not enabled")
        return 
    end
    
    if not matchActive then 
        debugPrint("EXIT: Match not active")
        return 
    end
    
    if not isMyTurn then 
        debugPrint("EXIT: Not my turn")
        return 
    end
    
    if serverLetter == "" then 
        debugPrint("EXIT: Server letter empty")
        return 
    end

    autoRunning = true
    debugPrint("Auto running set to TRUE")

    -- FORCE DELAY
    humanDelay()

    -- GET WORDS
    local words = getSmartWords(serverLetter)
    debugPrint("Words available:", #words)
    
    if #words == 0 then
        debugPrint("EXIT: No words available")
        autoRunning = false
        return
    end

    -- SELECT WORD
    local selectedWord = words[1]
    debugPrint("Selected word (initial):", selectedWord)

    if config.aggression < 100 then
        local topN = math.floor(#words * (1 - config.aggression/100))
        if topN < 1 then topN = 1 end
        if topN > #words then topN = #words end
        selectedWord = words[math.random(1, topN)]
        debugPrint("Selected word (after aggression):", selectedWord)
    end

    -- TYPE LETTER BY LETTER
    local currentWord = serverLetter
    local remain = string.sub(selectedWord, #serverLetter + 1)
    debugPrint("Remaining letters:", remain)

    for i = 1, string.len(remain) do
        debugPrint("Typing letter", i, "of", string.len(remain))

        if not matchActive or not isMyTurn then
            debugPrint("STOP: Match state changed")
            autoRunning = false
            return
        end

        currentWord = currentWord .. string.sub(remain, i, i)
        debugPrint("Current word:", currentWord)

        -- FIRE REMOTES
        pcall(function()
            TypeSound:FireServer()
            BillboardUpdate:FireServer(currentWord)
            debugPrint("Fired TypeSound and BillboardUpdate")
        end)

        humanDelay()
    end

    -- SUBMIT
    debugPrint("Submitting word:", selectedWord)
    humanDelay()

    pcall(function()
        SubmitWord:FireServer(selectedWord)
        debugPrint("Submitted")
    end)

    addUsedWord(selectedWord)

    humanDelay()

    pcall(function()
        BillboardEnd:FireServer()
        debugPrint("BillboardEnd fired")
    end)

    autoRunning = false
    debugPrint("=== AUTO AI FINISHED ===")
end

-- =========================
-- FORCE START FUNCTION (UNTUK TEST)
-- =========================
local function forceStartAI()
    debugPrint("FORCE STARTING AI...")
    -- Set state buat test
    matchActive = true
    isMyTurn = true
    serverLetter = "a" -- GANTI INI SESUAI HURUF YANG ADA
    
    startUltraAI()
end

-- =========================
-- UI
-- =========================
local Window = Rayfield:CreateWindow({
    Name = "Sambung-kata (FIXED)",
    LoadingTitle = "Loading Gui...",
    LoadingSubtitle = "by sazaraaax",
    ConfigurationSaving = {Enabled = false}
})

local MainTab = Window:CreateTab("Main")

-- Wordlist info
MainTab:CreateParagraph({Title = "Wordlist", Content = tostring(#kataModule) .. " kata"})

-- Toggle Auto
MainTab:CreateToggle({
    Name = "Aktifkan Auto",
    CurrentValue = false,
    Callback = function(Value)
        debugPrint("Auto toggled:", Value)
        autoEnabled = Value
        if Value then
            startUltraAI()
        end
    end
})

-- FORCE START BUTTON (UNTUK TEST)
MainTab:CreateButton({
    Name = "FORCE START AI (TEST)",
    Callback = function()
        debugPrint("Force start button pressed")
        forceStartAI()
    end
})

-- Sliders (sama seperti sebelumnya)
MainTab:CreateSlider({
    Name = "Aggression",
    Range = {0,100},
    Increment = 5,
    CurrentValue = config.aggression,
    Callback = function(Value) config.aggression = Value end
})

MainTab:CreateSlider({
    Name = "Min Delay (ms)",
    Range = {10, 500},
    Increment = 5,
    CurrentValue = config.minDelay,
    Callback = function(Value) config.minDelay = Value end
})

MainTab:CreateSlider({
    Name = "Max Delay (ms)",
    Range = {100, 1000},
    Increment = 5,
    CurrentValue = config.maxDelay,
    Callback = function(Value) config.maxDelay = Value end
})

-- Status Paragraphs
local statusMatch = MainTab:CreateParagraph({Title = "Match Status", Content = "Unknown"})
local statusTurn = MainTab:CreateParagraph({Title = "Turn Status", Content = "Unknown"})
local statusLetter = MainTab:CreateParagraph({Title = "Start Letter", Content = "-"})
local statusWords = MainTab:CreateParagraph({Title = "Available Words", Content = "0"})

-- Update status function
local function updateStatusDisplay()
    pcall(function()
        statusMatch.Set(statusMatch, {Title = "Match Status", Content = matchActive and "Active" or "Inactive"})
        statusTurn.Set(statusTurn, {Title = "Turn Status", Content = isMyTurn and "Your Turn" or "Opponent Turn"})
        statusLetter.Set(statusLetter, {Title = "Start Letter", Content = serverLetter ~= "" and serverLetter or "-"})
        
        local words = getSmartWords(serverLetter)
        statusWords.Set(statusWords, {Title = "Available Words", Content = tostring(#words)})
    end)
end

-- =========================
-- REMOTE EVENTS
-- =========================
MatchUI.OnClientEvent:Connect(function(cmd, value)
    debugPrint("MatchUI event:", cmd, value or "nil")
    
    if cmd == "ShowMatchUI" then
        matchActive = true
        isMyTurn = false
        resetUsedWords()
        debugPrint("Match started")

    elseif cmd == "HideMatchUI" then
        matchActive = false
        isMyTurn = false
        serverLetter = ""
        resetUsedWords()
        debugPrint("Match ended")

    elseif cmd == "StartTurn" then
        isMyTurn = true
        debugPrint("My turn started")
        if autoEnabled then
            debugPrint("Auto enabled, starting AI...")
            startUltraAI()
        else
            debugPrint("Auto disabled")
        end

    elseif cmd == "EndTurn" then
        isMyTurn = false
        debugPrint("My turn ended")

    elseif cmd == "UpdateServerLetter" then
        serverLetter = value or ""
        debugPrint("Server letter updated:", serverLetter)
    end
    
    updateStatusDisplay()
end)

BillboardUpdate.OnClientEvent:Connect(function(word)
    if matchActive and not isMyTurn then
        opponentStreamWord = word or ""
        debugPrint("Opponent typing:", opponentStreamWord)
    end
end)

UsedWordWarn.OnClientEvent:Connect(function(word)
    if word then
        debugPrint("Used word warning:", word)
        addUsedWord(word)
        if autoEnabled and matchActive and isMyTurn then
            debugPrint("Restarting AI with new word")
            humanDelay()
            startUltraAI()
        end
    end
end)

-- Update status periodically
spawn(function()
    while true do
        task.wait(1)
        updateStatusDisplay()
    end
end)

debugPrint("SCRIPT FULLY LOADED - CHECK F9 FOR DEBUG OUTPUT")
