/**
 * Definicion del modelo para los componentes detalle de un producto.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-24 04:42:57 -0500 (mar, 24 jun 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_productodetalle",
    showPrompt: true,
    dataFormat: "json",
    fields: [
        {name: "producto_detalle_id", primaryKey: "true", required: true},
        {name: "insumo_id_origen", title: 'Producto Origen', foreignKey: "mdl_insumo.insumo_id", required: true},
        {name: "insumo_id", title: 'Insumo', foreignKey: "mdl_insumo.insumo_id", required: true},
        {
            name: "unidad_medida_codigo",
            title: 'U.Medida',
            foreignKey: "mdl_unidadmedida.unidad_medida_codigo",
            required: true
        },
        {
            name: "producto_detalle_cantidad", title: 'Cantidad', required: true, type: 'double', format: "0.0000",
            validators: [{type: 'floatRange', min: 0.0001, max: 100000.00}, {type: "floatPrecision", precision: 4}]
        },
        {
            name: "producto_detalle_merma", title: 'Merma', required: true, type: 'double', format: "0.0000",
            validators: [{type: 'floatRange', min: 0.0000, max: 100000.00}, {type: "floatPrecision", precision: 4}]
        },
        // Campos join
        {name: "insumo_descripcion", title: 'Insumo'},
        {name: "unidad_medida_descripcion", title: 'U.Medida'},
        {name: "moneda_simbolo"},
        {
            name: "producto_detalle_costo", title: 'Costo', required: true, type: 'double', format: "0.0000",
            validators: [{type: 'floatRange', min: -3, max: 100000.00}, {type: "floatPrecision", precision: 4}]
        }
    ],
    fetchDataURL: glb_dataUrl + 'productoDetalleController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'productoDetalleController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'productoDetalleController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'productoDetalleController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"},
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "update", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"}
    ]
});