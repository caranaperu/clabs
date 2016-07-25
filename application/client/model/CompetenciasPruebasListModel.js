/**
 * Definicion del modelo para todas las pruebas posibles de agregarse
 * a una determinada competencia. Si la combinadas ya existen en la competencia estas no apareceran.
 *
 * Es un modelo de consulta no realiza operaciones CRUD.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-24 02:39:31 -0500 (mar, 24 jun 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_competencias_pruebas_list",
    showPrompt: true,
    dataFormat: "json",
    fields: [
        {name: "pruebas_codigo", title: 'Codigo', primaryKey: "true", required: true},
        {name: "pruebas_descripcion", title: "Descripcion"},
        {name: "pruebas_generica_codigo"},
        //   {name: "pruebas_codigo_origen"},
        {name: "categorias_codigo", title: "Categoria"},
        {name: "pruebas_sexo", title: 'S'},
        {name: "apppruebas_multiple", title: 'Combinada', type: 'boolean', getFieldValue: function(r, v, f, fn) {
                return mdl_competencias_pruebas_list._getBooleanFieldValue(v);
            }},
        {name: "apppruebas_verifica_viento", type: 'boolean', getFieldValue: function(r, v, f, fn) {
                return mdl_competencias_pruebas_list._getBooleanFieldValue(v);
            }},
        {name: "apppruebas_viento_individual", type: 'boolean', getFieldValue: function(r, v, f, fn) {
                return mdl_competencias_pruebas_list._getBooleanFieldValue(v);
            }},
        {name: "competencias_pruebas_origen_id", type: 'integer'},
        {name: "apppruebas_descripcion"},
        {name: "apppruebas_nro_atletas"},
        {name: "unidad_medida_tipo"},
        {name: "unidad_medida_regex_e"},
        {name: "unidad_medida_regex_m"}
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
    fetchDataURL: glb_dataUrl + 'competenciasPruebasController?op=fetch&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams", skipRowCount: true}
    ],
    /**
     * Caso especial para generar el JSON de un advanced criteria para ser pasada como parte del
     * POST.
     */
    transformRequest: function(dsRequest) {
     //   dsRequest.blocking = true;
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