/**
 * Definicion del modelo para las regiones atleticas
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-27 17:27:42 -0500 (vie, 27 jun 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_regiones",
    dataFormat: "json",
    cacheAllData: true, // Son datos pequeños hay que evitar releer
    fields: [
        {name: "regiones_codigo", title: "Codigo", primaryKey: "true", required: true},
        {name: "regiones_descripcion", title: "Descripcion", required: true,
            validators: [{type: "regexp", expression: glb_RE_onlyValidText}]
        }
    ],
    fetchDataURL: glb_dataUrl + 'regionesController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'regionesController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'regionesController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'regionesController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"},
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "update", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"}
    ]
});