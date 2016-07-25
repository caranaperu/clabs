/**
 * Definicion del modelo para los paises
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-04-06 19:53:00 -0500 (dom, 06 abr 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_pruebas",
    dataFormat: "json",
    showPrompt: true,
    fields: [
        {name: "pruebas_codigo", title: 'Codigo', primaryKey: "true", required: true},
        {name: "pruebas_descripcion", title: "Descripcion", required: true},
        {name: "pruebas_generica_codigo", title: "Generica de Prueba", required: true, foreignKey: "mdl_apppruebas.apppruebas_codigo"},
        {name: "categorias_codigo", title: "Categoria", required: true, foreignKey: "mdl_categorias.categorias_codigo"},
        {name: "pruebas_sexo", title: "Sexo", valueMap: ["M", "F"], required: true},
        {name: "pruebas_record_hasta", title: "Record Valido Hasta", required: true, foreignKey: "mdl_categorias.categorias_codigo"},
        {name: "pruebas_anotaciones", title: "Anotaciones"},
        // Los sguientes son solo para pantalla , pueden venir o no segun el query

        {name: "apppruebas_verifica_viento", title: 'Usa Viento', type: 'boolean', getFieldValue: function(r, v, f, fn) {
                return mdl_pruebas._getBooleanFieldValue(v);
            }, required: true},
        {name: "apppruebas_multiple", title: 'Combinada', type: 'boolean', getFieldValue: function(r, v, f, fn) {
                return mdl_pruebas._getBooleanFieldValue(v);
            }, required: true},
        {name: "categorias_descripcion", title: "Categoria"},
        {name: "pruebas_clasificacion_descripcion", title: "Clasificacion"},
        {name: "pruebas_protected", title: '', type: 'boolean', getFieldValue: function(r, v, f, fn) {
                return mdl_pruebas._getBooleanFieldValue(v);
            }, required: true}
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
    fetchDataURL: glb_dataUrl + 'pruebasController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'pruebasController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'pruebasController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'pruebasController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams", skipRowCount: true},
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "update", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"}
    ],
    /**
     * Caso especial para generar el JSON de un advanced criteria para ser pasada como parte del
     * POST.
     */
    transformRequest: function(dsRequest) {
        // Se desactiva se usa mejores metodos para controlar el problema de la lectura asincrona.
        //dsRequest.blocking = true;

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