<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'Parallax Landing')</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@300;400;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-color: #2c3e50;
            --secondary-color: #3498db;
            --accent-color: #e74c3c;
        }

        body {
            font-family: 'Montserrat', sans-serif;
            overflow-x: hidden;
        }

        .parallax-section {
            position: relative;
            height: 100vh;
            background-attachment: fixed;
            background-position: center;
            background-repeat: no-repeat;
            background-size: cover;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .content-section {
            padding: 100px 0;
            background: white;
        }

        .hero-content {
            text-align: center;
            color: white;
            z-index: 2;
        }

        .overlay {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0,0,0,0.5);
        }

        .btn-custom {
            background: var(--secondary-color);
            color: white;
            padding: 12px 30px;
            border-radius: 30px;
            text-decoration: none;
            transition: all 0.3s ease;
        }

        .btn-custom:hover {
            background: #2980b9;
            transform: translateY(-2px);
        }
    </style>
</head>
<body>
@yield('content')

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Простой параллакс эффект
    window.addEventListener('scroll', function() {
        const scrolled = window.pageYOffset;
        const parallaxElements = document.querySelectorAll('.parallax-section');

        parallaxElements.forEach(function(element) {
            const speed = 0.5;
            element.style.transform = `translateY(${scrolled * speed}px)`;
        });
    });
</script>
</body>
</html>