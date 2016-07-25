/**
 * Definicion del modelo los resultados de un atleta en todas las pruebas validas
 * para record, osea el viento sea el correcto , y no tenga porblemas de anemometro u otros
 * no validos para record.
 *
 * Es unicamente para efectos de seleccion.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-07-15 21:23:28 -0500 (mar, 15 jul 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_atletaspruebas_resultados_for_records",
    showPrompt: true,
    dataFormat: "json",
    fields: [
        {name: "atletas_resultados_id", primaryKey: "true", type: 'integer'},
        {name: "competencias_pruebas_viento", title: "Viento", type: 'double'},
        {name: "ciudades_altura", title: 'Altura?', type: 'boolean', getFieldValue: function(r, v, f, fn) {
                return mdl_atletaspruebas_resultados_for_records._getBooleanFieldValue(v);
            }},
        {name: "competencias_pruebas_fecha", title: "Fecha", type: 'date'},
        {name: "categorias_codigo", title: 'Categoria'},
        {name: "competencias_descripcion", title: 'Competencia'},
        {name: "paises_descripcion", title: 'Pais'},
        {name: "ciudades_descripcion", title: ' Ciudad'},
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
    fetchDataURL: glb_dataUrl + 'atletasPruebasResultadosController?op=fetch&libid=SmartClient&_operationId=fetchForRecords',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"}
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