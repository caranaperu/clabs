/**
 * Definicion del modelo para las genericas de pruebas pero solo para mostrar las descripciones
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-07-15 21:22:37 -0500 (mar, 15 jul 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_apppruebas_description",
    showPrompt: true,
    dataFormat: "json",
    fields: [
        {name: "apppruebas_codigo", title: 'Codigo', primaryKey: "true", required: true},
        {name: "apppruebas_descripcion", title: "Descripcion", required: true}
    ],
    fetchDataURL: glb_dataUrl + 'appPruebasController?op=fetch&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"}
    ]
});