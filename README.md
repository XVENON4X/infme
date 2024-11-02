<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Wprowadź swój nick</title>
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
            // URL formularza Google
            const formUrl = "https://docs.google.com/forms/d/e/1FAIpQLSe5q0Itgar0bfb8--jN7ykQr_tAOrvYzhBf6DpAOJGD0ReYKA/formResponse";
            // Użyj identyfikatora pola formularza Google
            const formFieldID = "entry.1068117997";
            // Utwórz dane formularza z nickiem
            const formData = new FormData();
            formData.append(formFieldID, username);
            try {
                // Wyślij dane do formularza Google
                await fetch(formUrl, {
                    method: "POST",
                    mode: "no-cors",
                    body: formData
                });
                alert("Nick zapisany pomyślnie!");
                document.getElementById('username').value = ""; // Wyczyść pole po wysłaniu
            } catch (error) {
                console.error("Błąd:", error);
                alert("Wystąpił błąd podczas zapisu.");
            }
        }
    </script>
</body>
</html>
