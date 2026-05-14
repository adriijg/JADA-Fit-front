# JADA FIT - The Ultimate AI Fitness Ecosystem

![JADA FIT Logo](https://img.shields.io/badge/JADA-FIT-D1FF00?style=for-the-badge&logo=fitness&logoColor=black)
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

JADA FIT es una plataforma integral de salud y alto rendimiento que utiliza Inteligencia Artificial para personalizar cada aspecto de la vida del usuario: desde entrenamientos dinámicos hasta nutrición de precisión y bienestar mental.

---

## 🚀 Características Principales

- **Coach IA Contextual**: Un asistente disponible 24/7 que recuerda tu progreso, lesiones y preferencias.
- **Rutinas Adaptativas**: Generación de entrenamientos que se ajustan en tiempo real según tu fatiga y equipo disponible.
- **Nutrición Inteligente**: Seguimiento de macros sincronizado con tu gasto calórico real.
- **Interfaz Premium**: Diseño basado en *glassmorphism* y neuroestética para maximizar la motivación.
- **Social & Gamificación**: Desafíos comunitarios y sistema de progresión por niveles.

---

## 🏗️ Arquitectura del Proyecto

El proyecto sigue una arquitectura **limpia y modular orientada a Features**, facilitando la escalabilidad y el mantenimiento.

### Estructura de Directorios

```text
lib/
├── core/              # Lógica compartida, temas, constantes y servicios base
│   ├── network/       # Gestión de APIs y excepciones
│   ├── theme/         # Sistema de diseño (AppColors, AppTheme)
│   └── storage/       # Persistencia segura (JWT, Preferencias)
├── features/          # Módulos independientes por funcionalidad
│   ├── auth/          # Login, Registro y AuthGate
│   ├── workout/       # Rutinas, Ejercicios y Seguimiento
│   ├── nutrition/     # Dieta, Macros y Comidas
│   └── ai/            # Chatbot y lógica de procesamiento IA
└── main.dart          # Punto de entrada de la aplicación
```

---

## 📊 Diseño del Sistema (UML)

### 1. Diagrama de Arquitectura de Capas
Representa cómo fluye la información entre las diferentes capas de la aplicación.

```mermaid
graph TD
    UI[Presentation Layer] --> Provider[State Management]
    Provider --> Service[Domain Layer]
    Service --> Repository[Data Layer]
    Repository --> Storage[Local/Remote Storage]
    
    subgraph Core
        Theme[Theme/Colors]
        Network[Network Client]
        Constants[App Constants]
    end
    
    UI -.-> Theme
    Repository -.-> Network
```

### 2. Diagrama de Clases (Core Entities)
Modelo conceptual de las entidades principales del sistema de entrenamiento.

```mermaid
classDiagram
    class User {
        +String id
        +String email
        +FitnessProfile profile
    }
    class Routine {
        +String id
        +String name
        +String targetGoal
        +List~Exercise~ exercises
    }
    class Exercise {
        +String id
        +String name
        +int sets
        +int reps
        +String muscleGroup
    }
    class Meal {
        +String id
        +String name
        +double calories
        +double protein
    }

    User "1" --o "*" Routine : creates
    Routine "1" --* "*" Exercise : contains
    User "1" --o "*" Meal : logs
```

### 3. Flujo de Autenticación (Sequence Diagram)
Proceso de validación de sesión al iniciar la app.

```mermaid
sequenceDiagram
    participant App as JADA App
    participant Gate as AuthGate
    participant Secure as SecureStorage
    participant API as Backend API

    App->>Gate: Initialize
    Gate->>Secure: Read JWT Token
    alt Token exists
        Secure-->>Gate: Token Data
        Gate->>API: Validate Token / Get User
        API-->>Gate: User Profile (200 OK)
        Gate->>App: Navigate to HomeScreen
    else Token missing or invalid
        Gate-->>App: Navigate to LoginScreen
    end
```

### 4. Modelo de Base de Datos (ERD)
Estructura relacional de las entidades en el backend.

```mermaid
erDiagram
    USERS ||--o{ ROUTINES : creates
    USERS ||--o{ MEALS : logs
    ROUTINES ||--|{ EXERCISES : contains
    USERS {
        string id PK
        string email
        string password
    }
    ROUTINES {
        string id PK
        string name
        string targetGoal
    }
    EXERCISES {
        string id PK
        string name
        int sets
        int reps
    }
    MEALS {
        string id PK
        string name
        double calories
        date created_at
    }
```

---

## 🛠️ Tech Stack

- **Framework**: Flutter 3.x
- **Lenguaje**: Dart 3.x
- **Gestión de Estado**: Provider
- **Persistencia**: Flutter Secure Storage (Encriptado)
- **Networking**: HTTP con Interceptores de Error
- **UI/UX**: Custom Material Design con soporte para modo oscuro avanzado.

---

## 🛠️ Instalación y Configuración

1. **Clonar el repositorio**:
   ```bash
   git clone https://github.com/tu-usuario/JADA-Fit-front.git
   ```
2. **Instalar dependencias**:
   ```bash
   flutter pub get
   ```
3. **Configurar variables de entorno**:
   Crea un archivo `.env` o configura tus constantes en `lib/core/constants/api_constants.dart`.
4. **Ejecutar la app**:
   ```bash
   flutter run
   ```

---

## 🧩 Flujos de Usuario y Estados (State Diagram)

Para entender cómo JADA FIT gestiona la experiencia del usuario durante un entrenamiento, utilizamos el siguiente diagrama de estados:

```mermaid
stateDiagram-v2
    [*] --> Idle: Inicio de App
    Idle --> AuthGate: Verificando Sesión
    AuthGate --> Login: Sin Token
    Login --> AuthGate: Credenciales Válidas
    AuthGate --> Dashboard: Token Válido
    
    Dashboard --> WorkoutSelection: Explorar Rutinas
    WorkoutSelection --> WorkoutActive: Iniciar Entrenamiento
    
    state WorkoutActive {
        [*] --> ExercisePrep: Preparando Ejercicio
        ExercisePrep --> InSet: Realizando Serie
        InSet --> Rest: Tiempo de Descanso
        Rest --> InSet: Siguiente Serie
        Rest --> ExercisePrep: Siguiente Ejercicio
        InSet --> [*]: Entrenamiento Finalizado
    }
    
    WorkoutActive --> Summary: Guardar Progreso
    Summary --> Dashboard: Volver al Inicio
```

---

## 🛠️ Detalles de Implementación Técnica

### Gestión de Estado
Utilizamos **Provider** para manejar el estado de forma reactiva en toda la aplicación. Esto nos permite desacoplar la lógica de negocio de la interfaz de usuario y notificar cambios en tiempo real.

### Seguridad y Persistencia
- **JWT (JSON Web Tokens)**: Todas las peticiones a la API están protegidas.
- **AES Encryption**: Los tokens y datos sensibles se almacenan localmente usando el llavero del sistema a través de `flutter_secure_storage`.

---

## 📈 Roadmap de Desarrollo

- [x] **Fase 1: UI Premium & Core Auth**
  - Refactorización completa de la pantalla de rutinas con estilo Glassmorphism.
  - Flujo de autenticación con persistencia segura.
- [ ] **Fase 2: Motor de IA & Visión**
  - Implementación de JADA Vision para corrección biomecánica.
  - Integración de voz para el AI Coach.
- [ ] **Fase 3: Ecosistema & Wearables**
  - Conexión con Apple HealthKit y Google Fit.
- [ ] **Fase 4: Expansión Corporativa**
  - Dashboard para empresas y retos grupales.

---

## 📝 Licencia

Este proyecto está bajo la Licencia MIT. Consulta el archivo `LICENSE` para más detalles.