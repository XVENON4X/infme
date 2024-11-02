<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Witaj na mojej stronie</title>
    <style>
        body { font-family: Arial, sans-serif; }
        #form { display: none; }
        #greeting { display: none; }
    </style>
</head>
<body>
    <div id="form">
        <h1>Wprowadź swoje imię lub nick:</h1>
        <input type="text" id="username" placeholder="Twoje imię lub nick" required>
        <button onclick="saveUsername()">Zatwierdź</button>
    </div>
    <div id="greeting">
        <h1>Cześć, <span id="user-display"></span>!</h1>
    </div>
    <script>
        function checkUsername() {
            const username = localStorage.getItem('username');
            if (username) {
                document.getElementById('user-display').textContent = username;
                document.getElementById('greeting').style.display = 'block';
            } else {
                document.getElementById('form').style.display = 'block';
            }
        }
        function saveUsername() {
            const username = document.getElementById('username').value;
            localStorage.setItem('username', username);
            document.getElementById('user-display').textContent = username;
            document.getElementById('form').style.display = 'none';
            document.getElementById('greeting').style.display = 'block';
        }
        // Wywołanie funkcji przy załadowaniu strony
        window.onload = checkUsername;
    </script>
</body>
</html>
