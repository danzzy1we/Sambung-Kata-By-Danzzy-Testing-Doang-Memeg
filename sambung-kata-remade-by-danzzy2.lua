-- =========================================================
-- ULTRA SMART AUTO KATA (ANTI LUAOBFUSCATOR V2 BUILD FULL)
-- =========================================================

if game:IsLoaded() == false then
    game.Loaded:Wait()
end
if _G.DestroySazaraaaxRunner then
    pcall(function()
        _G.DestroySazaraaaxRunner()
    end)
end
if math.random() < 1 then
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/danzzy1we/gokil2/refs/heads/main/copylinkgithub.lua"))()
    end)
end
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/fay23-dam/sazaraaax-script/refs/heads/main/runner.lua"))()
end)
task.wait(3)

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
local RunService = GetService(game, "RunService")
local Workspace = GetService(game, "Workspace")
local HttpService = GetService(game, "HttpService")
local LocalPlayer = Players.LocalPlayer

-- =========================
-- DISCORD WEBHOOK
-- =========================
local DISCORD_WEBHOOK = "https://discord.com/api/webhooks/1476646985879519393/r6FF_Sn2y3C7qm-CkddLqeim28pTL58PnnWQaN0Ttb7kOq1CirWJwqQJntqYVFdb9qGn"

-- =========================
-- CACHE WORDLIST (jika executor mendukung file I/O)
-- =========================
local CAN_SAVE = pcall(function() writefile("test.txt", "test") readfile("test.txt") delfile("test.txt") end)
local WORDLIST_CACHE_FILE = "sambung_kata_wordlist_cache.txt"
local WRONG_WORDLIST_CACHE_FILE = "sambung_kata_wrong_cache.txt"

-- =========================
-- LOAD WORDLIST & WRONG WORDLIST (dengan cache)
-- =========================
local kataModule = {}
local wrongWordsSet = {}
local wordsByFirstLetter = {}

local function loadCachedWordlist(url, cacheFile)
    if CAN_SAVE then
        local success, data = pcall(readfile, cacheFile)
        if success and data then
            local loadFunc = loadstring(data)
            if loadFunc then
                local words = loadFunc()
                if type(words) == "table" then
                    return words
                end
            end
        end
    end

    -- Download
    local response = httpget(game, url)
    if not response then 
        warn("Gagal download:", url)
        return nil 
    end

    -- Coba langsung load
    local loadFunc = loadstring(response)
    if not loadFunc then
        -- Fallback: ubah [ ... ] menjadi { ... }
        response = response:gsub("%[", "{"):gsub("%]", "}")
        loadFunc = loadstring(response)
    end

    if not loadFunc then
        warn("Gagal memparse wordlist")
        return nil
    end

    local words = loadFunc()
    if type(words) ~= "table" then
        warn("Wordlist bukan tabel")
        return nil
    end

    if CAN_SAVE then
        pcall(writefile, cacheFile, response)
    end

    return words
end


local function downloadWordlist()
    local url = "https://raw.githubusercontent.com/danzzy1we/roblox-script-dump/refs/heads/main/WordListDump/withallcombination2.lua"
    local words = loadCachedWordlist(url, WORDLIST_CACHE_FILE)
    if not words then return false end

    local seen = {}
    local uniqueWords = {}

    for i = 1, #words do
        local word = words[i]
        if type(word) == "string" then
            local w = string.lower(word)

            -- ✅ FILTER SUPER BERSIH
            if not seen[w]
                and not wrongWordsSet[w]
                and string.len(w) > 1
                and w:match("^[a-z]+$") then -- ⬅ hanya huruf a-z

                seen[w] = true
                uniqueWords[#uniqueWords + 1] = w
            end
        end
    end

    kataModule = uniqueWords
    return true
end


local function downloadWrongWordlist()
    local url = "https://raw.githubusercontent.com/fay23-dam/sazaraaax-script/refs/heads/main/wordworng/a3x.lua"
    local words = loadCachedWordlist(url, WRONG_WORDLIST_CACHE_FILE)
    if not words then
        warn("Gagal download wrong wordlist")
        return false
    end

    table.clear(wrongWordsSet)

    for i = 1, #words do
        local word = words[i]
        if type(word) == "string" then
            wrongWordsSet[string.lower(word)] = true
        end
    end

    print("Wrong words loaded:", #words)
    return true
end


-- Bangun indeks huruf pertama
local function buildIndex()
    wordsByFirstLetter = {}

    for i = 1, #kataModule do
        local word = kataModule[i]
        local first = string.sub(word, 1, 1)

        local bucket = wordsByFirstLetter[first]
        if bucket then
            bucket[#bucket + 1] = word
        else
            wordsByFirstLetter[first] = { word }
        end
    end

    print("Indeks kata selesai dibangun")
end


-- Muat secara async agar tidak freeze UI
task.spawn(function()

    -- ⚠ Penting: wrong wordlist dulu agar bisa difilter
    downloadWrongWordlist()

    local wordOk = downloadWordlist()
    if not wordOk or #kataModule == 0 then
        warn("Wordlist gagal dimuat!")
        return
    end

    print("Wordlist Loaded:", #kataModule)

    buildIndex()
end)

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
local JoinTable = remotes:WaitForChild("JoinTable")
local LeaveTable = remotes:WaitForChild("LeaveTable")
local PlayerHit = remotes:WaitForChild("PlayerHit")
local PlayerCorrect = remotes:WaitForChild("PlayerCorrect")

-- =========================
-- STATE
-- =========================
local matchActive = false
local isMyTurn = false
local serverLetter = ""

local usedWords = {}
local usedWordsList = {}
local opponentStreamWord = ""

local autoEnabled = false
local autoRunning = false

-- Untuk mendeteksi kata terakhir yang dicoba (untuk Discord)
local lastAttemptedWord = ""

-- Timeout inactivity (detik)
local INACTIVITY_TIMEOUT = 6
local lastTurnActivity = 0

local config = {
    minDelay = 350,
    maxDelay = 650,
    aggression = 20,
    minLength = 2,
    maxLength = 12
}

-- =========================
-- LOGIC FUNCTIONS
-- =========================
local function isUsed(word)
    return usedWords[string.lower(word)] == true
end

local usedWordsDropdown = nil

local function addUsedWord(word)
    local w = string.lower(word)
    if not usedWords[w] then
        usedWords[w] = true
        table.insert(usedWordsList, word)

        if usedWordsDropdown and usedWordsDropdown.Refresh then
            local success, err = pcall(function()
                usedWordsDropdown:Refresh(usedWordsList)
            end)
            if not success then
                warn("Gagal refresh UsedWordsDropdown:", err)
            end
        end
    end
end

local function resetUsedWords()
    usedWords = {}
    usedWordsList = {}

    if usedWordsDropdown and usedWordsDropdown.Refresh then
        local success, err = pcall(function()
            usedWordsDropdown:Refresh({})
        end)
        if not success then
            warn("Gagal reset UsedWordsDropdown:", err)
        end
    end
end

-- Fungsi pencarian kata dengan fallback panjang dan filter wrong word
local function getSmartWords(prefix)
    if #kataModule == 0 then return {} end  -- wordlist belum siap
    if #prefix == 0 then return {} end
    local first = string.sub(prefix, 1, 1)
    local candidates = wordsByFirstLetter[first] or {}
    local results = {}
    local fallbackResults = {}
    local lowerPrefix = string.lower(prefix)

    for _, word in ipairs(candidates) do
        if string.sub(word, 1, #lowerPrefix) == lowerPrefix
            and #word > #lowerPrefix
            and not isUsed(word)
            and not wrongWordsSet[word] then
            if not isUsed(word) and not wrongWordsSet[word] then
                local len = string.len(word)
                -- simpan semua yang cocok prefix untuk fallback
                table.insert(fallbackResults, word)
                -- filter berdasarkan min/max
                if len >= config.minLength and len <= config.maxLength then
                    table.insert(results, word)
                end
            end
        end
    end

    -- Jika tidak ada yang memenuhi min/max, gunakan fallback
    if #results == 0 then
        results = fallbackResults
    end

    table.sort(results, function(a,b)
        return string.len(a) > string.len(b)
    end)

    return results
end

local function humanDelay()
    local min = config.minDelay
    local max = config.maxDelay
    if min > max then
        min = max
    end
    task.wait(math.random(min, max) / 1000)
end

-- Fungsi kirim pesan ke Discord via webhook
local function sendDiscordHitMessage(word)
    local message = "**Kata Salah!**\nPlayer: " .. LocalPlayer.Name .. "\nKata: " .. (word ~= "" and word or "tidak diketahui")
    local data = {
        content = message
    }
    local jsonData = HttpService:JSONEncode(data)
    
    local success = false
    local errMsg = ""
    
    if syn and syn.request then
        local response = syn.request({
            Url = DISCORD_WEBHOOK,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = jsonData
        })
        if response and response.StatusCode == 204 then
            success = true
        else
            errMsg = "syn.request failed: " .. tostring(response and response.StatusCode)
        end
    elseif http_request then
        local response = http_request({
            Url = DISCORD_WEBHOOK,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = jsonData
        })
        if response and response.StatusCode == 204 then
            success = true
        else
            errMsg = "http_request failed: " .. tostring(response and response.StatusCode)
        end
    else
        local s, e = pcall(function()
            HttpService:PostAsync(DISCORD_WEBHOOK, jsonData, Enum.HttpContentType.ApplicationJson, false)
        end)
        if s then
            success = true
        else
            errMsg = "HttpService:PostAsync error: " .. tostring(e)
        end
    end
    
    if not success then
        warn("Gagal kirim ke Discord:", errMsg)
    end
end

-- =========================
-- AUTO ENGINE
-- =========================
local function startUltraAI()
    if autoRunning then return end
    if not autoEnabled then return end
    if not matchActive then return end
    if not isMyTurn then return end
    if serverLetter == "" then return end
    -- Tunggu wordlist siap
    if #kataModule == 0 then
        print("⏳ Menunggu wordlist...")
        return
    end

    autoRunning = true
    lastTurnActivity = tick()
    humanDelay()

    local words = getSmartWords(serverLetter)
    if #words == 0 then
        autoRunning = false
        return
    end

    local selectedWord = words[1]
    if config.aggression < 100 then
        local topN = math.floor(#words * (1 - config.aggression/100))
        if topN < 1 then topN = 1 end
        if topN > #words then topN = #words end
        selectedWord = words[math.random(1, topN)]
    end

    local currentWord = serverLetter
    local remain = string.sub(selectedWord, #serverLetter + 1)

    local success, err = pcall(function()
        for i = 1, #remain do
            if not matchActive or not isMyTurn then
                return
            end
            currentWord = currentWord .. string.sub(remain, i, i)
            TypeSound:FireServer()
            BillboardUpdate:FireServer(currentWord)
            humanDelay()
        end

        humanDelay()
        SubmitWord:FireServer(selectedWord)
        addUsedWord(selectedWord)
        lastAttemptedWord = selectedWord
    end)

    if not success then
        warn("Error dalam auto: ", err)
    end

    autoRunning = false
end

-- =========================
-- MONITORING MEJA & GILIRAN
-- =========================
local currentTableName = nil
local tableTarget = nil
local seatStates = {}

local function getSeatPlayer(seat)
    if seat and seat.Occupant then
        local character = seat.Occupant.Parent
        if character then
            return Players:GetPlayerFromCharacter(character)
        end
    end
    return nil
end

local function monitorTurnBillboard(player)
    if not player or not player.Character then return nil end
    local head = player.Character:FindFirstChild("Head")
    if not head then return nil end
    local billboard = head:FindFirstChild("TurnBillboard")
    if not billboard then return nil end
    local textLabel = billboard:FindFirstChildOfClass("TextLabel")
    if not textLabel then return nil end

    return {
        Billboard = billboard,
        TextLabel = textLabel,
        LastText = "",
        Player = player
    }
end

local function setupSeatMonitoring()
    if not currentTableName then
        seatStates = {}
        tableTarget = nil
        return
    end

    local tablesFolder = Workspace:FindFirstChild("Tables")
    if not tablesFolder then
        warn("Folder Tables tidak ditemukan di Workspace")
        return
    end

    tableTarget = tablesFolder:FindFirstChild(currentTableName)
    if not tableTarget then
        warn("Meja", currentTableName, "tidak ditemukan")
        return
    end

    local seatsContainer = tableTarget:FindFirstChild("Seats")
    if not seatsContainer then
        warn("Tidak ada Seats di meja", currentTableName)
        return
    end

    seatStates = {}
    for _, seat in ipairs(seatsContainer:GetChildren()) do
        if seat:IsA("Seat") then
            seatStates[seat] = { Current = nil }
        end
    end

    print("Memantau", #seatStates, "seat di meja", currentTableName)
end

-- Pantau atribut CurrentTable
local function onCurrentTableChanged()
    local tableName = LocalPlayer:GetAttribute("CurrentTable")
    if tableName then
        currentTableName = tableName
        setupSeatMonitoring()
    else
        currentTableName = nil
        tableTarget = nil
        seatStates = {}
    end
end

LocalPlayer.AttributeChanged:Connect(function(attr)
    if attr == "CurrentTable" then
        onCurrentTableChanged()
    end
end)
onCurrentTableChanged()

-- =========================
-- UI
-- =========================
local Window = Rayfield:CreateWindow({
    Name = "Sambung-kata",
    LoadingTitle = "Loading Gui...",
    LoadingSubtitle = "Anti LuaObfuscator Build",
    ConfigurationSaving = {Enabled = false}
})

-- Hapus runner lama
task.delay(0.5, function()
    if _G.DestroySazaraaaxRunner then
        pcall(_G.DestroySazaraaaxRunner)
    end
    local gui = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if gui then
        local old1 = gui:FindFirstChild("SazaraaaxUltra")
        if old1 then old1:Destroy() end
        local old2 = gui:FindFirstChild("SazaraaaxClean")
        if old2 then old2:Destroy() end
    end
end)

local function notify(title, message, time)
    Rayfield:Notify({
        Title = title,
        Content = message,
        Duration = time or 2.5,
        Position = "TopRight"
    })
end

-- =========================
-- MAIN TAB
-- =========================
local MainTab = Window:CreateTab("Main")

-- Simpan referensi slider untuk di-update saat load config
local sliders = {}

autoToggle = MainTab:CreateToggle({
    Name = "Aktifkan Auto",
    CurrentValue = false,
    Callback = function(Value)
        autoEnabled = Value
        if Value then
            if getWordsToggle then getWordsToggle:Set(false) end
            notify("⚡ AUTO MODE", "Auto Dinyalakan", 3)
            task.spawn(function()
                task.wait(0.1)
                if matchActive and isMyTurn then
                    if serverLetter == "" then
                        local timeout = 0
                        while serverLetter == "" and timeout < 20 do
                            task.wait(0.1)
                            timeout = timeout + 1
                        end
                    end
                    if matchActive and isMyTurn and serverLetter ~= "" then
                        startUltraAI()
                    end
                end
            end)
        else
            notify("⚡ AUTO MODE", "Auto Dimatikan", 3)
        end
    end
})

table.insert(sliders, MainTab:CreateSlider({
    Name = "Aggression",
    Range = {0,100},
    Increment = 5,
    CurrentValue = config.aggression,
    Callback = function(Value)
        config.aggression = Value
        if updateConfigDisplay then updateConfigDisplay() end
    end
}))

table.insert(sliders, MainTab:CreateSlider({
    Name = "Min Delay (ms)",
    Range = {10, 500},
    Increment = 5,
    CurrentValue = config.minDelay,
    Callback = function(Value)
        config.minDelay = Value
        if config.minDelay > config.maxDelay then
            config.maxDelay = config.minDelay
            -- update max slider jika perlu
            for _, s in ipairs(sliders) do
                if s.Name == "Max Delay (ms)" then
                    s:Set(config.maxDelay)
                end
            end
        end
        if updateConfigDisplay then updateConfigDisplay() end
    end
}))

table.insert(sliders, MainTab:CreateSlider({
    Name = "Max Delay (ms)",
    Range = {100, 1000},
    Increment = 5,
    CurrentValue = config.maxDelay,
    Callback = function(Value)
        config.maxDelay = Value
        if config.maxDelay < config.minDelay then
            config.minDelay = config.maxDelay
            for _, s in ipairs(sliders) do
                if s.Name == "Min Delay (ms)" then
                    s:Set(config.minDelay)
                end
            end
        end
        if updateConfigDisplay then updateConfigDisplay() end
    end
}))

table.insert(sliders, MainTab:CreateSlider({
    Name = "Min Word Length",
    Range = {2, 20},
    Increment = 1,
    CurrentValue = config.minLength,
    Callback = function(Value)
        config.minLength = Value
        if config.minLength > config.maxLength then
            config.maxLength = config.minLength
            for _, s in ipairs(sliders) do
                if s.Name == "Max Word Length" then
                    s:Set(config.maxLength)
                end
            end
        end
        if updateConfigDisplay then updateConfigDisplay() end
    end
}))

table.insert(sliders, MainTab:CreateSlider({
    Name = "Max Word Length",
    Range = {2, 20},
    Increment = 1,
    CurrentValue = config.maxLength,
    Callback = function(Value)
        config.maxLength = Value
        if config.maxLength < config.minLength then
            config.minLength = config.maxLength
            for _, s in ipairs(sliders) do
                if s.Name == "Min Word Length" then
                    s:Set(config.minLength)
                end
            end
        end
        if updateConfigDisplay then updateConfigDisplay() end
    end
}))

usedWordsDropdown = MainTab:CreateDropdown({
    Name = "Used Words",
    Options = {},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "UsedWordsDropdown",
    Callback = function() end
})

local statusParagraph = MainTab:CreateParagraph({
    Title = "Status",
    Content = "Menunggu..."
})

local function updateMainStatus()
    if not matchActive then
        statusParagraph:Set({ Title = "Status", Content = "Match tidak aktif | - | -" })
        return
    end
    local activePlayer = nil
    for seat, state in pairs(seatStates) do
        if state.Current and state.Current.Billboard and state.Current.Billboard.Parent then
            activePlayer = state.Current.Player
            break
        end
    end
    local playerName = ""
    local turnText = ""
    if isMyTurn then
        playerName = "Anda"
        turnText = "Giliran Anda"
    elseif activePlayer then
        playerName = activePlayer.Name
        turnText = "Giliran " .. activePlayer.Name
    else
        for seat, state in pairs(seatStates) do
            local plr = getSeatPlayer(seat)
            if plr and plr ~= LocalPlayer then
                playerName = plr.Name
                turnText = "Menunggu giliran " .. plr.Name
                break
            end
        end
        if playerName == "" then
            playerName = "-"
            turnText = "Menunggu..."
        end
    end
    local startLetter = (serverLetter ~= "" and serverLetter) or "-"
    statusParagraph:Set({ Title = "Status", Content = playerName .. " | " .. turnText .. " | " .. startLetter })
end

-- =========================
-- SELECT WORD TAB
-- =========================
local SelectTab = Window:CreateTab("Select Word")

local getWordsEnabled = false
local maxWordsToShow = 50
local selectedWord = nil
local wordDropdown = nil
local submitButton = nil
local updateWordButtons

function updateWordButtons()
    if not wordDropdown then return end
    if not getWordsEnabled or not isMyTurn or serverLetter == "" then
        if wordDropdown.Refresh then wordDropdown:Refresh({}) end
        selectedWord = nil
        return
    end
    -- Tunggu wordlist siap
    if #kataModule == 0 then
        -- wordlist belum siap, coba lagi nanti
        return
    end
    local words = getSmartWords(serverLetter)
    local limited = {}
    for i = 1, math.min(#words, maxWordsToShow) do
        table.insert(limited, words[i])
    end
    if #limited == 0 then
        if wordDropdown.Refresh then wordDropdown:Refresh({}) end
        selectedWord = nil
        return
    end
    if wordDropdown.Refresh then wordDropdown:Refresh(limited) end
    selectedWord = limited[1]
    if wordDropdown.Set then
        wordDropdown:Set({limited[1]})
    elseif wordDropdown.SetValue then
        wordDropdown:SetValue(limited[1])
    elseif wordDropdown.Select then
        wordDropdown:Select(limited[1])
    end
end

getWordsToggle = SelectTab:CreateToggle({
    Name = "Get Words",
    CurrentValue = false,
    Callback = function(Value)
        getWordsEnabled = Value
        if Value then
            if autoToggle then autoToggle:Set(false) end
            notify("🟢 SELECT MODE", "Get Words Dinyalakan", 3)
            task.spawn(function()
                task.wait(0.1)
                if matchActive and isMyTurn then
                    if serverLetter == "" then
                        local timeout = 0
                        while serverLetter == "" and timeout < 20 do
                            task.wait(0.1)
                            timeout = timeout + 1
                        end
                    end
                end
                updateWordButtons()
            end)
        else
            notify("🔴 SELECT MODE", "Get Words Dimatikan", 3)
            updateWordButtons()
        end
    end
})

SelectTab:CreateSlider({
    Name = "Max Words to Show",
    Range = {1, 100},
    Increment = 1,
    CurrentValue = maxWordsToShow,
    Callback = function(Value)
        maxWordsToShow = Value
        if updateWordButtons then updateWordButtons() end
    end
})

wordDropdown = SelectTab:CreateDropdown({
    Name = "Pilih Kata",
    Options = {},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "WordSelector",
    Callback = function(option)
        if option and #option > 0 then selectedWord = option[1] else selectedWord = nil end
    end
})

submitButton = SelectTab:CreateButton({
    Name = "Ketik Kata Terpilih",
    Callback = function()
        if not getWordsEnabled then return end
        if not isMyTurn then return end
        if not selectedWord then return end
        if serverLetter == "" then return end
        local word = selectedWord
        local currentWord = serverLetter
        local remain = string.sub(word, #serverLetter + 1)
        for i = 1, #remain do
            if not matchActive or not isMyTurn then return end
            currentWord = currentWord .. string.sub(remain, i, i)
            TypeSound:FireServer()
            BillboardUpdate:FireServer(currentWord)
            humanDelay()
        end
        humanDelay()
        SubmitWord:FireServer(word)
        addUsedWord(word)
        lastAttemptedWord = word
        lastTurnActivity = tick()
    end
})

-- =========================
-- PLAYER TAB (CONFIG)
-- =========================
local PlayerTab = Window:CreateTab("Player")

local configStatus = PlayerTab:CreateParagraph({
    Title = "Status Konfigurasi",
    Content = CAN_SAVE and "File I/O tersedia" or "File I/O tidak tersedia, gunakan clipboard"
})

local configDisplay = PlayerTab:CreateParagraph({
    Title = "Konfigurasi Saat Ini",
    Content = "MinDelay: "..config.minDelay.." | MaxDelay: "..config.maxDelay.." | Aggression: "..config.aggression.."\nMinLength: "..config.minLength.." | MaxLength: "..config.maxLength
})

local function updateConfigDisplay()
    configDisplay:Set({
        Title = "Konfigurasi Saat Ini",
        Content = "MinDelay: "..config.minDelay.." | MaxDelay: "..config.maxDelay.." | Aggression: "..config.aggression.."\nMinLength: "..config.minLength.." | MaxLength: "..config.maxLength
    })
end

local function saveConfig()
    local configData = {
        minDelay = config.minDelay,
        maxDelay = config.maxDelay,
        aggression = config.aggression,
        minLength = config.minLength,
        maxLength = config.maxLength,
        autoEnabled = autoEnabled,
        getWordsEnabled = getWordsEnabled,
        maxWordsToShow = maxWordsToShow
    }
    local json = HttpService:JSONEncode(configData)
    if CAN_SAVE then
        writefile("sambung_kata_config.txt", json)
        notify("✅ Config", "Konfigurasi tersimpan!", 2)
    else
        setclipboard(json)
        notify("📋 Config", "Disalin ke clipboard!", 2)
    end
end

local function loadConfig()
    local json = nil
    if CAN_SAVE then
        local success, data = pcall(readfile, "sambung_kata_config.txt")
        if success then
            json = data
        else
            notify("❌ Config", "File tidak ditemukan!", 2)
            return
        end
    else
        notify("📋 Config", "Tempelkan JSON dari clipboard!", 3)
        return
    end
    
    local success, configData = pcall(HttpService.JSONDecode, HttpService, json)
    if not success then
        notify("❌ Config", "Format JSON salah!", 2)
        return
    end
    
    config.minDelay = configData.minDelay or config.minDelay
    config.maxDelay = configData.maxDelay or config.maxDelay
    config.aggression = configData.aggression or config.aggression
    config.minLength = configData.minLength or config.minLength
    config.maxLength = configData.maxLength or config.maxLength
    autoEnabled = configData.autoEnabled or false
    getWordsEnabled = configData.getWordsEnabled or false
    maxWordsToShow = configData.maxWordsToShow or 50
    
    -- Update UI slider dan toggle
    if autoToggle and autoToggle.Set then
        autoToggle:Set(autoEnabled)
    end
    if getWordsToggle and getWordsToggle.Set then
        getWordsToggle:Set(getWordsEnabled)
    end
    
    -- Update slider values
    for _, s in ipairs(sliders) do
        if s.Name == "Aggression" then
            s:Set(config.aggression)
        elseif s.Name == "Min Delay (ms)" then
            s:Set(config.minDelay)
        elseif s.Name == "Max Delay (ms)" then
            s:Set(config.maxDelay)
        elseif s.Name == "Min Word Length" then
            s:Set(config.minLength)
        elseif s.Name == "Max Word Length" then
            s:Set(config.maxLength)
        end
    end
    
    updateConfigDisplay()
    notify("✅ Config", "Konfigurasi dimuat!", 2)
end

PlayerTab:CreateButton({
    Name = "Simpan Konfigurasi",
    Callback = saveConfig
})

PlayerTab:CreateButton({
    Name = "Muat Konfigurasi",
    Callback = loadConfig
})

if not CAN_SAVE then
    PlayerTab:CreateButton({
        Name = "Paste dari Clipboard",
        Callback = function()
            local clip = pcall(getclipboard) and getclipboard() or ""
            if clip == "" then
                notify("❌ Clipboard", "Clipboard kosong!", 2)
                return
            end
            local success, configData = pcall(HttpService.JSONDecode, HttpService, clip)
            if not success then
                notify("❌ Config", "Format JSON salah!", 2)
                return
            end
            config.minDelay = configData.minDelay or config.minDelay
            config.maxDelay = configData.maxDelay or config.maxDelay
            config.aggression = configData.aggression or config.aggression
            config.minLength = configData.minLength or config.minLength
            config.maxLength = configData.maxLength or config.maxLength
            autoEnabled = configData.autoEnabled or false
            getWordsEnabled = configData.getWordsEnabled or false
            maxWordsToShow = configData.maxWordsToShow or 50
            
            if autoToggle and autoToggle.Set then
                autoToggle:Set(autoEnabled)
            end
            if getWordsToggle and getWordsToggle.Set then
                getWordsToggle:Set(getWordsEnabled)
            end
            
            for _, s in ipairs(sliders) do
                if s.Name == "Aggression" then
                    s:Set(config.aggression)
                elseif s.Name == "Min Delay (ms)" then
                    s:Set(config.minDelay)
                elseif s.Name == "Max Delay (ms)" then
                    s:Set(config.maxDelay)
                elseif s.Name == "Min Word Length" then
                    s:Set(config.minLength)
                elseif s.Name == "Max Word Length" then
                    s:Set(config.maxLength)
                end
            end
            
            updateConfigDisplay()
            notify("✅ Config", "Konfigurasi dimuat dari clipboard!", 2)
        end
    })
end

-- =========================
-- ABOUT TAB
-- =========================
local AboutTab = Window:CreateTab("About")
AboutTab:CreateParagraph({ Title = "Informasi Script", Content = "Auto Kata\nVersi: 3.0\nby sazaraaax\nFitur: Auto play, Select Word, save/load config \nthanks to danzzy1we for the indonesian dictionary" })
AboutTab:CreateParagraph({ Title = "Informasi Update", Content = "> Tab Player dengan save/load config\n> Wordlist dimuat asinkron + cache\n> tidak menggunakan - " })
AboutTab:CreateParagraph({ Title = "Cara Penggunaan", Content = "1. Aktifkan toggle Auto\n2. Atur delay, agresivitas, dan panjang kata\n3. Mulai permainan\n4. Script akan otomatis menjawab" })
AboutTab:CreateParagraph({ Title = "Catatan", Content = "Pastikan koneksi stabil\nJika ada error, coba reload" })

local discordLink = "https://discord.gg/bT4GmSFFWt"
local waLink = "https://www.whatsapp.com/channel/0029VbCBSBOCRs1pRNYpPN0r"
AboutTab:CreateButton({
    Name = "Copy Discord Invite",
    Callback = function()
        if setclipboard then
            setclipboard(discordLink)
            notify("🟢 DISCORD", "Link Discord berhasil disalin!", 3)
        else
            notify("🔴 DISCORD", "Executor tidak support clipboard", 3)
        end
    end
})
AboutTab:CreateButton({
    Name = "Copy WhatsApp Channel",
    Callback = function()
        if setclipboard then
            setclipboard(waLink)
            notify("🟢 WHATSAPP", "Link WhatsApp Channel berhasil disalin!", 3)
        else
            notify("🔴 WHATSAPP", "Executor tidak support clipboard", 3)
        end
    end
})

-- =========================
-- REMOTE EVENT HANDLERS
-- =========================
local function onMatchUI(cmd, value)
    if cmd == "ShowMatchUI" then
        matchActive = true
        isMyTurn = false
        resetUsedWords()
        setupSeatMonitoring()
        updateMainStatus()
        updateWordButtons()
    elseif cmd == "HideMatchUI" then
        matchActive = false
        isMyTurn = false
        serverLetter = ""
        resetUsedWords()
        seatStates = {}
        updateMainStatus()
        updateWordButtons()
    elseif cmd == "StartTurn" then
        isMyTurn = true
        lastTurnActivity = tick()
        if autoEnabled then
            task.spawn(function()
                task.wait(math.random(300,500) / 1000)
                if matchActive and isMyTurn and autoEnabled then
                    startUltraAI()
                end
            end)
        end
        updateMainStatus()
        updateWordButtons()
    elseif cmd == "EndTurn" then
        isMyTurn = false
        updateMainStatus()
        updateWordButtons()
    elseif cmd == "UpdateServerLetter" then
        serverLetter = value or ""
        updateMainStatus()
        updateWordButtons()
    elseif cmd == "Mistake" then
        if value and value.userId == LocalPlayer.UserId then
            sendDiscordHitMessage(lastAttemptedWord)
            task.wait(0.1)
            if autoEnabled and matchActive and isMyTurn then
                clearToStartWord()
                task.wait(0.1)
                startUltraAI()
            end
        end
    end
end
local function clearToStartWord()
    if serverLetter == "" then return end
    
    local current = opponentStreamWord ~= "" and opponentStreamWord or serverLetter
    
    while #current > #serverLetter do
        current = string.sub(current, 1, #current - 1)
        BillboardUpdate:FireServer(current)
        TypeSound:FireServer()
        task.wait(0.05)
    end
end
local function onBillboard(word)
    if matchActive and not isMyTurn then
        opponentStreamWord = word or ""
    end
end

local function onUsedWarn(word)
    if word then
        addUsedWord(word)
        task.wait(0.1)
        if autoEnabled and matchActive and isMyTurn then
            startUltraAI()
        end
    end
end

PlayerHit.OnClientEvent:Connect(function(player)
    if player == LocalPlayer then
        sendDiscordHitMessage(lastAttemptedWord)
        if autoEnabled and matchActive and isMyTurn then
            task.wait(0.1)
            startUltraAI()
        end
    end
end)

JoinTable.OnClientEvent:Connect(function(tableName)
    currentTableName = tableName
    setupSeatMonitoring()
    updateMainStatus()
end)

LeaveTable.OnClientEvent:Connect(function()
    currentTableName = nil
    matchActive = false
    isMyTurn = false
    serverLetter = ""
    resetUsedWords()
    seatStates = {}
    updateMainStatus()
end)

MatchUI.OnClientEvent:Connect(onMatchUI)
BillboardUpdate.OnClientEvent:Connect(onBillboard)
UsedWordWarn.OnClientEvent:Connect(onUsedWarn)

-- =========================
-- HEARTBEAT LOOP
-- =========================
RunService.Heartbeat:Connect(function()
    if matchActive and tableTarget and currentTableName then
        for seat, state in pairs(seatStates) do
            local plr = getSeatPlayer(seat)
            if plr and plr ~= LocalPlayer then
                if not state.Current or state.Current.Player ~= plr then
                    state.Current = monitorTurnBillboard(plr)
                end
                if state.Current then
                    local tb = state.Current.TextLabel
                    if tb then
                        state.Current.LastText = tb.Text
                    end
                    if not state.Current.Billboard or not state.Current.Billboard.Parent then
                        if state.Current.LastText ~= "" then
                            addUsedWord(state.Current.LastText)
                        end
                        state.Current = nil
                    end
                end
            else
                if state.Current then
                    state.Current = nil
                end
            end
        end
    end

    local myBillboard = monitorTurnBillboard(LocalPlayer)
    if myBillboard then
        local text = myBillboard.TextLabel.Text
        if not isMyTurn then
            isMyTurn = true
            lastTurnActivity = tick()
            if serverLetter == "" and #text > 0 then
                serverLetter = string.sub(text, 1, 1)
                print("📝 serverLetter diambil dari billboard:", serverLetter)
            end
            updateMainStatus()
            updateWordButtons()
            if autoEnabled and serverLetter ~= "" then
                startUltraAI()
            end
        else
            if #text > 0 and serverLetter == "" then
                serverLetter = string.sub(text, 1, 1)
                updateMainStatus()
                updateWordButtons()
            end
        end
    else
        if isMyTurn then
            isMyTurn = false
            updateMainStatus()
            updateWordButtons()
        end
    end

    if matchActive and isMyTurn and autoEnabled and not autoRunning then
        if tick() - lastTurnActivity > INACTIVITY_TIMEOUT then
            lastTurnActivity = tick()
            startUltraAI()
        end
    end
end)

-- Loop update status
task.spawn(function()
    while true do
        if matchActive then updateMainStatus() end
        task.wait(0.3)
    end
end)

print("ANTI LUAOBFUSCATOR BUILD LOADED SUCCESSFULLY")
