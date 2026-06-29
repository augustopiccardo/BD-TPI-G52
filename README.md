🍽️ RestauranteDB
Trabajo Práctico Integrador – Base de Datos II
📚 Contexto Académico

Proyecto desarrollado para la materia Base de Datos II.

🧩 Descripción del Proyecto

RestauranteDB es una base de datos diseñada para gestionar el funcionamiento integral de un restaurante.

El sistema modela las operaciones principales del negocio permitiendo administrar:

Clientes
Empleados
Mesas
Productos del menú
Pedidos
Consumos
Métodos de pago
Facturación

El objetivo principal del proyecto es representar reglas reales del negocio mediante estructuras relacionales, automatización de procesos y validaciones que garanticen la integridad de los datos.

🏗️ Estructura del Proyecto
CREATE_DB.sql

Script encargado de crear toda la estructura de la base de datos.

Incluye:

Creación de tablas
Claves primarias (PK)
Claves foráneas (FK)
Restricciones de integridad
Validaciones implementadas
Capacidad de mesa mayor a cero
Precio de producto positivo
Stock no negativo
Cantidad pedida mayor a cero
INSERCION_DATOS.sql

Script encargado de cargar datos de prueba para simular un entorno real.

Incluye registros de:

Clientes
Empleados
Mesas libres y ocupadas
Productos del menú
Consumos abiertos y cerrados
Pedidos
Facturas
👁️‍🗨️ Vistas

Se implementaron vistas para facilitar consultas frecuentes.

vista_consumosAbiertos

Permite visualizar:

Mesa asociada
Cliente
Cantidad de pedidos
Total parcial consumido
vista_productosMasVendidos

Permite consultar:

Producto
Categoría
Cantidad vendida
Total recaudado
vista_ventasFacturadas

Muestra información consolidada:

Número de factura
Mesa
Cliente
Método de pago
Subtotal
IVA
Total
⚙️ Procedimientos Almacenados
sp_abrirConsumo

Permite abrir un consumo validando:

Existencia de mesa
Cantidad válida de comensales
Existencia del cliente
Que no exista otro consumo abierto
sp_cerrarConsumoYFacturar

Permite cerrar un consumo y generar automáticamente la factura.

Realiza:

Validación del consumo
Validación del método de pago
Cálculo de subtotal
Cálculo de IVA
Cálculo del total
Inserción de factura
Cambio de estado del consumo
🔄 Triggers
trg_calcularPrecioSubtotalDetallePedido

Automatiza:

Obtención del precio actual del producto
Cálculo automático del subtotal

Fórmula:

PrecioUnitario × Cantidad

trg_descontarStockDetallePedido

Valida:

Existencia del producto
Disponibilidad
Stock suficiente

Además:

Descuenta stock automáticamente
Cancela operaciones inválidas
trg_actualizarEstadoMesaPorConsumo

Actualiza automáticamente el estado de la mesa.

Estados:

LIBRE
OCUPADA

Según:

Apertura del consumo
Cierre del consumo
🧪 Pruebas Realizadas

Para validar el funcionamiento se realizaron pruebas sobre:

Creación de base de datos
Inserción de registros
Ejecución de vistas
Ejecución de procedimientos almacenados
Validación de triggers

Además se desarrolló un pequeño programa en C# que:

Ejecuta procedimientos almacenados
Muestra resultados por consola
Utiliza rollback para evitar persistencia de datos de prueba
🚀 Tecnologías Utilizadas
SQL Server
T-SQL
C#
Visual Studio
ADO.NET
✅ Conclusión

Este proyecto no solo implementa una estructura relacional, sino también reglas de negocio automatizadas mediante procedimientos almacenados, vistas y triggers.

El objetivo principal fue mantener la integridad de los datos, optimizar operaciones y representar el comportamiento real del funcionamiento de un restaurante.
