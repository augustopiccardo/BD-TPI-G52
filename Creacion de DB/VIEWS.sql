-- VISTA DE CONSUMOS ABIERTOS
/*
Se utiliza la vista vista_consumosAbiertos para consultar las mesas que tienen consumos abiertos.
Permite visualizar el número de mesa, fecha de apertura del consumo, cantidad de comensales, cliente
asociado, cantidad de pedidos realizados y total parcial consumido hasta el momento. 
*/
CREATE OR ALTER VIEW dbo.vista_consumosAbiertos AS
SELECT
c.IdConsumo,
m.NumeroMesa,
c.FechaHoraApertura,
c.CantidadComensales,
ISNULL(cli.NombreRazonSocial, 'Consumidor final') AS Cliente,
COUNT(DISTINCT p.IdPedido) AS CantidadPedidos,
ISNULL(SUM(dp.Subtotal), 0) AS TotalParcial
FROM dbo.Consumo c
INNER JOIN dbo.Mesa m
ON m.IdMesa = c.IdMesa
LEFT JOIN dbo.Cliente cli
ON cli.IdCliente = c.IdCliente
LEFT JOIN dbo.Pedido p
ON p.IdConsumo = c.IdConsumo
LEFT JOIN dbo.DetallePedido dp
ON dp.IdPedido = p.IdPedido
WHERE c.EstadoConsumo = 'ABIERTO'
GROUP BY
c.IdConsumo,
m.NumeroMesa,
c.FechaHoraApertura,
c.CantidadComensales,
cli.NombreRazonSocial;
GO
-- VISTA DE PRODUCTOS MAS VENDIDOS
/*
Se utiliza la vista vista_productosMasVendidos para obtener los productos del menú con mayor
cantidad de ventas. Esta vista permite consultar el ranking de productos más solicitados por los
clientes, mostrando la categoría, cantidad vendida y total recaudado por cada producto.
*/
CREATE OR ALTER VIEW dbo.vista_productosMasVendidos AS
SELECT TOP 100
pm.IdProductoMenu,
pm.NombreProducto,
cp.NombreCategoria,
SUM(dp.Cantidad) AS CantidadVendida,
SUM(dp.Subtotal) AS TotalVendido
FROM dbo.DetallePedido dp
INNER JOIN dbo.ProductoMenu pm
ON pm.IdProductoMenu = dp.IdProductoMenu
INNER JOIN dbo.CategoriaProducto cp
ON cp.IdCategoria = pm.IdCategoria
INNER JOIN dbo.Pedido p
ON p.IdPedido = dp.IdPedido
INNER JOIN dbo.Consumo c
ON c.IdConsumo = p.IdConsumo
WHERE c.EstadoConsumo = 'CERRADO'
GROUP BY
pm.IdProductoMenu,
pm.NombreProducto,
cp.NombreCategoria
ORDER BY
SUM(dp.Cantidad) DESC;
GO
-- VISTA DE VENTAS FACTURADAS
/*
Se utiliza la vista vista_ventasFacturadas para consultar el historial de facturas emitidas por el
restaurante. Muestra datos de la factura, consumo asociado, mesa, cliente, método de pago, subtotal,
IVA, total y estado de pago.
*/
CREATE OR ALTER VIEW dbo.vista_ventasFacturadas AS
SELECT
f.IdFactura,
f.FechaHoraEmision,
f.TipoFactura,
f.PuntoVenta,
f.NumeroFactura,
f.CAE,
f.Subtotal,
f.IVA,
f.Total,
f.EstadoFactura,
f.EstadoPago,
mp.NombreMetodoPago,
c.IdConsumo,
m.NumeroMesa,
ISNULL(cli.NombreRazonSocial, 'Consumidor final') AS Cliente
FROM dbo.Factura f
INNER JOIN dbo.Consumo c
ON c.IdConsumo = f.IdConsumo
INNER JOIN dbo.Mesa m
ON m.IdMesa = c.IdMesa
LEFT JOIN dbo.Cliente cli
ON cli.IdCliente = c.IdCliente
INNER JOIN dbo.MetodoPago mp
ON mp.IdMetodoPago = f.IdMetodoPago
WHERE f.EstadoFactura = 'EMITIDA';
GO
