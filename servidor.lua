-- Sistema de Login MTA SA
-- Autor: Daniel Taveras

local DB_PATH = ":memory:" -- O usa "users.db" para almacenamiento persistente
local db

-- Inicializar base de datos
function initializeDatabase()
    db = dbConnect("sqlite", "users.db")
    
    if not db then
        outputDebugString("Error: No se pudo conectar a la base de datos", 3)
        return false
    end
    
    -- Crear tabla de usuarios si no existe
    local query = [[
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            last_login DATETIME
        )
    ]]
    
    dbExec(db, query)
    outputDebugString("Base de datos inicializada correctamente")
    return true
end

-- Hashear contraseña
function hashPassword(password)
    return sha256(password)
end

-- Verificar si el usuario existe
function userExists(username)
    if not db then return false end
    
    local query = "SELECT id FROM users WHERE username = ?"
    local result = dbQuery(db, query, username)
    
    if result then
        local row = dbFetch(result)
        dbFree(result)
        return row ~= nil
    end
    
    return false
end

-- Registrar nuevo usuario
function registerUser(username, password)
    if not db then return false, "Base de datos no disponible" end
    
    -- Validar datos
    if not username or username == "" then
        return false, "Usuario vacío"
    end
    
    if not password or password == "" then
        return false, "Contraseña vacía"
    end
    
    if #username < 3 then
        return false, "El usuario debe tener mínimo 3 caracteres"
    end
    
    if #password < 6 then
        return false, "La contraseña debe tener mínimo 6 caracteres"
    end
    
    -- Verificar si ya existe
    if userExists(username) then
        return false, "Este usuario ya existe"
    end
    
    -- Insertar usuario
    local hashedPassword = hashPassword(password)
    local query = "INSERT INTO users (username, password) VALUES (?, ?)"
    
    local success = dbExec(db, query, username, hashedPassword)
    
    if success then
        return true, "Usuario registrado correctamente"
    else
        return false, "Error al registrar el usuario"
    end
end

-- Login de usuario
function loginUser(username, password)
    if not db then return false, "Base de datos no disponible" end
    
    if not username or username == "" then
        return false, "Usuario vacío"
    end
    
    if not password or password == "" then
        return false, "Contraseña vacía"
    end
    
    -- Buscar usuario
    local query = "SELECT id, password FROM users WHERE username = ?"
    local result = dbQuery(db, query, username)
    
    if not result then
        return false, "Usuario o contraseña incorrectos"
    end
    
    local row = dbFetch(result)
    dbFree(result)
    
    if not row then
        return false, "Usuario o contraseña incorrectos"
    end
    
    -- Verificar contraseña
    local hashedPassword = hashPassword(password)
    
    if row["password"] == hashedPassword then
        -- Actualizar último login
        local updateQuery = "UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE username = ?"
        dbExec(db, updateQuery, username)
        
        return true, "Login exitoso"
    else
        return false, "Usuario o contraseña incorrectos"
    end
end

-- Eventos del servidor
addEventHandler("onResourceStart", resourceRoot, function()
    if initializeDatabase() then
        outputDebugString("Sistema de login iniciado correctamente")
    end
end)

-- Evento: Registrar usuario (llamado desde el cliente)
addEvent("registerRequest", true)
addEventHandler("registerRequest", root, function(username, password)
    local client = source
    local success, message = registerUser(username, password)
    
    triggerClientEvent(client, "registerResponse", client, success, message)
    
    if success then
        outputDebugString("Nuevo usuario registrado: " .. username)
    else
        outputDebugString("Error en registro: " .. message)
    end
end)

-- Evento: Login de usuario (llamado desde el cliente)
addEvent("loginRequest", true)
addEventHandler("loginRequest", root, function(username, password)
    local client = source
    local success, message = loginUser(username, password)
    
    triggerClientEvent(client, "loginResponse", client, success, message)
    
    if success then
        outputDebugString("Usuario logueado: " .. username)
        -- Aquí puedes agregar lógica adicional después del login
    else
        outputDebugString("Error en login: " .. message)
    end
end)

-- Comando para crear usuario admin (opcional)
addCommandHandler("createadmin", function(player, cmd, username, password)
    if not isObjectInACLGroup("user." .. getAccountName(getPlayerAccount(player)), aclGetGroup("Admin")) then
        outputChatBox("No tienes permiso", player)
        return
    end
    
    local success, message = registerUser(username, password)
    outputChatBox(message, player)
end)
