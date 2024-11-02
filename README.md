<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Wprowadź swój nick</title>
    <style>
        body { font-family: Arial, sans-serif; }
        input, button { font-size: 1.2em; padding: 8px; }
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
            // URL do formularza Google (z odpowiednim ID formularza)
            const formUrl = "https://docs.google.com/forms/d/e/1FAIpQLSe5q0Itgar0bfb8--jN7ykQr_tAOrvYzhBf6DpAOJGD0ReYKA/formResponse";
            // ID pola formularza (np. "entry.1234567890")
            const formFieldID = "entry.1234567890";
            // Utworzenie danych do wysłania
            const formData = new FormData();
            formData.append(formFieldID, username);
            try {
                // Wysłanie danych do formularza Google z opóźnieniem
                await fetch(formUrl, {
                    method: "POST",
                    mode: "no-cors",
                    body: formData
                });
                // Dodaj opóźnienie po wysłaniu danych, aby formularz Google mógł je przetworzyć
                await new Promise(resolve => setTimeout(resolve, 500));
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
