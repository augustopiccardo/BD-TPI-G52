USE RestauranteDB;
GO

-- =========================
-- CLIENTES
-- =========================

INSERT INTO Cliente
    (NombreRazonSocial, TipoDocumento, NumeroDocumento, CondicionIVA, Telefono, Email)
VALUES
    ('Juan Perez', 'DNI', '30111222', 'Consumidor Final', '1122334455', 'juan.perez@gmail.com'),
    ('Maria Gomez', 'DNI', '32222333', 'Consumidor Final', '1133445566', 'maria.gomez@gmail.com'),
    ('Carlos Lopez', 'DNI', '33444555', 'Responsable Inscripto', '1144556677', 'carlos.lopez@gmail.com'),
    ('Empresa Norte SRL', 'CUIT', '30712345678', 'Responsable Inscripto', '1155667788', 'contacto@empresanorte.com'),
    ('Ana Martinez', 'DNI', '35666777', 'Monotributista', '1166778899', 'ana.martinez@gmail.com'),
    ('Lucia Fernandez', 'DNI', '37888999', 'Consumidor Final', '1177889900', 'lucia.fernandez@gmail.com');
GO

-- =========================
-- EMPLEADOS
-- =========================

INSERT INTO Empleado
    (Nombre, Apellido, Cargo, FechaIngreso, EstadoEmpleado)
VALUES
    ('Pedro', 'Ramirez', 'Mozo', '2023-03-10', 'ACTIVO'),
    ('Sofia', 'Diaz', 'Moza', '2022-08-15', 'ACTIVO'),
    ('Martin', 'Sosa', 'Cocinero', '2021-05-20', 'ACTIVO'),
    ('Valentina', 'Ruiz', 'Cajera', '2023-11-01', 'ACTIVO'),
    ('Diego', 'Morales', 'Encargado', '2020-01-12', 'ACTIVO');
GO

-- =========================
-- MESAS
-- =========================

INSERT INTO Mesa
    (NumeroMesa, Capacidad, EstadoMesa)
VALUES
    (1, 2, 'LIBRE'),
    (2, 4, 'LIBRE'),
    (3, 4, 'OCUPADA'),
    (4, 6, 'OCUPADA'),
    (5, 2, 'LIBRE'),
    (6, 8, 'OCUPADA'),
    (7, 4, 'LIBRE'),
    (8, 6, 'LIBRE');
GO

-- =========================
-- CATEGORIAS
-- =========================

INSERT INTO CategoriaProducto
    (NombreCategoria, Descripcion)
VALUES
    ('Entradas', 'Platos pequeños para iniciar la comida'),
    ('Platos Principales', 'Platos principales del restaurante'),
    ('Bebidas', 'Bebidas con y sin alcohol'),
    ('Postres', 'Postres del restaurante'),
    ('Cafetería', 'Café, té e infusiones');
GO

-- =========================
-- PRODUCTOS DEL MENU
-- =========================

INSERT INTO ProductoMenu
    (NombreProducto, Descripcion, PrecioVenta, StockDisponible, EstadoProducto, IdCategoria)
VALUES
    ('Empanadas de carne', 'Empanadas fritas de carne cortada a cuchillo', 1200.00, 50, 'DISPONIBLE', 1),
    ('Papas bravas', 'Papas con salsa picante', 2800.00, 30, 'DISPONIBLE', 1),
    ('Milanesa con papas', 'Milanesa de carne con guarnición', 6500.00, 40, 'DISPONIBLE', 2),
    ('Bife de chorizo', 'Bife de chorizo con papas rústicas', 8900.00, 30, 'DISPONIBLE', 2),
    ('Ensalada Caesar', 'Ensalada con pollo, croutons y parmesano', 4200.00, 35, 'DISPONIBLE', 2),
    ('Pizza muzzarella', 'Pizza grande de muzzarella', 5500.00, 20, 'DISPONIBLE', 2),
    ('Agua mineral', 'Agua mineral sin gas 500ml', 1200.00, 80, 'DISPONIBLE', 3),
    ('Gaseosa', 'Gaseosa línea Pepsi 500ml', 1800.00, 80, 'DISPONIBLE', 3),
    ('Vino de la casa', 'Vino tinto de la casa', 7200.00, 15, 'DISPONIBLE', 3),
    ('Flan casero', 'Flan con dulce de leche', 2500.00, 20, 'DISPONIBLE', 4),
    ('Tiramisu', 'Postre tiramisú individual', 3200.00, 12, 'DISPONIBLE', 4),
    ('Café', 'Café espresso', 1300.00, 100, 'DISPONIBLE', 5);
GO

-- =========================
-- METODOS DE PAGO
-- =========================

INSERT INTO MetodoPago
    (NombreMetodoPago)
VALUES
    ('Efectivo'),
    ('Tarjeta de débito'),
    ('Tarjeta de crédito'),
    ('Transferencia'),
    ('Mercado Pago');
GO

-- =========================
-- CONSUMOS
-- =========================

INSERT INTO Consumo
    (FechaHoraApertura, FechaHoraCierre, EstadoConsumo, CantidadComensales, IdMesa, IdCliente)
VALUES
    ('2026-06-20T20:15:00', '2026-06-20T22:10:00', 'CERRADO', 2, 1, 1),
    ('2026-06-21T21:00:00', '2026-06-21T23:05:00', 'CERRADO', 4, 2, 2),
    ('2026-06-22T20:30:00', NULL, 'ABIERTO', 3, 3, 3),
    ('2026-06-22T21:10:00', NULL, 'ABIERTO', 5, 4, NULL),
    ('2026-06-23T13:00:00', '2026-06-23T14:20:00', 'CERRADO', 2, 5, 4),
    ('2026-06-23T21:30:00', NULL, 'ABIERTO', 6, 6, 5);
GO

-- =========================
-- PEDIDOS
-- =========================

INSERT INTO Pedido
    (FechaHoraPedido, EstadoPedido, IdConsumo, IdEmpleado)
VALUES
    ('2026-06-20T20:25:00', 'ENTREGADO', 1, 1),
    ('2026-06-20T21:10:00', 'ENTREGADO', 1, 2),
    ('2026-06-21T21:15:00', 'ENTREGADO', 2, 1),
    ('2026-06-22T20:40:00', 'PENDIENTE', 3, 3),
    ('2026-06-22T21:00:00', 'EN PREPARACION', 3, 2),
    ('2026-06-22T21:20:00', 'PENDIENTE', 4, 1),
    ('2026-06-23T13:10:00', 'ENTREGADO', 5, 4),
    ('2026-06-23T13:35:00', 'ENTREGADO', 5, 2),
    ('2026-06-23T21:40:00', 'PENDIENTE', 6, 3);
GO

-- =========================
-- DETALLES DE PEDIDO

-- =========================

INSERT INTO DetallePedido
    (IdPedido, IdProductoMenu, Cantidad, PrecioUnitario, Subtotal, Observacion)
VALUES
    (1, 1, 2, 1200.00, 2400.00, 'Sin picante'),
    (1, 7, 2, 1200.00, 2400.00, NULL),
    (2, 3, 2, 6500.00, 13000.00, 'Milanesa bien cocida'),
    (2, 10, 1, 2500.00, 2500.00, 'Con dulce de leche'),

    (3, 4, 1, 8900.00, 8900.00, 'Punto medio'),
    (3, 9, 1, 7200.00, 7200.00, NULL),
    (3, 12, 2, 1300.00, 2600.00, NULL),

    (4, 6, 1, 5500.00, 5500.00, NULL),
    (4, 8, 2, 1800.00, 3600.00, NULL),
    (5, 10, 1, 2500.00, 2500.00, NULL),
    (5, 12, 1, 1300.00, 1300.00, 'Cortado'),

    (6, 1, 3, 1200.00, 3600.00, NULL),
    (6, 2, 1, 2800.00, 2800.00, 'Extra salsa'),

    (7, 5, 1, 4200.00, 4200.00, 'Sin pollo'),
    (7, 7, 1, 1200.00, 1200.00, NULL),
    (8, 10, 2, 2500.00, 5000.00, NULL),

    (9, 4, 1, 8900.00, 8900.00, 'Bien cocido'),
    (9, 8, 2, 1800.00, 3600.00, NULL);
GO

-- =========================
-- FACTURAS
-- =========================

INSERT INTO Factura
    (FechaHoraEmision, TipoFactura, PuntoVenta, NumeroFactura, CAE, FechaVencimientoCAE, Subtotal, IVA, Total, EstadoFactura, EstadoPago, IdConsumo, IdMetodoPago)
VALUES
    ('2026-06-20T22:10:00', 'B', 1, 1, 'CAE000000000001', '2026-07-01', 20300.00, 4263.00, 24563.00, 'EMITIDA', 'PAGADO', 1, 1),
    ('2026-06-21T23:05:00', 'B', 1, 2, 'CAE000000000002', '2026-07-02', 18700.00, 3927.00, 22627.00, 'EMITIDA', 'PAGADO', 2, 2),
    ('2026-06-23T14:20:00', 'A', 1, 3, 'CAE000000000003', '2026-07-03', 10400.00, 2184.00, 12584.00, 'EMITIDA', 'PAGADO', 5, 4);
GO