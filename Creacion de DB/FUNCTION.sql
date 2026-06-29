/* 
Se utiliza la función fn_totalConsumo para calcular el total consumido en una cuenta determinada.
Recibe como parámetro el ID del consumo y devuelve la suma de los subtotales de todos los productos
incluidos en los pedidos asociados a ese consumo.
*/
CREATE OR ALTER FUNCTION dbo.fn_totalConsumo (@IdConsumo INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
DECLARE @Total DECIMAL(10,2);
SELECT
@Total = ISNULL(SUM(dp.Subtotal), 0)
FROM dbo.Pedido p
INNER JOIN dbo.DetallePedido dp
ON dp.IdPedido = p.IdPedido
WHERE p.IdConsumo = @IdConsumo;
RETURN ISNULL(@Total, 0);
END;
GO
