/**
 * Definicion del modelo para las postas
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-24 04:42:57 -0500 (mar, 24 jun 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_postas",
    showPrompt: true,
    dataFormat: "json",
    fields: [
        {
            name: "postas_id",
            title: "Posta",
            primaryKey: "true",
            type: 'integer',
            required: true
        },
        {
            name: "postas_descripcion",
            title: "Descripcion",
            required: true,
            validators: [{
                type: "regexp",
                expression: glb_RE_onlyValidText
            }]
        },
        {
            name: "competencias_pruebas_id",
            foreignKey: "mdl_competencias_pruebas.competencias_pruebas_id",
            type: 'integer',
            required: true
        },
        // Virtuales producto de un join
        // Solo para efectos de GUI no se grabaran
        {
            name: "postas_atletas",
            title: 'Atletas'
        }
    ],
    fetchDataURL: glb_dataUrl + 'postasController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'postasController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'postasController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'postasController?op=del&libid=SmartClient',
    operationBindings: [
        {
            operationType: "fetch",
            dataProtocol: "postParams"
        },
        {
            operationType: "add",
            dataProtocol: "postParams"
        },
        {
            operationType: "update",
            dataProtocol: "postParams"
        },
        {
            operationType: "remove",
            dataProtocol: "postParams"
        }
    ],
    /**
     * Caso especial para generar el JSON de un advanced criteria para ser pasada como parte del
     * POST.
     */
    transformRequest: function (dsRequest) {

        console.log(dsRequest);
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