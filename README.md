# MiKROM - Mobile Network Management Dashboard

Aplicación móvil profesional de grado corporativo desarrollada en **Flutter** para la administración, monitoreo y control en tiempo real de redes Wi-Fi locales y adaptadores de red LAN, con una interfaz inspirada en dashboards de routers modernos (Mercusys / TP-Link Tether / UniFi Network).

---

## Características Principales

### 1. Dashboard Principal (Home)
- **Estado de Red en Vivo**: Indicador de conectividad con badge "En línea", nombre de red activa (SSID) y botón de escaneo rápido con microinteracciones.
- **Resumen de Tráfico y Enlace**: Visualización compacta de clientes activos vs. bloqueados, velocidades de subida / bajada y canal Wi-Fi.
- **Lista de Dispositivos Conectados**:
  - Iconos dinámicos automáticos según el tipo de dispositivo (Laptop, Smartphone, Consola, Smart TV, IoT, Desktop, Impresora).
  - Nombre de host / Alias amigable personalizable y dirección IP.
  - Dirección física MAC renderizada en estilo chip monoespaciado (`AA:BB:CC:DD:EE:FF`).
  - Switch de acción inmediata para permitir o bloquear acceso a la red.
  - Menú contextual desplegable para: Ver detalles completos, Renombrar alias, Limitar ancho de banda (Mbps) o Asignar IP estática (DHCP reservation).
  - Buscador en tiempo real por IP, MAC o Hostname y filtro por categorías.

### 2. Módulo de Configuración Wi-Fi (Ajustes Inalámbricos)
- Modificación del SSID (Nombre de Red) y clave de seguridad WPA2-PSK / WPA3-SAE.
- Selector de banda de frecuencia (2.4 GHz / 5 GHz / Dual-Band simultáneo).
- Selector de canales de transmisión y potencia de señal (TX Power).
- Opción para ocultar la difusión del SSID (Red invisible).
- Diálogo de confirmación con advertencia de reinicio de la interfaz de radio.

### 3. Módulo de Control de Acceso (Filtro MAC)
- Pestaña dedicada a **Dispositivos Bloqueados** con botón de desbloqueo en 1 toque.
- Pestaña de **Dispositivos Permitidos** (Lista blanca).
- Formulario modal con validación estricta por expresión regular para registrar y bloquear direcciones MAC manualmente.

### 4. Configuración LAN y Máscara de Subred
- Visualización y edición de la configuración del adaptador: Interfaz (`eth0`, `wlan0`), IP local del router, Puerta de enlace predeterminada y servidores DNS primario/secundario.
- **Calculadora Bidireccional de Subred**: Conversión automática entre prefijo CIDR (ej: `/24`) y máscara decimal con puntos (ej: `255.255.255.0`), calculando la capacidad máxima de hosts disponibles.
- Interruptor para habilitar/deshabilitar el servidor DHCP local.

### 5. Configuración de Host & Modo Simulación
- Modal para ajustar dinámicamente el endpoint del daemon REST del router (`http://192.168.1.1:8080` u otro host local).
- Modo demostración offline integrado para pruebas y desarrollo sin necesidad de router físico activo.

---

## Reglas Estrictas de UI/UX y Estilo Visual

- **Cero Emojis**: Prohibido el uso de emojis en toda la aplicación. Se emplean exclusivamente iconos vectoriales limpios de Material Icons.
- **Paleta de Colores Corporativa**:
  - Fondo Scaffold: `#F8FAFC` (Slate 50 neutro).
  - Contenedores / Tarjetas: Blanco puro `#FFFFFF` con borde sutil de 1px en `#E2E8F0` y elevación mínima.
  - Acento Primario: Rojo Mercusys (`#D32F2F`) con contrastes en Azul Redes (`#0284C7`) y Slate Oscuro (`#0F172A`).
  - Estados de Seguridad: Verde Éxito (`#16A34A`), Ámbar Advertencia (`#D97706`), Rojo Bloqueo (`#DC2626`).
- **Tipografía**: Jerarquía sans-serif con `GoogleFonts.inter` y renderizado de IPs y direcciones MAC en fuente monoespaciada `GoogleFonts.jetBrainsMono`.
- **Microinteracciones**: `RefreshIndicator` para Pull-to-refresh nativo, skeleton loaders animados durante el escaneo y feedback inmediato mediante `SnackBar` flotante minimalista.

---

## Arquitectura del Proyecto

El código está estructurado siguiendo una arquitectura limpia orientada a características (**Feature-First**):

```
lib/
├── core/
│   ├── constants/
│   │   ├── api_endpoints.dart       # Endpoints REST del daemon
│   │   ├── app_colors.dart          # Paleta corporativa estricta
│   │   └── app_typography.dart      # Tipografía y estilos monoespaciados
│   ├── errors/
│   │   └── network_exception.dart   # Mapeo y tipado de errores de red
│   ├── network/
│   │   ├── api_client.dart          # Cliente Dio centralizado con interceptores
│   │   └── server_config.dart       # Persistencia de URL del host del router
│   ├── theme/
│   │   └── app_theme.dart           # Tema Material 3 corporativo
│   ├── utils/
│   │   ├── formatters.dart          # Formateo de velocidades y direcciones MAC
│   │   ├── ip_utils.dart            # Cálculo de subredes, CIDR y máscaras
│   │   └── validators.dart          # Validadores Regex de MAC e IPv4
│   └── widgets/
│       ├── custom_snackbar.dart     # Notificaciones flotantes corporativas
│       └── status_badge.dart        # Pills de estado en línea / bloqueado
├── features/
│   ├── dashboard/
│   │   ├── models/                  # DeviceModel, NetworkStatsModel
│   │   ├── providers/               # DevicesProvider, NetworkStatsProvider
│   │   ├── services/                # NetworkApiService
│   │   ├── widgets/                 # HeaderStatusCard, TrafficSummaryCard, DeviceCard, etc.
│   │   └── views/                   # DashboardView
│   ├── wifi_config/
│   │   ├── models/                  # WifiConfigModel
│   │   ├── providers/               # WifiConfigProvider
│   │   ├── widgets/                 # RestartConfirmationDialog
│   │   └── views/                   # WifiConfigView
│   ├── access_control/
│   │   ├── providers/               # AccessControlProvider
│   │   ├── widgets/                 # BlockedDeviceTile, ManualMacDialog
│   │   └── views/                   # AccessControlView
│   ├── network_settings/
│   │   ├── models/                  # AdapterConfigModel
│   │   ├── providers/               # NetworkSettingsProvider
│   │   └── views/                   # NetworkSettingsView
│   ├── server_settings/
│   │   ├── providers/               # ServerSettingsProvider
│   │   └── views/                   # ServerSettingsDialog
│   └── navigation/
│       └── views/                   # MainNavigationShell
└── main.dart                        # Punto de entrada con ProviderScope
```

---

## Endpoints de la API REST Consumidos

| Método | Endpoint | Descripción | Payload / Retorno |
|---|---|---|---|
| `GET` | `/api/devices` | Lista de clientes conectados | Retorna JSON con lista de `{ "ip", "mac", "hostname", "is_blocked" }` |
| `POST` | `/api/wifi/config` | Modificar SSID y credenciales | Envía `{ "ssid": string, "password": string, ... }` |
| `POST` | `/api/mac/block` | Bloquear acceso por dirección MAC | Envía `{ "mac": string }` |
| `POST` | `/api/mac/allow` | Permitir / desbloquear acceso por MAC | Envía `{ "mac": string }` |
| `POST` | `/api/network/set-mask` | Configurar adaptador y subred LAN | Envía `{ "interface": string, "ip": string, "prefix": int, "gateway": string }` |

---

## Requisitos y Configuración de Entorno

- **Flutter SDK**: `>= 3.12.0` (Dart SDK `>= 3.12.0`)
- **Android**: API 21+ / **iOS**: iOS 12+

### Instalación y Ejecución

1. Clonar el repositorio:
   ```bash
   git clone git@github.com:eizy-c/MiKROM.git
   cd MiKROM
   ```

2. Instalar dependencias:
   ```bash
   flutter pub get
   ```

3. Ejecutar pruebas unitarias y de widgets:
   ```bash
   flutter test
   ```

4. Ejecutar la aplicación:
   ```bash
   flutter run
   ```

---

## Repositorio

- **Git Remote**: `git@github.com:eizy-c/MiKROM.git`
- **Licencia**: Propietaria / Redes Locales MiKROM.
