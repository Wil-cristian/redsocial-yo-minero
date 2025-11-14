# 🏗️ ARQUITECTURA ESCALABLE - YoMinero Polls

## 📊 Situación Actual vs Ideal

### ❌ ACTUAL (No escalable)
```
Flutter App
    ↓ (múltiples queries)
Supabase Client Library
    ↓ (SQL directo)
PostgreSQL Database
    ↓ (calcula en tiempo real)
Devuelve resultados
```

**Problemas:**
- 10 encuestas = 20+ queries (1 post + 1 votos por cada poll)
- Sin caché → cada refresh golpea la DB
- 1000 usuarios simultáneos = 20,000 queries/segundo
- PostgreSQL empezará a lagear con ~500 usuarios activos

---

## ✅ ARQUITECTURA RECOMENDADA (Producción)

```
┌─────────────────┐
│  Flutter App    │
└────────┬────────┘
         │ HTTP REST
         ↓
┌─────────────────────────────────────┐
│   Supabase Edge Functions          │
│   (Deno/TypeScript Serverless)     │
│                                     │
│  ┌──────────────┐  ┌─────────────┐ │
│  │ Vote Handler │  │ Poll Cache  │ │
│  │   Logic      │  │   Manager   │ │
│  └──────────────┘  └─────────────┘ │
└───────────┬─────────────────────────┘
            │
      ┌─────┴─────┐
      │           │
      ↓           ↓
┌──────────┐  ┌──────────────────┐
│  Redis   │  │   PostgreSQL     │
│  Cache   │  │   (RLS, Votos)   │
└──────────┘  └──────────────────┘
```

---

## 🔧 Implementación por Fases

### FASE 1: Optimización SQL (YA HECHO ✅)
```sql
-- Tabla poll_votes con índices
CREATE INDEX idx_poll_votes_poll_id ON poll_votes(poll_id);
CREATE INDEX idx_poll_votes_user_id ON poll_votes(user_id);
```

**Capacidad:** ~100 usuarios simultáneos

---

### FASE 2: Función PostgreSQL (FÁCIL DE IMPLEMENTAR)

En lugar de hacer queries separadas, crea una función que devuelva todo:

```sql
CREATE OR REPLACE FUNCTION get_poll_with_results(poll_id_param UUID)
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_build_object(
    'poll', (SELECT row_to_json(p) FROM posts p WHERE p.id = poll_id_param),
    'total_votes', (SELECT COUNT(*) FROM poll_votes WHERE poll_id = poll_id_param),
    'results', (
      SELECT json_agg(json_build_object('option', selected_option, 'votes', count))
      FROM (
        SELECT selected_option, COUNT(*) as count
        FROM poll_votes
        WHERE poll_id = poll_id_param
        GROUP BY selected_option
      ) subquery
    ),
    'user_vote', (
      SELECT selected_option 
      FROM poll_votes 
      WHERE poll_id = poll_id_param AND user_id = auth.uid()
    )
  ) INTO result;
  
  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

**Beneficios:**
- 1 query en lugar de 3-4
- Ejecutado en el servidor (más rápido)
- Capacidad: ~500 usuarios simultáneos

---

### FASE 3: Edge Function con Caché (ESCALABILIDAD REAL)

**Archivo:** `supabase/functions/poll-results/index.ts`

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// Redis para caché (opcional con Upstash)
const CACHE_TTL = 10 // 10 segundos

serve(async (req) => {
  const { pollId } = await req.json()
  
  // 1. Revisar caché primero
  const cached = await redis.get(`poll:${pollId}:results`)
  if (cached) {
    return new Response(JSON.stringify({ 
      data: JSON.parse(cached),
      cached: true 
    }), {
      headers: { "Content-Type": "application/json" }
    })
  }
  
  // 2. Si no está en caché, consultar DB
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL'),
    Deno.env.get('SUPABASE_SERVICE_KEY')
  )
  
  const { data, error } = await supabase.rpc('get_poll_with_results', {
    poll_id_param: pollId
  })
  
  if (error) throw error
  
  // 3. Guardar en caché
  await redis.setex(`poll:${pollId}:results`, CACHE_TTL, JSON.stringify(data))
  
  return new Response(JSON.stringify({ 
    data,
    cached: false 
  }), {
    headers: { "Content-Type": "application/json" }
  })
})
```

**Beneficios:**
- Caché reduce carga de DB en 90%
- 10,000+ usuarios simultáneos sin problema
- Edge = cerca del usuario (baja latencia)

---

### FASE 4: WebSocket Real-Time (OPCIONAL)

Para actualizar resultados en tiempo real sin polling:

```typescript
// Supabase Realtime Subscription
const channel = supabase
  .channel('poll-votes')
  .on('postgres_changes', {
    event: 'INSERT',
    schema: 'public',
    table: 'poll_votes',
    filter: `poll_id=eq.${pollId}`
  }, (payload) => {
    // Actualizar UI automáticamente
    updatePollResults(payload.new)
  })
  .subscribe()
```

**Capacidad:** Ilimitada (Supabase maneja esto)

---

## 📈 Comparación de Capacidad

| Fase | Usuarios Simultáneos | Latencia | Costo |
|------|---------------------|----------|-------|
| **Fase 1** (Actual) | ~100 | 200-500ms | $0 |
| **Fase 2** (SQL Function) | ~500 | 100-200ms | $0 |
| **Fase 3** (Edge + Cache) | 10,000+ | 20-50ms | $25/mes |
| **Fase 4** (WebSocket) | Ilimitado | <10ms | $25/mes |

---

## 🎯 Recomendación para YoMinero

### CORTO PLAZO (Próximos 2 meses):
✅ Mantener arquitectura actual
✅ Monitorear con Supabase Dashboard

### MEDIANO PLAZO (6 meses):
1. Implementar **Fase 2** (SQL Functions)
2. Agregar monitoreo con logs

### LARGO PLAZO (12+ meses):
1. Migrar a **Edge Functions**
2. Implementar Redis cache
3. WebSocket para real-time

---

## 🔍 Cómo Saber Cuándo Escalar

**Indicadores de que necesitas Fase 2:**
- ⚠️ Dashboard de Supabase muestra >500 queries/min
- ⚠️ Usuarios reportan lentitud al votar
- ⚠️ La app tarda >2 segundos en mostrar resultados

**Indicadores de que necesitas Fase 3:**
- 🚨 >1000 usuarios activos simultáneos
- 🚨 Supabase cobra >$100/mes por bandwidth
- 🚨 Latencia >500ms consistentemente

---

## 🛠️ Implementación Inmediata (Opcional)

Si quieres mejorar AHORA sin Edge Functions:

### 1. Materializar votos en la tabla posts

```sql
-- Agregar columna cached_votes
ALTER TABLE posts ADD COLUMN cached_votes JSONB;

-- Trigger para actualizar automáticamente
CREATE OR REPLACE FUNCTION update_poll_cache()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE posts
  SET cached_votes = (
    SELECT jsonb_object_agg(selected_option, count)
    FROM (
      SELECT selected_option, COUNT(*) as count
      FROM poll_votes
      WHERE poll_id = NEW.poll_id
      GROUP BY selected_option
    ) subquery
  )
  WHERE id = NEW.poll_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER poll_vote_cache_trigger
AFTER INSERT OR UPDATE OR DELETE ON poll_votes
FOR EACH ROW
EXECUTE FUNCTION update_poll_cache();
```

**Beneficio:** 
- Flutter solo lee 1 tabla (posts)
- Los votos se precalculan automáticamente
- Capacidad: ~1000 usuarios simultáneos

---

## 📚 Recursos

- [Supabase Edge Functions](https://supabase.com/docs/guides/functions)
- [PostgreSQL Functions](https://supabase.com/docs/guides/database/functions)
- [Upstash Redis](https://upstash.com/) (caché gratuito)
- [Supabase Realtime](https://supabase.com/docs/guides/realtime)

---

## ✅ Conclusión

**Tu código actual está BIEN para:**
- MVP/Beta (100-200 usuarios)
- Pruebas con clientes
- Primeros 6 meses

**Debes escalar cuando:**
- Superes 500 usuarios activos
- La app se sienta lenta
- El costo de Supabase aumente mucho

**La buena noticia:** Supabase hace la migración FÁCIL porque todo es PostgreSQL + REST APIs.
