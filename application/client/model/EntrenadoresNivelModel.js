/**
 * Definicion del modelo para niveles de los entrenadores
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-03-25 11:17:30 -0500 (mar, 25 mar 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_entrenadores_nivel",
    showPrompt: true,
    dataFormat: "json",
    cacheAllData: true, // Son datos pequeños hay que evitar releer
    fields: [
        {name: "entrenadores_nivel_codigo", title: 'codigo', primaryKey: "true", required: true},
        {name: "entrenadores_nivel_descripcion", title: "Descripcion", required: true,
            validators: [{type: "regexp", expression: glb_RE_onlyValidText}]
        },
        {name: "entrenadores_nivel_protected", title: '', type: 'boolean', getFieldValue: function(r, v, f, fn) {
                return mdl_entrenadores_nivel._getBooleanFieldValue(v);
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
    fetchDataURL: glb_dataUrl + 'entrenadoresNivelController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'entrenadoresNivelController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'entrenadoresNivelController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'entrenadoresNivelController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"},
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "update", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"}
    ]
});