# 📋 CASOS DE USO: Integración del Dashboard

## 🎯 ESCENARIO 1: Gerente Minero - Monitoreo Diario

### Contexto
- **Usuario**: Carlos (Gerente de Operaciones)
- **Hora**: 8:00 AM - Llega a la oficina
- **Acción**: Abre la app

### Flujo

```
1️⃣  8:01 AM - Carlos abre la app
    ↓
    Sistema detecta: app abierta
    ↓
    App: Muestra badge 🔴3 (3 notificaciones no leídas)
    ↓
2️⃣  8:02 AM - Carlos ve notificaciones
    ↓
    Notificación 1 (🔴CRÍTICA): "Efectivo Bajo"
    - Saldo: $50,000 USD
    - Mínimo requerido: $100,000 USD
    - Acción: Toca → Abre Dashboard
    
    Notificación 2 (🟡WARNING): "Proyecto 'Veta Norte' en Riesgo"
    - Progreso: 25%
    - Tiempo restante: 30 días
    - Acción: Toca → Abre popup de proyectos
    
    Notificación 3 (🟡WARNING): "Recursos Sobre-utilizados"
    - Equipos: 95% utilización
    - Acción: Toca → Abre uso de recursos
    
3️⃣  8:05 AM - Carlos abre Dashboard
    ↓
    Ve:
    - Balance Neto: -$50,000 (rojo)
    - Ingresos: $800,000 ✅
    - Gastos: $850,000 ⚠️
    - Gráficos en tiempo real
    - Tab de Alertas: 5 alertas activas
    
4️⃣  8:10 AM - Toca "Desempeño por Proyecto"
    ↓
    Popup muestra:
    - Proyecto A: 78% ✅
    - Proyecto B: 25% 🚨 En Riesgo
      - Presupuesto: $245k / $300k
      - ROI: 18.3%
      - Días: 45 restantes
    - Proyecto C: 45% 🟡 Vigilar
    
5️⃣  8:15 AM - Carlos toma acción
    ↓
    "Necesito acelerar Proyecto B"
    ↓
    Abre detalles del proyecto
    ↓
    Actualiza: Agrega 2 trabajadores más
    ↓
    Sistema: Calcula nuevo ROI (+3%)
    
6️⃣  8:20 AM - Se registra nueva transacción
    ↓
    Nómina de 2 empleados: $12,000
    ↓
    Trigger: Actualiza Dashboard en tiempo real
    ↓
    Carlos ve: Balance ahora -$62,000
    ↓
    Nueva alerta: "Presupuesto de Personal 85% utilizado"
    
7️⃣  8:25 AM - Decisión
    ↓
    "Necesito financiamiento urgente"
    ↓
    Toca: "Exportar Reportes"
    ↓
    Descarga: PDF con estado financiero completo
    ↓
    Lo envía al director por email
```

### Resultado
✅ Carlos está informado en 25 minutos
✅ Identifica problemas críticos inmediatamente
✅ Toma decisiones basadas en datos en tiempo real
✅ Exporta reporte profesional para presentar

---

## 🎯 ESCENARIO 2: Vendedor de Productos - Notificación de Compra

### Contexto
- **Usuario**: María (Vendedora de Productos Mineros)
- **Hora**: Variable - Un cliente compra su producto
- **Acción**: Recibe notificación

### Flujo

```
1️⃣  3:45 PM - Cliente abre app
    ↓
    Navega a "Productos"
    ↓
    Busca: "Explosivos tipo C"
    ↓
    Encuentra producto de María
    ↓
    Cantidad: 50 unidades
    Precio: $500 cada una
    Total: $25,000
    ↓
    Presiona: "COMPRAR"

2️⃣  3:46 PM - Procesamiento
    ↓
    ProductsRepository.createPurchase({
      product_id: 'explosives_c_123',
      seller_id: maria_id,
      buyer_id: client_id,
      quantity: 50,
      amount: 25000,
      status: 'pending_confirmation'
    })
    ↓
    INSERT INTO purchases
    ↓
    Trigger: notify_new_purchase()

3️⃣  3:46:30 PM - María está en Dashboard
    ↓
    Sistema: Supabase Realtime detección INSERT
    ↓
    Envía evento: new_purchase a María
    ↓
    Notificación aparece 🔔 en tiempo real
    ↓
    Badge: +1 sin leer
    ↓
    Notificación: 
    "🎉 Nueva compra de $25,000"
    "[Cliente Nombre] compró 50x Explosivos tipo C"
    ↓
    Sonido: ding.mp3 (si está habilitado)

4️⃣  3:47 PM - María hace clic
    ↓
    Toca la notificación
    ↓
    Navega a: '/products/explosives_c_123'
    ↓
    Ve: Detalles de la compra
    - Comprador: [Info del cliente]
    - Cantidad: 50 unidades
    - Total: $25,000
    - Estado: Pendiente confirmación
    - Botones: [Confirmar] [Rechazar] [Contactar]
    ↓
    María presiona: "Confirmar"

5️⃣  3:48 PM - Confirmación de compra
    ↓
    Estado cambia: 'confirmed'
    ↓
    Trigger: notify_purchase_confirmed()
    ↓
    CLIENTE recibe notificación:
    "✅ Tu compra ha sido confirmada"
    "Será enviada en 2 días hábiles"
    ↓
    MARÍA ve en Dashboard:
    - Transacción registrada automáticamente
    - Ingresos: +$25,000
    - En sección "Transacciones Recientes"

6️⃣  3:50 PM - Dashboard actualiza
    ↓
    Gráfico de Ingresos sube
    ↓
    Balance total aumenta
    ↓
    Margen de ganancia se actualiza
    ↓
    María: "¡Excelente! Voy 90% de la meta mensual"

7️⃣  3:55 PM - Notificación adicional (automática)
    ↓
    Sistema: Verifica saldo de productos
    ↓
    Efectivo de María: Ahora $150,000
    ↓
    Alerta previa (si < $50k) se cancela ✅
    ↓
    Nueva alerta: "Stock bajo de Explosivos tipo C"
    - Quedó: 3 unidades
    - Mínimo: 10
    ↓
    María recibe notificación:
    "⚠️ Stock bajo: Explosivos tipo C"
    "Reorden sugerido: 50 unidades"
```

### Resultado
✅ Venta completada en 10 minutos
✅ Dashboard automáticamente sincronizado
✅ Financiero actualizado en tiempo real
✅ Alerta de reorden generada automáticamente
✅ Cliente confirmado en tiempo real

---

## 🎯 ESCENARIO 3: Jefe de Proyecto - Monitoreo de Riesgo

### Contexto
- **Usuario**: Roberto (Jefe de Proyecto "Ampliación Planta")
- **Problema**: El proyecto va retrasado
- **Acción**: Sistema detecta y alerta

### Flujo

```
1️⃣  ANTES: Viernes 5:00 PM
    ↓
    Dashboard calcula estado de proyectos
    ↓
    Proyecto "Ampliación Planta":
    - Progreso: 25% (debería ser 50%)
    - Presupuesto: $180k gastado de $500k
    - Días restantes: 165 (6 meses)
    - ESTADO: ⚠️ VIGILANCIA NORMAL
    ↓
    ROI esperado: 0% (proyecto aún en progreso)

2️⃣  CRISIS: Lunes 9:00 AM
    ↓
    Trabajadores reportan:
    "Equipos retrasados, llegan miércoles"
    ↓
    Roberto registra en Dashboard:
    - Progreso: ACTUALIZAR a 15% (perdió 10%)
    - Retraso: 2 semanas
    - Nuevos días restantes: 151 (5.1 meses)
    ↓
    Sistema recalcula:
    - Velocidad actual: 3% por semana
    - Velocidad requerida: 9.5% por semana
    - ¿Completable a tiempo? ❌ NO

3️⃣  LUNES 9:05 AM - ALERTA AUTOMÁTICA
    ↓
    Trigger: check_project_risk()
    ↓
    IF progress < 25% AND remaining_days < 180:
       severity = 'CRITICAL'
    ↓
    INSERT INTO notifications:
    {
      user_id: roberto_id,
      type: 'project_at_risk',
      title: '🚨 Proyecto CRÍTICO: Ampliación Planta',
      body: 'Progreso: 15% | Tiempo restante: 5.1 meses | Riesgo: NO completable a tiempo',
      severity: 'critical',
      related_type: 'project',
      related_id: project_id,
      action_url: '/company/accounting?tab=projects'
    }
    ↓
    Roberto recibe notificación inmediatamente
    ↓
    Badge: 🔴1 crítica

4️⃣  LUNES 9:06 AM - Roberto abre notificación
    ↓
    Toca: "🚨 Proyecto CRÍTICO"
    ↓
    Navega a Dashboard
    ↓
    Popup: "Desempeño por Proyecto" se abre automáticamente
    ↓
    Ve tarjeta del proyecto:
    {
      nombre: "Ampliación Planta",
      progreso: 15% [========     ],
      presupuesto: "$180k / $500k",
      roi: "-36% (proyectado)",
      estado: 🔴 EN RIESGO,
      días_restantes: 151,
      velocidad_actual: "3% por semana",
      velocidad_requerida: "9.5% por semana",
      brecha: "6.5% - IMPOSIBLE"
    }

5️⃣  LUNES 9:10 AM - Análisis
    ↓
    Roberto: "Necesito acelerar esto"
    ↓
    Opciones:
    a) Agregar más trabajadores (aumentar gastos)
    b) Extender la duración (cambiar deadline)
    c) Reducir scope (hacer menos)
    ↓
    Roberto elige: Opción A
    ↓
    Registra:
    - Agregar 10 trabajadores más
    - Costo adicional: $50,000
    
6️⃣  LUNES 9:15 AM - Recalculación automática
    ↓
    Dashboard actualiza:
    - Presupuesto nuevo: $230k de $500k
    - Velocidad nueva: 7% por semana
    - ¿Completable? ✅ SÍ (pero ajustado)
    - Días: 145 (5 semanas para 85% del trabajo)
    - Nuevo ROI: -15% (mejor pero aún negativo)
    
7️⃣  LUNES 9:20 AM - Decisión ejecutada
    ↓
    Roberto: "Aprobado. Notificar a nómina"
    ↓
    Abre: "Nómina Minera"
    ↓
    Registra: +10 trabajadores = +$12,500 semanales
    ↓
    Sistema actualiza: Gasto semanal proyectado
    
8️⃣  MARTES 8:00 AM - Nueva notificación
    ↓
    Sistema: Re-evalúa proyecto (diario)
    ↓
    Progreso: Ahora 18% (mejoró)
    ↓
    Velocidad: 5% por semana (con nuevos trabajadores)
    ↓
    ¿Sigue siendo riesgo? ✅ MEJORADO
    ↓
    Estado: 🟡 VIGILANCIA ELEVADA (no crítico ya)
    ↓
    Roberto: "Bien, vamos por el camino correcto"
    ↓
    Notificación: "Proyecto en monitoreo. Mejoría detectada."
```

### Resultado
✅ Sistema detecta problema en TIEMPO REAL
✅ Alerta crítica genera acción inmediata
✅ Roberto toma decisión basada en datos
✅ Seguimiento automático de mejoras
✅ Histórico completo en Dashboard

---

## 🎯 ESCENARIO 4: Contador - Factura Próxima a Vencer

### Contexto
- **Usuario**: Patricia (Contadora)
- **Problema**: Factura por cobrar vence en 7 días
- **Acción**: Sistema alerta automáticamente

### Flujo

```
1️⃣  VIERNES 10:00 AM - Monitor automático
    ↓
    FinancialAlertsService ejecuta cada hora
    ↓
    Busca: cuentas por cobrar con vencimiento < 7 días
    ↓
    Encuentra: Factura #2024-001
    {
      cliente: "Empresa Minera Beta",
      monto: $150,000,
      fecha_emision: "2024-12-01",
      fecha_vencimiento: "2024-12-08",
      días_hasta_vencer: 7,
      estado: 'pending',
      notas: 'Sin pagos parciales'
    }

2️⃣  VIERNES 10:05 AM - Notificación
    ↓
    INSERT INTO notifications:
    {
      user_id: patricia_id,
      type: 'invoice_due',
      severity: 'warning',
      title: '⏰ Factura #2024-001 Vence en 7 Días',
      body: 'Empresa Minera Beta - $150,000 - Vence: 2024-12-08',
      action_url: '/company/accounting?section=accounts-receivable'
    }
    ↓
    Patricia recibe notificación

3️⃣  VIERNES 10:06 AM - Patricia ve notificación
    ↓
    Badge: 1 warning
    ↓
    Toca: Abre Dashboard
    ↓
    Navega a: "Cuentas por Cobrar/Pagar"
    ↓
    Ve filtro: Factura próxima a vencer
    {
      "Factura #2024-001",
      "Empresa Minera Beta",
      "$150,000",
      "⏰ Vence: 2024-12-08 (7 días)",
      [Contactar] [Registrar Pago] [Extender]
    }

4️⃣  VIERNES 10:15 AM - Patricia toma acción
    ↓
    "Voy a llamar al cliente"
    ↓
    Presiona: [Contactar]
    ↓
    Abre chat/llamada con cliente
    ↓
    Cliente: "Pagaré el miércoles"
    ↓
    Patricia: "Confirma recepción de factura"
    ↓
    Cliente: "Sí, está lista para pagar"

5️⃣  MIÉRCOLES 2:00 PM - Pago recibido
    ↓
    Banco notifica a Patricia
    ↓
    Patricia registra en Dashboard:
    "Pago recibido - Factura #2024-001"
    ↓
    Estado: changed from 'pending' to 'paid'
    ↓
    Monto: +$150,000 a ingresos
    ↓
    Dashboard actualiza automáticamente

6️⃣  MIÉRCOLES 2:05 PM - Confirmación
    ↓
    Notificación a Patricia:
    "✅ Factura #2024-001 Pagada"
    "Ingresos: +$150,000"
    ↓
    Dashboard:
    - Balance total: +$150,000
    - Efectivo disponible: +$150,000
    - Alerta de efectivo bajo: Se cancela automáticamente
    
7️⃣  MIÉRCOLES 2:10 PM - Reportería
    ↓
    Patricia: "Voy a generar reporte mensual"
    ↓
    Dashboard → Exportar Reportes
    ↓
    Opciones:
    - Estado de Flujo de Caja
    - Cuentas por Cobrar (Vencidas y Por Vencer)
    - Ingresos vs Gastos
    - Proyección Mensual
    ↓
    Descarga: PDF profesional
    ↓
    Lo envía a director general
```

### Resultado
✅ Factura se pagó a tiempo (previno vencimiento)
✅ Sistema alertó 7 días antes
✅ Patricia contactó proactivamente al cliente
✅ Efectivo bajo se resolvió automáticamente
✅ Reportería generada en minutos

---

## 📊 RESUMEN DE BENEFICIOS

| Escenario | Problema | Solución | Resultado |
|-----------|----------|----------|-----------|
| Gerente | Muchos problemas, no sabe dónde empezar | Notificaciones priorizadas | Decisiones rápidas, informadas |
| Vendedor | No sabe cuándo vende | Notificación inmediata de compra | Reacciona rápido, reorden automático |
| Jefe Proyecto | Proyecto en riesgo, sin visibilidad | Alerta automática + análisis | Toma acción preventiva |
| Contador | Facturas se vencen sin notar | Alerta 7 días antes | Cobros a tiempo, flujo positivo |

---

## 🎬 CONCLUSIÓN

El sistema integrado permite que:
- 🔔 **Notificaciones** mantengan a todos informados
- 📊 **Dashboard** proporcione contexto completo
- ⚡ **Automatización** cree alertas inteligentes
- 📈 **Datos en tiempo real** faciliten decisiones
- ✅ **Acciones rápidas** resuelvan problemas antes de escalar

