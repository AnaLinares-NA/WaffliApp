<div align="center">

<img src="Assets/Banner_Waffli.gif" alt="Waffli Banner" width="100%"/>

[![iOS](https://img.shields.io/badge/iOS-17%2B-black?style=for-the-badge&logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.9-F05138?style=for-the-badge&logo=swift&logoColor=white)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-blue?style=for-the-badge&logo=swift&logoColor=white)](https://developer.apple.com/swiftui/)
[![SwiftData](https://img.shields.io/badge/SwiftData-persistence-orange?style=for-the-badge&logo=apple&logoColor=white)](https://developer.apple.com/documentation/swiftdata)
[![Android](https://img.shields.io/badge/Android-coming%20soon-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://developer.android.com/develop?hl=es-419)
[![License](https://img.shields.io/badge/License-All%20Rights%20Reserved-red?style=for-the-badge)](#license)

*Organiza tus tareas del día a día, proyectos personales y profesionales — todo en un solo lugar.*

</div>

---

## Características

| Feature | Descripción |
|---|---|
| **3 categorías** | Día a día · Personal · Profesional |
| **Progreso visual** | Barras de avance y anillo de porcentaje global |
| **Auto-archivo** | Las tareas completadas se archivan automáticamente con animación |
| **Archivadas** | Historial de tareas completadas con fecha y estadísticas |
| **Perfil** | Foto desde galería, nombre editable, racha de días y stats |
| **Fechas límite** | Con alertas visuales: hoy, mañana, vencido |
| **Paleta propia** | Maple · Waffle · Cocoa · Crema · Canela |
| **Persistencia local** | SwiftData — sin backend, sin cuenta, sin internet |
| **Gamificación** | Zorrito mascota, waffles, tienda de outfits y logros |

---

## Plataformas

| Plataforma | Estado | Tecnología |
|---|---|---|
| iOS | Disponible | SwiftUI + SwiftData |
| Android | Próximamente | Jetpack Compose |

---

## Gamificación

Waffli incluye un sistema de gamificación completo centrado en **Mappli**, tu zorrito mascota:

- **Waffles** — ganas 1 waffle por cada tarea completada
- **Zorrito** — necesita 2 waffles al día para estar feliz; tiene 5 estados de ánimo según tu actividad
- **Tienda** — gasta tus waffles en sombreros, ropa y colores de pelaje para personalizar a tu zorrito
- **Logros** — 12 medallas desbloqueables por rachas, waffles acumulados, horarios y más
- **Notificaciones in-app** — popup al desbloquear un logro + badge en el botón del zorrito

---

## Paleta de colores

```
🍯 Maple   #D88C3A / #F2B36A  →  Acciones principales, energía
🧈 Waffle  #E6C36A / #F3DC9A  →  Éxito, completado, logros
☕ Cocoa   #6B4A3A / #B08A74  →  Estructura, texto, estabilidad
🥛 Crema   #FFF6E8 / #2A211C  →  Fondos principales
🍪 Canela  #C86B4A / #E39A7A  →  Creatividad, urgencia, carácter
```

---

## Arquitectura

```
Waffli/
├── WaffliApp.swift                 # Entry point + ModelContainer (5 modelos)
├── Models/
│   ├── WaffliItem.swift            # Modelo principal de tareas
│   ├── FoxModel.swift              # Zorrito mascota + FoxMood enum
│   ├── WaffleLog.swift             # Registro de waffles ganados
│   ├── AchievementModel.swift      # Logros + AchievementType enum
│   ├── ShopItem.swift              # Catálogo de tienda + PurchasedItem
│   └── GamificationManager.swift  # Lógica central de gamificación
├── Views/
│   ├── MainView.swift              # Contenedor raíz + popup de logros
│   ├── HomeView.swift              # Pantalla principal
│   ├── ProfileView.swift           # Perfil del usuario
│   ├── ArchivedView.swift          # Tareas archivadas
│   ├── TaskFormView.swift          # Formulario nueva/editar tarea
│   ├── FoxView.swift               # Pantalla del zorrito
│   ├── ShopView.swift              # Tienda de outfits
│   └── AchievementsView.swift      # Muro de logros
└── Components/
    ├── WaffliHeader.swift          # Barra superior flotante
    ├── BottomBar.swift             # Barra inferior con botón + y 🦊
    ├── SummaryHeader.swift         # Anillo de progreso + stats
    ├── ItemListSection.swift       # Lista de tarjetas de tareas
    ├── CategoryFilterBar.swift     # Chips de filtro con animaciones
    ├── FoxSVGView.swift            # Zorrito animado en SwiftUI Canvas
    └── WaffliPreviewData.swift     # Datos de preview para Canvas
```

---

## Instalación

### Requisitos
- Xcode 15+
- iOS 17+
- Swift 5.9+

### Pasos
```bash
git clone https://github.com/AnaLinares-NA/WaffliApp.git
cd WaffliApp/iOS
open Waffli.xcodeproj
```

Selecciona un simulador o dispositivo iOS 17+ y presiona **Cmd+R**.

> No se requieren dependencias externas. SwiftData viene incluido en el SDK de Apple.

---

## Permisos requeridos

```
Privacy - Photo Library Usage Description
→ Waffli usa tus fotos para personalizar tu perfil
```

---

## Autora

**Ana Linares**

Desarrolladora iOS · Diseño centrado en el usuario

[![GitHub](https://img.shields.io/badge/GitHub-@AnaLinares--NA-181717?style=flat-square&logo=github)](https://github.com/AnaLinares-NA)

---

## Licencia

Copyright © 2026 Ana Paola Linares Guzmán. Todos los derechos reservados.

Este proyecto es parte de un portafolio personal. No está permitida su reproducción, distribución o uso comercial sin autorización expresa de la autora.

Ver [`LICENSE`](LICENSE) para más detalles.
