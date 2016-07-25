/**
 * Definicion del modelo para los paises
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-03-25 10:50:10 -0500 (mar, 25 mar 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_appcategorias",
    dataFormat: "json",
    cacheAllData: true, // Son datos pequeños y en este caso fijos hay que evitar releer
    fields: [
        {name: "appcat_codigo", title: 'Codigo', primaryKey: "true", required: true},
        {name: "appcat_peso", title: "Peso Relativo", required: true, type: 'integer'}
    ],
    fetchDataURL: glb_dataUrl + 'appCategoriasController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'appCategoriasController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'appCategoriasController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'appCategoriasController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"},
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "update", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"}
    ]
});