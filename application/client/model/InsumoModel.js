/**
 * Definicion del modelo para los insumos.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-27 17:27:42 -0500 (vie, 27 jun 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_insumo",
    dataFormat: "json",
    showPrompt: true,
    fields: [
        {name: "insumo_id", title: "Id", primaryKey: "true", required: true},
        {name: "insumo_tipo", required: true},
        {name: "insumo_codigo", title: "Codigo", required: true},
        {name: "insumo_descripcion", title: "Descripcion", required: true,
            validators: [{type: "regexp", expression: glb_RE_onlyValidText}]
        },
        {name: "tcostos_codigo", title: "Tipo Costos", foreignKey: "mdl_tcostos.tcostos_codigo", required: true},
        {name: "tinsumo_codigo", title: "Tipo Insumo", foreignKey: "mdl_tinsumo.tinsumo_codigo", required: true},
        {name: "unidad_medida_codigo_ingreso", title: 'Unidad Ingreso', foreignKey: "mdl_unidadmedida.unidad_medida_codigo", required: true},
        {name: "unidad_medida_codigo_costo", title: 'Unidad Costo', foreignKey: "mdl_unidadmedida.unidad_medida_codigo", required: true},
        {
            name: "insumo_merma", title:'Merma',required: true,
            validators: [{type: 'floatRange', min: 0.0000, max: 100000.00}, {type: "floatPrecision", precision: 4}]
        },
        {
            name: "insumo_costo", title:'Costo',required: true,
            validators: [{type: 'floatRange', min: 0.0000, max: 100000.00}, {type: "floatPrecision", precision: 4}]
        },
        {name: "moneda_codigo_costo", title:'Moneda Costo',foreignKey: "mdl_moneda.moneda_codigo", required: true},
        // campos join
        {name: "tcostos_descripcion", title: "Tipo Costos"},
        {name: "tcostos_indirecto", title: "Indirecto",type: 'boolean', getFieldValue: function(r, v, f, fn) {
            return mdl_insumo._getBooleanFieldValue(v);
        }, required: true},
        {name: "tinsumo_descripcion", title: "Tipo Insumo"},
        {name: "unidad_medida_descripcion_ingreso", title: "Unidad Ingreso"},
        {name: "unidad_medida_descripcion_costo", title: "Unidad Costo"},
        {name: "moneda_descripcion", title: "Moneda Costo"},
        {name: "moneda_simbolo"}

    ],
    /**
     * Normalizador de valores booleanos ya que el backend pude devolver de diversas formas
     * segun la base de datos.
     */
    _getBooleanFieldValue: function(value) {
        if (value !== 't' && value !== 'T' && value !== 'Y' && value !== 'y' && value !== 'TRUE' && value !== 'true' && value !== true) {
            return false;
        } else {
            return true;
        }

    },
    fetchDataURL: glb_dataUrl + 'insumoController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'insumoController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'insumoController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'insumoController?op=del&libid=SmartClient',
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