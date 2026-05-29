// Sistema de Login - JavaScript

function switchTab(tab) {
    // Ocultar todos los tabs
    document.querySelectorAll('.tab-content').forEach(el => {
        el.classList.remove('active');
    });
    
    // Desactivar todos los botones
    document.querySelectorAll('.tab-btn').forEach(el => {
        el.classList.remove('active');
    });
    
    // Mostrar tab seleccionado
    document.getElementById(tab + '-tab').classList.add('active');
    
    // Activar botón seleccionado
    event.target.classList.add('active');
    
    // Limpiar mensajes
    clearMessage();
}

function handleLogin(event) {
    event.preventDefault();
    
    const username = document.getElementById('login-username').value.trim();
    const password = document.getElementById('login-password').value.trim();
    
    // Validar campos
    if (!username || !password) {
        showMessage('Por favor completa todos los campos', false);
        return;
    }
    
    if (username.length < 3) {
        showMessage('El usuario debe tener mínimo 3 caracteres', false);
        return;
    }
    
    if (password.length < 6) {
        showMessage('La contraseña debe tener mínimo 6 caracteres', false);
        return;
    }
    
    // Enviar al servidor
    if (typeof loginUser !== 'undefined') {
        loginUser(username, password);
    }
}

function handleRegister(event) {
    event.preventDefault();
    
    const username = document.getElementById('register-username').value.trim();
    const password = document.getElementById('register-password').value.trim();
    const passwordConfirm = document.getElementById('register-password-confirm').value.trim();
    
    // Validar campos
    if (!username || !password || !passwordConfirm) {
        showMessage('Por favor completa todos los campos', false);
        return;
    }
    
    if (username.length < 3) {
        showMessage('El usuario debe tener mínimo 3 caracteres', false);
        return;
    }
    
    if (password.length < 6) {
        showMessage('La contraseña debe tener mínimo 6 caracteres', false);
        return;
    }
    
    if (password !== passwordConfirm) {
        showMessage('Las contraseñas no coinciden', false);
        return;
    }
    
    // Validar caracteres especiales
    const usernameRegex = /^[a-zA-Z0-9_-]+$/;
    if (!usernameRegex.test(username)) {
        showMessage('El usuario solo puede contener letras, números, guiones y guiones bajos', false);
        return;
    }
    
    // Enviar al servidor
    if (typeof registerUser !== 'undefined') {
        registerUser(username, password);
    }
}

function showMessage(message, isSuccess) {
    const messageEl = document.getElementById('message');
    messageEl.textContent = message;
    messageEl.classList.remove('success', 'error');
    messageEl.classList.add(isSuccess ? 'success' : 'error');
}

function clearMessage() {
    const messageEl = document.getElementById('message');
    messageEl.textContent = '';
    messageEl.classList.remove('success', 'error');
}

// Limpiar formularios al cargar
window.addEventListener('load', function() {
    document.querySelectorAll('input').forEach(input => {
        input.value = '';
    });
});
