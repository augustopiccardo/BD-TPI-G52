/*
Trigger 1: trg_calcularPrecioSubtotalDetallePedido

Se utiliza el trigger trg_calcularPrecioSubtotalDetallePedido
para calcular automáticamente el precio unitario y el subtotal
de cada detalle de pedido.

Al insertar o modificar un detalle, toma el precio actual del
producto del menú y calcula el subtotal multiplicando la cantidad
por el precio de venta.
*/

CREATE OR ALTER TRIGGER dbo.trg_calcularPrecioSubtotalDetallePedido
ON dbo.DetallePedido
AFTER INSERT, UPDATE
AS
 BEGIN
SET NOCOUNT ON;
    -- Evita llamadas recursivas
    IF TRIGGER_NESTLEVEL() > 1
        RETURN;
    IF UPDATE(Cantidad)
       OR UPDATE(IdProductoMenu)
       OR UPDATE(PrecioUnitario)
    BEGIN
        UPDATE dp
        SET
            dp.PrecioUnitario = pm.PrecioVenta,
            dp.Subtotal =
                i.Cantidad * pm.PrecioVenta
        FROM dbo.DetallePedido dp
        INNER JOIN inserted i
            ON i.IdDetallePedido = dp.IdDetallePedido
        INNER JOIN dbo.ProductoMenu pm
            ON pm.IdProductoMenu = i.IdProductoMenu;
    END
END;
GO

/*
Trigger 2: trg_descontarStockDetallePedido

Se utiliza el trigger trg_descontarStockDetallePedido
para controlar el stock disponible de los productos
del menú.

Cuando se inserta un detalle de pedido, valida que
exista stock suficiente y descuenta la cantidad
solicitada del producto correspondiente.

Si no hay stock suficiente, cancela la operación.
*/

CREATE OR ALTER TRIGGER dbo.trg_descontarStockDetallePedido
ON dbo.DetallePedido
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Cantidades TABLE
    (
        IdProductoMenu INT PRIMARY KEY,
        CantidadSolicitada INT
    );
    INSERT INTO @Cantidades
    (
        IdProductoMenu,
        CantidadSolicitada
    )
    SELECT
        IdProductoMenu,
        SUM(Cantidad)
    FROM inserted
    GROUP BY IdProductoMenu;

    IF EXISTS
    (
        SELECT 1
        FROM @Cantidades c
        LEFT JOIN dbo.ProductoMenu pm
            ON pm.IdProductoMenu = c.IdProductoMenu
        WHERE
            pm.IdProductoMenu IS NULL
            OR pm.StockDisponible < c.CantidadSolicitada
            OR pm.EstadoProducto <> 'DISPONIBLE'
    )
    BEGIN
        RAISERROR
        (
            'No hay stock suficiente o el producto no se encuentra disponible.',
            16,
            1
        );

        ROLLBACK TRANSACTION;
        RETURN;
    END;

    UPDATE pm
    SET
        pm.StockDisponible =
            pm.StockDisponible - c.CantidadSolicitada
    FROM dbo.ProductoMenu pm
    INNER JOIN @Cantidades c
        ON c.IdProductoMenu = pm.IdProductoMenu;
END;
GO
/*
Trigger 3: trg_actualizarEstadoMesaPorConsumo

Se utiliza el trigger trg_actualizarEstadoMesaPorConsumo
para actualizar automáticamente el estado de una mesa
según el estado del consumo asociado.

Cuando se abre un consumo, la mesa pasa a estar ocupada.

Cuando el consumo se cierra, la mesa vuelve a quedar
libre siempre que no tenga otro consumo abierto.
*/

CREATE OR ALTER TRIGGER dbo.trg_actualizarEstadoMesaPorConsumo
ON dbo.Consumo
AFTER INSERT, UPDATE
AS
BEGIN

    SET NOCOUNT ON;


    -- Marcar mesas ocupadas

    UPDATE m
    SET
        m.EstadoMesa = 'OCUPADA'
    FROM dbo.Mesa m
    INNER JOIN inserted i
        ON i.IdMesa = m.IdMesa
    WHERE
        i.EstadoConsumo = 'ABIERTO'
        AND i.FechaHoraCierre IS NULL;

    -- Liberar mesas

    UPDATE m
    SET
        m.EstadoMesa = 'LIBRE'
    FROM dbo.Mesa m
    INNER JOIN inserted i
        ON i.IdMesa = m.IdMesa
    WHERE

        (
            i.EstadoConsumo = 'CERRADO'
            OR i.FechaHoraCierre IS NOT NULL
        )

        AND NOT EXISTS
        (
            SELECT 1
            FROM dbo.Consumo c
            WHERE
                c.IdMesa = m.IdMesa
                AND c.EstadoConsumo = 'ABIERTO'
                AND c.FechaHoraCierre IS NULL
        );
END;
GO