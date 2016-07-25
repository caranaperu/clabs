/**
 * Definicion del modelo para los paises
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-03-25 10:40:54 -0500 (mar, 25 mar 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_pruebas_tipo",
    dataFormat: "json",
    cacheAllData: true, // Son datos pequeños hay que evitar releer
    fields: [
        {name: "pruebas_tipo_codigo", title: 'Codigo', primaryKey: "true", required: true},
        {name: "pruebas_tipo_descripcion", title: "Descripcion", required: true}
    ],
    fetchDataURL: glb_dataUrl + 'pruebasTipoController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'pruebasTipoController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'pruebasTipoController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'pruebasTipoController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"},
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "update", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"}
    ]
});