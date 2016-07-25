/**
 * Definicion del modelo para los paises
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-03-25 11:27:45 -0500 (mar, 25 mar 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_categorias",
    dataFormat: "json",
    cacheAllData: true, // Son datos pequeños hay que evitar releer
    fields: [
        {name: "categorias_codigo", primaryKey: "true", required: true},
        {name: "categorias_descripcion", title: "Descripcion", required: true,
            validators: [{type: "regexp", expression: glb_RE_onlyValidText}]
        },
        {name: "categorias_edad_inicial", type: 'integer', required: true,
            validators: [
                {type: "integerRange", min: 11, max: 50}
            ]},
        {name: "categorias_edad_final", type: 'integer', required: true,
            validators: [
                {type: "integerRange", min: 11, max: 50}

            ]},
        {name: "categorias_valido_desde", type: 'date', required: true},
        {name: "categorias_validacion", type: 'text', foreignKey: "mdl_appcategorias.appcat_codigo", required: true},
        {name: "categorias_protected", title: '', type: 'boolean', getFieldValue: function(r, v, f, fn) {
                return mdl_categorias._getBooleanFieldValue(v);
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
    fetchDataURL: glb_dataUrl + 'categoriasController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'categoriasController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'categoriasController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'categoriasController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"},
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "update", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"}
    ]
});