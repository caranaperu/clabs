/**
 * Definicion del modelo para los records, el modelo tiene diversos
 * campos virtuales para soporte de la grilla.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-07-16 00:10:26 -0500 (mié, 16 jul 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_records",
    showPrompt: true,
    dataFormat: "json",
    noNullUpdates: true,
    // sendExtraFields: true,
    //   dropExtraFields: true,
    fields: [
        {name: "records_id", primaryKey: "true", required: true, type: 'integer'},
        {name: "records_tipo_codigo", title: 'Tipo', foreignKey: "mdl_records_tipo.records_tipo_codigo", required: true},
        {name: "atletas_resultados_id", foreignKey: "mdl_atletaspruebas_resultados.atletas_resultados_id", required: true, type: 'integer'},
        {name: "categorias_codigo", title: 'Cat', required: true},
        {name: "records_id_origen"},
        {name: "records_protected", required: true,  getFieldValue: function(r, v, f, fn) {
                return mdl_records._getBooleanFieldValue(v);
            }},
        {name: "versionId"},
        // Virtuales
        {name: "ciudades_altura", title: 'Altura?', type: 'boolean', getFieldValue: function(r, v, f, fn) {
                return mdl_records._getBooleanFieldValue(v);
            }}
    ],
    /**
     * Normalizador de valores booleanos ya que el backend pude devolver de diversas formas
     * segun la base de datos.
     */
    _getBooleanFieldValue: function(value) {
        //  console.log(value);
        if (value !== 't' && value !== 'T' && value !== 'Y' && value !== 'y' && value !== 'TRUE' && value !== 'true' && value !== true) {
            return false;
        } else {
            return true;
        }

    },
    fetchDataURL: glb_dataUrl + 'recordsController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'recordsController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'recordsController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'recordsController?op=del&libid=SmartClient',
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