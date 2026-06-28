using System.Data;
using Microsoft.Data.SqlClient;

const string defaultConnectionString =
    "Server=.\\SQLEXPRESS;Database=RestauranteDB;Integrated Security=True;Encrypt=True;TrustServerCertificate=True;";

var connectionString = args.Length > 0
    ? args[0]
    : Environment.GetEnvironmentVariable("RESTAURANTE_DB_CONNECTION") ?? defaultConnectionString;

PrintTitle("Prueba automatizada de stored procedures");
PrintInfo($"Conexion: {GetConnectionSummary(connectionString)}");
PrintInfo("Modo de prueba: usa una transaccion y hace rollback al final.");

await using var connection = new SqlConnection(connectionString);

PrintStep("1. Abriendo conexion a SQL Server");
await connection.OpenAsync();
PrintOk("Conexion abierta correctamente.");

await EnsureStoredProceduresExist(connection);

await using var transaction = (SqlTransaction)await connection.BeginTransactionAsync();
PrintStep("3. Transaccion de prueba iniciada");
PrintInfo("Todo lo que se cree desde este punto se va a deshacer con ROLLBACK.");

try
{
    var testData = await CreateBaseTestData(connection, transaction);

    var idConsumo = await TestAbrirConsumo(connection, transaction, testData.IdMesa);
    await PrintConsumo(
        connection,
        transaction,
        idConsumo,
        "ABIERTO",
        "6. Validando consumo abierto generado por sp_abrirConsumo");

    var idPedido = await CreatePedidoWithDetalle(
        connection,
        transaction,
        idConsumo,
        testData.IdEmpleado,
        testData.IdProductoMenu,
        testData.PrecioVenta);

    PrintOk($"Pedido de prueba creado. IdPedido: {idPedido}");

    var idFactura = await TestCerrarConsumoYFacturar(connection, transaction, idConsumo, testData.IdMetodoPago);
    await PrintConsumo(
        connection,
        transaction,
        idConsumo,
        "CERRADO",
        "9. Validando consumo cerrado por sp_cerrarConsumoYFacturar");
    await PrintFactura(connection, transaction, idFactura, idConsumo);

    PrintTitle("Resultado final");
    PrintOk("Los dos stored procedures se ejecutaron y validaron correctamente.");
}
catch (Exception ex)
{
    PrintTitle("Error durante la prueba");
    PrintError(ex.Message);
    throw;
}
finally
{
    await transaction.RollbackAsync();
    PrintTitle("Limpieza");
    PrintOk("Rollback ejecutado. No quedaron datos de prueba guardados.");
}

static async Task EnsureStoredProceduresExist(SqlConnection connection)
{
    PrintStep("2. Verificando que existan los procedimientos");

    const string sql = """
        SELECT name
        FROM sys.procedures
        WHERE name IN ('sp_abrirConsumo', 'sp_cerrarConsumoYFacturar')
        ORDER BY name;
        """;

    await using var command = new SqlCommand(sql, connection);
    await using var reader = await command.ExecuteReaderAsync();

    var names = new List<string>();
    while (await reader.ReadAsync())
    {
        names.Add(reader.GetString(0));
    }

    if (names.Count != 2)
    {
        throw new InvalidOperationException(
            "No estan creados los dos procedimientos. Ejecuta primero Creacion de DB\\STORE_PROCEDURE.sql.");
    }

    foreach (var name in names)
    {
        PrintData("Procedimiento encontrado", name);
    }

    PrintOk("Procedimientos requeridos encontrados.");
}

static async Task<TestData> CreateBaseTestData(SqlConnection connection, SqlTransaction transaction)
{
    PrintStep("4. Preparando datos minimos para la prueba");

    var idEmpleado = await GetRequiredInt(connection, transaction, "SELECT TOP 1 IdEmpleado FROM dbo.Empleado ORDER BY IdEmpleado;");
    var idMetodoPago = await GetRequiredInt(connection, transaction, "SELECT TOP 1 IdMetodoPago FROM dbo.MetodoPago ORDER BY IdMetodoPago;");

    const string productSql = """
        SELECT TOP 1 IdProductoMenu, PrecioVenta
        FROM dbo.ProductoMenu
        WHERE StockDisponible > 0
        ORDER BY IdProductoMenu;
        """;

    await using var productCommand = new SqlCommand(productSql, connection, transaction);
    await using var reader = await productCommand.ExecuteReaderAsync();

    if (!await reader.ReadAsync())
    {
        throw new InvalidOperationException("No hay productos disponibles para crear el detalle de pedido.");
    }

    var idProductoMenu = reader.GetInt32(0);
    var precioVenta = reader.GetDecimal(1);
    await reader.CloseAsync();

    PrintData("Empleado elegido", idEmpleado);
    PrintData("Metodo de pago elegido", idMetodoPago);
    PrintData("Producto elegido", idProductoMenu);
    PrintData("Precio unitario", FormatMoney(precioVenta));

    const string mesaSql = """
        INSERT INTO dbo.Mesa (NumeroMesa, Capacidad, EstadoMesa)
        OUTPUT INSERTED.IdMesa
        VALUES (9999, 4, 'LIBRE');
        """;

    var idMesa = await GetRequiredInt(connection, transaction, mesaSql);

    PrintData("Mesa temporal creada", $"IdMesa={idMesa}, NumeroMesa=9999, Capacidad=4, EstadoMesa=LIBRE");
    PrintOk("Datos base preparados.");

    return new TestData(idMesa, idEmpleado, idMetodoPago, idProductoMenu, precioVenta);
}

static async Task<int> TestAbrirConsumo(SqlConnection connection, SqlTransaction transaction, int idMesa)
{
    PrintStep("5. Ejecutando dbo.sp_abrirConsumo");
    PrintData("Parametro @IdMesa", idMesa);
    PrintData("Parametro @IdCliente", "NULL");
    PrintData("Parametro @CantidadComensales", 2);

    await using var command = new SqlCommand("dbo.sp_abrirConsumo", connection, transaction)
    {
        CommandType = CommandType.StoredProcedure
    };

    command.Parameters.AddWithValue("@IdMesa", idMesa);
    command.Parameters.AddWithValue("@IdCliente", DBNull.Value);
    command.Parameters.AddWithValue("@CantidadComensales", 2);

    var output = new SqlParameter("@IdConsumoGenerado", SqlDbType.Int)
    {
        Direction = ParameterDirection.Output
    };
    command.Parameters.Add(output);

    await command.ExecuteNonQueryAsync();

    var idConsumo = Convert.ToInt32(output.Value);
    PrintData("Output @IdConsumoGenerado", idConsumo);
    PrintOk("sp_abrirConsumo se ejecuto correctamente.");

    return idConsumo;
}

static async Task<int> CreatePedidoWithDetalle(
    SqlConnection connection,
    SqlTransaction transaction,
    int idConsumo,
    int idEmpleado,
    int idProductoMenu,
    decimal precioVenta)
{
    PrintStep("7. Cargando pedido y detalle para poder facturar el consumo");
    PrintData("IdConsumo", idConsumo);
    PrintData("IdEmpleado", idEmpleado);
    PrintData("IdProductoMenu", idProductoMenu);

    const string pedidoSql = """
        INSERT INTO dbo.Pedido (FechaHoraPedido, EstadoPedido, IdConsumo, IdEmpleado)
        OUTPUT INSERTED.IdPedido
        VALUES (GETDATE(), 'ENTREGADO', @IdConsumo, @IdEmpleado);
        """;

    await using var pedidoCommand = new SqlCommand(pedidoSql, connection, transaction);
    pedidoCommand.Parameters.AddWithValue("@IdConsumo", idConsumo);
    pedidoCommand.Parameters.AddWithValue("@IdEmpleado", idEmpleado);

    var idPedido = Convert.ToInt32(await pedidoCommand.ExecuteScalarAsync());
    var cantidad = 2;
    var subtotal = cantidad * precioVenta;

    const string detalleSql = """
        INSERT INTO dbo.DetallePedido (IdPedido, IdProductoMenu, Cantidad, PrecioUnitario, Subtotal, Observacion)
        VALUES (@IdPedido, @IdProductoMenu, @Cantidad, @PrecioUnitario, @Subtotal, 'Prueba automatizada C#');
        """;

    await using var detalleCommand = new SqlCommand(detalleSql, connection, transaction);
    detalleCommand.Parameters.AddWithValue("@IdPedido", idPedido);
    detalleCommand.Parameters.AddWithValue("@IdProductoMenu", idProductoMenu);
    detalleCommand.Parameters.AddWithValue("@Cantidad", cantidad);
    detalleCommand.Parameters.AddWithValue("@PrecioUnitario", precioVenta);
    detalleCommand.Parameters.AddWithValue("@Subtotal", subtotal);
    await detalleCommand.ExecuteNonQueryAsync();

    PrintData("Pedido insertado", $"IdPedido={idPedido}, EstadoPedido=ENTREGADO");
    PrintData("Detalle insertado", $"Cantidad={cantidad}, PrecioUnitario={FormatMoney(precioVenta)}, Subtotal={FormatMoney(subtotal)}");

    return idPedido;
}

static async Task<int> TestCerrarConsumoYFacturar(
    SqlConnection connection,
    SqlTransaction transaction,
    int idConsumo,
    int idMetodoPago)
{
    PrintStep("8. Ejecutando dbo.sp_cerrarConsumoYFacturar");
    PrintData("Parametro @IdConsumo", idConsumo);
    PrintData("Parametro @IdMetodoPago", idMetodoPago);
    PrintData("Parametro @TipoFactura", "B");
    PrintData("Parametro @PuntoVenta", 99);
    PrintData("Parametro @NumeroFactura", 9999);
    PrintData("Parametro @CAE", "CAEPRUEBACSHARP");
    PrintData("Parametro @FechaVencimientoCAE", "NULL, el SP calcula una fecha por defecto");

    await using var command = new SqlCommand("dbo.sp_cerrarConsumoYFacturar", connection, transaction)
    {
        CommandType = CommandType.StoredProcedure
    };

    command.Parameters.AddWithValue("@IdConsumo", idConsumo);
    command.Parameters.AddWithValue("@IdMetodoPago", idMetodoPago);
    command.Parameters.AddWithValue("@TipoFactura", "B");
    command.Parameters.AddWithValue("@PuntoVenta", 99);
    command.Parameters.AddWithValue("@NumeroFactura", 9999);
    command.Parameters.AddWithValue("@CAE", "CAEPRUEBACSHARP");
    command.Parameters.AddWithValue("@FechaVencimientoCAE", DBNull.Value);

    var output = new SqlParameter("@IdFacturaGenerada", SqlDbType.Int)
    {
        Direction = ParameterDirection.Output
    };
    command.Parameters.Add(output);

    await command.ExecuteNonQueryAsync();

    var idFactura = Convert.ToInt32(output.Value);
    PrintData("Output @IdFacturaGenerada", idFactura);
    PrintOk("sp_cerrarConsumoYFacturar se ejecuto correctamente.");

    return idFactura;
}

static async Task PrintConsumo(
    SqlConnection connection,
    SqlTransaction transaction,
    int idConsumo,
    string estadoEsperado,
    string stepTitle)
{
    PrintStep(stepTitle);
    PrintData("IdConsumo a validar", idConsumo);
    PrintData("Estado esperado", estadoEsperado);

    const string sql = """
        SELECT IdConsumo, IdMesa, IdCliente, CantidadComensales, EstadoConsumo, FechaHoraApertura, FechaHoraCierre
        FROM dbo.Consumo
        WHERE IdConsumo = @IdConsumo;
        """;

    await using var command = new SqlCommand(sql, connection, transaction);
    command.Parameters.AddWithValue("@IdConsumo", idConsumo);

    await using var reader = await command.ExecuteReaderAsync();
    if (!await reader.ReadAsync())
    {
        throw new InvalidOperationException($"No se encontro el consumo {idConsumo}.");
    }

    var estadoActual = reader.GetString(4);

    if (estadoActual != estadoEsperado)
    {
        throw new InvalidOperationException(
            $"Estado de consumo incorrecto. Esperado: {estadoEsperado}. Actual: {estadoActual}.");
    }

    PrintData("IdConsumo", reader.GetInt32(0));
    PrintData("IdMesa", reader.GetInt32(1));
    PrintData("IdCliente", reader.IsDBNull(2) ? "NULL" : reader.GetInt32(2));
    PrintData("CantidadComensales", reader.GetInt32(3));
    PrintData("EstadoConsumo", estadoActual);
    PrintData("FechaHoraApertura", reader.GetDateTime(5));
    PrintData("FechaHoraCierre", reader.IsDBNull(6) ? "NULL" : reader.GetDateTime(6));
    PrintOk($"Consumo validado en estado {estadoEsperado}.");
}

static async Task PrintFactura(SqlConnection connection, SqlTransaction transaction, int idFactura, int idConsumo)
{
    PrintStep($"10. Validando factura {idFactura}");

    const string sql = """
        SELECT IdFactura, IdConsumo, TipoFactura, PuntoVenta, NumeroFactura, Subtotal, IVA, Total, EstadoFactura, EstadoPago
        FROM dbo.Factura
        WHERE IdFactura = @IdFactura
          AND IdConsumo = @IdConsumo;
        """;

    await using var command = new SqlCommand(sql, connection, transaction);
    command.Parameters.AddWithValue("@IdFactura", idFactura);
    command.Parameters.AddWithValue("@IdConsumo", idConsumo);

    await using var reader = await command.ExecuteReaderAsync();
    if (!await reader.ReadAsync())
    {
        throw new InvalidOperationException("No se encontro la factura generada.");
    }

    var estadoFactura = reader.GetString(8);
    var estadoPago = reader.GetString(9);
    var total = reader.GetDecimal(7);

    if (estadoFactura != "EMITIDA" || estadoPago != "PAGADO" || total <= 0)
    {
        throw new InvalidOperationException("La factura generada no tiene los valores esperados.");
    }

    PrintData("IdFactura", reader.GetInt32(0));
    PrintData("IdConsumo", reader.GetInt32(1));
    PrintData("TipoFactura", reader.GetString(2));
    PrintData("PuntoVenta", reader.GetInt32(3));
    PrintData("NumeroFactura", reader.GetInt32(4));
    PrintData("Subtotal", FormatMoney(reader.GetDecimal(5)));
    PrintData("IVA", FormatMoney(reader.GetDecimal(6)));
    PrintData("Total", FormatMoney(total));
    PrintData("EstadoFactura", estadoFactura);
    PrintData("EstadoPago", estadoPago);
    PrintOk("Factura validada correctamente.");
}

static async Task<int> GetRequiredInt(SqlConnection connection, SqlTransaction transaction, string sql)
{
    await using var command = new SqlCommand(sql, connection, transaction);
    var value = await command.ExecuteScalarAsync();

    if (value is null || value is DBNull)
    {
        throw new InvalidOperationException($"La consulta no devolvio ningun valor: {sql}");
    }

    return Convert.ToInt32(value);
}

static string GetConnectionSummary(string connectionString)
{
    var builder = new SqlConnectionStringBuilder(connectionString);
    return $"{builder.DataSource}/{builder.InitialCatalog}";
}

static string FormatMoney(decimal value) => value.ToString("0.00");

static void PrintTitle(string text)
{
    Console.WriteLine();
    Console.WriteLine(new string('=', 72));
    Console.WriteLine(text.ToUpperInvariant());
    Console.WriteLine(new string('=', 72));
}

static void PrintStep(string text)
{
    Console.WriteLine();
    Console.WriteLine($"-- {text}");
}

static void PrintInfo(string text) => Console.WriteLine($"INFO - {text}");

static void PrintOk(string text) => Console.WriteLine($"OK   - {text}");

static void PrintError(string text) => Console.WriteLine($"ERROR- {text}");

static void PrintData(string label, object? value) => Console.WriteLine($"     {label}: {value}");

internal sealed record TestData(
    int IdMesa,
    int IdEmpleado,
    int IdMetodoPago,
    int IdProductoMenu,
    decimal PrecioVenta);
