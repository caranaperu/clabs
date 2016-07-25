/**
 * Definicion del modelo para los Tipos de competencia
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-03-25 10:42:48 -0500 (mar, 25 mar 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_competencia_tipo",
    dataFormat: "json",
    cacheAllData: true, // Son datos pequeños hay que evitar releer
    fields: [
        {name: "competencia_tipo_codigo", title: "Codigo", primaryKey: "true", required: true},
        {name: "competencia_tipo_descripcion", title: "Descripcion", required: true,
            validators: [{type: "regexp", expression: glb_RE_onlyValidText}]
        }
    ],
    fetchDataURL: glb_dataUrl + 'competenciaTipoController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'competenciaTipoController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'competenciaTipoController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'competenciaTipoController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"},
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "update", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"}
    ]
});