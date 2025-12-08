# 🔄 DIAGRAMA DE FLUJOS: Dashboard → Sistema de Notificaciones

## 📊 Arquitectura General

```
┌─────────────────────────────────────────────────────────────────┐
│                      USUARIO FINAL (APP)                         │
└─────────────────────────────────────────────────────────────────┘
                              ↕
┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐
│  Dashboard       │    │  NotificationsPage│   │  Chat/Productos  │
│  Financiero      │    │                  │    │                  │
│  - Alertas       │────│  - Inbox         │────│  - Compras       │
│  - Proyectos     │    │  - Filtros       │    │  - Preguntas     │
│  - Empleados     │    │  - Badge count   │    │  - Comentarios   │
│  - Recursos      │    │  - Tiempo real   │    │  - Servicios     │
└──────────────────┘    └──────────────────┘    └──────────────────┘
                              ↑
                         ┌────┴─────┐
                         │ Realtime │
                         │ Updates  │
                         └────┬─────┘
                              ↓
        ┌────────────────────────────────────┐
        │    SUPABASE (Backend)              │
        │                                    │
        │  ┌─────────────────────────────┐   │
        │  │   notifications table       │   │
        │  │  - id, user_id, type        │   │
        │  │  - title, body, severity    │   │
        │  │  - is_read, action_url      │   │
        │  └─────────────────────────────┘   │
        │                                    │
        │  ┌─────────────────────────────┐   │
        │  │   Realtime Channels         │   │
        │  │  - notifications_${userId}  │   │
        │  │  - INSERT events            │   │
        │  └─────────────────────────────┘   │
        │                                    │
        │  ┌─────────────────────────────┐   │
        │  │   Triggers                  │   │
        │  │  - notify_new_message       │   │
        │  │  - notify_alert_system      │   │
        │  └─────────────────────────────┘   │
        └────────────────────────────────────┘
                      ↓
        ┌────────────────────────────────────┐
        │  DATA SOURCES                      │
        │                                    │
        │  ┌──────────────────────────────┐  │
        │  │ financial_entries            │  │
        │  │ financial_budgets            │  │
        │  │ payroll_entries              │  │
        │  │ inventory_items              │  │
        │  └──────────────────────────────┘  │
        │                                    │
        │  ┌──────────────────────────────┐  │
        │  │ conversations                │  │
        │  │ messages                     │  │
        │  │ products                     │  │
        │  │ posts & comments             │  │
        │  └──────────────────────────────┘  │
        └────────────────────────────────────┘
```

---

## 🔔 FLUJOS ESPECÍFICOS

### FLUJO 1: Efectivo Bajo
```
Evento: Usuario abre Dashboard
                ↓
AccountingRepository.generateAlerts()
                ↓
    Verificar: cashBalance < threshold
                ↓
    ¿Baja? SÍ
                ↓
FinancialAlertsService.createNotification(
  type: AlertType.lowCash,
  severity: AlertSeverity.critical
)
                ↓
INSERT INTO notifications (
  user_id: current_user,
  type: 'financial_alert',
  title: 'Efectivo Bajo ⚠️',
  body: '$50,000 USD < $100,000 USD requerido',
  severity: 'critical',
  action_url: '/company/accounting'
)
                ↓
Supabase Realtime Channel
'notifications_${userId}'
                ↓
OnPostgresChanges(INSERT)
                ↓
NotificationsPage.setState()
                ↓
Mostrar en inbox rojo "CRÍTICO"
Agregar badge rojo al icono
                ↓
Usuario hace clic
                ↓
Navegar a Dashboard financiero
                ↓
Ver sección de Alertas
```

### FLUJO 2: Compra Registrada
```
EVENTO: Cliente compra producto
(en products_page.dart o checkout)
                ↓
Usuario presiona "Comprar"
                ↓
ProductsRepository.createPurchase({
  product_id,
  buyer_id,
  seller_id,
  amount
})
                ↓
INSERT INTO purchases table
                ↓
Trigger: notify_purchase()
                ↓
PERFORM create_notification(
  seller_id,
  'purchase',
  '[Comprador] compró [Producto]',
  ...
)
                ↓
NotificationsPage VENDEDOR
Mostrar: "Nueva venta de $500"
                ↓
Dashboard VENDEDOR
Actualizar: Total de Ingresos en tiempo real
                ↓
Optional: Email al vendedor
         SMS (si está configurado)
         Push notification (si tiene app)
```

### FLUJO 3: Proyecto en Riesgo
```
Evento: Cada hora (scheduled)
                ↓
Dashboard carga ProjectPerformance
                ↓
Para cada proyecto:
  IF progress < 25% AND daysRemaining < 30:
    risk_level = 'CRITICAL'
                ↓
FinancialAlertsService.createProjectAlert(project)
                ↓
INSERT INTO notifications (
  type: 'project_at_risk',
  title: '🚨 ${project.name} en riesgo',
  body: '25% completado, 30 días restantes',
  action_url: '/company/accounting' (popup proyectos)
)
                ↓
Manager recibe notificación
                ↓
Hace clic → Abre popup de proyectos
→ Ve detalles completos
→ Puede ajustar plan
```

### FLUJO 4: Comentario/Pregunta
```
EVENTO: Usuario comenta en post
(en community_feed_page.dart)
                ↓
CommentRepository.createComment({
  post_id,
  user_id,
  content
})
                ↓
INSERT INTO comments
                ↓
Trigger: notify_new_comment()
                ↓
get poster_id FROM posts WHERE id = post_id
                ↓
PERFORM create_notification(
  poster_id,
  'comment',
  '[Usuario] comentó en tu publicación',
  '[Preview del comentario]'
)
                ↓
POST AUTHOR recibe notificación
                ↓
NotificationsPage (tab "Sistema")
Mostrar: "[Usuario]: ¿Cuál es el precio...?"
                ↓
Hace clic → Abre publicación
           → Ve todos los comentarios
           → Puede responder
```

---

## ⏰ TIMELINE DE EVENTOS

```
T=0min     Dashboard se abre
           └→ generateAlerts() ejecuta
           └→ Verifica 5 condiciones críticas

T=5min     Monitor financiero ejecuta
           └→ Revisa cambios en transacciones
           └→ Crea alertas si es necesario

T=10min    Usuario registra compra en productos
           └→ Trigger automático crea notificación
           └→ Vendor ve notificación en tiempo real

T=15min    Empleado comenta en publicación
           └→ Trigger crea notificación
           └→ Post author ve notificación

T=20min    Dashboard recarga proyectos
           └→ Detecta proyecto en riesgo
           └→ Crea alerta
           └→ Manager notificado

T=25min    Usuario hace clic en notificación
           └→ Se marca como leída
           └→ Navega a sección relevante
           └→ Toma acción correctiva

T=60min    Monitoreo completo de la hora
           └→ Se repite ciclo de alertas
           └→ Se crean nuevas notificaciones si es necesario
```

---

## 🔌 PUNTOS DE INTEGRACIÓN

| Módulo | Punto de Integración | Acción | Prioridad |
|--------|----------------------|--------|-----------|
| **Accounting Dashboard** | generateAlerts() | Crear 8 tipos de alertas | 🔴 P0 |
| **Accounting Dashboard** | _loadDashboardData() | Monitorear cada 5 min | 🔴 P0 |
| **Products Page** | createPurchase() | Notificar al vendedor | 🟡 P1 |
| **Community Feed** | createComment() | Notificar al post author | 🟡 P1 |
| **Chat** | sendMessage() | Notificar al receptor | ✅ P0 (EXISTE) |
| **Inventory Page** | updateStock() | Alerta si < crítico | ✅ P0 (EXISTE) |
| **Projects Page** | updateProgress() | Verificar riesgo | 🟡 P1 |
| **Employees Page** | recordProductivity() | Alerta si < 70% | 🟡 P1 |

---

## 🎯 MAPEO DE TIPOS DE NOTIFICACIÓN

```dart
// NotificationType enum extendido

// CATEGORÍA: Mensajería (Existentes ✅)
message              // Nuevo mensaje
groupInvite          // Invitación a grupo

// CATEGORÍA: Comunidad (Existentes ✅)
comment              // Comentario en publicación
mention              // Mención en publicación
newFollower          // Nuevo seguidor
productLiked         // Producto marcado como favorito

// CATEGORÍA: Servicios (Existentes ✅)
serviceRequest       // Solicitud de servicio

// CATEGORÍA: Finanzas (NUEVOS 🆕)
financialAlert       // Alerta genérica de finanzas
lowCash              // Efectivo insuficiente
overBudget           // Presupuesto excedido
invoiceDue           // Factura por vencer
invoiceOverdue       // Factura vencida
profitDecline        // Caída de ganancias
payrollPending       // Nómina pendiente

// CATEGORÍA: Proyectos (NUEVOS 🆕)
projectAtRisk        // Proyecto en riesgo de no completarse
projectMilestone     // Hito completado
projectDelay         // Retraso en proyecto

// CATEGORÍA: Recursos Humanos (NUEVOS 🆕)
lowProductivity      // Empleado con baja productividad
highAbsenteeism      // Ausentismo elevado
trainingDue          // Capacitación vencida

// CATEGORÍA: Inventario (NUEVOS 🆕)
stockCritical        // Stock próximo a agotarse
stockOverage         // Exceso de inventario
itemDiscontinued     // Artículo descontinuado

// CATEGORÍA: Compras (NUEVOS 🆕)
purchase             // Nueva compra (para vendedor)
purchaseConfirmed    // Compra confirmada (para comprador)
purchaseShipped      // Compra enviada
purchaseDelivered    // Compra entregada

// CATEGORÍA: Sistema (NUEVOS 🆕)
systemAlert          // Alerta del sistema
maintenanceScheduled // Mantenimiento programado
updateAvailable      // Actualización disponible
```

---

## 📊 BASE DE DATOS: Nueva Tabla

```sql
-- Extensión de la tabla notifications existente
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS (
  severity TEXT DEFAULT 'info' CHECK (severity IN ('info', 'warning', 'critical')),
  related_type TEXT,           -- Tipo de entidad relacionada (project, employee, etc)
  related_id UUID,             -- ID de la entidad relacionada
  action_data JSONB DEFAULT '{}', -- Datos adicionales para la acción
  auto_generated BOOLEAN DEFAULT FALSE, -- True si fue creada por trigger/sistema
  expires_at TIMESTAMP          -- Expirar notificaciones antiguas automáticamente
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_notifications_severity ON notifications(severity);
CREATE INDEX IF NOT EXISTS idx_notifications_related_type ON notifications(related_type);
CREATE INDEX IF NOT EXISTS idx_notifications_auto_generated ON notifications(auto_generated);
```

---

## 🔐 SEGURIDAD: RLS Policies

```sql
-- Permitir que solo el usuario vea sus propias notificaciones
CREATE POLICY notifications_select_policy ON notifications
  FOR SELECT
  USING (auth.uid() = user_id);

-- Permitir que el usuario marque sus propias notificaciones como leídas
CREATE POLICY notifications_update_policy ON notifications
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Solo el sistema puede crear notificaciones (via triggers)
CREATE POLICY notifications_insert_policy ON notifications
  FOR INSERT
  WITH CHECK (false); -- Bloqueado, solo triggers pueden insertar
```

---

## 🧪 TESTING CHECKLIST

- [ ] Alerta de efectivo bajo se crea correctamente
- [ ] Notificación aparece en tiempo real
- [ ] Badge se actualiza en la navegación
- [ ] Marcar como leída actualiza BD
- [ ] Hacer clic navega a la sección correcta
- [ ] RLS previene ver notificaciones de otros usuarios
- [ ] Rate limiting previene duplicados
- [ ] Prueba con 2 usuarios simultáneamente
- [ ] Prueba con notificaciones expiradas
- [ ] Email digest se envía (si está configurado)
- [ ] Sound alert funciona (si está habilitado)
- [ ] Push notifications funcionan (si hay app móvil)

