// lib/features/pages/pedidos/models/pedido_model.dart

import '../../productos/models/producto_model.dart';

class ClienteModel {
  final int idCliente;
  final String razonSocial;
  final String numeroDocumento;
  final String telefono;
  final String email;
  final String direccion;

  ClienteModel({
    required this.idCliente,
    required this.razonSocial,
    required this.numeroDocumento,
    required this.telefono,
    required this.email,
    required this.direccion,
  });

  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    return ClienteModel(
      idCliente: int.tryParse(json['id_cliente']?.toString() ?? json['idCliente']?.toString() ?? '0') ?? 0,
      razonSocial: json['razonSocial'] ?? json['razon_social'] ?? '',
      numeroDocumento: json['numeroDocumento'] ?? json['numero_documento'] ?? '',
      telefono: json['telefono'] ?? '',
      email: json['email'] ?? '',
      direccion: json['direccion'] ?? '',
    );
  }
}

class PedidoDetalleModel {
  final int idPedidoDetalle;
  final int idProducto;
  final int cantidadSolicitada;
  final double precioVenta;
  final double descuentoAplicado;
  final double subtotalLinea;
  final ProductoModel? producto;

  PedidoDetalleModel({
    required this.idPedidoDetalle,
    required this.idProducto,
    required this.cantidadSolicitada,
    required this.precioVenta,
    required this.descuentoAplicado,
    required this.subtotalLinea,
    this.producto,
  });

  factory PedidoDetalleModel.fromJson(Map<String, dynamic> json) {
    return PedidoDetalleModel(
      idPedidoDetalle: int.tryParse(json['id_pedido_detalle']?.toString() ?? '0') ?? 0,
      idProducto: int.tryParse(json['id_producto']?.toString() ?? '0') ?? 0,
      cantidadSolicitada: int.tryParse(json['cantidad_solicitada']?.toString() ?? '0') ?? 0,
      precioVenta: double.tryParse(json['precio_venta']?.toString() ?? '0') ?? 0.0,
      descuentoAplicado: double.tryParse(json['descuento_aplicado']?.toString() ?? '0') ?? 0.0,
      subtotalLinea: double.tryParse(json['subtotal_linea']?.toString() ?? '0') ?? 0.0,
      producto: json['producto'] != null ? ProductoModel.fromJson(json['producto']) : null,
    );
  }
}

class PedidoModel {
  final int idPedido;
  final int idCliente;
  final int idVendedor;
  final int idOrigenPedido;
  final int idEstadoPedido;
  final double subtotal;
  final double descuentos;
  final double impuestos;
  final double totalNeto;
  final double totalAbonado;
  final double saldoPendiente;
  final String tipoPago;
  final String estadoPago;
  final String estadoDespacho;
  final String codigoDescuento;
  final String notas;
  final String fechaPedido;
  final ClienteModel? cliente;
  final List<PedidoDetalleModel> detalles;

  PedidoModel({
    required this.idPedido,
    required this.idCliente,
    required this.idVendedor,
    required this.idOrigenPedido,
    required this.idEstadoPedido,
    required this.subtotal,
    required this.descuentos,
    required this.impuestos,
    required this.totalNeto,
    required this.totalAbonado,
    required this.saldoPendiente,
    required this.tipoPago,
    required this.estadoPago,
    required this.estadoDespacho,
    required this.codigoDescuento,
    required this.notas,
    required this.fechaPedido,
    this.cliente,
    required this.detalles,
  });

  factory PedidoModel.fromJson(Map<String, dynamic> json) {
    return PedidoModel(
      idPedido: int.tryParse(json['id_pedido']?.toString() ?? '0') ?? 0,
      idCliente: int.tryParse(json['id_cliente']?.toString() ?? '0') ?? 0,
      idVendedor: int.tryParse(json['id_vendedor']?.toString() ?? '0') ?? 0,
      idOrigenPedido: int.tryParse(json['id_origen_pedido']?.toString() ?? '0') ?? 1,
      idEstadoPedido: int.tryParse(json['id_estado_pedido']?.toString() ?? '1') ?? 1,
      subtotal: double.tryParse(json['subtotal']?.toString() ?? json['total_bruto']?.toString() ?? json['total']?.toString() ?? '0') ?? 0.0,
      descuentos: double.tryParse(json['descuentos']?.toString() ?? json['total_descuentos']?.toString() ?? json['total_descuento']?.toString() ?? json['descuento']?.toString() ?? '0') ?? 0.0,
      impuestos: double.tryParse(json['impuestos']?.toString() ?? json['total_impuestos']?.toString() ?? json['total_impuesto']?.toString() ?? json['iva']?.toString() ?? '0') ?? 0.0,
      totalNeto: double.tryParse(json['total_neto']?.toString() ?? json['totalNeto']?.toString() ?? json['total_pagar']?.toString() ?? '0') ?? 0.0,
      totalAbonado: double.tryParse(json['total_abonado']?.toString() ?? '0') ?? 0.0,
      saldoPendiente: double.tryParse(json['saldo_pendiente']?.toString() ?? '0') ?? 0.0,
      tipoPago: json['tipo_pago'] ?? '',
      estadoPago: json['estado_pago'] ?? 'Pendiente',
      estadoDespacho: json['estado_despacho'] ?? 'Sin estado',
      codigoDescuento: json['codigo_descuento'] ?? '',
      notas: json['notas'] ?? '',
      fechaPedido: json['fecha_pedido'] ?? '',
      cliente: json['cliente'] != null ? ClienteModel.fromJson(json['cliente']) : null,
      detalles: (json['detalles'] as List<dynamic>?)
              ?.map((e) => PedidoDetalleModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
