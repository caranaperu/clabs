/**
 * Definicion del modelo para los insumos.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-27 17:27:42 -0500 (vie, 27 jun 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_producto",
    dataFormat: "json",
    showPrompt: true,
    fields: [
        {name: "insumo_id", title: "Id", primaryKey: "true", required: true},
        {name: "insumo_tipo", required: true},
        {name: "insumo_codigo", title: "Codigo", required: true},
        {name: "insumo_descripcion", title: "Descripcion", required: true,
            validators: [{type: "regexp", expression: glb_RE_onlyValidText}]
        },
        {name: "unidad_medida_codigo_costo", title: 'Unidad Costo', foreignKey: "mdl_unidadmedida.unidad_medida_codigo", required: true},
        {
            name: "insumo_merma", title:'Merma',required: true,
            validators: [{type: 'floatRange', min: 0.0001, max: 100000.00}, {type: "floatPrecision", precision: 4}]
        },
        {name: "moneda_codigo_costo", title:'Moneda Costo',foreignKey: "mdl_moneda.moneda_codigo", required: true},
        // campos join
        {name: "unidad_medida_descripcion_costo", title: "Unidad Costo"},
        {name: "moneda_descripcion", title: "Moneda Costo"},
        {name: "moneda_simbolo"},
        {name: "insumo_costo", title:'Costo'}

    ],
    fetchDataURL: glb_dataUrl + 'productoController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'productoController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'productoController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'productoController?op=del&libid=SmartClient',
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
    transformRequest: function (dsRequest) {
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
                data._acriteria = jsonCriteria;
            }
        }
        return data;
    }
});