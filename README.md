<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Witaj na mojej stronie</title>
    <style>
        body { font-family: Arial, sans-serif; }
    </style>
</head>
<body>
    <h1>Wprowadź swoje imię lub nick:</h1>
    <input type="text" id="username" placeholder="Twoje imię lub nick" required>
    <button onclick="submitUsername()">Zatwierdź</button>
    <script>
        async function submitUsername() {
            const username = document.getElementById('username').value;
            if (!username) {
                alert('Wprowadź swoje imię lub nick!');
                return;
            }
            try {
                const response = await fetch('https://api.github.com/repos/<twoje_uzytkownik>/nazwa_repozytorium/contents/username.txt', {
                    method: 'PUT',
                    headers: {
                        'Authorization': 'Bearer <TWÓJ_TOKEN_OSOBISTY>',
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        message: 'Dodano nick użytkownika',
                        content: btoa(username + '\\n'),  // kodowanie w base64
                        sha: '<SHA_PLIKU>'
                    })
                });
                if (response.ok) {
                    alert('Nick zapisany pomyślnie!');
                } else {
                    alert('Wystąpił błąd: ' + response.statusText);
                }
            } catch (error) {
                console.error(error);
                alert('Wystąpił błąd podczas zapisu.');
            }
        }
    </script>
</body>
</html>
