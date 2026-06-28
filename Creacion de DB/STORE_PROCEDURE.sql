-- PROCEDIMIENTO ALMACENADO PARA ABRIR CONSUMO
/*
Se utiliza el procedimiento almacenado sp_abrirConsumo para abrir un nuevo consumo asociado a
una mesa. Valida que la mesa exista, que no tenga otro consumo abierto y registra la fecha y hora de
apertura. El procedimiento permite asociar un cliente cuando corresponda, por ejemplo, si luego se
necesita emitir factura con datos fiscales.
*/
CREATE OR ALTER PROCEDURE dbo.sp_abrirConsumo
@IdMesa INT,
@IdCliente INT = NULL,
@CantidadComensales INT,
@IdConsumoGenerado INT OUTPUT
AS
BEGIN
SET NOCOUNT ON;
BEGIN TRY
BEGIN TRANSACTION;
IF NOT EXISTS (
SELECT 1
FROM dbo.Mesa
WHERE IdMesa = @IdMesa
)
BEGIN
THROW 50001, 'La mesa indicada no existe.', 1;
END;
IF @CantidadComensales <= 0
BEGIN
THROW 50002, 'La cantidad de comensales debe ser mayor a cero.',
1;
END;
IF @IdCliente IS NOT NULL
AND NOT EXISTS (
SELECT 1
FROM dbo.Cliente
WHERE IdCliente = @IdCliente
)
BEGIN
THROW 50003, 'El cliente indicado no existe.', 1;
END;
IF EXISTS (
SELECT 1
FROM dbo.Consumo
WHERE IdMesa = @IdMesa
AND EstadoConsumo = 'ABIERTO'
AND FechaHoraCierre IS NULL
)
BEGIN
THROW 50004, 'La mesa ya tiene un consumo abierto.', 1;
END;
INSERT INTO dbo.Consumo (
FechaHoraApertura,
FechaHoraCierre,
EstadoConsumo,
CantidadComensales,
IdMesa,
IdCliente
)
VALUES (
GETDATE(),
NULL,
'ABIERTO',
@CantidadComensales,
@IdMesa,
@IdCliente
);
SET @IdConsumoGenerado = CONVERT(INT, SCOPE_IDENTITY());
COMMIT TRANSACTION;
PRINT 'Consumo abierto correctamente.';
END TRY
BEGIN CATCH
IF @@TRANCOUNT > 0
ROLLBACK TRANSACTION;
THROW;
END CATCH
END;
GO
-- PROCEDIMIENTO ALMACENADO PARA CERRAR CONSUMO Y FACTURAR
/*
Se utiliza el procedimiento almacenado sp_cerrarConsumoYFacturar para cerrar un consumo y
emitir su factura correspondiente. Calcula el subtotal a partir de los detalles de pedido, calcula el IVA,
obtiene el total final, registra la factura y marca el consumo como cerrado.
*/
CREATE OR ALTER PROCEDURE dbo.sp_cerrarConsumoYFacturar
@IdConsumo INT,
@IdMetodoPago INT,
@TipoFactura VARCHAR(5),
@PuntoVenta INT,
@NumeroFactura INT,
@CAE VARCHAR(30) = NULL,
@FechaVencimientoCAE DATE = NULL,
@IdFacturaGenerada INT OUTPUT
AS
BEGIN
SET NOCOUNT ON;
DECLARE @Subtotal DECIMAL(10,2);
DECLARE @IVA DECIMAL(10,2);
DECLARE @Total DECIMAL(10,2);
BEGIN TRY
BEGIN TRANSACTION;
IF NOT EXISTS (
SELECT 1
FROM dbo.Consumo
WHERE IdConsumo = @IdConsumo
AND EstadoConsumo = 'ABIERTO'
)
BEGIN
THROW 50005, 'El consumo indicado no existe o no se encuentra
abierto.', 1;
END;
IF EXISTS (
SELECT 1
FROM dbo.Factura
WHERE IdConsumo = @IdConsumo
)
BEGIN
THROW 50006, 'El consumo indicado ya posee una factura
asociada.', 1;
END;
IF NOT EXISTS (
SELECT 1
FROM dbo.MetodoPago
WHERE IdMetodoPago = @IdMetodoPago
)
BEGIN
THROW 50007, 'El método de pago indicado no existe.', 1;
END;
SELECT
@Subtotal = ISNULL(SUM(dp.Subtotal), 0)
FROM dbo.Pedido p
INNER JOIN dbo.DetallePedido dp
ON dp.IdPedido = p.IdPedido
WHERE p.IdConsumo = @IdConsumo;
IF @Subtotal <= 0
BEGIN
THROW 50008, 'No se puede facturar un consumo sin pedidos
cargados.', 1;
END;
SET @IVA = ROUND(@Subtotal * 0.21, 2);
SET @Total = @Subtotal + @IVA;
INSERT INTO dbo.Factura (
FechaHoraEmision,
TipoFactura,
PuntoVenta,
NumeroFactura,
CAE,
FechaVencimientoCAE,
Subtotal,
IVA,
Total,
EstadoFactura,
EstadoPago,
IdConsumo,
IdMetodoPago
)
VALUES (
GETDATE(),
@TipoFactura,
@PuntoVenta,
@NumeroFactura,
@CAE,
ISNULL(@FechaVencimientoCAE, DATEADD(DAY, 10, CAST(GETDATE() AS
DATE))),
@Subtotal,
@IVA,
@Total,
'EMITIDA',
'PAGADO',
@IdConsumo,
@IdMetodoPago
);
SET @IdFacturaGenerada = CONVERT(INT, SCOPE_IDENTITY());
UPDATE dbo.Consumo
SET
EstadoConsumo = 'CERRADO',
FechaHoraCierre = GETDATE()
WHERE IdConsumo = @IdConsumo;
COMMIT TRANSACTION;
PRINT 'Consumo cerrado y factura emitida correctamente.';
END TRY
BEGIN CATCH
IF @@TRANCOUNT > 0
ROLLBACK TRANSACTION;
THROW;
END CATCH
END;
GO
