-- Cliente - Sistema de Login MTA SA
-- Autor: Daniel Taveras

local loginWindow = nil
local loginActive = false

-- Crear ventana de login
function createLoginWindow()
    if loginWindow then
        destroyElement(loginWindow)
    end
    
    -- Cargar HTML
    loginWindow = guiCreateBrowser(0, 0, screenW, screenH, true)
    
    local filepath = "client/login.html"
    guiBrowserNavigate(loginWindow, "file://" .. filepath)
    
    -- Mostrar cursor
    showCursor(true)
    loginActive = true
end

-- Destruir ventana de login
function destroyLoginWindow()
    if loginWindow then
        destroyElement(loginWindow)
        loginWindow = nil
    end
    
    showCursor(false)
    loginActive = false
end

-- Eventos del cliente
addEventHandler("onClientResourceStart", resourceRoot, function()
    createLoginWindow()
end)

-- Evento: Registrar usuario
addEvent("registerRequest", true)
function sendRegisterRequest(username, password)
    triggerServerEvent("registerRequest", localPlayer, username, password)
end

-- Evento: Login
addEvent("loginRequest", true)
function sendLoginRequest(username, password)
    triggerServerEvent("loginRequest", localPlayer, username, password)
end

-- Respuesta de registro
addEvent("registerResponse", true)
addEventHandler("registerResponse", root, function(success, message)
    -- Enviar respuesta al navegador
    if loginWindow then
        guiBrowserExecuteJavascript(loginWindow, "showMessage('" .. message .. "', " .. tostring(success) .. ")")
    end
end)

-- Respuesta de login
addEvent("loginResponse", true)
addEventHandler("loginResponse", root, function(success, message)
    if success then
        destroyLoginWindow()
        outputChatBox("Bienvenido al servidor", 0, 255, 0)
    else
        if loginWindow then
            guiBrowserExecuteJavascript(loginWindow, "showMessage('" .. message .. "', false)")
        end
    end
end)

-- Funciones para JavaScript
function registerUser(username, password)
    sendRegisterRequest(username, password)
end

function loginUser(username, password)
    sendLoginRequest(username, password)
end

-- Evitar que el jugador se mueva mientras está en login
addEventHandler("onClientRender", root, function()
    if loginActive then
        guiSetInputEnabled(false)
    end
end)
