# 📊 ANÁLISIS DE INTEGRACIÓN: Dashboard Financiero + Resto de la Aplicación

## 🎯 Objetivo General
Integrar el Dashboard de Contabilidad con los sistemas existentes para crear un flujo de notificaciones, alertas y eventos que mantengan informado al usuario en tiempo real.

---

## 📱 SISTEMAS EXISTENTES DETECTADOS

### ✅ Sistema de Notificaciones (YA EXISTE)
**Ubicación**: `lib/features/notifications/`
- ✅ Tabla: `notifications` en Supabase
- ✅ Tipos soportados: 7 tipos (message, group_invite, product_liked, service_request, new_follower, comment, mention)
- ✅ Tiempo real: Suscripción realtime configurada
- ✅ UI: `notifications_page.dart` con filtrado por tabs
- ✅ Seguridad: RLS habilitado

### ✅ Sistema de Inventario con Alertas
**Ubicación**: `lib/company_inventory_page.dart`
- ✅ Items críticos (próximos a agotarse)
- ✅ Favoritos
- ✅ Más pedidos

### ✅ Sistema de Mensajería
**Ubicación**: `lib/messages_page.dart`, `lib/chat_detail_page.dart`
- ✅ Conversaciones en tiempo real
- ✅ Notificaciones de nuevos mensajes

### ✅ Sistema de Proyectos y Empleados
**Ubicación**: `lib/company_projects_page.dart`, `lib/company_employees_page.dart`
- ✅ Gestión de proyectos
- ✅ Datos de empleados

---

## 🔗 INTEGRACIONES PROPUESTAS

### **GRUPO 1: ALERTAS FINANCIERAS → NOTIFICACIONES**
#### 1.1 Alertas de Tesorería Baja
```
Dashboard: FinancialAlert (tipo: lowCash)
    ↓
Crear: notification {
  type: 'financial_alert',
  title: 'Efectivo Bajo',
  body: '${amount} < ${threshold}',
  severity: 'critical',
  action_url: '/company/accounting'
}
    ↓
NotificationsPage: Mostrar con badge rojo
```
**Responsables de creación:**
- ✅ Sistema: AccountingRepository.generateAlerts()
- ✅ Trigger: Al cargar dashboard (cada 5 min)
- ✅ Manual: Usuario puede marcar como resuelta

#### 1.2 Presupuesto Excedido
```
Dashboard: FinancialAlert (tipo: overBudget)
    ↓
Notificación: 'Presupuesto Excedido en [Proyecto]'
Acción: Navegar a budgets
```

#### 1.3 Facturas por Vencer
```
Dashboard: FinancialAlert (tipo: invoiceDue)
    ↓
Notificación: '[N] Facturas vencen en 7 días'
Acción: Navegar a accounts payable
```

#### 1.4 Caída de Ganancias
```
Dashboard: FinancialAlert (tipo: profitDecline)
    ↓
Notificación: 'Ganancia bajó un [X]% vs período anterior'
Acción: Ver análisis detallado
```

---

### **GRUPO 2: PROYECTOS Y EMPLEADOS → NOTIFICACIONES**
#### 2.1 Proyecto en Riesgo
```
Dashboard: ProjectPerformance (progress < 25% and days < 30)
    ↓
Notificación: '[Proyecto] en riesgo: 25% con 30 días restantes'
Severity: warning
Acción: Expandir vista de proyectos
```

#### 2.2 Empleado con Baja Productividad
```
Dashboard: EmployeeProductivity (< 70%)
    ↓
Notificación: '[Empleado] con baja productividad (60%)'
Acción: Ver detalles de empleado
```

#### 2.3 Recurso Sobre-utilizado
```
Dashboard: ResourceUsage (> 80%)
    ↓
Notificación: '[Recurso] sobre-utilizado (95%)'
Severity: critical
Acción: Expandir uso de recursos
```

---

### **GRUPO 3: INTEGRACIÓN CON CHAT Y COMPRAS**
#### 3.1 Notificaciones de Compras
```
EVENTO: Usuario compra producto/servicio
    ↓
Crear: notification {
  type: 'purchase',
  title: 'Nueva Compra',
  body: '[Cliente] compró ${item}',
  related_id: purchase_id,
  action_url: '/products/${item_id}'
}
    ↓
Dashboard: Mostrar en tab "Transacciones Recientes"
    ↓
NotificationsPage: Mostrar con icono de compra
```

#### 3.2 Notificaciones de Preguntas/Comentarios
```
EVENTO: Nuevo comentario en publicación
    ↓
Crear: notification {
  type: 'comment',
  title: 'Nuevo comentario de [Usuario]',
  body: '[Pregunta/comentario preview]'
}
    ↓
NotificationsPage: Tab "Sistema"
Acción: Navegar a publicación
```

#### 3.3 Actualización de Chat en Dashboard
```
EVENTO: Nuevo mensaje en conversación
    ↓
NotificationsPage: Mostrar en tab "Mensajes"
    ↓
Dashboard: Mostrar badge en sección de Empleados (si es comunicación del equipo)
```

---

### **GRUPO 4: SINCRONIZACIÓN EN TIEMPO REAL**
#### 4.1 Actualización de Métricas Financieras
```
Usuario A: Registra transacción
    ↓ Trigger en Supabase
    ↓
Actualizar: financial_entries, financial_summary
    ↓
Dashboard (Usuario B): Actualizar gráficos en tiempo real
    ↓ Supabase Realtime
    ↓
Mostrar: "Balance actualizado"
```

#### 4.2 Actualización de Inventario
```
Usuario A: Usa inventario
    ↓
Actualizar: inventory_items (stock crítico)
    ↓ 
Trigger: Crear alerta si stock < mínimo
    ↓
Notificación: "Item próximo a agotarse"
```

---

## 🛠️ CAMBIOS NECESARIOS EN CÓDIGO

### **1. Extender NotificationType**
```dart
// En shared/models/notification_model.dart
enum NotificationType {
  message,
  groupInvite,
  productLiked,
  serviceRequest,
  newFollower,
  comment,
  mention,
  // ⭐ NUEVOS:
  financialAlert,      // Alertas del dashboard
  lowCash,             // Efectivo bajo
  overBudget,          // Presupuesto excedido
  invoiceDue,          // Factura por vencer
  profitDecline,       // Caída de ganancias
  projectAtRisk,       // Proyecto en riesgo
  lowProductivity,     // Baja productividad
  overUtilization,     // Sobre-utilización de recursos
  purchase,            // Nueva compra
  stockAlert,          // Alerta de inventario
}
```

### **2. Crear Servicio de Alertas Financieras**
```dart
// lib/features/accounting/services/financial_alerts_service.dart
class FinancialAlertsService {
  // Crear notificación a partir de FinancialAlert
  Future<void> createNotificationFromAlert(FinancialAlert alert) async {
    await _notificationsRepository.createNotification(
      type: _mapAlertTypeToNotificationType(alert.type),
      title: alert.title,
      body: alert.message,
      severity: _mapSeverity(alert.severity),
      actionUrl: '/company/accounting',
    );
  }
  
  // Monitorear alertas cada 5 minutos
  void startMonitoring() {
    Timer.periodic(Duration(minutes: 5), (_) async {
      final alerts = await _accountingRepository.generateAlerts(companyId);
      for (final alert in alerts) {
        await createNotificationFromAlert(alert);
      }
    });
  }
}
```

### **3. Extender AccountingRepository**
```dart
// Métodos nuevos en accounting_repository.dart
Future<void> notifyOnCriticalMetrics() async {
  final summary = await getSummary();
  
  if (summary.cashBalance < summary.criticalCashThreshold) {
    // Crear notificación de efectivo bajo
  }
  
  if (summary.profitChange < -20) {
    // Crear notificación de caída de ganancias
  }
}
```

### **4. Widget de Badge en Barra de Navegación**
```dart
// En main_app.dart o navigation bar
Stack(
  children: [
    Icon(Icons.notifications),
    if (_unreadNotificationsCount > 0)
      Positioned(
        right: 0,
        top: 0,
        child: Container(
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(6),
          ),
          constraints: BoxConstraints(minWidth: 14, minHeight: 14),
          child: Text(
            '$_unreadNotificationsCount',
            style: TextStyle(color: Colors.white, fontSize: 8),
            textAlign: TextAlign.center,
          ),
        ),
      ),
  ],
)
```

---

## 📊 TABLA DE INTEGRACIÓN

| Evento | Origen | Destino | Tipo | Prioridad | Estado |
|--------|--------|---------|------|-----------|--------|
| Efectivo Bajo | Dashboard | Notificaciones | Alerta | 🔴 Critical | ⏳ TODO |
| Presupuesto Excedido | Dashboard | Notificaciones | Alerta | 🟡 Warning | ⏳ TODO |
| Factura Vencida | Dashboard | Notificaciones | Alerta | 🟡 Warning | ⏳ TODO |
| Proyecto en Riesgo | Dashboard | Notificaciones | Alerta | 🟡 Warning | ⏳ TODO |
| Baja Productividad | Dashboard | Notificaciones | Alerta | 🟡 Warning | ⏳ TODO |
| Recurso Sobre-utilizado | Dashboard | Notificaciones | Alerta | 🔴 Critical | ⏳ TODO |
| Nueva Compra | Productos | Dashboard + Notif | Evento | 🔵 Info | ⏳ TODO |
| Nuevo Comentario | Publicaciones | Dashboard + Notif | Evento | 🔵 Info | ⏳ TODO |
| Nuevo Mensaje | Chat | Dashboard + Notif | Evento | 🟡 Warning | ✅ EXISTE |
| Stock Crítico | Inventario | Dashboard + Notif | Alerta | 🟡 Warning | ✅ EXISTE |

---

## 🎯 PLAN DE IMPLEMENTACIÓN FASES

### **FASE 1: Infraestructura Base** (Semana 1)
- [ ] Extender NotificationType enum
- [ ] Crear FinancialAlertsService
- [ ] Agregar tabla de configuración de alertas en BD
- [ ] Crear triggers en Supabase para alertas automáticas

### **FASE 2: Alertas Financieras** (Semana 2)
- [ ] Implementar notificación de efectivo bajo
- [ ] Implementar notificación de presupuesto excedido
- [ ] Implementar notificación de facturas vencidas
- [ ] Agregar monitoreo cada 5 minutos

### **FASE 3: Proyectos y Empleados** (Semana 3)
- [ ] Notificación de proyecto en riesgo
- [ ] Notificación de baja productividad
- [ ] Notificación de sobre-utilización de recursos
- [ ] Agregar a Dashboard los items críticos

### **FASE 4: Integración Cruzada** (Semana 4)
- [ ] Conectar con sistema de compras
- [ ] Conectar con sistema de comentarios
- [ ] Conectar con inventario
- [ ] Testing e2e

### **FASE 5: Pulido y Optimización** (Semana 5)
- [ ] Badge en navegación
- [ ] Push notifications (opcional)
- [ ] Sound alerts (opcional)
- [ ] Email digests (opcional)

---

## 🔐 Consideraciones de Seguridad

1. **RLS**: Asegurar que solo el usuario pueda ver sus propias alertas
2. **Rate Limiting**: No crear más de 1 alerta por minuto del mismo tipo
3. **Validación**: Verificar que los valores de alerta sean válidos
4. **Auditoría**: Registrar quién marcó alerta como resuelta

---

## 📈 Métricas de Éxito

- [ ] 100% de alertas financieras críticas generan notificaciones
- [ ] Notificaciones llegan en < 5 segundos
- [ ] 80%+ de usuarios leen las notificaciones críticas
- [ ] Tasa de falsos positivos < 5%
- [ ] Usuarios desactivan < 10% de tipos de notificaciones

---

## 💬 Preguntas para el Usuario

1. ¿Quieres que todas las alertas se creen automáticamente o algunas requieran confirmación?
2. ¿Deseas notificaciones por email además de en la app?
3. ¿Qué frecuencia de monitoreo prefieres? (1 min, 5 min, 15 min)
4. ¿Notificaciones sonoras para alertas críticas?
5. ¿Integración con WhatsApp/Telegram para alertas críticas?

---

## 🚀 Próximos Pasos

1. ✅ Revisar y aprobar este análisis
2. ⏳ Empezar FASE 1: Infraestructura base
3. ⏳ Implementar modelo de datos extendido
4. ⏳ Crear servicio de alertas financieras
5. ⏳ Testing y validación
