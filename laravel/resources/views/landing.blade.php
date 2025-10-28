@extends('layouts.app')

@section('content')
    <!-- Герой секция -->
    <section class="parallax-section" style="background-image: url('https://images.unsplash.com/photo-1506905925346-21bda4d32df4?ixlib=rb-4.0.3&auto=format&fit=crop&w=1950&q=80');">
        <div class="overlay"></div>
        <div class="hero-content">
            <div class="container">
                <h1 class="display-3 fw-bold mb-4">Добро пожаловать в будущее</h1>
                <p class="lead mb-4">Инновационные решения для вашего бизнеса</p>
                <a href="#contact" class="btn btn-custom">Начать сейчас</a>
            </div>
        </div>
    </section>

    <!-- О нас -->
    <section class="content-section">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-lg-6">
                    <h2 class="display-5 fw-bold mb-4">О нашей компании</h2>
                    <p class="lead mb-4">Мы создаем уникальные решения, которые помогают бизнесу расти и развиваться в цифровую эпоху.</p>
                    <ul class="list-unstyled">
                        <li class="mb-2">✓ Инновационные технологии</li>
                        <li class="mb-2">✓ Профессиональная команда</li>
                        <li class="mb-2">✓ Гарантия качества</li>
                    </ul>
                </div>
                <div class="col-lg-6">
                    <img src="https://images.unsplash.com/photo-1552664730-d307ca884978?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"
                         alt="О нас" class="img-fluid rounded">
                </div>
            </div>
        </div>
    </section>

    <!-- Параллакс секция 2 -->
    <section class="parallax-section" style="background-image: url('https://images.unsplash.com/photo-1518709268805-4e9042af2176?ixlib=rb-4.0.3&auto=format&fit=crop&w=1950&q=80');">
        <div class="overlay"></div>
        <div class="hero-content">
            <div class="container text-center">
                <h2 class="display-4 fw-bold mb-4">Инновации в каждом проекте</h2>
                <p class="lead">Мы используем современные технологии для достижения лучших результатов</p>
            </div>
        </div>
    </section>

    <!-- Услуги -->
    <section class="content-section bg-light">
        <div class="container">
            <div class="text-center mb-5">
                <h2 class="display-5 fw-bold">Наши услуги</h2>
                <p class="lead">Мы предлагаем комплексные решения для вашего бизнеса</p>
            </div>
            <div class="row g-4">
                <div class="col-md-4">
                    <div class="card h-100 border-0 shadow-sm">
                        <div class="card-body text-center p-4">
                            <div class="mb-3">
                                <i class="fas fa-laptop-code fa-3x text-primary"></i>
                            </div>
                            <h5 class="card-title">Веб-разработка</h5>
                            <p class="card-text">Создание современных и функциональных веб-сайтов и приложений.</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card h-100 border-0 shadow-sm">
                        <div class="card-body text-center p-4">
                            <div class="mb-3">
                                <i class="fas fa-mobile-alt fa-3x text-primary"></i>
                            </div>
                            <h5 class="card-title">Мобильные приложения</h5>
                            <p class="card-text">Разработка кроссплатформенных мобильных приложений.</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card h-100 border-0 shadow-sm">
                        <div class="card-body text-center p-4">
                            <div class="mb-3">
                                <i class="fas fa-chart-line fa-3x text-primary"></i>
                            </div>
                            <h5 class="card-title">Digital-маркетинг</h5>
                            <p class="card-text">Комплексное продвижение вашего бизнеса в интернете.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Контакты -->
    <section id="contact" class="content-section">
        <div class="container">
            <div class="row">
                <div class="col-lg-8 mx-auto">
                    <h2 class="display-5 fw-bold text-center mb-5">Свяжитесь с нами</h2>
                    <form>
                        <div class="row g-3">
                            <div class="col-md-6">
                                <input type="text" class="form-control form-control-lg" placeholder="Ваше имя" required>
                            </div>
                            <div class="col-md-6">
                                <input type="email" class="form-control form-control-lg" placeholder="Email" required>
                            </div>
                            <div class="col-12">
                                <textarea class="form-control form-control-lg" rows="5" placeholder="Сообщение" required></textarea>
                            </div>
                            <div class="col-12 text-center">
                                <button type="submit" class="btn btn-custom btn-lg">Отправить сообщение</button>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </section>

    <!-- Футер -->
    <footer class="bg-dark text-white py-4">
        <div class="container text-center">
            <p class="mb-0">&copy; 2024 Parallax Landing. Все права защищены.</p>
        </div>
    </footer>
@endsection