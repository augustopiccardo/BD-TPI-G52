CREATE DATABASE RestauranteDB;
GO

USE RestauranteDB;
GO


CREATE TABLE Cliente
(
    IdCliente INT IDENTITY(1,1) PRIMARY KEY,

    NombreRazonSocial VARCHAR(150) NOT NULL,

    TipoDocumento VARCHAR(20) NOT NULL,

    NumeroDocumento VARCHAR(20) NOT NULL UNIQUE,

    CondicionIVA VARCHAR(50) NOT NULL,

    Telefono VARCHAR(20),

    Email VARCHAR(150)
);
GO

CREATE TABLE Empleado
(
    IdEmpleado INT IDENTITY(1,1) PRIMARY KEY,

    Nombre VARCHAR(100) NOT NULL,

    Apellido VARCHAR(100) NOT NULL,

    Cargo VARCHAR(80) NOT NULL,

    FechaIngreso DATE NOT NULL,

    EstadoEmpleado VARCHAR(30)
        DEFAULT 'ACTIVO'
);
GO

CREATE TABLE Mesa
(
    IdMesa INT IDENTITY(1,1) PRIMARY KEY,

    NumeroMesa INT NOT NULL UNIQUE,

    Capacidad INT NOT NULL,

    EstadoMesa VARCHAR(30)
        DEFAULT 'LIBRE',

    CONSTRAINT CK_MesaCapacidad
        CHECK (Capacidad > 0)
);
GO

CREATE TABLE CategoriaProducto
(
    IdCategoria INT IDENTITY(1,1) PRIMARY KEY,

    NombreCategoria VARCHAR(100)
        UNIQUE NOT NULL,

    Descripcion VARCHAR(255)
);
GO

CREATE TABLE ProductoMenu
(
    IdProductoMenu INT IDENTITY(1,1) PRIMARY KEY,

    NombreProducto VARCHAR(150)
        NOT NULL,

    Descripcion VARCHAR(255),

    PrecioVenta DECIMAL(10,2)
        NOT NULL,

    StockDisponible INT
        NOT NULL,

    EstadoProducto VARCHAR(30)
        DEFAULT 'ACTIVO',

    IdCategoria INT NOT NULL,

    CONSTRAINT FK_ProductoCategoria
        FOREIGN KEY (IdCategoria)

        REFERENCES CategoriaProducto(IdCategoria),

    CONSTRAINT CK_Precio
        CHECK (PrecioVenta > 0),

    CONSTRAINT CK_Stock
        CHECK (StockDisponible >= 0)
);
GO

CREATE TABLE MetodoPago
(
    IdMetodoPago INT IDENTITY(1,1) PRIMARY KEY,

    NombreMetodoPago VARCHAR(50)

        UNIQUE NOT NULL
);
GO

CREATE TABLE Consumo
(
    IdConsumo INT IDENTITY(1,1) PRIMARY KEY,

    FechaHoraApertura DATETIME
        DEFAULT GETDATE(),

    FechaHoraCierre DATETIME,

    EstadoConsumo VARCHAR(30)

        DEFAULT 'ABIERTO',

    CantidadComensales INT NOT NULL,

    IdMesa INT NOT NULL,

    IdCliente INT,

    CONSTRAINT FK_ConsumoMesa

        FOREIGN KEY (IdMesa)

        REFERENCES Mesa(IdMesa),

    CONSTRAINT FK_ConsumoCliente

        FOREIGN KEY (IdCliente)

        REFERENCES Cliente(IdCliente),

    CONSTRAINT CK_Comensales

        CHECK (CantidadComensales > 0)

);
GO

CREATE TABLE Pedido
(
    IdPedido INT IDENTITY(1,1) PRIMARY KEY,

    FechaHoraPedido DATETIME

        DEFAULT GETDATE(),

    EstadoPedido VARCHAR(30)

        DEFAULT 'PENDIENTE',

    IdConsumo INT NOT NULL,

    IdEmpleado INT NOT NULL,

    CONSTRAINT FK_PedidoConsumo

        FOREIGN KEY (IdConsumo)

        REFERENCES Consumo(IdConsumo),

    CONSTRAINT FK_PedidoEmpleado

        FOREIGN KEY (IdEmpleado)

        REFERENCES Empleado(IdEmpleado)

);
GO

CREATE TABLE DetallePedido
(
    IdDetallePedido INT IDENTITY(1,1)

        PRIMARY KEY,

    IdPedido INT NOT NULL,

    IdProductoMenu INT NOT NULL,

    Cantidad INT NOT NULL,

    PrecioUnitario DECIMAL(10,2)

        NOT NULL,

    Subtotal DECIMAL(10,2)

        NOT NULL,

    Observacion VARCHAR(255),

    CONSTRAINT FK_DetallePedido

        FOREIGN KEY (IdPedido)

        REFERENCES Pedido(IdPedido),

    CONSTRAINT FK_DetalleProducto

        FOREIGN KEY (IdProductoMenu)

        REFERENCES ProductoMenu(IdProductoMenu),

    CONSTRAINT CK_Cantidad

        CHECK (Cantidad > 0)

);
GO

CREATE TABLE Factura
(
    IdFactura INT IDENTITY(1,1)

        PRIMARY KEY,

    FechaHoraEmision DATETIME

        DEFAULT GETDATE(),

    TipoFactura VARCHAR(5)

        NOT NULL,

    PuntoVenta INT NOT NULL,

    NumeroFactura INT NOT NULL,

    CAE VARCHAR(30),

    FechaVencimientoCAE DATE,

    Subtotal DECIMAL(10,2)

        NOT NULL,

    IVA DECIMAL(10,2)

        NOT NULL,

    Total DECIMAL(10,2)

        NOT NULL,

    EstadoFactura VARCHAR(30)

        DEFAULT 'EMITIDA',

    EstadoPago VARCHAR(30)

        DEFAULT 'PENDIENTE',

    IdConsumo INT UNIQUE NOT NULL,

    IdMetodoPago INT NOT NULL,

    CONSTRAINT FK_FacturaConsumo

        FOREIGN KEY (IdConsumo)

        REFERENCES Consumo(IdConsumo),

    CONSTRAINT FK_FacturaMetodoPago

        FOREIGN KEY (IdMetodoPago)

        REFERENCES MetodoPago(IdMetodoPago)

);
GO