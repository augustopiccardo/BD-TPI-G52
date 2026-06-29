# RestauranteDB

Trabajo Práctico Integrador - Base de Datos II

## Contexto académico

Proyecto desarrollado para la materia **Base de Datos II**.

## Grupo

**Grupo 52**

Integrantes:

- Lucas Alejo Bellesi
- Matias Julian Salum
- Augusto Adrian Piccardo
- Juan Manuel Tello

## Descripción del proyecto

`RestauranteDB` es una base de datos diseñada para gestionar el funcionamiento integral de un restaurante.

El sistema modela las operaciones principales del negocio y permite administrar:

- Clientes
- Empleados
- Mesas
- Productos del menú
- Pedidos
- Consumos
- Métodos de pago
- Facturación

El objetivo principal del proyecto es representar reglas reales del negocio mediante estructuras relacionales, automatización de procesos y validaciones que garanticen la integridad de los datos.

## Estructura del proyecto

```text
Creacion de DB/
├── CREATE_DB.sql
├── INSERCION_DATOS.sql
├── VIEWS.sql
├── STORE_PROCEDURE.sql
├── TRIGGERS.sql
└── FUNCTION.sql

Pruebas/
└── StoredProcedureTester/
    ├── Program.cs
    └── StoredProcedureTester.csproj
```

## Scripts principales

### `CREATE_DB.sql`

Script encargado de crear toda la estructura de la base de datos.

Incluye:

- Creación de tablas
- Claves primarias (`PK`)
- Claves foráneas (`FK`)
- Restricciones de integridad

Validaciones implementadas:

- Capacidad de mesa mayor a cero
- Precio de producto positivo
- Stock no negativo
- Cantidad pedida mayor a cero

### `INSERCION_DATOS.sql`

Script encargado de cargar datos de prueba para simular un entorno real.

Incluye registros de:

- Clientes
- Empleados
- Mesas libres y ocupadas
- Productos del menú
- Consumos abiertos y cerrados
- Pedidos
- Facturas

## Vistas

Se implementaron vistas para facilitar consultas frecuentes.

### `vista_consumosAbiertos`

Permite visualizar:

- Mesa asociada
- Cliente
- Cantidad de pedidos
- Total parcial consumido

### `vista_productosMasVendidos`

Permite consultar:

- Producto
- Categoría
- Cantidad vendida
- Total recaudado

### `vista_ventasFacturadas`

Muestra información consolidada:

- Número de factura
- Mesa
- Cliente
- Método de pago
- Subtotal
- IVA
- Total

## Procedimientos almacenados

### `sp_abrirConsumo`

Permite abrir un consumo validando:

- Existencia de mesa
- Cantidad válida de comensales
- Existencia del cliente, si se informa uno
- Que no exista otro consumo abierto para la misma mesa

### `sp_cerrarConsumoYFacturar`

Permite cerrar un consumo y generar automáticamente la factura.

Realiza:

- Validación del consumo
- Validación del método de pago
- Cálculo de subtotal
- Cálculo de IVA
- Cálculo del total
- Inserción de factura
- Cambio de estado del consumo

## Triggers

### `trg_calcularPrecioSubtotalDetallePedido`

Automatiza:

- Obtención del precio actual del producto
- Cálculo automático del subtotal

Formula:

```text
PrecioUnitario * Cantidad
```

### `trg_descontarStockDetallePedido`

Valida:

- Existencia del producto
- Disponibilidad
- Stock suficiente

Además:

- Descuenta stock automáticamente
- Cancela operaciones inválidas

### `trg_actualizarEstadoMesaPorConsumo`

Actualiza automáticamente el estado de la mesa.

Estados posibles:

- `LIBRE`
- `OCUPADA`

Se actualiza según:

- Apertura del consumo
- Cierre del consumo

## Función

### `fn_totalConsumo`

Calcula el total consumido para un consumo determinado.

Recibe como parámetro el identificador del consumo y devuelve la suma de los subtotales de todos los detalles de pedido asociados.

Ejemplo:

```sql
SELECT dbo.fn_totalConsumo(1) AS TotalConsumo;
```

## Orden sugerido de ejecución

Los scripts principales están pensados para ejecutarse sobre una base limpia.

```text
1. CREATE_DB.sql
2. INSERCION_DATOS.sql
3. VIEWS.sql
4. STORE_PROCEDURE.sql
5. TRIGGERS.sql
6. FUNCTION.sql
```

## Pruebas realizadas

Para validar el funcionamiento se realizaron pruebas sobre:

- Creación de base de datos
- Inserción de registros
- Ejecución de vistas
- Ejecución de procedimientos almacenados
- Validación de triggers
- Validación de la función `fn_totalConsumo`

Además, se desarrolló un pequeño programa en C# que:

- Ejecuta procedimientos almacenados
- Muestra resultados por consola
- Utiliza `ROLLBACK` para evitar persistencia de datos de prueba

Para ejecutarlo:

```powershell
dotnet run --project "Pruebas\StoredProcedureTester\StoredProcedureTester.csproj"
```

## Tecnologías utilizadas

- SQL Server
- T-SQL
- C#
- ADO.NET
- Visual Studio / Visual Studio Code

## Conclusión

Este proyecto no solo implementa una estructura relacional, sino también reglas de negocio automatizadas mediante procedimientos almacenados, vistas, triggers y funciones.

El objetivo principal fue mantener la integridad de los datos, optimizar operaciones y representar el comportamiento real del funcionamiento de un restaurante.
