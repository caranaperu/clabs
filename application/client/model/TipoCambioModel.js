/**
 * Definicion del modelo para la conversion de unidades de medida.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-24 04:42:57 -0500 (mar, 24 jun 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_tipocambio",
    showPrompt: true,
    dataFormat: "json",
    fields: [
        {name: "tipo_cambio_id", primaryKey: "true", required: true},
        {name: "moneda_codigo_origen", title:'Moneda Origen',foreignKey: "mdl_moneda.moneda_codigo", required: true},
        {name: "moneda_codigo_destino", title:'Moneda Destino',foreignKey: "mdl_moneda.moneda_codigo", required: true},
        {name: "tipo_cambio_fecha_desde", title:'Desde Fecha',type: 'date', required: true},
        {name: "tipo_cambio_fecha_hasta", title:'Hasta Fecha',type: 'date', required: true},
        {
            name: "tipo_cambio_tasa", title:'Tasa',required: true,type: 'double', format: "0.0000",
            validators: [{type: 'floatRange', min: 0.0001, max: 100000.00}, {type: "floatPrecision", precision: 4}]
        },
        // Campos join
        {name: "_moneda_descripcion_o",title:'Moneda Origen'},
        {name: "_moneda_descripcion_d", title:'Moneda Destino'}
    ],
    fetchDataURL: glb_dataUrl + 'tipoCambioController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'tipoCambioController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'tipoCambioController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'tipoCambioController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"},
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "update", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"}
    ],
    /**
     * Caso especial para generar el JSON de un advanced criteria para ser pasada como parte del
     * POST.
     */
    transformRequest: function(dsRequest) {
        var data = this.Super("transformRequest", arguments);
        // Si esxiste criteria y se define que proviene de un advanced filter y la operacion es fetch,
        // construimos un objeto JSON serializado como texto para que el lado servidor lo interprete correctamente.
        if (data.criteria && data._constructor == "AdvancedCriteria" && data._operationType == 'fetch') {
            var advFilter = {};
            advFilter.operator = data.operator;
            advFilter.criteria = data.criteria;

            // Borramos datos originales que no son necesario ya que  seran trasladados al objeto JSON
            delete data.operator;
            delete data.criteria;
            delete data._constructor;

            // Creamos el objeto json como string para pasarlo al rest
            // finalmente se coloca como data del request para que siga su proceso estandard.
            var jsonCriteria = isc.JSON.encode(advFilter, {prettyPrint: false});
            if (jsonCriteria) {
                //console.log(jsonCriteria);
                data._acriteria = jsonCriteria;
            }
        }
        return data;
    }
});